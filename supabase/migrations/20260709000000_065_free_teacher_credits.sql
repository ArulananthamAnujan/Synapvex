/*
  # 065 — Free exploration credits for teachers (freemium onboarding)

  Every new teacher gets a free allotment of AI credits to explore the
  platform before subscribing. When their balance falls to half (or runs
  out) the app prompts them to pick a monthly/annual plan.

  ## Changes
  1. teacher_ai_credits.free_credits_granted — the initial free grant, so
     the app can compute "half used" (balance <= granted/2).
  2. grant_teacher_starter_credits() + trigger — seeds FREE credits the
     first time a profile becomes a teacher (ON CONFLICT DO NOTHING so
     credits are never re-granted once used).
  3. Backfill: grant free credits to existing teachers who have none.
  4. deduct_teacher_tokens() — atomic, service-role-only decrement used by
     the ai-generate function so solo-teacher credits actually get spent.
  5. SECURITY FIX: drop the teacher INSERT/UPDATE RLS policies on
     teacher_ai_credits. They let a teacher set their own token_balance to
     any value directly through the API — bypassing payment entirely.
     Balances are now mutated only server-side (webhook + SECURITY DEFINER
     functions). Teachers keep read-only access.
*/

-- Free grant size (also referenced in the app for the "half used" prompt).
-- 200 credits ≈ 25–40 AI generations (outline 5, lesson 8, quiz 6, …).

ALTER TABLE teacher_ai_credits
  ADD COLUMN IF NOT EXISTS free_credits_granted integer NOT NULL DEFAULT 0;

-- ── 5. Lock down direct writes (self-crediting hole) ──────────────────────────
DROP POLICY IF EXISTS "Teachers can insert own AI credits" ON teacher_ai_credits;
DROP POLICY IF EXISTS "Teachers can update own AI credits" ON teacher_ai_credits;

-- ── 2. Grant free credits when a profile becomes a teacher ────────────────────
CREATE OR REPLACE FUNCTION grant_teacher_starter_credits()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.role = 'teacher' THEN
    INSERT INTO teacher_ai_credits (user_id, token_balance, free_credits_granted)
    VALUES (NEW.id, 200, 200)
    ON CONFLICT (user_id) DO NOTHING;  -- never re-grant once they have a row
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

-- ── 3. Backfill existing teachers who never received free credits ─────────────
INSERT INTO teacher_ai_credits (user_id, token_balance, free_credits_granted)
SELECT id, 200, 200 FROM profiles WHERE role = 'teacher'
ON CONFLICT (user_id) DO UPDATE
  SET free_credits_granted = 200,
      token_balance = teacher_ai_credits.token_balance + 200
  WHERE teacher_ai_credits.free_credits_granted = 0
    AND teacher_ai_credits.total_purchased = 0;

-- ── 4. Atomic, service-role-only credit deduction ────────────────────────────
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
