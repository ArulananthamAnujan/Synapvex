
-- Teacher subscription plans table
CREATE TABLE IF NOT EXISTS teacher_subscription_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  price_monthly_cents integer NOT NULL,
  max_courses integer NOT NULL DEFAULT 5,
  max_students integer NOT NULL DEFAULT 100,
  ai_tokens_monthly integer NOT NULL DEFAULT 0,
  features jsonb NOT NULL DEFAULT '[]',
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE teacher_subscription_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anyone_can_view_plans" ON teacher_subscription_plans
  FOR SELECT TO anon, authenticated USING (is_active = true);

-- Teacher subscriptions table
CREATE TABLE IF NOT EXISTS teacher_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  plan_id uuid NOT NULL REFERENCES teacher_subscription_plans(id),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'expired', 'cancelled')),
  stripe_session_id text UNIQUE,
  stripe_payment_id text,
  amount_paid_cents integer,
  current_period_start timestamptz,
  current_period_end timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE teacher_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "teacher_select_own_subscription" ON teacher_subscriptions
  FOR SELECT TO authenticated USING (auth.uid() = teacher_id);

CREATE POLICY "teacher_insert_own_subscription" ON teacher_subscriptions
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "admin_manage_subscriptions" ON teacher_subscriptions
  FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'co_admin'))
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'co_admin'))
  );

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_teacher_subscriptions_teacher ON teacher_subscriptions(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_subscriptions_status ON teacher_subscriptions(status);

-- Seed plans
INSERT INTO teacher_subscription_plans (name, slug, price_monthly_cents, max_courses, max_students, ai_tokens_monthly, features, sort_order) VALUES
(
  'Starter',
  'starter',
  2900,
  3,
  50,
  500,
  '["Create up to 3 courses", "Up to 50 enrolled students", "500 AI tokens/month", "Quizzes & assignments", "Student progress tracking", "Shareable course links", "Email support"]',
  1
),
(
  'Professional',
  'professional',
  4900,
  15,
  500,
  2000,
  '["Create up to 15 courses", "Up to 500 enrolled students", "2,000 AI tokens/month", "Quizzes, exams & assignments", "AI course builder", "Live session booking", "Certificate issuance", "Earnings & payouts dashboard", "Priority email support"]',
  2
),
(
  'Business',
  'business',
  9900,
  -1,
  -1,
  10000,
  '["Unlimited courses", "Unlimited students", "10,000 AI tokens/month", "Full AI curriculum builder", "Organisation management", "Team of teachers", "Custom branding options", "Advanced analytics", "Dedicated account manager", "Priority support"]',
  3
)
ON CONFLICT (slug) DO NOTHING;
