import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@14";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

async function safeUpsert(supabase: ReturnType<typeof createClient>, table: string, data: Record<string, unknown>, opts: { onConflict: string }) {
  const { error } = await supabase.from(table).upsert(data, opts);
  if (error) throw new Error(`${table} upsert failed: ${error.message}`);
}

const totalWithProcessingCost = (base: number) => base + Math.max(0, Math.ceil((base + 30) / 0.983) - base);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
    if (!stripeKey) {
      return new Response(JSON.stringify({ error: "Stripe not configured" }), {
        status: 503,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { session_id } = await req.json();
    if (!session_id) {
      return new Response(JSON.stringify({ error: "session_id required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const stripe = new Stripe(stripeKey, { apiVersion: "2024-11-20.acacia" });
    const session = await stripe.checkout.sessions.retrieve(session_id);

    if (session.payment_status !== "paid") {
      return new Response(JSON.stringify({ enrolled: false, reason: "Payment not completed" }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const metadata = session.metadata || {};
    const amountCents = session.amount_total || 0;
    const baseAmountCents = Number(metadata.base_amount_cents || amountCents);
    if (metadata.base_amount_cents && amountCents !== totalWithProcessingCost(baseAmountCents)) {
      throw new Error("Checkout total does not match the signed base amount and processing cost");
    }
    const stripeSessionId = session.id;
    const stripePaymentId = typeof session.payment_intent === "string" ? session.payment_intent : "";

    const purchaseType = metadata.type || "course";
    const ownerId = purchaseType.startsWith("teacher_")
      ? metadata.teacher_id
      : metadata.student_id;

    if (ownerId !== user.id) {
      return new Response(JSON.stringify({ error: "Session does not belong to this user" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (purchaseType === "teacher_subscription") {
      const { plan_id } = metadata;
      if (!plan_id) {
        return new Response(JSON.stringify({ error: "Missing plan_id in session metadata" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const interval = metadata.billing_interval === "yearly" ? "yearly" : metadata.billing_interval === "quarterly" ? "quarterly" : "monthly";
      const { data: fulfillment, error: fulfillmentError } = await supabase.rpc(
        "fulfill_teacher_subscription",
        {
          p_teacher_id: user.id,
          p_plan_id: plan_id,
          p_billing_interval: interval,
          p_stripe_session_id: stripeSessionId,
          p_stripe_payment_id: stripePaymentId,
          p_amount_cents: baseAmountCents,
        },
      );
      if (fulfillmentError) {
        throw new Error(`Teacher subscription fulfilment failed: ${fulfillmentError.message}`);
      }
      const result = fulfillment?.[0] as { applied?: boolean; tokens_added?: number } | undefined;

      await safeUpsert(supabase, "payments", {
        user_id: user.id,
        amount: amountCents / 100,
        currency: "AUD",
        status: "completed",
        stripe_session_id: stripeSessionId,
        stripe_payment_id: stripePaymentId || null,
      }, { onConflict: "stripe_session_id" });

      return new Response(JSON.stringify({
        enrolled: true,
        type: purchaseType,
        activated: true,
        tokens_added: result?.tokens_added ?? 0,
        already_fulfilled: result?.applied === false,
      }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (purchaseType === "teacher_ai_plan" || purchaseType === "teacher_topup_custom") {
      const { data: fulfillment, error: fulfillmentError } = await supabase.rpc(
        "fulfill_teacher_topup",
        {
          p_teacher_id: user.id,
          p_purchase_type: purchaseType,
          p_plan_id: metadata.plan_id || null,
          p_stripe_session_id: stripeSessionId,
          p_stripe_payment_id: stripePaymentId,
          p_amount_cents: baseAmountCents,
        },
      );
      if (fulfillmentError) {
        throw new Error(`Teacher top-up fulfilment failed: ${fulfillmentError.message}`);
      }
      const result = fulfillment?.[0] as { applied?: boolean; tokens_added?: number } | undefined;

      await safeUpsert(supabase, "payments", {
        user_id: user.id,
        amount: amountCents / 100,
        currency: "AUD",
        status: "completed",
        stripe_session_id: stripeSessionId,
        stripe_payment_id: stripePaymentId || null,
      }, { onConflict: "stripe_session_id" });

      return new Response(JSON.stringify({
        enrolled: true,
        type: purchaseType,
        tokens_added: result?.tokens_added ?? 0,
        already_fulfilled: result?.applied === false,
      }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (purchaseType === "ai_plan") {
      const { plan_id } = metadata;
      if (!plan_id) {
        return new Response(JSON.stringify({ error: "Missing plan_id in session metadata" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: fulfillment, error: fulfillmentError } = await supabase.rpc(
        "fulfill_student_ai_plan",
        {
          p_student_id: user.id,
          p_plan_id: plan_id,
          p_stripe_session_id: stripeSessionId,
          p_stripe_payment_id: stripePaymentId,
          p_amount_cents: baseAmountCents,
        },
      );
      if (fulfillmentError) {
        throw new Error(`Student AI fulfilment failed: ${fulfillmentError.message}`);
      }
      const result = fulfillment?.[0] as { applied?: boolean; tokens_added?: number } | undefined;
      const tokens = result?.tokens_added ?? 0;

      await safeUpsert(supabase, "payments", {
        user_id: user.id,
        amount: amountCents / 100,
        currency: "AUD",
        status: "completed",
        stripe_session_id: stripeSessionId,
        stripe_payment_id: stripePaymentId || null,
      }, { onConflict: "stripe_session_id" });

      console.log(`AI plan ${plan_id}: ${tokens} tokens for user ${user.id}`);
      return new Response(JSON.stringify({
        enrolled: true,
        type: "ai_plan",
        tokens_added: tokens,
        already_fulfilled: result?.applied === false,
      }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Course purchase
    const { course_id, teacher_id } = metadata;
    if (!course_id) {
      return new Response(JSON.stringify({ error: "Missing course_id in session metadata" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Enroll in course_enrollments (idempotent)
    try {
      const { error: enrollError } = await supabase.from("course_enrollments").upsert({
        user_id: user.id,
        course_id,
        enrollment_type: "paid",
        payment_status: "completed",
        payment_id: stripePaymentId,
        amount_paid: baseAmountCents / 100,
        currency: "AUD",
        enrolled_at: new Date().toISOString(),
      }, { onConflict: "user_id,course_id" });
      if (enrollError) console.error("course_enrollments upsert error:", enrollError);
    } catch (e) {
      console.error("Enrollment exception:", e);
    }

    // Legacy enrollments table
    await safeUpsert(supabase, "enrollments", {
      student_id: user.id,
      course_id,
      progress_percent: 0,
      enrolled_at: new Date().toISOString(),
    }, { onConflict: "student_id,course_id" });

    // Teacher earning
    if (teacher_id && amountCents > 0) {
      try {
        await supabase.rpc("record_teacher_earning", {
          p_teacher_id: teacher_id,
          p_course_id: course_id,
          p_student_id: user.id,
          p_gross_cents: baseAmountCents,
          p_stripe_payment_intent: stripePaymentId,
        });
      } catch (e) {
        console.error("Teacher earning error:", e);
      }
    }

    // Payment record
    await safeUpsert(supabase, "payments", {
      user_id: user.id,
      course_id,
      amount: amountCents / 100,
      currency: "AUD",
      status: "completed",
      stripe_session_id: stripeSessionId,
      stripe_payment_id: stripePaymentId || null,
    }, { onConflict: "stripe_session_id" });

    console.log(`Enrolled user ${user.id} in course ${course_id} via session ${stripeSessionId}`);
    return new Response(JSON.stringify({ enrolled: true, type: "course", course_id }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err) {
    const message = err instanceof Error ? err.message : "Internal error";
    console.error("Verify session error:", message);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
