/* Three-month promotional teacher plans and matching AI credit-pack offers. */

ALTER TABLE teacher_subscription_plans
  ADD COLUMN IF NOT EXISTS price_quarterly_cents integer,
  ADD COLUMN IF NOT EXISTS price_list_quarterly_cents integer,
  ADD COLUMN IF NOT EXISTS ai_tokens_quarterly integer;

UPDATE teacher_subscription_plans SET
  price_list_quarterly_cents = CASE slug
    WHEN 'starter' THEN 7499 WHEN 'professional' THEN 10000 WHEN 'business' THEN 20000
  END,
  price_quarterly_cents = CASE slug
    WHEN 'starter' THEN 4999 WHEN 'professional' THEN 8900 WHEN 'business' THEN 17500
  END,
  ai_tokens_quarterly = CASE slug
    WHEN 'starter' THEN 500 WHEN 'professional' THEN 900 WHEN 'business' THEN 1800
  END
WHERE slug IN ('starter', 'professional', 'business');

-- Keep the migration safe if an administrator has added another active plan.
UPDATE teacher_subscription_plans SET
  price_quarterly_cents = COALESCE(price_quarterly_cents, price_monthly_cents * 3),
  price_list_quarterly_cents = COALESCE(price_list_quarterly_cents, price_monthly_cents * 3),
  ai_tokens_quarterly = COALESCE(ai_tokens_quarterly, ai_tokens_monthly * 3);

ALTER TABLE teacher_subscription_plans
  ALTER COLUMN price_quarterly_cents SET NOT NULL,
  ALTER COLUMN price_list_quarterly_cents SET NOT NULL,
  ALTER COLUMN ai_tokens_quarterly SET NOT NULL;

UPDATE teacher_subscription_plans
SET features = replace(
  replace(
    replace(features::text,
      '500 AI tokens/month', '500 AI credits for 3 months'),
      '2,000 AI tokens/month', '900 AI credits for 3 months'),
      '10,000 AI tokens/month', '1,800 AI credits for 3 months')::jsonb
WHERE slug IN ('starter', 'professional', 'business');

ALTER TABLE teacher_ai_plans
  ADD COLUMN IF NOT EXISTS list_price_cents integer;

UPDATE teacher_ai_plans SET
  list_price_cents = CASE name
    WHEN 'Creator' THEN 999 WHEN 'Pro' THEN 3999 WHEN 'Studio' THEN 12499
  END,
  price_cents = CASE name
    WHEN 'Creator' THEN 699 WHEN 'Pro' THEN 2999 WHEN 'Studio' THEN 9999
  END
WHERE name IN ('Creator', 'Pro', 'Studio');

ALTER TABLE teacher_subscriptions
  DROP CONSTRAINT IF EXISTS teacher_subscriptions_billing_interval_check;
ALTER TABLE teacher_subscriptions
  ADD CONSTRAINT teacher_subscriptions_billing_interval_check
  CHECK (billing_interval IN ('monthly', 'quarterly', 'yearly'));

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
  v_quarterly_tokens integer;
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

  v_interval := CASE
    WHEN p_billing_interval = 'yearly' THEN 'yearly'
    WHEN p_billing_interval = 'monthly' THEN 'monthly'
    ELSE 'quarterly'
  END;

  SELECT
    ai_tokens_monthly,
    ai_tokens_quarterly,
    CASE
      WHEN v_interval = 'yearly' THEN COALESCE(price_yearly_cents, price_monthly_cents * 10)
      WHEN v_interval = 'monthly' THEN price_monthly_cents
      ELSE price_quarterly_cents
    END
  INTO v_monthly_tokens, v_quarterly_tokens, v_expected_amount
  FROM teacher_subscription_plans
  WHERE id = p_plan_id;

  IF NOT FOUND THEN RAISE EXCEPTION 'Teacher subscription plan not found'; END IF;
  IF p_amount_cents IS DISTINCT FROM v_expected_amount THEN
    RAISE EXCEPTION 'Teacher subscription payment amount does not match plan price';
  END IF;

  v_tokens := CASE
    WHEN v_interval = 'yearly' THEN GREATEST(0, v_monthly_tokens) * 12
    WHEN v_interval = 'monthly' THEN GREATEST(0, v_monthly_tokens)
    ELSE GREATEST(0, v_quarterly_tokens)
  END;
  v_period_end := v_now + CASE
    WHEN v_interval = 'yearly' THEN interval '1 year'
    WHEN v_interval = 'monthly' THEN interval '1 month'
    ELSE interval '3 months'
  END;

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
