-- ── organizations ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS organizations (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name               text NOT NULL,
  slug               text UNIQUE NOT NULL,
  logo_url           text,
  website            text,
  description        text,
  token_balance      integer NOT NULL DEFAULT 0 CHECK (token_balance >= 0),
  plan_tier          text NOT NULL DEFAULT 'starter' CHECK (plan_tier IN ('starter','growth','professional','enterprise')),
  feature_flags      jsonb DEFAULT '{}',
  is_active          boolean NOT NULL DEFAULT true,
  stripe_customer_id text,
  created_by         uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at         timestamptz DEFAULT now(),
  updated_at         timestamptz DEFAULT now()
);
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- ── org_members (must exist before org policies that reference it) ─────────────
CREATE TABLE IF NOT EXISTS org_members (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id      uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role        text NOT NULL DEFAULT 'teacher' CHECK (role IN ('owner', 'teacher')),
  invited_by  uuid REFERENCES profiles(id) ON DELETE SET NULL,
  joined_at   timestamptz DEFAULT now(),
  UNIQUE (org_id, user_id)
);
ALTER TABLE org_members ENABLE ROW LEVEL SECURITY;

-- Org policies now that both tables exist
CREATE POLICY "Org members can view own org" ON organizations FOR SELECT TO authenticated
  USING (id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Org admins can update own org" ON organizations FOR UPDATE TO authenticated
  USING (get_my_role() IN ('admin','co_admin') OR id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner'))
  WITH CHECK (get_my_role() IN ('admin','co_admin') OR id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner'));
CREATE POLICY "Admins can insert orgs" ON organizations FOR INSERT TO authenticated
  WITH CHECK (get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Admins can delete orgs" ON organizations FOR DELETE TO authenticated
  USING (get_my_role() IN ('admin','co_admin'));

CREATE POLICY "Org members can view own org members" ON org_members FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Org owners can insert members" ON org_members FOR INSERT TO authenticated
  WITH CHECK (get_my_role() IN ('admin','co_admin') OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner'));
CREATE POLICY "Org owners can delete members" ON org_members FOR DELETE TO authenticated
  USING (get_my_role() IN ('admin','co_admin') OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner'));

-- Add org_id to courses
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='org_id') THEN
    ALTER TABLE courses ADD COLUMN org_id uuid REFERENCES organizations(id) ON DELETE SET NULL;
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_courses_org_id ON courses(org_id);

-- ── token_packages ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_packages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text NOT NULL,
  description  text,
  token_amount integer NOT NULL CHECK (token_amount > 0),
  price_cents  integer NOT NULL CHECK (price_cents > 0),
  is_active    boolean DEFAULT true,
  plan_tier    text,
  created_at   timestamptz DEFAULT now()
);
ALTER TABLE token_packages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active token packages" ON token_packages FOR SELECT USING (is_active = true);
CREATE POLICY "Admins manage token packages" ON token_packages FOR ALL TO authenticated USING (get_my_role() IN ('admin','co_admin'));

INSERT INTO token_packages (name, description, token_amount, price_cents, plan_tier) VALUES
  ('Starter Pack',      '500 AI tokens for course generation',  500,   4999,  'starter'),
  ('Growth Pack',       '2,000 AI tokens',                      2000,  14999, 'growth'),
  ('Professional Pack', '5,000 AI tokens',                      5000,  29999, 'professional'),
  ('Enterprise Pack',   '15,000 AI tokens',                     15000, 74999, 'enterprise')
ON CONFLICT DO NOTHING;

-- ── token_purchases ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_purchases (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id             uuid REFERENCES organizations(id) ON DELETE CASCADE,
  user_id            uuid REFERENCES profiles(id) ON DELETE SET NULL,
  package_id         uuid REFERENCES token_packages(id) ON DELETE SET NULL,
  tokens_purchased   integer NOT NULL,
  amount_paid_cents  integer NOT NULL,
  stripe_session_id  text,
  status             text DEFAULT 'completed',
  created_at         timestamptz DEFAULT now()
);
ALTER TABLE token_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Org admins view own purchases" ON token_purchases FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));

-- ── token_usage_log ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_usage_log (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id       uuid REFERENCES organizations(id) ON DELETE SET NULL,
  user_id      uuid REFERENCES profiles(id) ON DELETE SET NULL,
  tokens_used  integer NOT NULL,
  task         text,
  created_at   timestamptz DEFAULT now()
);
ALTER TABLE token_usage_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Org admins view own token usage" ON token_usage_log FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Authenticated insert token usage" ON token_usage_log FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- ── course_enrollments ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS course_enrollments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id        uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  user_id          uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrolled_at      timestamptz DEFAULT now(),
  completed_at     timestamptz,
  progress         numeric DEFAULT 0,
  payment_status   text DEFAULT 'not_required',
  stripe_session_id text,
  amount_paid      numeric DEFAULT 0,
  UNIQUE (course_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_user   ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course ON course_enrollments(course_id);
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students view own enrollments" ON course_enrollments FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Students enroll themselves" ON course_enrollments FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "Update enrollments" ON course_enrollments FOR UPDATE TO authenticated
  USING (get_my_role() IN ('admin','co_admin') OR user_id = auth.uid());
CREATE POLICY "Delete enrollments" ON course_enrollments FOR DELETE TO authenticated
  USING (get_my_role() IN ('admin','co_admin') OR user_id = auth.uid());

-- ── ai_usage_logs ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ai_usage_logs (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              uuid REFERENCES profiles(id) ON DELETE SET NULL,
  org_id               uuid REFERENCES organizations(id) ON DELETE SET NULL,
  ai_task              text,
  input_tokens         integer DEFAULT 0,
  output_tokens        integer DEFAULT 0,
  cost_estimate_usd    numeric DEFAULT 0,
  success              boolean DEFAULT true,
  error_message        text,
  created_at           timestamptz DEFAULT now()
);
ALTER TABLE ai_usage_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own AI logs" ON ai_usage_logs FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Insert AI logs" ON ai_usage_logs FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

-- ── flashcards ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS flashcards (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id   uuid REFERENCES lessons(id) ON DELETE CASCADE,
  course_id   uuid REFERENCES courses(id) ON DELETE CASCADE,
  front       text NOT NULL,
  back        text NOT NULL,
  created_at  timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_flashcards_user ON flashcards(user_id);
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own flashcards" ON flashcards FOR ALL TO authenticated USING (user_id = auth.uid());

-- ── lesson_activities ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lesson_activities (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id    uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id    uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  type         text NOT NULL CHECK (type IN ('practice','reflection','discussion','project','research')),
  title        text NOT NULL DEFAULT '',
  instructions text DEFAULT '',
  order_index  integer DEFAULT 0,
  created_at   timestamptz DEFAULT now()
);
ALTER TABLE lesson_activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled view activities" ON lesson_activities FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM course_enrollments ce WHERE ce.course_id = lesson_activities.course_id AND ce.user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Teachers manage activities" ON lesson_activities FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM courses c WHERE c.id = lesson_activities.course_id AND c.teacher_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));

-- ── lesson_documents ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lesson_documents (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id    uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id    uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  type         text NOT NULL CHECK (type IN ('notes','slides','handout')),
  title        text DEFAULT '',
  content      text DEFAULT '',
  file_url     text,
  ai_generated boolean DEFAULT false,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);
ALTER TABLE lesson_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled view docs" ON lesson_documents FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM course_enrollments ce WHERE ce.course_id = lesson_documents.course_id AND ce.user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Teachers manage docs" ON lesson_documents FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM courses c WHERE c.id = lesson_documents.course_id AND c.teacher_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));
