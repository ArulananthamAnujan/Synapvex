-- Create teacher_ai_credits table and apply free credits migration

CREATE TABLE IF NOT EXISTS teacher_ai_credits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token_balance integer NOT NULL DEFAULT 0,
  total_purchased integer NOT NULL DEFAULT 0,
  total_used integer NOT NULL DEFAULT 0,
  free_credits_granted integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

ALTER TABLE teacher_ai_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_own_teacher_ai_credits" ON teacher_ai_credits
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

-- Also add teacher_ai_plans (token top-up packs) if not present
CREATE TABLE IF NOT EXISTS teacher_ai_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  token_amount integer NOT NULL,
  price_cents integer NOT NULL,
  is_popular boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE teacher_ai_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_teacher_ai_plans" ON teacher_ai_plans
  FOR SELECT TO anon, authenticated USING (is_active = true);

-- Seed token packs
INSERT INTO teacher_ai_plans (name, description, token_amount, price_cents, is_popular, sort_order)
VALUES
  ('Starter Pack',  '~25–40 AI generations. Good for a single course.',   200, 1500, false, 1),
  ('Creator Pack',  '~75–100 AI generations. Best value for active creators.', 600, 3900, true,  2),
  ('Pro Pack',      '~200+ AI generations. For heavy builders.',           1500, 7900, false, 3)
ON CONFLICT DO NOTHING;

-- Grant free credits trigger
CREATE OR REPLACE FUNCTION grant_teacher_starter_credits()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.role = 'teacher' THEN
    INSERT INTO teacher_ai_credits (user_id, token_balance, free_credits_granted)
    VALUES (NEW.id, 200, 200)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_grant_teacher_starter_credits') THEN
    CREATE TRIGGER trg_grant_teacher_starter_credits
      AFTER INSERT OR UPDATE OF role ON profiles
      FOR EACH ROW
      WHEN (NEW.role = 'teacher')
      EXECUTE FUNCTION grant_teacher_starter_credits();
  END IF;
END $$;

-- Backfill existing teachers
INSERT INTO teacher_ai_credits (user_id, token_balance, free_credits_granted)
SELECT id, 200, 200 FROM profiles WHERE role = 'teacher'
ON CONFLICT (user_id) DO UPDATE
  SET free_credits_granted = 200,
      token_balance = teacher_ai_credits.token_balance + 200
  WHERE teacher_ai_credits.free_credits_granted = 0
    AND teacher_ai_credits.total_purchased = 0;

-- Atomic deduction function (service-role only)
CREATE OR REPLACE FUNCTION deduct_teacher_tokens(
  p_user_id uuid,
  p_tokens  integer
)
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  remaining integer;
BEGIN
  UPDATE teacher_ai_credits
  SET token_balance = GREATEST(0, token_balance - p_tokens),
      total_used    = total_used + p_tokens,
      updated_at    = now()
  WHERE user_id = p_user_id
  RETURNING token_balance INTO remaining;

  RETURN COALESCE(remaining, 0);
END;
$$;

REVOKE ALL ON FUNCTION deduct_teacher_tokens(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION deduct_teacher_tokens(uuid, integer) FROM authenticated;
REVOKE ALL ON FUNCTION deduct_teacher_tokens(uuid, integer) FROM anon;
GRANT EXECUTE ON FUNCTION deduct_teacher_tokens(uuid, integer) TO service_role;
