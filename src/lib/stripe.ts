import { supabase } from './supabase';

export interface StripeVerificationResult {
  enrolled: boolean;
  type?: string;
  activated?: boolean;
  tokens_added?: number;
  already_fulfilled?: boolean;
  error?: string;
  reason?: string;
}

/**
 * Verify a paid Checkout Session with Stripe and fulfil it server-side.
 * The database fulfilment RPC is idempotent, so this is safe to call after
 * the webhook or again after a network interruption.
 */
export async function verifyStripeCheckoutSession(sessionId: string): Promise<StripeVerificationResult> {
  const { data: { session } } = await supabase.auth.getSession();
  const token = session?.access_token;
  if (!token) throw new Error('Please sign in again to verify your payment.');

  const response = await fetch(
    `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/stripe-verify-session`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ session_id: sessionId }),
    },
  );
  const data = await response.json() as StripeVerificationResult;

  if (!response.ok || !data.enrolled) {
    throw new Error(data.error || data.reason || 'Could not verify the payment. Please contact support.');
  }

  return data;
}

