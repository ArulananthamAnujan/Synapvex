/*
  # 068 — Keep legacy payments compatible with Stripe fulfilment

  Some production databases created `payments` from the earliest LMS schema.
  Later CREATE TABLE IF NOT EXISTS statements did not add the `user_id` and
  `updated_at` columns expected by the Stripe webhook and return-page verifier.
  This could make the audit upsert fail after the transactional entitlement had
  already been granted.
*/

ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);

UPDATE public.payments
SET stripe_session_id = NULL
WHERE btrim(COALESCE(stripe_session_id, '')) = '';

DROP INDEX IF EXISTS public.payments_stripe_session_id_uidx;
ALTER TABLE public.payments DROP CONSTRAINT IF EXISTS payments_stripe_session_id_key;
ALTER TABLE public.payments
  ADD CONSTRAINT payments_stripe_session_id_key UNIQUE (stripe_session_id);
