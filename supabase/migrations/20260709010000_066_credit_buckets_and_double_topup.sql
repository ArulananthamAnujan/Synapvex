/*
  # 066 — Two credit buckets + double-rate top-up spending

  Implements the freemium spend model:
  - token_balance  = free credits + monthly plan credits (spent at 1×)
  - topup_balance  = purchased top-up credits (spent at 2× once plan/free
    credits run out)

  ## Changes
  1. teacher_ai_credits.topup_balance — purchased emergency credits.
  2. add_teacher_topup() — credits the topup bucket (used by the Stripe
     webhook for teacher_ai_plan purchases). total_purchased is bumped so
     the app knows the teacher is no longer a pure free user.
  3. deduct_teacher_tokens() rewritten: spend plan/free credits first at
     face cost; when those can't cover the action, spend top-up credits at
     DOUBLE the cost. Returns the remaining spendable balance.
*/

ALTER TABLE teacher_ai_credits
  ADD COLUMN IF NOT EXISTS topup_balance integer NOT NULL DEFAULT 0;

-- Credit the top-up bucket (service-role only; called by the webhook)
CREATE OR REPLACE FUNCTION add_teacher_topup(
  p_user_id uuid,
  p_tokens  integer
)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO teacher_ai_credits (user_id, topup_balance, total_purchased, last_purchase_at)
  VALUES (p_user_id, p_tokens, p_tokens, now())
  ON CONFLICT (user_id) DO UPDATE
    SET topup_balance   = teacher_ai_credits.topup_balance + p_tokens,
        total_purchased = teacher_ai_credits.total_purchased + p_tokens,
        last_purchase_at = now(),
        updated_at = now();
END;
$$;

REVOKE ALL ON FUNCTION add_teacher_topup(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION add_teacher_topup(uuid, integer) FROM authenticated;
REVOKE ALL ON FUNCTION add_teacher_topup(uuid, integer) FROM anon;
GRANT EXECUTE ON FUNCTION add_teacher_topup(uuid, integer) TO service_role;

-- Spend: plan/free credits first (1×), then top-up credits (2×)
CREATE OR REPLACE FUNCTION deduct_teacher_tokens(
  p_user_id uuid,
  p_tokens  integer
)
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bal integer;
  top integer;
BEGIN
  SELECT token_balance, topup_balance INTO bal, top
  FROM teacher_ai_credits
  WHERE user_id = p_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  IF bal >= p_tokens THEN
    -- Covered by plan/free credits at face cost
    UPDATE teacher_ai_credits
    SET token_balance = token_balance - p_tokens,
        total_used    = total_used + p_tokens,
        updated_at    = now()
    WHERE user_id = p_user_id;
  ELSE
    -- Plan/free credits can't cover it: charge top-up at DOUBLE the cost
    UPDATE teacher_ai_credits
    SET topup_balance = GREATEST(0, topup_balance - (p_tokens * 2)),
        total_used    = total_used + p_tokens,
        updated_at    = now()
    WHERE user_id = p_user_id;
  END IF;

  SELECT token_balance + topup_balance INTO bal
  FROM teacher_ai_credits WHERE user_id = p_user_id;
  RETURN bal;
END;
$$;

REVOKE ALL ON FUNCTION deduct_teacher_tokens(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION deduct_teacher_tokens(uuid, integer) FROM authenticated;
REVOKE ALL ON FUNCTION deduct_teacher_tokens(uuid, integer) FROM anon;
GRANT EXECUTE ON FUNCTION deduct_teacher_tokens(uuid, integer) TO service_role;
