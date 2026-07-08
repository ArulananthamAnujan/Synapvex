-- ── exams, exam_questions, exam_submissions ───────────────────────────────────
CREATE TABLE IF NOT EXISTS exams (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id       uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title           text NOT NULL DEFAULT '',
  description     text DEFAULT '',
  instructions    text DEFAULT '',
  duration_minutes integer DEFAULT 60,
  pass_percentage integer DEFAULT 50,
  is_published    boolean DEFAULT false,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);
ALTER TABLE exams ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled view exams" ON exams FOR SELECT TO authenticated
  USING (is_published = true AND EXISTS (SELECT 1 FROM course_enrollments ce WHERE ce.course_id = exams.course_id AND ce.user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Teachers manage exams" ON exams FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM courses c WHERE c.id = exams.course_id AND c.teacher_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));

CREATE TABLE IF NOT EXISTS exam_questions (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id      uuid NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  question     text NOT NULL DEFAULT '',
  type         text DEFAULT 'essay' CHECK (type IN ('essay','short_answer','mcq')),
  options      jsonb DEFAULT '[]',
  max_points   integer DEFAULT 10,
  order_index  integer DEFAULT 0,
  created_at   timestamptz DEFAULT now()
);
ALTER TABLE exam_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled view exam questions" ON exam_questions FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM exams e JOIN course_enrollments ce ON ce.course_id = e.course_id WHERE e.id = exam_questions.exam_id AND ce.user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Teachers manage exam questions" ON exam_questions FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM exams e JOIN courses c ON c.id = e.course_id WHERE e.id = exam_questions.exam_id AND c.teacher_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));

CREATE TABLE IF NOT EXISTS exam_submissions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id          uuid NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  student_id       uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  answers          jsonb DEFAULT '{}',
  ai_scores        jsonb DEFAULT '{}',
  teacher_scores   jsonb DEFAULT '{}',
  final_scores     jsonb DEFAULT '{}',
  total_score      numeric,
  max_score        numeric,
  percentage       numeric,
  status           text DEFAULT 'submitted' CHECK (status IN ('submitted','ai_graded','teacher_reviewed','finalised')),
  submitted_at     timestamptz DEFAULT now(),
  graded_at        timestamptz,
  feedback         text
);
ALTER TABLE exam_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students view own submissions" ON exam_submissions FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Students insert submissions" ON exam_submissions FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid());
CREATE POLICY "Teachers update submissions" ON exam_submissions FOR UPDATE TO authenticated
  USING (get_my_role() IN ('admin','co_admin','teacher'));

-- ── face_to_face_requests ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS face_to_face_requests (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  teacher_id   uuid REFERENCES profiles(id) ON DELETE SET NULL,
  course_id    uuid REFERENCES courses(id) ON DELETE SET NULL,
  subject      text DEFAULT '',
  message      text DEFAULT '',
  preferred_date date,
  preferred_time text,
  status       text DEFAULT 'pending' CHECK (status IN ('pending','approved','declined','completed')),
  notes        text,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);
ALTER TABLE face_to_face_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students view own f2f requests" ON face_to_face_requests FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR teacher_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Students insert f2f requests" ON face_to_face_requests FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid());
CREATE POLICY "Teachers update f2f requests" ON face_to_face_requests FOR UPDATE TO authenticated
  USING (teacher_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));

-- ── teacher_earnings, payouts ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS teacher_earnings (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id    uuid REFERENCES courses(id) ON DELETE SET NULL,
  enrollment_id uuid,
  amount       numeric NOT NULL DEFAULT 0,
  currency     text DEFAULT 'AUD',
  status       text DEFAULT 'pending' CHECK (status IN ('pending','available','paid')),
  created_at   timestamptz DEFAULT now()
);
ALTER TABLE teacher_earnings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Teachers view own earnings" ON teacher_earnings FOR SELECT TO authenticated
  USING (teacher_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "System insert earnings" ON teacher_earnings FOR INSERT TO authenticated
  WITH CHECK (get_my_role() IN ('admin','co_admin') OR teacher_id = auth.uid());

CREATE TABLE IF NOT EXISTS payouts (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount       numeric NOT NULL DEFAULT 0,
  currency     text DEFAULT 'AUD',
  status       text DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed')),
  stripe_payout_id text,
  notes        text,
  created_at   timestamptz DEFAULT now(),
  processed_at timestamptz
);
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Teachers view own payouts" ON payouts FOR SELECT TO authenticated
  USING (teacher_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Admins manage payouts" ON payouts FOR ALL TO authenticated
  USING (get_my_role() IN ('admin','co_admin'));

-- ── quiz_extra_attempts ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quiz_extra_attempts (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id      uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  granted_by   uuid REFERENCES profiles(id) ON DELETE SET NULL,
  extra_count  integer DEFAULT 1,
  created_at   timestamptz DEFAULT now(),
  UNIQUE (quiz_id, student_id)
);
ALTER TABLE quiz_extra_attempts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students view own extra attempts" ON quiz_extra_attempts FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR get_my_role() IN ('admin','co_admin','teacher'));
CREATE POLICY "Teachers grant extra attempts" ON quiz_extra_attempts FOR ALL TO authenticated
  USING (get_my_role() IN ('admin','co_admin','teacher'));

-- ── admin_messages ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_messages (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id     uuid REFERENCES profiles(id) ON DELETE SET NULL,
  recipient_id  uuid REFERENCES profiles(id) ON DELETE CASCADE,
  subject       text DEFAULT '',
  body          text NOT NULL,
  is_read       boolean DEFAULT false,
  created_at    timestamptz DEFAULT now()
);
ALTER TABLE admin_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own messages" ON admin_messages FOR SELECT TO authenticated
  USING (recipient_id = auth.uid() OR sender_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Admins send messages" ON admin_messages FOR INSERT TO authenticated
  WITH CHECK (get_my_role() IN ('admin','co_admin') OR sender_id = auth.uid());
CREATE POLICY "Recipients mark read" ON admin_messages FOR UPDATE TO authenticated
  USING (recipient_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));

-- ── faqs ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS faqs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question    text NOT NULL,
  answer      text NOT NULL,
  category    text DEFAULT 'general',
  order_index integer DEFAULT 0,
  is_published boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view published FAQs" ON faqs FOR SELECT USING (is_published = true);
CREATE POLICY "Admins manage FAQs" ON faqs FOR ALL TO authenticated USING (get_my_role() IN ('admin','co_admin'));

-- ── contact_messages ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS contact_messages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  email       text NOT NULL,
  subject     text DEFAULT '',
  message     text NOT NULL,
  is_read     boolean DEFAULT false,
  created_at  timestamptz DEFAULT now()
);
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anon can insert contact messages" ON contact_messages FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Admins view contact messages" ON contact_messages FOR SELECT TO authenticated USING (get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Admins update contact messages" ON contact_messages FOR UPDATE TO authenticated USING (get_my_role() IN ('admin','co_admin'));

-- ── site_settings ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS site_settings (
  key         text PRIMARY KEY,
  value       jsonb NOT NULL DEFAULT '{}',
  updated_at  timestamptz DEFAULT now()
);
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read site settings" ON site_settings FOR SELECT USING (true);
CREATE POLICY "Admins manage site settings" ON site_settings FOR ALL TO authenticated USING (get_my_role() IN ('admin','co_admin'));

-- ── course_categories ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS course_categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL UNIQUE,
  slug        text NOT NULL UNIQUE,
  description text DEFAULT '',
  order_index integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);
ALTER TABLE course_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view categories" ON course_categories FOR SELECT USING (is_active = true);
CREATE POLICY "Admins manage categories" ON course_categories FOR ALL TO authenticated USING (get_my_role() IN ('admin','co_admin'));

INSERT INTO course_categories (name, slug, order_index) VALUES
  ('Business & Finance',  'business-finance',  1),
  ('Technology',          'technology',         2),
  ('Language Learning',   'language-learning',  3),
  ('Health & Wellness',   'health-wellness',    4),
  ('Creative Arts',       'creative-arts',      5),
  ('Personal Development','personal-development',6),
  ('Education',           'education',          7),
  ('Other',               'other',              99)
ON CONFLICT DO NOTHING;

-- ── course_pages ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS course_pages (
  id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type             text NOT NULL CHECK (owner_type IN ('teacher', 'org')),
  teacher_id             uuid UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  org_id                 uuid UNIQUE REFERENCES organizations(id) ON DELETE CASCADE,
  slug                   text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9](?:[a-z0-9-]{0,58}[a-z0-9])?$'),
  display_name           text NOT NULL,
  tagline                text NOT NULL DEFAULT '',
  description            text NOT NULL DEFAULT '',
  logo_url               text,
  hero_image_url         text,
  brand_color            text NOT NULL DEFAULT '#0f172a' CHECK (brand_color ~ '^#[0-9a-fA-F]{6}$'),
  accent_color           text NOT NULL DEFAULT '#0284c7' CHECK (accent_color ~ '^#[0-9a-fA-F]{6}$'),
  website                text,
  contact_email          text,
  hide_platform_branding boolean NOT NULL DEFAULT false,
  is_published           boolean NOT NULL DEFAULT false,
  created_at             timestamptz NOT NULL DEFAULT now(),
  updated_at             timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT course_pages_owner_check CHECK (
    (owner_type = 'teacher' AND teacher_id IS NOT NULL AND org_id IS NULL) OR
    (owner_type = 'org' AND org_id IS NOT NULL AND teacher_id IS NULL)
  )
);
CREATE INDEX IF NOT EXISTS idx_course_pages_slug    ON course_pages(slug);
CREATE INDEX IF NOT EXISTS idx_course_pages_teacher ON course_pages(teacher_id);
CREATE INDEX IF NOT EXISTS idx_course_pages_org     ON course_pages(org_id);
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'course_pages_updated_at') THEN
    CREATE TRIGGER course_pages_updated_at BEFORE UPDATE ON course_pages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;
ALTER TABLE course_pages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view published course pages" ON course_pages FOR SELECT USING (is_published = true);
CREATE POLICY "Owners view own page" ON course_pages FOR SELECT TO authenticated
  USING (teacher_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()) OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Owners manage own page" ON course_pages FOR INSERT TO authenticated
  WITH CHECK (teacher_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner') OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Owners update own page" ON course_pages FOR UPDATE TO authenticated
  USING (teacher_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner') OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "Owners delete own page" ON course_pages FOR DELETE TO authenticated
  USING (teacher_id = auth.uid() OR org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid() AND role = 'owner') OR get_my_role() IN ('admin','co_admin'));

-- ── promo_codes missing columns ───────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='uses_count') THEN
    ALTER TABLE promo_codes ADD COLUMN uses_count integer DEFAULT 0;
  END IF;
END $$;

-- ── student AI plan support ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS student_ai_plans (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  plan_name       text DEFAULT 'free',
  token_balance   integer DEFAULT 0,
  stripe_subscription_id text,
  expires_at      timestamptz,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);
ALTER TABLE student_ai_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students view own AI plan" ON student_ai_plans FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
CREATE POLICY "System upsert AI plan" ON student_ai_plans FOR ALL TO authenticated
  USING (user_id = auth.uid() OR get_my_role() IN ('admin','co_admin'));
