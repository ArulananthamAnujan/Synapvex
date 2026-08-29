import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@14";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const ALLOWED_ORIGINS = [
  Deno.env.get("SITE_URL"),
  "https://synapvex.com.au",
  "https://www.synapvex.com.au",
  "https://maximusacademy.com.au",
  "https://www.maximusacademy.com.au",
].filter(Boolean) as string[];

function getSiteUrl(req: Request): string {
  // Prefer the current trusted app origin. This keeps Checkout returns on the
  // right product even when a legacy SITE_URL secret still points at Maximus.
  const origin = req.headers.get("origin");
  if (origin && ALLOWED_ORIGINS.includes(origin)) return origin;

  const envUrl = Deno.env.get("SITE_URL");
  if (envUrl && ALLOWED_ORIGINS.includes(envUrl)) return envUrl;

  // Safe fallback — never use an untrusted header for redirect URLs.
  return "https://synapvex.com.au";
}

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

    const stripe = new Stripe(stripeKey, { apiVersion: "2024-11-20.acacia" });

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

    const body = await req.json();
    const { type, course_id, plan_id, billing_interval, amount_cents } = body;
    const siteUrl = getSiteUrl(req);

    // --- Teacher Subscription ---
    if (type === "teacher_subscription") {
      if (!plan_id) {
        return new Response(JSON.stringify({ error: "plan_id required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: plan } = await supabase
        .from("teacher_subscription_plans")
        .select("id, name, slug, price_monthly_cents, price_yearly_cents")
        .eq("id", plan_id)
        .maybeSingle();

      if (!plan) {
        return new Response(JSON.stringify({ error: "Plan not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const interval = billing_interval === "yearly" ? "yearly" : "monthly";
      const unitAmount = interval === "yearly"
        ? (plan.price_yearly_cents ?? plan.price_monthly_cents * 10)
        : plan.price_monthly_cents;
      const periodLabel = interval === "yearly" ? "12 Months" : "1 Month";

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer_email: user.email,
        line_items: [
          {
            price_data: {
              currency: "aud",
              product_data: {
                name: `Synapvex Learn — ${plan.name} Teacher Plan (${periodLabel})`,
                description: interval === "yearly"
                  ? "Annual teacher plan for Synapvex Learn, paid upfront"
                  : "Monthly teacher plan for Synapvex Learn",
              },
              unit_amount: unitAmount,
            },
            quantity: 1,
          },
        ],
        metadata: {
          teacher_id: user.id,
          plan_id: plan.id,
          plan_slug: plan.slug,
          billing_interval: interval,
          type: "teacher_subscription",
        },
        success_url: `${siteUrl}/teacher/billing?subscription=success&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${siteUrl}/teach/register?plan=${plan.slug}&cancelled=1`,
      });

      return new Response(JSON.stringify({ url: session.url }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (type === "course") {
      if (!course_id) {
        return new Response(JSON.stringify({ error: "course_id required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: course } = await supabase
        .from("courses")
        .select("id, title, price, price_amount, thumbnail_url, teacher_id, is_free")
        .eq("id", course_id)
        .maybeSingle();

      if (!course) {
        return new Response(JSON.stringify({ error: "Course not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const price = Number(course.price_amount ?? course.price ?? 0);
      if (course.is_free || price === 0) {
        return new Response(JSON.stringify({ error: "This course is free" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      // Only include images if the URL is publicly accessible (not a data URL or blob)
      const images: string[] = [];
      if (
        course.thumbnail_url &&
        (course.thumbnail_url.startsWith("https://") || course.thumbnail_url.startsWith("http://"))
      ) {
        images.push(course.thumbnail_url);
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer_email: user.email,
        line_items: [
          {
            price_data: {
              currency: "aud",
              product_data: {
                name: course.title,
                ...(images.length > 0 ? { images } : {}),
              },
              unit_amount: Math.round(price * 100),
            },
            quantity: 1,
          },
        ],
        metadata: {
          student_id: user.id,
          course_id: course.id,
          teacher_id: course.teacher_id || "",
          type: "course",
        },
        success_url: `${siteUrl}/student/courses?payment=success&course_id=${course_id}&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${siteUrl}/courses/${course_id}?payment=cancelled`,
      });

      return new Response(JSON.stringify({ url: session.url }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (type === "ai_plan") {
      if (!plan_id) {
        return new Response(JSON.stringify({ error: "plan_id required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: plan } = await supabase
        .from("student_ai_plans")
        .select("id, name, price_cents, token_amount")
        .eq("id", plan_id)
        .maybeSingle();

      if (!plan) {
        return new Response(JSON.stringify({ error: "Plan not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer_email: user.email,
        line_items: [
          {
            price_data: {
              currency: "aud",
              product_data: {
                name: `${plan.name} — ${plan.token_amount} AI Tokens`,
              },
              unit_amount: plan.price_cents,
            },
            quantity: 1,
          },
        ],
        metadata: {
          student_id: user.id,
          plan_id: plan.id,
          token_amount: String(plan.token_amount),
          type: "ai_plan",
        },
        success_url: `${siteUrl}/student/ai-plans?payment=success&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${siteUrl}/student/ai-plans?payment=cancelled`,
      });

      return new Response(JSON.stringify({ url: session.url }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (type === "teacher_ai_plan") {
      if (!plan_id) {
        return new Response(JSON.stringify({ error: "plan_id required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: plan } = await supabase
        .from("teacher_ai_plans")
        .select("id, name, price_cents, token_amount")
        .eq("id", plan_id)
        .maybeSingle();

      if (!plan) {
        return new Response(JSON.stringify({ error: "Plan not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer_email: user.email,
        line_items: [
          {
            price_data: {
              currency: "aud",
              product_data: {
                name: `Synapvex Learn — ${plan.name} (${plan.token_amount} AI Credits)`,
                description: "AI credit top-up for your teacher account. Credits never expire.",
              },
              unit_amount: plan.price_cents,
            },
            quantity: 1,
          },
        ],
        metadata: {
          teacher_id: user.id,
          plan_id: plan.id,
          token_amount: String(plan.token_amount),
          type: "teacher_ai_plan",
        },
        success_url: `${siteUrl}/teacher/billing?tokens=success&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${siteUrl}/teacher/billing?tokens=cancelled`,
      });

      return new Response(JSON.stringify({ url: session.url }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (type === "teacher_topup_custom") {
      const cents = Math.round(Number(amount_cents) || 0);
      // The paid amount is authoritative. Never let the browser choose how
      // many credits a custom payment grants.
      const credits = Math.round((cents * 12) / 100);
      if (cents < 500) {
        return new Response(JSON.stringify({ error: "Minimum top-up is $5." }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer_email: user.email,
        line_items: [
          {
            price_data: {
              currency: "aud",
              product_data: {
                name: `Synapvex Learn — AI Credit Top-up (${credits.toLocaleString()} credits)`,
                description: "Custom AI credit top-up. Credits never expire.",
              },
              unit_amount: cents,
            },
            quantity: 1,
          },
        ],
        metadata: {
          teacher_id: user.id,
          token_amount: String(credits),
          type: "teacher_topup_custom",
        },
        success_url: `${siteUrl}/teacher/billing?tokens=success&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${siteUrl}/teacher/billing?tokens=cancelled`,
      });

      return new Response(JSON.stringify({ url: session.url }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ error: "Invalid type. Use 'course' or 'ai_plan'" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err) {
    const message = err instanceof Error ? err.message : "Internal error";
    console.error("Checkout error:", message, err);
    return new Response(
      JSON.stringify({ error: message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
