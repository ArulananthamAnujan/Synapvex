import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const allowedOrigins = new Set([
  "https://synapvex.com.au",
  "https://www.synapvex.com.au",
  "http://localhost:5173",
]);

function corsHeaders(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": allowedOrigins.has(origin) ? origin : "https://synapvex.com.au",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
    "Vary": "Origin",
  };
}

function json(req: Request, body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...corsHeaders(req), "Content-Type": "application/json" } });
}

async function sha256(value: string) {
  const bytes = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return Array.from(new Uint8Array(bytes), b => b.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders(req) });
  if (req.method !== "POST") return json(req, { error: "Method not allowed" }, 405);

  const origin = req.headers.get("origin");
  if (origin && !allowedOrigins.has(origin)) return json(req, { error: "Origin not allowed" }, 403);

  try {
    const body = await req.json();
    const name = String(body.name ?? "").trim();
    const email = String(body.email ?? "").trim().toLowerCase();
    const subject = String(body.subject ?? "").trim();
    const message = String(body.message ?? "").trim();
    const website = String(body.website ?? "").trim();

    // Honeypot: respond successfully without storing bot submissions.
    if (website) return json(req, { success: true });
    if (name.length < 2 || name.length > 200 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 200 || subject.length < 1 || subject.length > 200 || message.length < 10 || message.length > 5000) {
      return json(req, { error: "Please check the submitted fields." }, 400);
    }

    const forwarded = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() || req.headers.get("cf-connecting-ip") || "unknown";
    const fingerprint = await sha256(`${forwarded}|${email}|${Deno.env.get("CONTACT_RATE_SALT") || Deno.env.get("SUPABASE_URL")}`);
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: accepted, error: limitError } = await supabase.rpc("register_contact_attempt", { p_fingerprint: fingerprint });
    if (limitError) throw limitError;
    if (!accepted) return json(req, { error: "Please wait before sending another message." }, 429);

    const { error } = await supabase.from("contact_messages").insert({ name, email, subject, message, status: "open" });
    if (error) throw error;
    return json(req, { success: true }, 201);
  } catch (error) {
    console.error("contact-submit failed", error instanceof Error ? error.message : error);
    return json(req, { error: "Unable to send your message right now." }, 500);
  }
});
