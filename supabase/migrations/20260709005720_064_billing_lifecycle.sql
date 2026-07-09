-- 1. Annual pricing on plans
ALTER TABLE teacher_subscription_plans
  ADD COLUMN IF NOT EXISTS price_yearly_cents integer;

UPDATE teacher_subscription_plans
SET price_yearly_cents = price_monthly_cents * 10
WHERE price_yearly_cents IS NULL;

-- 2. Subscription lifecycle columns
ALTER TABLE teacher_subscriptions
  ADD COLUMN IF NOT EXISTS billing_interval text NOT NULL DEFAULT 'monthly'
    CHECK (billing_interval IN ('monthly', 'yearly')),
  ADD COLUMN IF NOT EXISTS cancel_at_period_end boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS cancelled_at timestamptz;

-- 3. Teacher-facing cancel/resume, limited to the renewal flag
CREATE OR REPLACE FUNCTION set_subscription_renewal(
  p_subscription_id uuid,
  p_cancel boolean
)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE teacher_subscriptions
  SET cancel_at_period_end = p_cancel,
      cancelled_at = CASE WHEN p_cancel THEN now() ELSE NULL END,
      updated_at = now()
  WHERE id = p_subscription_id
    AND teacher_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Subscription not found or not owned by caller';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION set_subscription_renewal(uuid, boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION set_subscription_renewal(uuid, boolean) TO authenticated;

-- 4. Lock down add_teacher_tokens / add_student_tokens if they exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'add_teacher_tokens') THEN
    EXECUTE 'REVOKE ALL ON FUNCTION add_teacher_tokens(uuid, integer) FROM PUBLIC';
    EXECUTE 'REVOKE ALL ON FUNCTION add_teacher_tokens(uuid, integer) FROM authenticated';
    EXECUTE 'REVOKE ALL ON FUNCTION add_teacher_tokens(uuid, integer) FROM anon';
    EXECUTE 'GRANT EXECUTE ON FUNCTION add_teacher_tokens(uuid, integer) TO service_role';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'add_student_tokens') THEN
    EXECUTE 'REVOKE ALL ON FUNCTION add_student_tokens(uuid, integer) FROM PUBLIC';
    EXECUTE 'REVOKE ALL ON FUNCTION add_student_tokens(uuid, integer) FROM authenticated';
    EXECUTE 'REVOKE ALL ON FUNCTION add_student_tokens(uuid, integer) FROM anon';
    EXECUTE 'GRANT EXECUTE ON FUNCTION add_student_tokens(uuid, integer) TO service_role';
  END IF;
END $$;
