import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@14";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey, stripe-signature",
};

async function safeUpsert(supabase: ReturnType<typeof createClient>, table: string, data: Record<string, unknown>, opts: { onConflict: string }) {
  const { error } = await supabase.from(table).upsert(data, opts);
  if (error) throw new Error(`${table} upsert failed: ${error.message}`);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
    const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");

    if (!stripeKey) {
      return new Response(JSON.stringify({ error: "Stripe not configured" }), {
        status: 503,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!webhookSecret) {
      console.error("STRIPE_WEBHOOK_SECRET not configured");
      return new Response(JSON.stringify({ error: "Webhook secret not configured" }), {
        status: 503,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const stripe = new Stripe(stripeKey, { apiVersion: "2024-11-20.acacia" });
    const body = await req.text();
    const sig = req.headers.get("stripe-signature");

    if (!sig) {
      return new Response(JSON.stringify({ error: "Missing stripe-signature header" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    let event: Stripe.Event;
    try {
      event = await stripe.webhooks.constructEventAsync(body, sig, webhookSecret);
    } catch (err) {
      console.error("Webhook signature verification failed:", err);
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (event.type !== "checkout.session.completed") {
      return new Response(JSON.stringify({ received: true }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const session = event.data.object as Stripe.Checkout.Session;
    const metadata = session.metadata || {};
    const amountCents = session.amount_total || 0;
    const stripeSessionId = session.id;
    const stripePaymentId = typeof session.payment_intent === "string" ? session.payment_intent : "";

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const purchaseType = metadata.type || "course";

    // --- Teacher Subscription Purchase ---
    if (purchaseType === "teacher_subscription") {
      const { teacher_id, plan_id } = metadata;
      if (!teacher_id || !plan_id) {
        console.error("Missing metadata for teacher subscription");
        return new Response(JSON.stringify({ received: true, warning: "Missing metadata" }), {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const interval = metadata.billing_interval === "yearly" ? "yearly" : "monthly";
      const { data: fulfillment, error: fulfillmentError } = await supabase.rpc(
        "fulfill_teacher_subscription",
        {
          p_teacher_id: teacher_id,
          p_plan_id: plan_id,
          p_billing_interval: interval,
          p_stripe_session_id: stripeSessionId,
          p_stripe_payment_id: stripePaymentId,
          p_amount_cents: amountCents,
        },
      );
      if (fulfillmentError) {
        throw new Error(`Teacher subscription fulfilment failed: ${fulfillmentError.message}`);
      }
      const result = fulfillment?.[0] as { applied?: boolean; tokens_added?: number } | undefined;

      await safeUpsert(supabase, "payments", {
        user_id: teacher_id,
        amount: amountCents / 100,
        currency: "AUD",
        status: "completed",
        stripe_session_id: stripeSessionId,
        stripe_payment_id: stripePaymentId || null,
      }, { onConflict: "stripe_session_id" });

      console.log(
        `Teacher subscription ${result?.applied ? "activated" : "already fulfilled"} for ${teacher_id} on plan ${plan_id}`,
      );
      return new Response(
        JSON.stringify({
          received: true,
          type: "teacher_subscription",
          activated: true,
          already_fulfilled: result?.applied === false,
          tokens_added: result?.tokens_added ?? 0,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // --- AI Plan / custom credit top-up ---
    if (purchaseType === "teacher_ai_plan" || purchaseType === "teacher_topup_custom") {
      const { teacher_id, plan_id } = metadata;
      if (!teacher_id || (purchaseType === "teacher_ai_plan" && !plan_id)) {
        console.error("Missing metadata for teacher AI top-up");
        return new Response(JSON.stringify({ received: true, warning: "Missing metadata" }), {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: fulfillment, error: fulfillmentError } = await supabase.rpc(
        "fulfill_teacher_topup",
        {
          p_teacher_id: teacher_id,
          p_purchase_type: purchaseType,
          p_plan_id: plan_id || null,
          p_stripe_session_id: stripeSessionId,
          p_stripe_payment_id: stripePaymentId,
          p_amount_cents: amountCents,
        },
      );
      if (fulfillmentError) {
        throw new Error(`Teacher top-up fulfilment failed: ${fulfillmentError.message}`);
      }
      const result = fulfillment?.[0] as { applied?: boolean; tokens_added?: number } | undefined;
      const tokens = result?.tokens_added ?? 0;

      await safeUpsert(supabase, "payments", {
        user_id: teacher_id,
        amount: amountCents / 100,
        currency: "AUD",
        status: "completed",
        stripe_session_id: stripeSessionId,
        stripe_payment_id: stripePaymentId || null,
      }, { onConflict: "stripe_session_id" });

      console.log(
        `${result?.applied ? "Added" : "Previously added"} ${tokens} AI credits to teacher ${teacher_id} (plan ${plan_id})`,
      );
      return new Response(
        JSON.stringify({
          received: true,
          type: purchaseType,
          tokens_added: tokens,
          already_fulfilled: result?.applied === false,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (purchaseType === "ai_plan") {
      const { student_id, plan_id } = metadata;
      if (!student_id || !plan_id) {
        console.error("Missing metadata for AI plan purchase");
        return new Response(JSON.stringify({ received: true, warning: "Missing metadata" }), {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: fulfillment, error: fulfillmentError } = await supabase.rpc(
        "fulfill_student_ai_plan",
        {
          p_student_id: student_id,
          p_plan_id: plan_id,
          p_stripe_session_id: stripeSessionId,
          p_stripe_payment_id: stripePaymentId,
          p_amount_cents: amountCents,
        },
      );
      if (fulfillmentError) {
        throw new Error(`Student AI fulfilment failed: ${fulfillmentError.message}`);
      }
      const result = fulfillment?.[0] as { applied?: boolean; tokens_added?: number } | undefined;
      const tokens = result?.tokens_added ?? 0;

      await safeUpsert(supabase, "payments", {
        user_id: student_id,
        amount: amountCents / 100,
        currency: "AUD",
        status: "completed",
        stripe_session_id: stripeSessionId,
        stripe_payment_id: stripePaymentId || null,
      }, { onConflict: "stripe_session_id" });

      console.log(
        `${result?.applied ? "Added" : "Previously added"} ${tokens} AI tokens to student ${student_id} (plan ${plan_id})`,
      );
      return new Response(
        JSON.stringify({
          received: true,
          type: "ai_plan",
          tokens_added: tokens,
          already_fulfilled: result?.applied === false,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // --- Course Purchase ---
    const { student_id, course_id, teacher_id } = metadata;
    if (!student_id || !course_id) {
      console.error("Missing student_id or course_id in Stripe metadata");
      return new Response(JSON.stringify({ received: true, warning: "Missing metadata" }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Enroll in course_enrollments
    try {
      const { error } = await supabase.from("course_enrollments").upsert({
        user_id: student_id,
        course_id,
        enrollment_type: "paid",
        payment_status: "completed",
        payment_id: stripePaymentId,
        amount_paid: amountCents / 100,
        currency: "AUD",
        enrolled_at: new Date().toISOString(),
      }, { onConflict: "user_id,course_id" });
      if (error) console.error("Enrollment error:", error);
    } catch (e) {
      console.error("Enrollment exception:", e);
    }

    // 2. Legacy enrollments table
    await safeUpsert(supabase, "enrollments", {
      student_id,
      course_id,
      progress_percent: 0,
      enrolled_at: new Date().toISOString(),
    }, { onConflict: "student_id,course_id" });

    // 3. Teacher earning
    if (teacher_id && amountCents > 0) {
      try {
        await supabase.rpc("record_teacher_earning", {
          p_teacher_id: teacher_id,
          p_course_id: course_id,
          p_student_id: student_id,
          p_gross_cents: amountCents,
          p_stripe_payment_intent: stripePaymentId,
        });
      } catch (e) {
        console.error("Teacher earning error:", e);
      }
    }

    // 4. Payment record
    await safeUpsert(supabase, "payments", {
      user_id: student_id,
      course_id,
      amount: amountCents / 100,
      currency: "AUD",
      status: "completed",
      stripe_session_id: stripeSessionId,
      stripe_payment_id: stripePaymentId || null,
    }, { onConflict: "stripe_session_id" });

    console.log(`Enrolled student ${student_id} in course ${course_id}`);
    return new Response(
      JSON.stringify({ received: true, type: "course", enrolled: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("Webhook error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
