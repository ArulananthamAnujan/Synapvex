/*
  # 067 — Transactional, idempotent Stripe credit fulfilment

  A successful Checkout Session can be delivered by both the Stripe webhook
  and the signed-in return-page verifier.  Previously each path incremented
  balances independently, so a missing webhook left a customer uncredited
  while a retry could credit the same payment twice.

  This migration records each Stripe Checkout Session exactly once and keeps
  the idempotency claim and its balance/subscription mutation in one database
  transaction.  Prices and credit quantities are derived from server-side plan
  rows (or from the paid amount for custom top-ups), never from browser input.
*/

CREATE TABLE IF NOT EXISTS stripe_fulfillments (
  stripe_session_id text PRIMARY KEY,
  purchase_type text NOT NULL,
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  stripe_payment_id text,
  amount_cents integer NOT NULL CHECK (amount_cents >= 0),
  tokens_added integer NOT NULL DEFAULT 0 CHECK (tokens_added >= 0),
  fulfilled_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE stripe_fulfillments ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE stripe_fulfillments FROM PUBLIC, anon, authenticated;
GRANT ALL ON TABLE stripe_fulfillments TO service_role;

-- PostgREST upserts need a real unique constraint to target.  The earlier
-- partial unique index protected non-null values but could not be inferred by
-- `ON CONFLICT (stripe_session_id)`, causing payment-record upserts to fail.
UPDATE payments SET stripe_session_id = NULL WHERE btrim(COALESCE(stripe_session_id, '')) = '';
DROP INDEX IF EXISTS payments_stripe_session_id_uidx;
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_stripe_session_id_key;
ALTER TABLE payments ADD CONSTRAINT payments_stripe_session_id_key UNIQUE (stripe_session_id);

CREATE OR REPLACE FUNCTION fulfill_teacher_subscription(
  p_teacher_id uuid,
  p_plan_id uuid,
  p_billing_interval text,
  p_stripe_session_id text,
  p_stripe_payment_id text,
  p_amount_cents integer
)
RETURNS TABLE(applied boolean, tokens_added integer)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_monthly_tokens integer;
  v_expected_amount integer;
  v_tokens integer;
  v_interval text;
  v_now timestamptz := now();
  v_period_end timestamptz;
  v_claimed text;
  v_existing stripe_fulfillments%ROWTYPE;
BEGIN
  IF p_teacher_id IS NULL OR p_plan_id IS NULL OR COALESCE(p_stripe_session_id, '') = '' THEN
    RAISE EXCEPTION 'Missing teacher subscription fulfilment data';
  END IF;

  v_interval := CASE WHEN p_billing_interval = 'yearly' THEN 'yearly' ELSE 'monthly' END;

  SELECT
    ai_tokens_monthly,
    CASE
      WHEN v_interval = 'yearly' THEN COALESCE(price_yearly_cents, price_monthly_cents * 10)
      ELSE price_monthly_cents
    END
  INTO v_monthly_tokens, v_expected_amount
  FROM teacher_subscription_plans
  WHERE id = p_plan_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Teacher subscription plan not found';
  END IF;
  IF p_amount_cents IS DISTINCT FROM v_expected_amount THEN
    RAISE EXCEPTION 'Teacher subscription payment amount does not match plan price';
  END IF;

  -- Annual plans are paid upfront.  Until monthly refill scheduling exists,
  -- grant all 12 monthly allocations so the advertised annual entitlement is
  -- not reduced to a single month's credits.
  v_tokens := GREATEST(0, v_monthly_tokens) * CASE WHEN v_interval = 'yearly' THEN 12 ELSE 1 END;
  v_period_end := v_now + CASE WHEN v_interval = 'yearly' THEN interval '1 year' ELSE interval '1 month' END;

  INSERT INTO stripe_fulfillments (
    stripe_session_id, purchase_type, user_id, stripe_payment_id, amount_cents, tokens_added
  ) VALUES (
    p_stripe_session_id, 'teacher_subscription', p_teacher_id,
    NULLIF(p_stripe_payment_id, ''), p_amount_cents, v_tokens
  )
  ON CONFLICT (stripe_session_id) DO NOTHING
  RETURNING stripe_session_id INTO v_claimed;

  IF v_claimed IS NULL THEN
    SELECT * INTO v_existing FROM stripe_fulfillments WHERE stripe_session_id = p_stripe_session_id;
    IF v_existing.purchase_type <> 'teacher_subscription' OR v_existing.user_id <> p_teacher_id THEN
      RAISE EXCEPTION 'Stripe session was already fulfilled for a different purchase';
    END IF;
    RETURN QUERY SELECT false, v_existing.tokens_added;
    RETURN;
  END IF;

  INSERT INTO teacher_subscriptions (
    teacher_id, plan_id, status, billing_interval, cancel_at_period_end,
    cancelled_at, stripe_session_id, stripe_payment_id, amount_paid_cents,
    current_period_start, current_period_end, updated_at
  ) VALUES (
    p_teacher_id, p_plan_id, 'active', v_interval, false,
    NULL, p_stripe_session_id, NULLIF(p_stripe_payment_id, ''), p_amount_cents,
    v_now, v_period_end, v_now
  )
  ON CONFLICT (stripe_session_id) DO UPDATE SET
    plan_id = EXCLUDED.plan_id,
    status = 'active',
    billing_interval = EXCLUDED.billing_interval,
    cancel_at_period_end = false,
    cancelled_at = NULL,
    stripe_payment_id = EXCLUDED.stripe_payment_id,
    amount_paid_cents = EXCLUDED.amount_paid_cents,
    current_period_start = EXCLUDED.current_period_start,
    current_period_end = EXCLUDED.current_period_end,
    updated_at = EXCLUDED.updated_at;

  INSERT INTO teacher_ai_credits (user_id, token_balance, total_purchased, last_purchase_at)
  VALUES (p_teacher_id, v_tokens, v_tokens, v_now)
  ON CONFLICT (user_id) DO UPDATE SET
    token_balance = teacher_ai_credits.token_balance + v_tokens,
    total_purchased = teacher_ai_credits.total_purchased + v_tokens,
    last_purchase_at = v_now,
    updated_at = v_now;

  UPDATE profiles SET role = 'teacher' WHERE id = p_teacher_id;

  RETURN QUERY SELECT true, v_tokens;
END;
$$;

CREATE OR REPLACE FUNCTION fulfill_teacher_topup(
  p_teacher_id uuid,
  p_purchase_type text,
  p_plan_id uuid,
  p_stripe_session_id text,
  p_stripe_payment_id text,
  p_amount_cents integer
)
RETURNS TABLE(applied boolean, tokens_added integer)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_expected_amount integer;
  v_tokens integer;
  v_now timestamptz := now();
  v_claimed text;
  v_existing stripe_fulfillments%ROWTYPE;
BEGIN
  IF p_teacher_id IS NULL OR COALESCE(p_stripe_session_id, '') = '' THEN
    RAISE EXCEPTION 'Missing teacher top-up fulfilment data';
  END IF;
  IF p_purchase_type NOT IN ('teacher_ai_plan', 'teacher_topup_custom') THEN
    RAISE EXCEPTION 'Unsupported teacher top-up type';
  END IF;

  IF p_purchase_type = 'teacher_ai_plan' THEN
    SELECT price_cents, token_amount
    INTO v_expected_amount, v_tokens
    FROM teacher_ai_plans
    WHERE id = p_plan_id AND is_active = true;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Teacher AI plan not found';
    END IF;
    IF p_amount_cents IS DISTINCT FROM v_expected_amount THEN
      RAISE EXCEPTION 'Teacher AI payment amount does not match plan price';
    END IF;
  ELSE
    IF p_amount_cents < 500 THEN
      RAISE EXCEPTION 'Minimum custom top-up is 500 cents';
    END IF;
    -- Published rate: AUD $1 = 12 credits.
    v_tokens := round((p_amount_cents::numeric * 12) / 100)::integer;
  END IF;

  INSERT INTO stripe_fulfillments (
    stripe_session_id, purchase_type, user_id, stripe_payment_id, amount_cents, tokens_added
  ) VALUES (
    p_stripe_session_id, p_purchase_type, p_teacher_id,
    NULLIF(p_stripe_payment_id, ''), p_amount_cents, v_tokens
  )
  ON CONFLICT (stripe_session_id) DO NOTHING
  RETURNING stripe_session_id INTO v_claimed;

  IF v_claimed IS NULL THEN
    SELECT * INTO v_existing FROM stripe_fulfillments WHERE stripe_session_id = p_stripe_session_id;
    IF v_existing.purchase_type <> p_purchase_type OR v_existing.user_id <> p_teacher_id THEN
      RAISE EXCEPTION 'Stripe session was already fulfilled for a different purchase';
    END IF;
    RETURN QUERY SELECT false, v_existing.tokens_added;
    RETURN;
  END IF;

  INSERT INTO teacher_ai_credits (user_id, topup_balance, total_purchased, last_purchase_at)
  VALUES (p_teacher_id, v_tokens, v_tokens, v_now)
  ON CONFLICT (user_id) DO UPDATE SET
    topup_balance = teacher_ai_credits.topup_balance + v_tokens,
    total_purchased = teacher_ai_credits.total_purchased + v_tokens,
    last_purchase_at = v_now,
    updated_at = v_now;

  RETURN QUERY SELECT true, v_tokens;
END;
$$;

CREATE OR REPLACE FUNCTION fulfill_student_ai_plan(
  p_student_id uuid,
  p_plan_id uuid,
  p_stripe_session_id text,
  p_stripe_payment_id text,
  p_amount_cents integer
)
RETURNS TABLE(applied boolean, tokens_added integer)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_expected_amount integer;
  v_tokens integer;
  v_now timestamptz := now();
  v_claimed text;
  v_existing stripe_fulfillments%ROWTYPE;
BEGIN
  IF p_student_id IS NULL OR p_plan_id IS NULL OR COALESCE(p_stripe_session_id, '') = '' THEN
    RAISE EXCEPTION 'Missing student AI fulfilment data';
  END IF;

  SELECT price_cents, token_amount
  INTO v_expected_amount, v_tokens
  FROM student_ai_plans
  WHERE id = p_plan_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Student AI plan not found';
  END IF;
  IF p_amount_cents IS DISTINCT FROM v_expected_amount THEN
    RAISE EXCEPTION 'Student AI payment amount does not match plan price';
  END IF;

  INSERT INTO stripe_fulfillments (
    stripe_session_id, purchase_type, user_id, stripe_payment_id, amount_cents, tokens_added
  ) VALUES (
    p_stripe_session_id, 'ai_plan', p_student_id,
    NULLIF(p_stripe_payment_id, ''), p_amount_cents, v_tokens
  )
  ON CONFLICT (stripe_session_id) DO NOTHING
  RETURNING stripe_session_id INTO v_claimed;

  IF v_claimed IS NULL THEN
    SELECT * INTO v_existing FROM stripe_fulfillments WHERE stripe_session_id = p_stripe_session_id;
    IF v_existing.purchase_type <> 'ai_plan' OR v_existing.user_id <> p_student_id THEN
      RAISE EXCEPTION 'Stripe session was already fulfilled for a different purchase';
    END IF;
    RETURN QUERY SELECT false, v_existing.tokens_added;
    RETURN;
  END IF;

  INSERT INTO student_ai_credits (user_id, token_balance, total_purchased, last_purchase_at)
  VALUES (p_student_id, v_tokens, v_tokens, v_now)
  ON CONFLICT (user_id) DO UPDATE SET
    token_balance = student_ai_credits.token_balance + v_tokens,
    total_purchased = student_ai_credits.total_purchased + v_tokens,
    last_purchase_at = v_now,
    updated_at = v_now;

  RETURN QUERY SELECT true, v_tokens;
END;
$$;

REVOKE ALL ON FUNCTION fulfill_teacher_subscription(uuid, uuid, text, text, text, integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION fulfill_teacher_topup(uuid, text, uuid, text, text, integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION fulfill_student_ai_plan(uuid, uuid, text, text, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION fulfill_teacher_subscription(uuid, uuid, text, text, text, integer) TO service_role;
GRANT EXECUTE ON FUNCTION fulfill_teacher_topup(uuid, text, uuid, text, text, integer) TO service_role;
GRANT EXECUTE ON FUNCTION fulfill_student_ai_plan(uuid, uuid, text, text, integer) TO service_role;
