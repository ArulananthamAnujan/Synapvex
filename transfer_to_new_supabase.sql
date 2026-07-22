/*
  # Maximus Academy LMS - Tables Only (Part 1)
  Creates all tables without cross-referencing policies.
*/

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text DEFAULT '',
  avatar_url text DEFAULT '',
  role text DEFAULT 'student' CHECK (role IN ('admin', 'teacher', 'student')),
  is_active boolean DEFAULT true,
  bio text DEFAULT '',
  phone text DEFAULT '',
  notification_email boolean DEFAULT true,
  notification_deadlines boolean DEFAULT true,
  notification_grades boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text DEFAULT '',
  short_description text DEFAULT '',
  thumbnail_url text DEFAULT '',
  price decimal(10,2) DEFAULT 0,
  currency text DEFAULT 'AUD',
  category text DEFAULT 'General',
  level text DEFAULT 'beginner' CHECK (level IN ('beginner', 'intermediate', 'advanced')),
  teacher_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  is_published boolean DEFAULT false,
  is_archived boolean DEFAULT false,
  is_free boolean DEFAULT false,
  duration_hours integer DEFAULT 0,
  total_lessons integer DEFAULT 0,
  total_students integer DEFAULT 0,
  rating decimal(3,2) DEFAULT 0,
  language text DEFAULT 'English',
  what_you_learn jsonb DEFAULT '[]',
  requirements jsonb DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id uuid REFERENCES sections(id) ON DELETE CASCADE,
  title text NOT NULL,
  type text DEFAULT 'video' CHECK (type IN ('video', 'pdf', 'article', 'link')),
  content text DEFAULT '',
  url text DEFAULT '',
  duration_minutes integer DEFAULT 0,
  order_index integer DEFAULT 0,
  is_required boolean DEFAULT true,
  is_preview boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  progress_percent integer DEFAULT 0,
  UNIQUE(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS lesson_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id uuid REFERENCES lessons(id) ON DELETE CASCADE,
  completed_at timestamptz DEFAULT now(),
  UNIQUE(student_id, lesson_id)
);

CREATE TABLE IF NOT EXISTS quizzes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text DEFAULT '',
  time_limit_minutes integer,
  pass_mark integer DEFAULT 70,
  max_attempts integer DEFAULT 3,
  is_required boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS quiz_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid REFERENCES quizzes(id) ON DELETE CASCADE,
  question text NOT NULL,
  type text DEFAULT 'mcq' CHECK (type IN ('mcq', 'true_false', 'short_answer')),
  options jsonb DEFAULT '[]',
  correct_answer text DEFAULT '',
  points integer DEFAULT 1,
  order_index integer DEFAULT 0
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  score integer DEFAULT 0,
  total_points integer DEFAULT 0,
  passed boolean DEFAULT false,
  answers jsonb DEFAULT '{}',
  submitted_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text DEFAULT '',
  due_date timestamptz,
  max_marks integer DEFAULT 100,
  is_required boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assignment_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id uuid REFERENCES assignments(id) ON DELETE CASCADE,
  student_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  content text DEFAULT '',
  file_url text DEFAULT '',
  grade integer,
  feedback text DEFAULT '',
  submitted_at timestamptz DEFAULT now(),
  graded_at timestamptz,
  UNIQUE(assignment_id, student_id)
);

CREATE TABLE IF NOT EXISTS certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  certificate_id text UNIQUE NOT NULL,
  issued_at timestamptz DEFAULT now(),
  revoked boolean DEFAULT false,
  revoked_at timestamptz,
  UNIQUE(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  course_id uuid REFERENCES courses(id) ON DELETE SET NULL,
  amount decimal(10,2) NOT NULL,
  currency text DEFAULT 'AUD',
  stripe_payment_id text DEFAULT '',
  promo_code text DEFAULT '',
  discount_percent integer DEFAULT 0,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'refunded', 'failed')),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS promo_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  discount_percent integer NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
  expires_at timestamptz,
  is_active boolean DEFAULT true,
  usage_limit integer,
  usage_count integer DEFAULT 0,
  created_by uuid REFERENCES profiles(id),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  created_by uuid REFERENCES profiles(id),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS activity_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  action text NOT NULL,
  resource_type text DEFAULT '',
  resource_id text DEFAULT '',
  details text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS discussions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  author_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  parent_id uuid,
  title text DEFAULT '',
  content text NOT NULL,
  is_pinned boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS live_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text DEFAULT '',
  meeting_link text DEFAULT '',
  scheduled_at timestamptz,
  duration_minutes integer DEFAULT 60,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_courses_teacher ON courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_published ON courses(is_published, is_archived);
CREATE INDEX IF NOT EXISTS idx_sections_course ON sections(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_section ON lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student ON lesson_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_student ON quiz_attempts(student_id, quiz_id);
CREATE INDEX IF NOT EXISTS idx_certificates_cert_id ON certificates(certificate_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created ON activity_logs(created_at DESC);
/*
  # Maximus Academy LMS - RLS Policies (Part 2)
  Enables Row Level Security and creates all access policies.
*/

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_sessions ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_insert" ON profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_admin" ON profiles FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "profiles_delete_admin" ON profiles FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- COURSES
CREATE POLICY "courses_select_public" ON courses FOR SELECT USING (is_published = true AND is_archived = false);
CREATE POLICY "courses_select_auth" ON courses FOR SELECT TO authenticated USING (true);
CREATE POLICY "courses_insert" ON courses FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "courses_update" ON courses FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin') OR teacher_id = auth.uid())
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin') OR teacher_id = auth.uid());
CREATE POLICY "courses_delete" ON courses FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- SECTIONS
CREATE POLICY "sections_select" ON sections FOR SELECT TO authenticated USING (true);
CREATE POLICY "sections_insert" ON sections FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "sections_update" ON sections FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "sections_delete" ON sections FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- LESSONS
CREATE POLICY "lessons_select" ON lessons FOR SELECT TO authenticated USING (true);
CREATE POLICY "lessons_insert" ON lessons FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "lessons_update" ON lessons FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "lessons_delete" ON lessons FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- ENROLLMENTS
CREATE POLICY "enrollments_select" ON enrollments FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "enrollments_insert" ON enrollments FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "enrollments_update" ON enrollments FOR UPDATE TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "enrollments_delete" ON enrollments FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- LESSON PROGRESS
CREATE POLICY "lesson_progress_select" ON lesson_progress FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "lesson_progress_insert" ON lesson_progress FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid());
CREATE POLICY "lesson_progress_delete" ON lesson_progress FOR DELETE TO authenticated
  USING (student_id = auth.uid());

-- QUIZZES
CREATE POLICY "quizzes_select" ON quizzes FOR SELECT TO authenticated USING (true);
CREATE POLICY "quizzes_insert" ON quizzes FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "quizzes_update" ON quizzes FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "quizzes_delete" ON quizzes FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- QUIZ QUESTIONS
CREATE POLICY "quiz_questions_select" ON quiz_questions FOR SELECT TO authenticated USING (true);
CREATE POLICY "quiz_questions_insert" ON quiz_questions FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "quiz_questions_update" ON quiz_questions FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "quiz_questions_delete" ON quiz_questions FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- QUIZ ATTEMPTS
CREATE POLICY "quiz_attempts_select" ON quiz_attempts FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "quiz_attempts_insert" ON quiz_attempts FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid());

-- ASSIGNMENTS
CREATE POLICY "assignments_select" ON assignments FOR SELECT TO authenticated USING (true);
CREATE POLICY "assignments_insert" ON assignments FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "assignments_update" ON assignments FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "assignments_delete" ON assignments FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- ASSIGNMENT SUBMISSIONS
CREATE POLICY "submissions_select" ON assignment_submissions FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "submissions_insert" ON assignment_submissions FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid());
CREATE POLICY "submissions_update" ON assignment_submissions FOR UPDATE TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- CERTIFICATES
CREATE POLICY "certificates_select" ON certificates FOR SELECT USING (true);
CREATE POLICY "certificates_insert" ON certificates FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "certificates_update" ON certificates FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- PAYMENTS
CREATE POLICY "payments_select" ON payments FOR SELECT TO authenticated
  USING (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "payments_insert" ON payments FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "payments_update" ON payments FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- PROMO CODES
CREATE POLICY "promo_select" ON promo_codes FOR SELECT TO authenticated USING (true);
CREATE POLICY "promo_insert" ON promo_codes FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "promo_update" ON promo_codes FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "promo_delete" ON promo_codes FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- ANNOUNCEMENTS
CREATE POLICY "announcements_select" ON announcements FOR SELECT TO authenticated USING (true);
CREATE POLICY "announcements_insert" ON announcements FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "announcements_update" ON announcements FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "announcements_delete" ON announcements FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- ACTIVITY LOGS
CREATE POLICY "activity_logs_select" ON activity_logs FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "activity_logs_insert" ON activity_logs FOR INSERT TO authenticated
  WITH CHECK (true);

-- DISCUSSIONS
CREATE POLICY "discussions_select" ON discussions FOR SELECT TO authenticated USING (true);
CREATE POLICY "discussions_insert" ON discussions FOR INSERT TO authenticated
  WITH CHECK (author_id = auth.uid());
CREATE POLICY "discussions_update" ON discussions FOR UPDATE TO authenticated
  USING (author_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')))
  WITH CHECK (author_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "discussions_delete" ON discussions FOR DELETE TO authenticated
  USING (author_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

-- LIVE SESSIONS
CREATE POLICY "live_sessions_select" ON live_sessions FOR SELECT TO authenticated USING (true);
CREATE POLICY "live_sessions_insert" ON live_sessions FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));
CREATE POLICY "live_sessions_update" ON live_sessions FOR UPDATE TO authenticated
  USING (teacher_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (teacher_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));
CREATE POLICY "live_sessions_delete" ON live_sessions FOR DELETE TO authenticated
  USING (teacher_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- AUTO-CREATE PROFILE TRIGGER
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
/*
  # Seed Sample Data for Maximus Academy

  Uses the existing auth user IDs to populate:
  - Profiles with correct roles
  - Sample courses assigned to teacher
  - Sections, lessons, quiz, assignment
  - Student enrollments and lesson progress
  - Promo codes and announcement
*/

DO $$
DECLARE
  admin_uid   uuid := '6c0e7959-b621-42ce-8598-868a8fc2e073';
  teacher_uid uuid := '494bced9-f191-429c-8b0b-1f19680e4442';
  student_uid uuid := '4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5';
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role, is_active, bio)
  VALUES
    (admin_uid,   'admin@maximus.edu.au',   'Admin User',     'admin',   true, 'Platform administrator for Maximus Academy Australia.'),
    (teacher_uid, 'teacher@maximus.edu.au', 'Sarah Thompson', 'teacher', true, 'Senior Business Communication instructor with 10+ years experience in corporate training.'),
    (student_uid, 'student@maximus.edu.au', 'James Wilson',   'student', true, 'Aspiring business professional based in Sydney, Australia.')
  ON CONFLICT (id) DO UPDATE SET
    role      = EXCLUDED.role,
    full_name = EXCLUDED.full_name,
    bio       = EXCLUDED.bio,
    is_active = true;
END $$;

-- Courses
INSERT INTO public.courses (id, title, short_description, description, thumbnail_url, price, category, level, teacher_id, is_published, is_free, duration_hours, total_lessons, total_students, rating, what_you_learn, requirements)
VALUES
  ('aa000000-0000-0000-0000-000000000001',
   'Business Communication Mastery',
   'Master professional communication skills for the modern Australian workplace.',
   'This comprehensive course covers all aspects of professional business communication, from email writing and presentation skills to negotiation and conflict resolution.',
   'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg',
   299.00, 'Business', 'intermediate',
   '494bced9-f191-429c-8b0b-1f19680e4442',
   true, false, 8, 6, 142, 4.8,
   '["Write clear professional emails","Deliver confident presentations","Negotiate effectively","Resolve workplace conflicts"]'::jsonb,
   '["No prior experience needed","Basic computer literacy"]'::jsonb),

  ('bb000000-0000-0000-0000-000000000002',
   'Digital Marketing Fundamentals',
   'Learn to build and execute winning digital marketing strategies.',
   'From SEO and social media to paid advertising and analytics, this course gives you a comprehensive introduction to digital marketing.',
   'https://images.pexels.com/photos/905163/pexels-photo-905163.jpeg',
   199.00, 'Marketing', 'beginner',
   '494bced9-f191-429c-8b0b-1f19680e4442',
   true, false, 6, 18, 98, 4.6,
   '["Create effective social media campaigns","Understand SEO fundamentals","Run Google Ads","Analyse marketing metrics"]'::jsonb,
   '["Basic computer skills","Interest in marketing"]'::jsonb),

  ('cc000000-0000-0000-0000-000000000003',
   'Introduction to Data Analysis',
   'Get started with data analysis using Excel and Python.',
   'This free introductory course teaches you the fundamentals of data analysis. Perfect for beginners who want to start working with data.',
   'https://images.pexels.com/photos/590022/pexels-photo-590022.jpeg',
   0.00, 'Technology', 'beginner',
   '494bced9-f191-429c-8b0b-1f19680e4442',
   true, true, 4, 12, 256, 4.7,
   '["Understand data types and structures","Use Excel for analysis","Write basic Python scripts","Create data visualisations"]'::jsonb,
   '["No programming experience needed","Microsoft Excel (any version)"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Sections
INSERT INTO public.sections (id, course_id, title, order_index) VALUES
  ('10000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000001', 'Module 1: Foundations of Business Communication', 0),
  ('20000000-0000-0000-0000-000000000002', 'aa000000-0000-0000-0000-000000000001', 'Module 2: Written Communication', 1),
  ('30000000-0000-0000-0000-000000000003', 'aa000000-0000-0000-0000-000000000001', 'Module 3: Presentations & Public Speaking', 2)
ON CONFLICT (id) DO NOTHING;

-- Lessons
INSERT INTO public.lessons (id, section_id, title, type, content, url, order_index, is_required, is_preview, duration_minutes) VALUES
  ('40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Welcome & Course Overview', 'video', '', 'https://www.w3schools.com/html/mov_bbb.mp4', 0, false, true, 5),
  ('50000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'What is Business Communication?', 'article', 'Business communication is the process of sharing information between people within and outside an organisation. Effective communication is a fundamental management function and a critical skill for all professionals in the modern Australian workplace.', '', 1, true, false, 15),
  ('60000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'Communication Styles & Barriers', 'article', 'Understanding different communication styles helps you adapt your message. The four main styles are assertive, passive, aggressive, and passive-aggressive. Common barriers include cultural differences, language barriers, jargon, and poor listening skills.', '', 2, true, false, 20),
  ('70000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', 'Professional Email Writing', 'article', 'Writing professional emails requires mastery of structure and tone. Key elements: a clear subject line, professional greeting, concise body, clear call to action, and appropriate sign-off. Always proofread before sending.', '', 0, true, false, 25),
  ('80000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', 'Business Report Writing', 'article', 'Business reports should follow a clear structure: executive summary, introduction, methodology, findings, conclusions, and recommendations. Use clear headings, bullet points, and visual aids to make your report easy to navigate.', '', 1, true, false, 30),
  ('90000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', 'Presentation Design Principles', 'article', 'Effective presentations follow the 10-20-30 rule: no more than 10 slides, no longer than 20 minutes, and font size no smaller than 30 points. Use high-quality images, limit text on slides, and practise your delivery.', '', 0, true, false, 20)
ON CONFLICT (id) DO NOTHING;

-- Enrolments for student
INSERT INTO public.enrollments (student_id, course_id, progress_percent) VALUES
  ('4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5', 'aa000000-0000-0000-0000-000000000001', 35),
  ('4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5', 'cc000000-0000-0000-0000-000000000003', 67)
ON CONFLICT (student_id, course_id) DO NOTHING;

-- Lesson progress for student
INSERT INTO public.lesson_progress (student_id, lesson_id) VALUES
  ('4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5', '40000000-0000-0000-0000-000000000001'),
  ('4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5', '50000000-0000-0000-0000-000000000002')
ON CONFLICT (student_id, lesson_id) DO NOTHING;

-- Quiz
INSERT INTO public.quizzes (id, course_id, title, description, time_limit_minutes, pass_mark, max_attempts, is_required) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000001', 'Module 1 Knowledge Check', 'Test your understanding of business communication fundamentals.', 15, 70, 3, true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.quiz_questions (quiz_id, question, type, options, correct_answer, points, order_index) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'Which of the following is a common barrier to effective communication?', 'mcq', '["Active listening","Clear language","Cultural differences","Eye contact"]'::jsonb, 'Cultural differences', 1, 0),
  ('a0000000-0000-0000-0000-000000000001', 'Business communication only occurs within an organisation.', 'true_false', '["True","False"]'::jsonb, 'False', 1, 1),
  ('a0000000-0000-0000-0000-000000000001', 'Name one technique to improve your active listening skills.', 'short_answer', '[]'::jsonb, 'paraphrasing', 1, 2);

-- Assignment
INSERT INTO public.assignments (id, course_id, title, description, due_date, max_marks, is_required) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000001', 'Professional Email Draft', 'Write a professional email to a client explaining a project delay. Approximately 200-300 words demonstrating the principles covered in Module 2.', now() + interval '14 days', 100, true)
ON CONFLICT (id) DO NOTHING;

-- Promo codes
INSERT INTO public.promo_codes (code, discount_percent, expires_at, is_active, usage_limit, usage_count, created_by) VALUES
  ('WELCOME20', 20, now() + interval '90 days', true, 100, 3, '6c0e7959-b621-42ce-8598-868a8fc2e073'),
  ('AUSSIE50',  50, now() + interval '30 days', true, 50,  1, '6c0e7959-b621-42ce-8598-868a8fc2e073')
ON CONFLICT (code) DO NOTHING;

-- Announcement
INSERT INTO public.announcements (title, content, created_by, is_active) VALUES
  ('Welcome to Maximus Academy!', 'We are thrilled to have you as part of the Maximus Academy community. Explore our growing library of courses and start your learning journey today. Use code WELCOME20 for 20% off your first course!', '6c0e7959-b621-42ce-8598-868a8fc2e073', true);

-- Activity logs
INSERT INTO public.activity_logs (user_id, action, resource_type, resource_id, details) VALUES
  ('6c0e7959-b621-42ce-8598-868a8fc2e073', 'create', 'course', 'aa000000-0000-0000-0000-000000000001', 'Created course: Business Communication Mastery'),
  ('494bced9-f191-429c-8b0b-1f19680e4442', 'create', 'quiz',   'a0000000-0000-0000-0000-000000000001', 'Created quiz: Module 1 Knowledge Check'),
  ('4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5', 'enroll',  'course', 'aa000000-0000-0000-0000-000000000001', 'Enrolled in: Business Communication Mastery');
/*
  # Add Maximus Academy Course Catalog

  Inserts 8 specific courses for Maximus Academy Australia:
  1. IELTS Preparation
  2. PTE Preparation
  3. Japanese Language Course
  4. French Language Course
  5. Spanish Language Course
  6. Xero Beginner Course
  7. Test Preparation (General)
  8. Short Courses & Workshops

  Uses the teacher profile ID from the seeded data.
  Courses use ON CONFLICT DO NOTHING to avoid duplicates.
*/

DO $$
DECLARE
  teacher_id uuid;
BEGIN
  SELECT id INTO teacher_id FROM public.profiles WHERE role = 'teacher' LIMIT 1;

  INSERT INTO public.courses (id, title, short_description, description, category, level, price, is_free, duration_hours, total_lessons, thumbnail_url, teacher_id, is_published, is_archived, rating, total_students)
  VALUES
    (
      gen_random_uuid(),
      'IELTS Preparation',
      'Comprehensive IELTS preparation covering all four skills: Listening, Reading, Writing, and Speaking.',
      'Our IELTS Preparation course is designed to help you achieve your target band score. We cover all four test components with expert-led strategies, practice tests, and personalised feedback. Whether you are aiming for Band 6, 7, or higher, our structured program gives you the skills and confidence to succeed.',
      'Test Preparation',
      'beginner',
      450.00,
      false,
      40,
      32,
      'https://images.pexels.com/photos/4144923/pexels-photo-4144923.jpeg',
      teacher_id,
      true,
      false,
      4.8,
      127
    ),
    (
      gen_random_uuid(),
      'PTE Academic Preparation',
      'Master the PTE Academic exam with targeted practice, AI-scored mock tests, and proven strategies.',
      'The PTE Academic Preparation course provides an intensive study program covering all PTE question types. You will learn time management strategies, practise with realistic mock tests, and receive detailed performance analysis to identify and improve your weak areas.',
      'Test Preparation',
      'intermediate',
      420.00,
      false,
      36,
      28,
      'https://images.pexels.com/photos/5427869/pexels-photo-5427869.jpeg',
      teacher_id,
      true,
      false,
      4.7,
      98
    ),
    (
      gen_random_uuid(),
      'Japanese Language Course',
      'Learn Japanese from scratch — hiragana, katakana, kanji, and everyday conversation.',
      'This Japanese Language Course takes you from complete beginner to conversational proficiency. You will master the writing systems (hiragana, katakana, and essential kanji), build vocabulary, study grammar, and practise real-world conversations. Ideal for travel, work, or cultural interest.',
      'Language Learning',
      'beginner',
      380.00,
      false,
      48,
      36,
      'https://images.pexels.com/photos/5926382/pexels-photo-5926382.jpeg',
      teacher_id,
      true,
      false,
      4.9,
      74
    ),
    (
      gen_random_uuid(),
      'French Language Course',
      'Speak French with confidence — from bonjour to business conversations.',
      'Our French Language Course is perfect for beginners and intermediate learners. You will develop all four language skills through interactive lessons, audio exercises, and live conversation practice. By the end, you will be ready for travel, study, or professional use in French-speaking environments.',
      'Language Learning',
      'beginner',
      360.00,
      false,
      45,
      34,
      'https://images.pexels.com/photos/5935791/pexels-photo-5935791.jpeg',
      teacher_id,
      true,
      false,
      4.8,
      62
    ),
    (
      gen_random_uuid(),
      'Spanish Language Course',
      'From hola to fluent — learn Spanish for travel, work, and everyday life.',
      'Spanish is one of the world''s most spoken languages. This course covers pronunciation, grammar, vocabulary, and conversation for beginners through to intermediate levels. Our immersive approach ensures you build real-world language skills quickly and effectively.',
      'Language Learning',
      'beginner',
      360.00,
      false,
      45,
      34,
      'https://images.pexels.com/photos/5935234/pexels-photo-5935234.jpeg',
      teacher_id,
      true,
      false,
      4.7,
      55
    ),
    (
      gen_random_uuid(),
      'Xero Beginner Course',
      'Get job-ready with Xero — the cloud accounting software used by thousands of businesses.',
      'This hands-on Xero Beginner Course teaches you to set up and manage accounts, process invoices, reconcile bank transactions, run payroll, and generate financial reports. Perfect for small business owners, bookkeepers, and administrative professionals looking to add a sought-after skill.',
      'Professional Skills',
      'beginner',
      320.00,
      false,
      20,
      18,
      'https://images.pexels.com/photos/6693661/pexels-photo-6693661.jpeg',
      teacher_id,
      true,
      false,
      4.6,
      143
    ),
    (
      gen_random_uuid(),
      'General Test Preparation',
      'Build study skills and exam strategies for academic and professional tests.',
      'This General Test Preparation course equips students with essential study techniques, time management skills, critical thinking strategies, and exam-specific approaches applicable across a wide range of tests. Ideal for students preparing for university entrance exams, professional certifications, or general academic assessments.',
      'Test Preparation',
      'beginner',
      280.00,
      false,
      24,
      20,
      'https://images.pexels.com/photos/4144101/pexels-photo-4144101.jpeg',
      teacher_id,
      true,
      false,
      4.5,
      89
    ),
    (
      gen_random_uuid(),
      'Short Courses & Workshops',
      'Intensive skill-building workshops designed for busy professionals and lifelong learners.',
      'Our Short Courses & Workshops series offers focused, high-impact learning experiences in a condensed format. Each workshop targets a specific skill — from communication and leadership to digital literacy and personal development. Perfect for professionals seeking to upskill quickly without a long-term commitment.',
      'Professional Skills',
      'beginner',
      150.00,
      false,
      8,
      10,
      'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg',
      teacher_id,
      true,
      false,
      4.6,
      201
    )
  ON CONFLICT DO NOTHING;
END $$;

/*
  # Fix Demo User Authentication v2

  Resets all three demo user passwords with simple, reliable credentials.
  Updates identity_data to include email_verified flag.

  New credentials:
  - admin@maximus.edu.au   → Admin1234!
  - teacher@maximus.edu.au → Teacher1234!
  - student@maximus.edu.au → Student1234!
*/

UPDATE auth.users
SET
  encrypted_password = crypt('Admin1234!', gen_salt('bf')),
  updated_at = now(),
  raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
  raw_user_meta_data = '{"role":"admin","full_name":"Alex Morrison"}'::jsonb,
  email_confirmed_at = COALESCE(email_confirmed_at, now()),
  is_sso_user = false,
  deleted_at = null,
  banned_until = null
WHERE email = 'admin@maximus.edu.au';

UPDATE auth.users
SET
  encrypted_password = crypt('Teacher1234!', gen_salt('bf')),
  updated_at = now(),
  raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
  raw_user_meta_data = '{"role":"teacher","full_name":"Sarah Johnson"}'::jsonb,
  email_confirmed_at = COALESCE(email_confirmed_at, now()),
  is_sso_user = false,
  deleted_at = null,
  banned_until = null
WHERE email = 'teacher@maximus.edu.au';

UPDATE auth.users
SET
  encrypted_password = crypt('Student1234!', gen_salt('bf')),
  updated_at = now(),
  raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
  raw_user_meta_data = '{"role":"student","full_name":"James Wilson"}'::jsonb,
  email_confirmed_at = COALESCE(email_confirmed_at, now()),
  is_sso_user = false,
  deleted_at = null,
  banned_until = null
WHERE email = 'student@maximus.edu.au';

UPDATE auth.identities
SET
  identity_data = jsonb_build_object(
    'sub', user_id::text,
    'email', (SELECT email FROM auth.users u WHERE u.id = auth.identities.user_id),
    'email_verified', true,
    'phone_verified', false
  ),
  updated_at = now()
WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email IN ('admin@maximus.edu.au','teacher@maximus.edu.au','student@maximus.edu.au')
);

/*
  # Recreate Demo Users - v5

  Final version handling all generated column constraints in auth.identities.

  Demo credentials:
  - admin@maximus.edu.au    / Admin1234!
  - teacher@maximus.edu.au  / Teacher1234!
  - student@maximus.edu.au  / Student1234!
*/

DO $$
DECLARE
  admin_uid   uuid := '6c0e7959-b621-42ce-8598-868a8fc2e073';
  teacher_uid uuid := '494bced9-f191-429c-8b0b-1f19680e4442';
  student_uid uuid := '4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5';
BEGIN

  -- Nullify FK refs from public schema
  UPDATE public.promo_codes   SET created_by = NULL WHERE created_by IN (admin_uid, teacher_uid, student_uid);
  UPDATE public.announcements SET created_by = NULL WHERE created_by IN (admin_uid, teacher_uid, student_uid);
  UPDATE public.courses       SET teacher_id = NULL WHERE teacher_id IN (admin_uid, teacher_uid, student_uid);
  DELETE FROM public.activity_logs WHERE user_id IN (admin_uid, teacher_uid, student_uid);

  -- Clean auth tables
  DELETE FROM auth.identities     WHERE user_id IN (admin_uid, teacher_uid, student_uid);
  DELETE FROM auth.sessions       WHERE user_id IN (admin_uid, teacher_uid, student_uid);
  DELETE FROM auth.refresh_tokens WHERE user_id IN (admin_uid::text, teacher_uid::text, student_uid::text);
  DELETE FROM auth.users          WHERE id      IN (admin_uid, teacher_uid, student_uid);

  -- Recreate auth users
  INSERT INTO auth.users (
    instance_id, id, aud, role,
    email, encrypted_password,
    email_confirmed_at,
    confirmation_token, recovery_token,
    email_change_token_new, email_change,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, created_at, updated_at,
    phone, phone_change, phone_change_token,
    email_change_token_current, email_change_confirm_status,
    reauthentication_token,
    is_sso_user, deleted_at, is_anonymous
  ) VALUES
  (
    '00000000-0000-0000-0000-000000000000', admin_uid,
    'authenticated', 'authenticated',
    'admin@maximus.edu.au', crypt('Admin1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"admin","full_name":"Alex Morrison"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', teacher_uid,
    'authenticated', 'authenticated',
    'teacher@maximus.edu.au', crypt('Teacher1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"teacher","full_name":"Sarah Thompson"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', student_uid,
    'authenticated', 'authenticated',
    'student@maximus.edu.au', crypt('Student1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"student","full_name":"James Wilson"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  );

  -- Recreate identities (email is a generated column, omit it)
  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, created_at, updated_at)
  VALUES
  (
    gen_random_uuid(), 'admin@maximus.edu.au', admin_uid,
    jsonb_build_object('sub', admin_uid::text, 'email', 'admin@maximus.edu.au', 'email_verified', true, 'phone_verified', false),
    'email', now(), now()
  ),
  (
    gen_random_uuid(), 'teacher@maximus.edu.au', teacher_uid,
    jsonb_build_object('sub', teacher_uid::text, 'email', 'teacher@maximus.edu.au', 'email_verified', true, 'phone_verified', false),
    'email', now(), now()
  ),
  (
    gen_random_uuid(), 'student@maximus.edu.au', student_uid,
    jsonb_build_object('sub', student_uid::text, 'email', 'student@maximus.edu.au', 'email_verified', true, 'phone_verified', false),
    'email', now(), now()
  );

  -- Recreate profiles
  INSERT INTO public.profiles (id, email, full_name, role, is_active, bio)
  VALUES
    (admin_uid,   'admin@maximus.edu.au',   'Alex Morrison',  'admin',   true, 'Platform administrator for Maximus Academy Australia.'),
    (teacher_uid, 'teacher@maximus.edu.au', 'Sarah Thompson', 'teacher', true, 'Senior Business Communication instructor with 10+ years experience.'),
    (student_uid, 'student@maximus.edu.au', 'James Wilson',   'student', true, 'Aspiring business professional based in Sydney, Australia.')
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email, full_name = EXCLUDED.full_name,
    role = EXCLUDED.role, is_active = true;

  -- Restore public references
  UPDATE public.courses       SET teacher_id = teacher_uid WHERE teacher_id IS NULL;
  UPDATE public.promo_codes   SET created_by = admin_uid   WHERE created_by IS NULL;
  UPDATE public.announcements SET created_by = admin_uid   WHERE created_by IS NULL;

  -- Restore activity logs
  INSERT INTO public.activity_logs (user_id, action, resource_type, resource_id, details) VALUES
    (admin_uid,   'create', 'course', 'aa000000-0000-0000-0000-000000000001', 'Created course: Business Communication Mastery'),
    (teacher_uid, 'create', 'quiz',   'a0000000-0000-0000-0000-000000000001', 'Created quiz: Module 1 Knowledge Check'),
    (student_uid, 'enroll', 'course', 'aa000000-0000-0000-0000-000000000001', 'Enrolled in: Business Communication Mastery');

END $$;

/*
  # Seed Demo Data for All Roles (v2)

  Corrected column names and constraint values:
  - quiz_questions.type uses 'mcq' not 'multiple_choice'
  - sections uses order_index not position
  - lessons uses type 'video','pdf','article','link'
  - certificates uses certificate_id column
  - promo_codes uses usage_limit and usage_count
  - announcements uses created_by not author_id, no target_type
*/

DO $$
DECLARE
  v_teacher_id uuid := '494bced9-f191-429c-8b0b-1f19680e4442';
  v_student_id uuid := '4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5';
  v_admin_id   uuid := '6c0e7959-b621-42ce-8598-868a8fc2e073';
  v_course1    uuid := '9170d2af-8369-4dc4-86f5-5806db1f2ddb';
  v_course2    uuid := 'd531dc2a-7cc2-461d-a769-9b006a016dea';
  v_course3    uuid := '87db5187-4f0e-4c69-927f-938556fa7097';
  v_assign1    uuid := gen_random_uuid();
  v_assign2    uuid := gen_random_uuid();
  v_quiz1      uuid := gen_random_uuid();
  v_cert_id    uuid := gen_random_uuid();
  v_section1   uuid := gen_random_uuid();
  v_section2   uuid := gen_random_uuid();
  v_lesson1    uuid := gen_random_uuid();
  v_lesson2    uuid := gen_random_uuid();
  v_lesson3    uuid := gen_random_uuid();
  v_lesson4    uuid := gen_random_uuid();
  i            int;
BEGIN

  -- ── Enrollments ──────────────────────────────────────────────────────────
  INSERT INTO enrollments (student_id, course_id, progress_percent, completed_at)
  VALUES
    (v_student_id, v_course1, 75,  NULL),
    (v_student_id, v_course2, 100, NOW() - INTERVAL '5 days'),
    (v_student_id, v_course3, 30,  NULL)
  ON CONFLICT (student_id, course_id) DO UPDATE
    SET progress_percent = EXCLUDED.progress_percent,
        completed_at     = EXCLUDED.completed_at;

  -- ── Sections ─────────────────────────────────────────────────────────────
  INSERT INTO sections (id, course_id, title, order_index)
  VALUES
    (v_section1, v_course1, 'Getting Started',  1),
    (v_section2, v_course1, 'Core Vocabulary',  2)
  ON CONFLICT (id) DO NOTHING;

  -- ── Lessons ──────────────────────────────────────────────────────────────
  INSERT INTO lessons (id, section_id, title, type, content, duration_minutes, order_index, is_required)
  VALUES
    (v_lesson1, v_section1, 'Introduction to French',      'video',   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 12, 1, true),
    (v_lesson2, v_section1, 'Basic Pronunciation Guide',   'article', 'In French, every syllable is equally stressed. Focus on nasal vowels and silent final consonants. Practice: "bon", "vin", "brun".', 8, 2, true),
    (v_lesson3, v_section2, 'Numbers 1 to 20',             'video',   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 10, 1, true),
    (v_lesson4, v_section2, 'Days of the Week',            'article', 'Lundi (Monday), Mardi (Tuesday), Mercredi (Wednesday), Jeudi (Thursday), Vendredi (Friday), Samedi (Saturday), Dimanche (Sunday).', 6, 2, false)
  ON CONFLICT (id) DO NOTHING;

  -- ── Lesson Progress ───────────────────────────────────────────────────────
  INSERT INTO lesson_progress (student_id, lesson_id, completed_at)
  VALUES
    (v_student_id, v_lesson1, NOW() - INTERVAL '3 days'),
    (v_student_id, v_lesson2, NOW() - INTERVAL '2 days'),
    (v_student_id, v_lesson3, NOW() - INTERVAL '1 day')
  ON CONFLICT (student_id, lesson_id) DO NOTHING;

  -- ── Assignments ──────────────────────────────────────────────────────────
  INSERT INTO assignments (id, course_id, title, description, due_date, max_marks, is_required)
  VALUES
    (v_assign1, v_course1,
     'French Conversation Practice',
     'Record a 2-minute spoken French conversation on any topic and upload the audio file. Focus on pronunciation and natural flow.',
     NOW() + INTERVAL '7 days', 100, true),
    (v_assign2, v_course2,
     'Spanish Vocabulary Essay',
     'Write a 300-word essay in Spanish using at least 20 vocabulary words from Module 2.',
     NOW() + INTERVAL '3 days', 80, true)
  ON CONFLICT (id) DO NOTHING;

  -- Student submission (ungraded — shows in teacher pending grades count)
  INSERT INTO assignment_submissions (assignment_id, student_id, content, submitted_at)
  VALUES (
    v_assign1, v_student_id,
    'Bonjour! Je m''appelle Marie. Je suis étudiante à Sydney. J''aime les langues étrangères.',
    NOW() - INTERVAL '1 day'
  ) ON CONFLICT DO NOTHING;

  -- ── Live Sessions ─────────────────────────────────────────────────────────
  INSERT INTO live_sessions (course_id, teacher_id, title, description, meeting_link, scheduled_at, duration_minutes)
  VALUES
    (v_course1, v_teacher_id,
     'French Pronunciation Workshop',
     'Live practice of French phonetics with native speaker exercises.',
     'https://meet.google.com/abc-demo-001',
     NOW() + INTERVAL '2 days', 60),
    (v_course2, v_teacher_id,
     'Spanish Grammar Q&A',
     'Open Q&A on subjunctive and conditional tenses.',
     'https://zoom.us/j/demo002',
     NOW() + INTERVAL '5 days', 45),
    (v_course3, v_teacher_id,
     'Business Communication: Presentations',
     'Practical techniques for professional presentations.',
     'https://teams.microsoft.com/l/demo003',
     NOW() + INTERVAL '10 days', 90)
  ON CONFLICT DO NOTHING;

  -- ── Quiz ─────────────────────────────────────────────────────────────────
  INSERT INTO quizzes (id, course_id, title, description, time_limit_minutes, pass_mark, max_attempts, is_required)
  VALUES (
    v_quiz1, v_course1,
    'French Basics Quiz',
    'Test your knowledge of French greetings and basic phrases.',
    15, 60, 3, true
  ) ON CONFLICT (id) DO NOTHING;

  INSERT INTO quiz_questions (quiz_id, question, type, options, correct_answer, points, order_index)
  VALUES
    (v_quiz1, 'How do you say "Good morning" in French?', 'mcq',
     '["Bonsoir","Bonjour","Bonne nuit","Au revoir"]', 'Bonjour', 1, 1),
    (v_quiz1, 'The French word "merci" means "thank you".', 'true_false',
     '["True","False"]', 'True', 1, 2),
    (v_quiz1, 'Translate to French: "My name is John"', 'short_answer',
     NULL, 'Je m''appelle John', 2, 3)
  ON CONFLICT DO NOTHING;

  -- ── Certificate ───────────────────────────────────────────────────────────
  INSERT INTO certificates (id, student_id, course_id, certificate_id, issued_at, revoked)
  VALUES (
    v_cert_id,
    v_student_id,
    v_course2,
    'MAXIMUS-2026-' || UPPER(SUBSTRING(v_cert_id::text FROM 1 FOR 8)),
    NOW() - INTERVAL '5 days',
    false
  ) ON CONFLICT (id) DO NOTHING;

  -- ── Payments ─────────────────────────────────────────────────────────────
  INSERT INTO payments (student_id, course_id, amount, currency, status, discount_percent)
  VALUES
    (v_student_id, v_course2,   0.00, 'AUD', 'completed', 0),
    (v_student_id, v_course3, 297.00, 'AUD', 'completed', 0)
  ON CONFLICT DO NOTHING;

  -- Historical payments for revenue chart (spread over 30 days)
  FOR i IN 1..18 LOOP
    INSERT INTO payments (student_id, course_id, amount, currency, status, created_at, discount_percent)
    VALUES (
      v_student_id,
      CASE WHEN i % 3 = 0 THEN v_course1 WHEN i % 3 = 1 THEN v_course2 ELSE v_course3 END,
      (ARRAY[197.00, 297.00, 397.00, 247.00, 347.00])[ ((i-1) % 5) + 1 ],
      'AUD',
      'completed',
      NOW() - (i * INTERVAL '40 hours'),
      0
    );
  END LOOP;

  -- ── Announcements ─────────────────────────────────────────────────────────
  INSERT INTO announcements (title, content, created_by, is_active)
  VALUES
    ('Welcome to Maximus Academy!',
     'We are thrilled to have you here. Explore world-class language and business courses designed to accelerate your professional growth.',
     v_admin_id, true),
    ('New Courses Available — July 2026',
     'Three new courses just added: Advanced Business Writing, Japanese for Beginners, and Data Analysis with Excel. Use code WELCOME20 for 20% off!',
     v_admin_id, true)
  ON CONFLICT DO NOTHING;

  -- ── Activity Logs ─────────────────────────────────────────────────────────
  INSERT INTO activity_logs (user_id, action, resource_type, resource_id, details)
  VALUES
    (v_admin_id,   'create', 'course',       v_course1,             'Created course: French Language Course'),
    (v_admin_id,   'create', 'user',          v_teacher_id,          'Created teacher account: teacher@maximus.edu.au'),
    (v_teacher_id, 'create', 'assignment',    v_assign1,             'Created assignment: French Conversation Practice'),
    (v_teacher_id, 'create', 'quiz',          v_quiz1,               'Created quiz: French Basics Quiz'),
    (v_student_id, 'enroll', 'course',        v_course1,             'Enrolled in: French Language Course'),
    (v_student_id, 'enroll', 'course',        v_course2,             'Enrolled in: Spanish Language Course'),
    (v_student_id, 'complete','course',       v_course2,             'Completed: Spanish Language Course'),
    (v_admin_id,   'update', 'course',        v_course3,             'Published: Advanced Business Communication'),
    (v_teacher_id, 'create', 'live_session',  gen_random_uuid(),     'Scheduled: French Pronunciation Workshop'),
    (v_admin_id,   'create', 'announcement',  gen_random_uuid(),     'Sent announcement: Welcome to Maximus Academy!')
  ON CONFLICT DO NOTHING;

  -- ── Promo Codes ───────────────────────────────────────────────────────────
  INSERT INTO promo_codes (code, discount_percent, usage_limit, usage_count, expires_at, is_active, created_by)
  VALUES
    ('WELCOME20', 20, 100,  3, NOW() + INTERVAL '90 days',  true,  v_admin_id),
    ('LAUNCH50',  50,  50,  0, NOW() + INTERVAL '30 days',  true,  v_admin_id),
    ('STUDENT10', 10, 200, 12, NOW() + INTERVAL '180 days', true,  v_admin_id),
    ('EARLYBIRD', 30,  20, 20, NOW() - INTERVAL '1 day',    false, v_admin_id)
  ON CONFLICT (code) DO UPDATE SET
    discount_percent = EXCLUDED.discount_percent,
    usage_limit      = EXCLUDED.usage_limit,
    expires_at       = EXCLUDED.expires_at,
    is_active        = EXCLUDED.is_active;

END $$;

-- Refresh course student counts
UPDATE courses
SET total_students = (
  SELECT COUNT(*) FROM enrollments WHERE enrollments.course_id = courses.id
);

/*
  # Clean up courses — keep only IELTS and Xero

  Removes all courses except:
  - IELTS Preparation (59102c80-84b8-4533-98dc-597ea80214e3)
  - Xero Beginner Course (421fc7e3-b096-4b68-87fe-89b44af69c0e)

  Also adds timeline columns to courses:
  - start_date: when the course cohort begins
  - end_date: when the course cohort ends
  - duration_weeks: total duration in weeks
*/

-- Remove all courses that are not IELTS or Xero
-- Cascade will handle sections, lessons, enrollments, quizzes etc.
DELETE FROM courses
WHERE id NOT IN (
  '59102c80-84b8-4533-98dc-597ea80214e3',
  '421fc7e3-b096-4b68-87fe-89b44af69c0e'
);

-- Add timeline columns to courses
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'start_date'
  ) THEN
    ALTER TABLE courses ADD COLUMN start_date date;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'end_date'
  ) THEN
    ALTER TABLE courses ADD COLUMN end_date date;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'duration_weeks'
  ) THEN
    ALTER TABLE courses ADD COLUMN duration_weeks integer;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'thumbnail_url'
  ) THEN
    ALTER TABLE courses ADD COLUMN thumbnail_url text;
  END IF;
END $$;

-- Set sensible defaults on the two kept courses
UPDATE courses
SET
  start_date     = CURRENT_DATE,
  end_date       = CURRENT_DATE + INTERVAL '12 weeks',
  duration_weeks = 12
WHERE id IN (
  '59102c80-84b8-4533-98dc-597ea80214e3',
  '421fc7e3-b096-4b68-87fe-89b44af69c0e'
);

/*
  # Create storage buckets for course media

  1. New Buckets
    - `course-videos` — stores uploaded lecture video files (mp4, webm, mov, avi)
    - `course-documents` — stores uploaded PDF and document files (pdf, doc, docx, ppt, pptx)

  2. Security
    - Admins and teachers can upload to both buckets
    - Any authenticated user can read (to view lessons they are enrolled in)
    - Files are scoped under course_id/section_id/filename paths
*/

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'course-videos',
  'course-videos',
  true,
  524288000,
  ARRAY[
    'video/mp4',
    'video/webm',
    'video/quicktime',
    'video/x-msvideo',
    'video/mpeg',
    'video/ogg'
  ]
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'course-documents',
  'course-documents',
  true,
  104857600,
  ARRAY[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  ]
)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Admins and teachers can upload videos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'course-videos' AND (
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
    )
  );

CREATE POLICY "Anyone authenticated can read videos"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'course-videos');

CREATE POLICY "Admins and teachers can delete videos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'course-videos' AND (
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
    )
  );

CREATE POLICY "Admins and teachers can upload documents"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'course-documents' AND (
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
    )
  );

CREATE POLICY "Anyone authenticated can read documents"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'course-documents');

CREATE POLICY "Admins and teachers can delete documents"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'course-documents' AND (
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'teacher'))
    )
  );
/*
  # Increase storage bucket file size limits

  1. Changes
    - `course-videos` bucket: increase limit to 5GB (5368709120 bytes)
    - `course-documents` bucket: increase limit to 5GB (5368709120 bytes)

  Note: Supabase Storage supports resumable uploads (TUS protocol) for large files.
  The UI will use the resumable upload endpoint for files over 6MB.
*/

UPDATE storage.buckets
SET file_size_limit = 5368709120
WHERE id = 'course-videos';

UPDATE storage.buckets
SET file_size_limit = 5368709120
WHERE id = 'course-documents';
/*
  # Add course-thumbnails storage bucket

  Creates a public storage bucket for course thumbnail images with appropriate
  file size limits and allowed MIME types.
*/

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'course-thumbnails',
  'course-thumbnails',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Authenticated users can upload thumbnails"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'course-thumbnails');

CREATE POLICY "Anyone can view thumbnails"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'course-thumbnails');

CREATE POLICY "Authenticated users can update thumbnails"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'course-thumbnails');

CREATE POLICY "Authenticated users can delete thumbnails"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'course-thumbnails');
/*
  # Add Stripe Payment Link to Courses & Clear Dummy Payments

  1. Changes
    - Add `stripe_payment_link` column to courses table (nullable text)
    - Delete all existing dummy payment records so the payments page starts clean

  2. Notes
    - teacher_id is already nullable on courses, so no changes needed there
    - stripe_payment_link stores the full Stripe Payment Link URL per course
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'stripe_payment_link'
  ) THEN
    ALTER TABLE courses ADD COLUMN stripe_payment_link text DEFAULT NULL;
  END IF;
END $$;

DELETE FROM payments;
/*
  # Add Performance Indexes

  Adds indexes on all columns used in WHERE clauses and JOINs across the LMS
  to ensure fast query execution as data grows.

  ## Indexes Added

  ### courses
  - teacher_id: JOIN with profiles
  - is_published, is_archived: common WHERE filters

  ### enrollments
  - student_id: most common lookup (student's courses)
  - course_id: course roster lookups
  - (student_id, course_id): unique pair lookups

  ### lessons
  - section_id: lesson list per section

  ### sections
  - course_id: section list per course

  ### lesson_progress
  - student_id: student progress lookups
  - lesson_id: lesson completion checks
  - (student_id, lesson_id): combined lookup

  ### quiz_attempts
  - student_id: student's attempts
  - quiz_id: attempts per quiz

  ### quizzes
  - course_id: quizzes per course

  ### assignments
  - course_id: assignments per course

  ### assignment_submissions
  - student_id: student's submissions
  - assignment_id: submissions per assignment

  ### certificates
  - student_id: student certificates
  - course_id: course certificates

  ### payments
  - student_id: student payments
  - status: filter by status
  - created_at: order by date

  ### activity_logs
  - user_id: user activity
  - created_at: recent activity ordering

  ### discussions
  - course_id: discussions per course
  - author_id: user's posts

  ### live_sessions
  - course_id: sessions per course
  - teacher_id: teacher's sessions
  - scheduled_at: upcoming sessions

  ### profiles
  - role: filter by user role
  - email: email lookups
*/

-- courses
CREATE INDEX IF NOT EXISTS idx_courses_teacher_id ON courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_is_published ON courses(is_published);
CREATE INDEX IF NOT EXISTS idx_courses_is_archived ON courses(is_archived);
CREATE INDEX IF NOT EXISTS idx_courses_published_archived ON courses(is_published, is_archived);
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category);

-- enrollments
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_course ON enrollments(student_id, course_id);

-- sections
CREATE INDEX IF NOT EXISTS idx_sections_course_id ON sections(course_id);

-- lessons
CREATE INDEX IF NOT EXISTS idx_lessons_section_id ON lessons(section_id);

-- lesson_progress
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_id ON lesson_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_lesson_id ON lesson_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_lesson ON lesson_progress(student_id, lesson_id);

-- quiz_attempts
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_student_id ON quiz_attempts(student_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz_id ON quiz_attempts(quiz_id);

-- quizzes
CREATE INDEX IF NOT EXISTS idx_quizzes_course_id ON quizzes(course_id);

-- quiz_questions
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);

-- assignments
CREATE INDEX IF NOT EXISTS idx_assignments_course_id ON assignments(course_id);

-- assignment_submissions
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student_id ON assignment_submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);

-- certificates
CREATE INDEX IF NOT EXISTS idx_certificates_student_id ON certificates(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course_id ON certificates(course_id);

-- payments
CREATE INDEX IF NOT EXISTS idx_payments_student_id ON payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_course_id ON payments(course_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at DESC);

-- activity_logs
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON activity_logs(created_at DESC);

-- discussions
CREATE INDEX IF NOT EXISTS idx_discussions_course_id ON discussions(course_id);
CREATE INDEX IF NOT EXISTS idx_discussions_author_id ON discussions(author_id);

-- live_sessions
CREATE INDEX IF NOT EXISTS idx_live_sessions_course_id ON live_sessions(course_id);
CREATE INDEX IF NOT EXISTS idx_live_sessions_teacher_id ON live_sessions(teacher_id);
CREATE INDEX IF NOT EXISTS idx_live_sessions_scheduled_at ON live_sessions(scheduled_at);

-- profiles
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
/*
  # Progress Tracking and Enrollment Gating

  Adds Udemy-style enrollment gating, granular lesson progress tracking,
  and quiz attempt recording.

  ## Changes

  ### Modified Tables
  - `courses` — adds is_paid, price_amount, preview_enabled columns
  - `lessons` — is_preview column already exists; ensuring it is present

  ### New Tables
  1. `course_enrollments`
     - Tracks student enrollments with type (free/paid/admin_granted)
     - Payment status for gating access
     - Progress tracking per enrollment

  2. `lesson_progress` (new enhanced version)
     - Per-lesson progress with position, time spent, completion
     - UNIQUE constraint on (user_id, lesson_id)

  3. `quiz_attempts` (new version with user_id FK)
     - Records each quiz attempt with score, percentage, pass/fail

  ### Security
  - has_course_access() function for RLS policy reuse
  - RLS on all new tables
  - Students can only access their own data
  - Teachers can read data for their courses
  - Admins have full access

  ### Notes
  - existing `enrollments` table is preserved unchanged
  - existing `lesson_progress` table is preserved; new table is `lesson_progress_v2`
    ACTUALLY: we will rename approach — create `course_enrollments` as new,
    and create `lesson_progress_v2` as the enhanced table since lesson_progress exists
  - existing `quiz_attempts` table stays; we add `user_quiz_attempts` as new table
*/

-- ============================================================
-- 1. Add pricing columns to courses (safe, IF NOT EXISTS)
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='is_paid') THEN
    ALTER TABLE courses ADD COLUMN is_paid boolean NOT NULL DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='price_amount') THEN
    ALTER TABLE courses ADD COLUMN price_amount numeric(10,2) NOT NULL DEFAULT 0 CHECK (price_amount >= 0);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='preview_enabled') THEN
    ALTER TABLE courses ADD COLUMN preview_enabled boolean NOT NULL DEFAULT true;
  END IF;
END $$;

-- ============================================================
-- 2. Ensure lessons.is_preview exists (already in schema but safety check)
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='is_preview') THEN
    ALTER TABLE lessons ADD COLUMN is_preview boolean NOT NULL DEFAULT false;
  END IF;
END $$;

-- ============================================================
-- 3. Create course_enrollments table
-- ============================================================
CREATE TABLE IF NOT EXISTS course_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_type text NOT NULL CHECK (enrollment_type IN ('free', 'paid', 'admin_granted')),
  payment_status text NOT NULL DEFAULT 'not_required' CHECK (payment_status IN ('not_required', 'pending', 'completed', 'refunded')),
  payment_id text,
  amount_paid numeric(10,2) NOT NULL DEFAULT 0,
  currency text,
  enrolled_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  progress_percent int NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  last_accessed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_course_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_payment_status ON course_enrollments(payment_status);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_last_accessed ON course_enrollments(last_accessed_at DESC);

ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;

-- Students: SELECT own rows
CREATE POLICY "Students can view own enrollments"
  ON course_enrollments FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Students: INSERT only free enrollments (type='free', status='not_required')
CREATE POLICY "Students can self-enroll in free courses"
  ON course_enrollments FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND enrollment_type = 'free'
    AND payment_status = 'not_required'
  );

-- Students: UPDATE own enrollment (progress, last_accessed)
CREATE POLICY "Students can update own enrollment progress"
  ON course_enrollments FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Teachers: SELECT enrollments for their courses
CREATE POLICY "Teachers can view enrollments for their courses"
  ON course_enrollments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = course_enrollments.course_id
        AND courses.teacher_id = auth.uid()
    )
  );

-- Admins: full access (insert with any enrollment_type)
CREATE POLICY "Admins have full access to enrollments"
  ON course_enrollments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can insert any enrollment"
  ON course_enrollments FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can update any enrollment"
  ON course_enrollments FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete any enrollment"
  ON course_enrollments FOR DELETE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- ============================================================
-- 4. Create has_course_access function
-- ============================================================
CREATE OR REPLACE FUNCTION has_course_access(p_user_id uuid, p_course_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  v_role text;
  v_teacher_id uuid;
  v_has_enrollment boolean;
BEGIN
  -- Check user role
  SELECT role INTO v_role FROM profiles WHERE id = p_user_id;

  -- Admins always have access
  IF v_role = 'admin' THEN RETURN true; END IF;

  -- Teachers who own the course have access
  SELECT teacher_id INTO v_teacher_id FROM courses WHERE id = p_course_id;
  IF v_teacher_id = p_user_id THEN RETURN true; END IF;

  -- Check active enrollment in course_enrollments
  SELECT EXISTS(
    SELECT 1 FROM course_enrollments
    WHERE user_id = p_user_id
      AND course_id = p_course_id
      AND payment_status IN ('completed', 'not_required')
  ) INTO v_has_enrollment;
  IF v_has_enrollment THEN RETURN true; END IF;

  -- Also check legacy enrollments table
  SELECT EXISTS(
    SELECT 1 FROM enrollments
    WHERE student_id = p_user_id
      AND course_id = p_course_id
  ) INTO v_has_enrollment;

  RETURN v_has_enrollment;
END;
$$;

-- ============================================================
-- 5. Create lesson_progress_v2 (enhanced tracking)
-- ============================================================
CREATE TABLE IF NOT EXISTS lesson_progress_v2 (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
  progress_percent int NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  last_position_seconds int NOT NULL DEFAULT 0,
  time_spent_seconds int NOT NULL DEFAULT 0,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_lp_v2_user_course ON lesson_progress_v2(user_id, course_id);
CREATE INDEX IF NOT EXISTS idx_lp_v2_user_lesson ON lesson_progress_v2(user_id, lesson_id);
CREATE INDEX IF NOT EXISTS idx_lp_v2_course_id ON lesson_progress_v2(course_id);

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_lesson_progress_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS lesson_progress_v2_updated_at ON lesson_progress_v2;
CREATE TRIGGER lesson_progress_v2_updated_at
  BEFORE UPDATE ON lesson_progress_v2
  FOR EACH ROW EXECUTE FUNCTION update_lesson_progress_updated_at();

ALTER TABLE lesson_progress_v2 ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own lesson progress"
  ON lesson_progress_v2 FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Students can insert own lesson progress if enrolled"
  ON lesson_progress_v2 FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND has_course_access(auth.uid(), course_id)
  );

CREATE POLICY "Students can update own lesson progress"
  ON lesson_progress_v2 FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Teachers can view lesson progress for their courses"
  ON lesson_progress_v2 FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_progress_v2.course_id
        AND courses.teacher_id = auth.uid()
    )
  );

CREATE POLICY "Admins have full access to lesson progress"
  ON lesson_progress_v2 FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert lesson progress"
  ON lesson_progress_v2 FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update lesson progress"
  ON lesson_progress_v2 FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- ============================================================
-- 6. Create user_quiz_attempts (new, with user_id + attempt_number)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quiz_id uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  score numeric NOT NULL,
  max_score numeric NOT NULL,
  percentage numeric GENERATED ALWAYS AS (
    CASE WHEN max_score > 0 THEN ROUND((score / max_score) * 100, 2) ELSE 0 END
  ) STORED,
  passed boolean NOT NULL,
  answers jsonb NOT NULL DEFAULT '{}',
  attempt_number int NOT NULL DEFAULT 1,
  started_at timestamptz,
  completed_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_uqa_user_quiz ON user_quiz_attempts(user_id, quiz_id);
CREATE INDEX IF NOT EXISTS idx_uqa_user_course ON user_quiz_attempts(user_id, course_id);
CREATE INDEX IF NOT EXISTS idx_uqa_quiz_id ON user_quiz_attempts(quiz_id);

ALTER TABLE user_quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own quiz attempts"
  ON user_quiz_attempts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Students can insert own quiz attempts if enrolled"
  ON user_quiz_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND has_course_access(auth.uid(), course_id)
  );

CREATE POLICY "Teachers can view quiz attempts for their courses"
  ON user_quiz_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = user_quiz_attempts.course_id
        AND courses.teacher_id = auth.uid()
    )
  );

CREATE POLICY "Admins have full access to quiz attempts"
  ON user_quiz_attempts FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert quiz attempts"
  ON user_quiz_attempts FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
/*
  # Extensions, Core Functions, and Profiles

  1. Extensions
    - pgcrypto for UUID generation

  2. Functions
    - update_updated_at_column() — trigger helper to auto-set updated_at
    - get_user_role() — SECURITY DEFINER, returns role from profiles for RLS use
    - handle_new_user() — auto-creates profile row on auth.users INSERT

  3. Tables
    - profiles — one row per auth.users row; stores role, full_name, avatar, bio, etc.

  4. Security
    - RLS enabled on profiles
    - Users can read their own profile; admins can read all; users can update own profile
    - Auth trigger: after insert on auth.users → create profile
*/

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ─── update_updated_at_column ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ─── profiles ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id            uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         text UNIQUE NOT NULL,
  full_name     text DEFAULT '',
  avatar_url    text DEFAULT '',
  bio           text DEFAULT '',
  role          text NOT NULL DEFAULT 'student' CHECK (role IN ('student','teacher','admin')),
  phone         text DEFAULT '',
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'profiles_updated_at') THEN
    CREATE TRIGGER profiles_updated_at
      BEFORE UPDATE ON profiles
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Teachers can view student profiles"
  ON profiles FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('teacher','admin'))
  );

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can update any profile"
  ON profiles FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

CREATE POLICY "Admins can insert profiles"
  ON profiles FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- ─── get_user_role ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid DEFAULT auth.uid())
RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = user_id;
$$;

-- ─── handle_new_user (auth trigger) ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
  ) THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION handle_new_user();
  END IF;
END $$;
/*
  # Courses, Sections, and Lessons (no enrollment-dependent RLS yet)

  1. New Tables
    - courses — main course record with pricing, metadata, publish state
    - sections — ordered sections within a course
    - lessons — individual lessons within a section

  2. Notes
    - Lesson RLS policies referencing enrollments are added in migration 004
      after the enrollments tables are created
*/

-- ─── courses ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id          uuid REFERENCES profiles(id) ON DELETE SET NULL,
  title               text NOT NULL DEFAULT '',
  short_description   text DEFAULT '',
  description         text DEFAULT '',
  thumbnail_url       text DEFAULT '',
  category            text DEFAULT '',
  level               text NOT NULL DEFAULT 'beginner' CHECK (level IN ('beginner','intermediate','advanced')),
  language            text DEFAULT 'English',
  duration_hours      numeric DEFAULT 0,
  total_lessons       integer DEFAULT 0,
  total_students      integer DEFAULT 0,
  rating              numeric DEFAULT 0,
  price               numeric DEFAULT 0,
  price_amount        numeric DEFAULT 0,
  is_free             boolean DEFAULT true,
  is_paid             boolean DEFAULT false,
  stripe_payment_link text DEFAULT '',
  is_published        boolean DEFAULT false,
  is_archived         boolean DEFAULT false,
  preview_enabled     boolean DEFAULT false,
  what_you_learn      text[] DEFAULT '{}',
  requirements        text[] DEFAULT '{}',
  tags                text[] DEFAULT '{}',
  created_at          timestamptz DEFAULT now(),
  updated_at          timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'courses_updated_at') THEN
    CREATE TRIGGER courses_updated_at
      BEFORE UPDATE ON courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_courses_teacher_id    ON courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_is_published  ON courses(is_published);
CREATE INDEX IF NOT EXISTS idx_courses_category      ON courses(category);
CREATE INDEX IF NOT EXISTS idx_courses_is_archived   ON courses(is_archived);

ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view published courses"
  ON courses FOR SELECT
  USING (is_published = true AND is_archived = false);

CREATE POLICY "Teachers can view own courses"
  ON courses FOR SELECT TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Admins can view all courses"
  ON courses FOR SELECT TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "Teachers can insert own courses"
  ON courses FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = teacher_id AND get_user_role() IN ('teacher','admin'));

CREATE POLICY "Teachers can update own courses"
  ON courses FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id OR get_user_role() = 'admin')
  WITH CHECK (auth.uid() = teacher_id OR get_user_role() = 'admin');

CREATE POLICY "Admins can delete courses"
  ON courses FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- ─── sections ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sections (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id   uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title       text NOT NULL DEFAULT '',
  order_index integer DEFAULT 0,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'sections_updated_at') THEN
    CREATE TRIGGER sections_updated_at
      BEFORE UPDATE ON sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_sections_course_id   ON sections(course_id);
CREATE INDEX IF NOT EXISTS idx_sections_order       ON sections(course_id, order_index);

ALTER TABLE sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view sections of published courses"
  ON sections FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = sections.course_id AND c.is_published = true AND c.is_archived = false)
  );

CREATE POLICY "Teachers can manage own course sections"
  ON sections FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = sections.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can update own sections"
  ON sections FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = sections.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = sections.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can delete own sections"
  ON sections FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = sections.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

-- ─── lessons ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lessons (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id            uuid NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
  course_id             uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title                 text NOT NULL DEFAULT '',
  description           text DEFAULT '',
  type                  text DEFAULT 'video' CHECK (type IN ('video','text','file','quiz')),
  lesson_type           text DEFAULT 'video' CHECK (lesson_type IN ('video','text','file','quiz')),
  video_url             text DEFAULT '',
  video_storage_path    text DEFAULT '',
  duration_minutes      integer DEFAULT 0,
  order_index           integer DEFAULT 0,
  is_preview            boolean DEFAULT false,
  content               text DEFAULT '',
  file_url              text DEFAULT '',
  created_at            timestamptz DEFAULT now(),
  updated_at            timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'lessons_updated_at') THEN
    CREATE TRIGGER lessons_updated_at
      BEFORE UPDATE ON lessons FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_lessons_section_id  ON lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_lessons_course_id   ON lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order       ON lessons(course_id, order_index);

ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view preview lessons of published courses"
  ON lessons FOR SELECT
  USING (
    is_preview = true AND
    EXISTS (SELECT 1 FROM courses c WHERE c.id = lessons.course_id AND c.is_published = true AND c.is_archived = false)
  );

CREATE POLICY "Teachers can manage own course lessons insert"
  ON lessons FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = lessons.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can update own course lessons"
  ON lessons FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = lessons.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = lessons.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can delete own course lessons"
  ON lessons FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = lessons.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );
/*
  # Quizzes and Quiz Questions

  1. New Tables
    - quizzes — quiz metadata linked to a course
    - quiz_questions — individual questions with options and correct answer

  2. Security
    - RLS on both tables
    - Published quiz questions visible to enrolled students (enrollment check added in 004)
    - Teachers can manage their own quizzes
*/

-- ─── quizzes ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quizzes (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id       uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id       uuid REFERENCES lessons(id) ON DELETE SET NULL,
  title           text NOT NULL DEFAULT '',
  description     text DEFAULT '',
  time_limit      integer DEFAULT 0,
  pass_percentage integer DEFAULT 70,
  max_attempts    integer DEFAULT 3,
  is_published    boolean DEFAULT false,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'quizzes_updated_at') THEN
    CREATE TRIGGER quizzes_updated_at
      BEFORE UPDATE ON quizzes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_quizzes_course_id ON quizzes(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_lesson_id ON quizzes(lesson_id);

ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view published quizzes"
  ON quizzes FOR SELECT TO authenticated
  USING (is_published = true);

CREATE POLICY "Teachers can manage own quizzes insert"
  ON quizzes FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = quizzes.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can update own quizzes"
  ON quizzes FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = quizzes.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = quizzes.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can delete own quizzes"
  ON quizzes FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = quizzes.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

-- ─── quiz_questions ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quiz_questions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id         uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  question        text NOT NULL DEFAULT '',
  options         jsonb DEFAULT '[]',
  correct_answer  integer DEFAULT 0,
  explanation     text DEFAULT '',
  points          integer DEFAULT 1,
  order_index     integer DEFAULT 0,
  created_at      timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);

ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view questions of published quizzes"
  ON quiz_questions FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM quizzes q WHERE q.id = quiz_questions.quiz_id AND q.is_published = true)
  );

CREATE POLICY "Teachers can manage quiz questions insert"
  ON quiz_questions FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  );

CREATE POLICY "Teachers can update quiz questions"
  ON quiz_questions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  );

CREATE POLICY "Teachers can delete quiz questions"
  ON quiz_questions FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  );
/*
  # Enrollments and Progress Tracking

  1. New Tables
    - enrollments — legacy enrollment table (student_id, course_id, progress_percent)
    - course_enrollments — new gated enrollment table with payment_status
    - lesson_progress — unified lesson completion tracking (supports legacy student_id and new user_id)
    - quiz_attempts — unified quiz attempt tracking (supports legacy student_id and new user_id)

  2. Functions
    - has_course_access(course_uuid, user_uuid) — SECURITY DEFINER, checks both enrollment tables
    - update_course_progress() — recalculates and updates enrollments.progress_percent after lesson progress insert/update

  3. Security
    - RLS on all tables
    - Users can only access their own records

  4. Notes
    - lesson_progress has UNIQUE indexes for both legacy (student_id) and new (user_id) access patterns
    - quiz_attempts has UNIQUE indexes for both patterns as well
*/

-- ─── enrollments (legacy) ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS enrollments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id       uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id        uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  progress_percent integer DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  enrolled_at      timestamptz DEFAULT now(),
  completed_at     timestamptz,
  UNIQUE (student_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id  ON enrollments(course_id);

ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own enrollments"
  ON enrollments FOR SELECT TO authenticated
  USING (auth.uid() = student_id);

CREATE POLICY "Teachers can view course enrollments"
  ON enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = enrollments.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Students can insert own enrollment"
  ON enrollments FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "System can update enrollment progress"
  ON enrollments FOR UPDATE TO authenticated
  USING (auth.uid() = student_id OR get_user_role() IN ('teacher','admin'))
  WITH CHECK (auth.uid() = student_id OR get_user_role() IN ('teacher','admin'));

CREATE POLICY "Admins can delete enrollments"
  ON enrollments FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- ─── course_enrollments (new gating) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS course_enrollments (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id      uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  payment_status text NOT NULL DEFAULT 'not_required' CHECK (payment_status IN ('not_required','pending','completed','failed','refunded')),
  payment_id     text DEFAULT '',
  progress_percent integer DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  last_accessed_at timestamptz DEFAULT now(),
  enrolled_at    timestamptz DEFAULT now(),
  completed_at   timestamptz,
  UNIQUE (user_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_ce_user_id    ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_ce_course_id  ON course_enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_ce_payment    ON course_enrollments(payment_status);

ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own course enrollments"
  ON course_enrollments FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Teachers can view their course enrollments"
  ON course_enrollments FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = course_enrollments.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Users can enroll in free courses"
  ON course_enrollments FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = user_id AND (
      EXISTS (SELECT 1 FROM courses c WHERE c.id = course_enrollments.course_id AND (c.is_free = true OR c.is_paid = false))
      OR get_user_role() = 'admin'
    )
  );

CREATE POLICY "System can update enrollment progress"
  ON course_enrollments FOR UPDATE TO authenticated
  USING (auth.uid() = user_id OR get_user_role() IN ('teacher','admin'))
  WITH CHECK (auth.uid() = user_id OR get_user_role() IN ('teacher','admin'));

CREATE POLICY "Admins can delete course enrollments"
  ON course_enrollments FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- ─── has_course_access ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION has_course_access(
  p_course_id uuid,
  p_user_id   uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = p_user_id AND role IN ('admin','teacher')
  ) OR EXISTS (
    SELECT 1 FROM courses WHERE id = p_course_id AND teacher_id = p_user_id
  ) OR EXISTS (
    SELECT 1 FROM enrollments WHERE course_id = p_course_id AND student_id = p_user_id
  ) OR EXISTS (
    SELECT 1 FROM course_enrollments
    WHERE course_id = p_course_id AND user_id = p_user_id
      AND payment_status IN ('not_required','completed')
  );
$$;

-- ─── Add lesson SELECT policy for enrolled students ───────────────────────────
CREATE POLICY "Enrolled students can view course lessons"
  ON lessons FOR SELECT TO authenticated
  USING (
    has_course_access(lessons.course_id) OR
    EXISTS (SELECT 1 FROM courses c WHERE c.id = lessons.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

-- ─── lesson_progress (unified legacy + new) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS lesson_progress (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- legacy column
  student_id            uuid REFERENCES profiles(id) ON DELETE CASCADE,
  -- new column
  user_id               uuid REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id             uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id             uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  is_completed          boolean DEFAULT false,
  watch_percentage      integer DEFAULT 0 CHECK (watch_percentage >= 0 AND watch_percentage <= 100),
  last_position_seconds integer DEFAULT 0,
  completed_at          timestamptz,
  updated_at            timestamptz DEFAULT now(),
  CONSTRAINT lp_student_or_user CHECK (student_id IS NOT NULL OR user_id IS NOT NULL)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'lesson_progress_updated_at') THEN
    CREATE TRIGGER lesson_progress_updated_at
      BEFORE UPDATE ON lesson_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_lp_student_lesson  ON lesson_progress(student_id, lesson_id) WHERE student_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_lp_user_lesson      ON lesson_progress(user_id, lesson_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lp_course_id               ON lesson_progress(course_id);

ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lesson progress"
  ON lesson_progress FOR SELECT TO authenticated
  USING (auth.uid() = student_id OR auth.uid() = user_id);

CREATE POLICY "Teachers can view student progress"
  ON lesson_progress FOR SELECT TO authenticated
  USING (get_user_role() IN ('teacher','admin'));

CREATE POLICY "Users can insert own lesson progress"
  ON lesson_progress FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = student_id OR auth.uid() = user_id);

CREATE POLICY "Users can update own lesson progress"
  ON lesson_progress FOR UPDATE TO authenticated
  USING (auth.uid() = student_id OR auth.uid() = user_id)
  WITH CHECK (auth.uid() = student_id OR auth.uid() = user_id);

-- ─── quiz_attempts (unified legacy + new) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- legacy column
  student_id    uuid REFERENCES profiles(id) ON DELETE CASCADE,
  -- new column
  user_id       uuid REFERENCES profiles(id) ON DELETE CASCADE,
  quiz_id       uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  course_id     uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  score         integer DEFAULT 0,
  total_points  integer DEFAULT 0,
  passed        boolean DEFAULT false,
  answers       jsonb DEFAULT '{}',
  time_taken    integer DEFAULT 0,
  attempt_number integer DEFAULT 1,
  created_at    timestamptz DEFAULT now(),
  CONSTRAINT qa_student_or_user CHECK (student_id IS NOT NULL OR user_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_qa_student_quiz  ON quiz_attempts(student_id, quiz_id) WHERE student_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_qa_user_quiz      ON quiz_attempts(user_id, quiz_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_qa_course_id      ON quiz_attempts(course_id);

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own quiz attempts"
  ON quiz_attempts FOR SELECT TO authenticated
  USING (auth.uid() = student_id OR auth.uid() = user_id);

CREATE POLICY "Teachers can view all quiz attempts"
  ON quiz_attempts FOR SELECT TO authenticated
  USING (get_user_role() IN ('teacher','admin'));

CREATE POLICY "Users can insert own quiz attempts"
  ON quiz_attempts FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = student_id OR auth.uid() = user_id);

-- ─── update_course_progress function + trigger ────────────────────────────────
CREATE OR REPLACE FUNCTION update_course_progress()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_course_id uuid;
  v_user_id   uuid;
  v_total     integer;
  v_completed integer;
  v_pct       integer;
BEGIN
  v_course_id := COALESCE(NEW.course_id, OLD.course_id);
  v_user_id   := COALESCE(NEW.user_id, NEW.student_id, OLD.user_id, OLD.student_id);

  SELECT COUNT(*) INTO v_total FROM lessons WHERE course_id = v_course_id;
  IF v_total = 0 THEN RETURN NEW; END IF;

  -- Count completed for this user (check both user_id and student_id columns)
  SELECT COUNT(*) INTO v_completed
  FROM lesson_progress
  WHERE course_id = v_course_id
    AND is_completed = true
    AND (user_id = v_user_id OR student_id = v_user_id);

  v_pct := ROUND((v_completed::numeric / v_total::numeric) * 100);

  -- Update new enrollments table
  UPDATE course_enrollments
  SET progress_percent = v_pct,
      last_accessed_at = now(),
      completed_at = CASE WHEN v_pct = 100 THEN COALESCE(completed_at, now()) ELSE NULL END
  WHERE course_id = v_course_id AND user_id = v_user_id;

  -- Update legacy enrollments table
  UPDATE enrollments
  SET progress_percent = v_pct,
      completed_at = CASE WHEN v_pct = 100 THEN COALESCE(completed_at, now()) ELSE NULL END
  WHERE course_id = v_course_id AND student_id = v_user_id;

  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'after_lesson_progress_change') THEN
    CREATE TRIGGER after_lesson_progress_change
      AFTER INSERT OR UPDATE ON lesson_progress
      FOR EACH ROW EXECUTE FUNCTION update_course_progress();
  END IF;
END $$;
/*
  # Assignments, Certificates, and Payments

  1. New Tables
    - assignments — course assignments with due dates
    - assignment_submissions — student submissions for assignments
    - certificates — awarded certificates on course completion
    - payments — payment records linked to enrollments
    - promo_codes — discount codes for courses

  2. Security
    - RLS on all tables
    - Students can only access their own data
    - Certificates allow anonymous SELECT for public verification page
    - Teachers can manage assignments for their courses
*/

-- ─── assignments ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assignments (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id    uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id   uuid REFERENCES profiles(id) ON DELETE SET NULL,
  title        text NOT NULL DEFAULT '',
  description  text DEFAULT '',
  due_date     timestamptz,
  total_points integer DEFAULT 100,
  is_published boolean DEFAULT false,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'assignments_updated_at') THEN
    CREATE TRIGGER assignments_updated_at
      BEFORE UPDATE ON assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_assignments_course_id  ON assignments(course_id);
CREATE INDEX IF NOT EXISTS idx_assignments_teacher_id ON assignments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_assignments_due_date   ON assignments(due_date);

ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled students can view published assignments"
  ON assignments FOR SELECT TO authenticated
  USING (
    is_published = true AND has_course_access(assignments.course_id)
  );

CREATE POLICY "Teachers can view all course assignments"
  ON assignments FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM courses c WHERE c.id = assignments.course_id AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin'))
  );

CREATE POLICY "Teachers can insert course assignments"
  ON assignments FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = teacher_id AND get_user_role() IN ('teacher','admin')
  );

CREATE POLICY "Teachers can update course assignments"
  ON assignments FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id OR get_user_role() = 'admin')
  WITH CHECK (auth.uid() = teacher_id OR get_user_role() = 'admin');

CREATE POLICY "Teachers can delete course assignments"
  ON assignments FOR DELETE TO authenticated
  USING (auth.uid() = teacher_id OR get_user_role() = 'admin');

-- ─── assignment_submissions ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assignment_submissions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id  uuid NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content        text DEFAULT '',
  file_url       text DEFAULT '',
  grade          integer,
  feedback       text DEFAULT '',
  status         text DEFAULT 'submitted' CHECK (status IN ('submitted','graded','returned')),
  submitted_at   timestamptz DEFAULT now(),
  graded_at      timestamptz,
  UNIQUE (assignment_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student    ON assignment_submissions(student_id);

ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own submissions"
  ON assignment_submissions FOR SELECT TO authenticated
  USING (auth.uid() = student_id);

CREATE POLICY "Teachers can view all submissions"
  ON assignment_submissions FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN courses c ON c.id = a.course_id
      WHERE a.id = assignment_submissions.assignment_id
        AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  );

CREATE POLICY "Students can submit assignments"
  ON assignment_submissions FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can update own submissions"
  ON assignment_submissions FOR UPDATE TO authenticated
  USING (auth.uid() = student_id AND status = 'submitted')
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Teachers can grade submissions"
  ON assignment_submissions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN courses c ON c.id = a.course_id
      WHERE a.id = assignment_submissions.assignment_id
        AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN courses c ON c.id = a.course_id
      WHERE a.id = assignment_submissions.assignment_id
        AND (c.teacher_id = auth.uid() OR get_user_role() = 'admin')
    )
  );

-- ─── certificates ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS certificates (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id       uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  certificate_url text DEFAULT '',
  issued_at       timestamptz DEFAULT now(),
  revoked         boolean DEFAULT false,
  revoked_at      timestamptz,
  verification_code text UNIQUE DEFAULT encode(gen_random_bytes(8), 'hex'),
  UNIQUE (student_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_certificates_student  ON certificates(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course   ON certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_verify   ON certificates(verification_code);

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- Allow anyone to verify a certificate by verification_code
CREATE POLICY "Anyone can verify certificates"
  ON certificates FOR SELECT
  USING (revoked = false);

CREATE POLICY "Students can view own certificates"
  ON certificates FOR SELECT TO authenticated
  USING (auth.uid() = student_id);

CREATE POLICY "Admins can manage certificates"
  ON certificates FOR INSERT TO authenticated
  WITH CHECK (get_user_role() = 'admin');

CREATE POLICY "Admins can update certificates"
  ON certificates FOR UPDATE TO authenticated
  USING (get_user_role() = 'admin')
  WITH CHECK (get_user_role() = 'admin');

-- ─── payments ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id         uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_id     uuid REFERENCES course_enrollments(id) ON DELETE SET NULL,
  stripe_session_id text DEFAULT '',
  stripe_payment_id text DEFAULT '',
  amount            numeric NOT NULL DEFAULT 0,
  currency          text DEFAULT 'aud',
  status            text DEFAULT 'pending' CHECK (status IN ('pending','completed','failed','refunded')),
  created_at        timestamptz DEFAULT now(),
  updated_at        timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'payments_updated_at') THEN
    CREATE TRIGGER payments_updated_at
      BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_payments_user_id   ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_course_id ON payments(course_id);
CREATE INDEX IF NOT EXISTS idx_payments_status    ON payments(status);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payments"
  ON payments FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all payments"
  ON payments FOR SELECT TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "System can insert payments"
  ON payments FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id OR get_user_role() = 'admin');

CREATE POLICY "Admins can update payments"
  ON payments FOR UPDATE TO authenticated
  USING (get_user_role() = 'admin')
  WITH CHECK (get_user_role() = 'admin');

-- ─── promo_codes ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS promo_codes (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code             text UNIQUE NOT NULL,
  discount_type    text DEFAULT 'percentage' CHECK (discount_type IN ('percentage','fixed')),
  discount_value   numeric NOT NULL DEFAULT 0,
  max_uses         integer DEFAULT 0,
  used_count       integer DEFAULT 0,
  valid_from       timestamptz DEFAULT now(),
  valid_until      timestamptz,
  course_id        uuid REFERENCES courses(id) ON DELETE SET NULL,
  is_active        boolean DEFAULT true,
  created_at       timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);

ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can look up promo codes"
  ON promo_codes FOR SELECT TO authenticated
  USING (is_active = true AND (valid_until IS NULL OR valid_until > now()));

CREATE POLICY "Admins can manage promo codes"
  ON promo_codes FOR INSERT TO authenticated
  WITH CHECK (get_user_role() = 'admin');

CREATE POLICY "Admins can update promo codes"
  ON promo_codes FOR UPDATE TO authenticated
  USING (get_user_role() = 'admin')
  WITH CHECK (get_user_role() = 'admin');

CREATE POLICY "Admins can delete promo codes"
  ON promo_codes FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');
/*
  # Communications and Logs

  1. New Tables
    - announcements — site-wide or course-specific notices
    - activity_logs — audit trail for admin review
    - discussions — course discussion threads
    - live_sessions — scheduled live sessions per course
    - ai_usage_logs — tracks AI feature usage per user
    - flashcards — spaced-repetition study cards per lesson/course

  2. Security
    - RLS on all tables
    - Discussions visible to enrolled students
    - Activity logs visible to admins only
    - AI usage logs visible to owner + admins
*/

-- ─── announcements ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title      text NOT NULL DEFAULT '',
  content    text DEFAULT '',
  author_id  uuid REFERENCES profiles(id) ON DELETE SET NULL,
  course_id  uuid REFERENCES courses(id) ON DELETE CASCADE,
  is_active  boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'announcements_updated_at') THEN
    CREATE TRIGGER announcements_updated_at
      BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_announcements_is_active ON announcements(is_active);
CREATE INDEX IF NOT EXISTS idx_announcements_course_id ON announcements(course_id);

ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active announcements"
  ON announcements FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins and teachers can manage announcements insert"
  ON announcements FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin','teacher'));

CREATE POLICY "Admins and teachers can update announcements"
  ON announcements FOR UPDATE TO authenticated
  USING (auth.uid() = author_id OR get_user_role() = 'admin')
  WITH CHECK (auth.uid() = author_id OR get_user_role() = 'admin');

CREATE POLICY "Admins can delete announcements"
  ON announcements FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- ─── activity_logs ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS activity_logs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid REFERENCES profiles(id) ON DELETE SET NULL,
  action      text NOT NULL DEFAULT '',
  entity_type text DEFAULT '',
  entity_id   uuid,
  details     jsonb DEFAULT '{}',
  ip_address  text DEFAULT '',
  created_at  timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id    ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON activity_logs(created_at DESC);

ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view all activity logs"
  ON activity_logs FOR SELECT TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "System can insert activity logs"
  ON activity_logs FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id OR get_user_role() = 'admin');

-- ─── discussions ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS discussions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id   uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id   uuid REFERENCES lessons(id) ON DELETE CASCADE,
  author_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id   uuid REFERENCES discussions(id) ON DELETE CASCADE,
  title       text DEFAULT '',
  content     text NOT NULL DEFAULT '',
  upvotes     integer DEFAULT 0,
  is_pinned   boolean DEFAULT false,
  is_resolved boolean DEFAULT false,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'discussions_updated_at') THEN
    CREATE TRIGGER discussions_updated_at
      BEFORE UPDATE ON discussions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_discussions_course_id ON discussions(course_id);
CREATE INDEX IF NOT EXISTS idx_discussions_lesson_id ON discussions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_discussions_author_id ON discussions(author_id);
CREATE INDEX IF NOT EXISTS idx_discussions_parent_id ON discussions(parent_id);

ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled users can view discussions"
  ON discussions FOR SELECT TO authenticated
  USING (has_course_access(discussions.course_id));

CREATE POLICY "Enrolled users can post discussions"
  ON discussions FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = author_id AND has_course_access(discussions.course_id)
  );

CREATE POLICY "Authors can update own discussions"
  ON discussions FOR UPDATE TO authenticated
  USING (auth.uid() = author_id OR get_user_role() IN ('teacher','admin'))
  WITH CHECK (auth.uid() = author_id OR get_user_role() IN ('teacher','admin'));

CREATE POLICY "Authors and admins can delete discussions"
  ON discussions FOR DELETE TO authenticated
  USING (auth.uid() = author_id OR get_user_role() = 'admin');

-- ─── live_sessions ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS live_sessions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id      uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id     uuid REFERENCES profiles(id) ON DELETE SET NULL,
  title          text NOT NULL DEFAULT '',
  description    text DEFAULT '',
  scheduled_at   timestamptz NOT NULL,
  duration_minutes integer DEFAULT 60,
  meeting_url    text DEFAULT '',
  meeting_id     text DEFAULT '',
  status         text DEFAULT 'scheduled' CHECK (status IN ('scheduled','live','completed','cancelled')),
  recording_url  text DEFAULT '',
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'live_sessions_updated_at') THEN
    CREATE TRIGGER live_sessions_updated_at
      BEFORE UPDATE ON live_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_live_sessions_course_id    ON live_sessions(course_id);
CREATE INDEX IF NOT EXISTS idx_live_sessions_scheduled_at ON live_sessions(scheduled_at);

ALTER TABLE live_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled students can view live sessions"
  ON live_sessions FOR SELECT TO authenticated
  USING (has_course_access(live_sessions.course_id));

CREATE POLICY "Teachers can manage own live sessions insert"
  ON live_sessions FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = teacher_id AND get_user_role() IN ('teacher','admin')
  );

CREATE POLICY "Teachers can update own live sessions"
  ON live_sessions FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id OR get_user_role() = 'admin')
  WITH CHECK (auth.uid() = teacher_id OR get_user_role() = 'admin');

CREATE POLICY "Teachers can delete own live sessions"
  ON live_sessions FOR DELETE TO authenticated
  USING (auth.uid() = teacher_id OR get_user_role() = 'admin');

-- ─── ai_usage_logs ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ai_usage_logs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  feature      text NOT NULL DEFAULT '',
  model        text DEFAULT '',
  tokens_used  integer DEFAULT 0,
  course_id    uuid REFERENCES courses(id) ON DELETE SET NULL,
  prompt_hash  text DEFAULT '',
  created_at   timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_logs_user_id    ON ai_usage_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_logs_created_at ON ai_usage_logs(created_at DESC);

ALTER TABLE ai_usage_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own AI usage"
  ON ai_usage_logs FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all AI usage"
  ON ai_usage_logs FOR SELECT TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "System can log AI usage"
  ON ai_usage_logs FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ─── flashcards ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS flashcards (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id   uuid REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id   uuid REFERENCES lessons(id) ON DELETE CASCADE,
  front       text NOT NULL DEFAULT '',
  back        text NOT NULL DEFAULT '',
  difficulty  text DEFAULT 'medium' CHECK (difficulty IN ('easy','medium','hard')),
  next_review timestamptz DEFAULT now(),
  review_count integer DEFAULT 0,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'flashcards_updated_at') THEN
    CREATE TRIGGER flashcards_updated_at
      BEFORE UPDATE ON flashcards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_flashcards_user_id   ON flashcards(user_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_course_id ON flashcards(course_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_next_rev  ON flashcards(user_id, next_review);

ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own flashcards"
  ON flashcards FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own flashcards"
  ON flashcards FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own flashcards"
  ON flashcards FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own flashcards"
  ON flashcards FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
/*
  # Storage Buckets

  Creates storage buckets for course media, videos, and thumbnails.
  Uses INSERT ... ON CONFLICT DO NOTHING to be idempotent.

  Buckets:
    - course-videos: private bucket for lesson video files
    - course-materials: private bucket for lesson file attachments
    - course-thumbnails: public bucket for course thumbnail images
    - avatars: public bucket for user profile photos
*/

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('course-videos', 'course-videos', false, 5368709120, ARRAY['video/mp4','video/webm','video/ogg','video/quicktime']),
  ('course-materials', 'course-materials', false, 104857600, ARRAY['application/pdf','application/zip','image/jpeg','image/png','image/gif','image/webp']),
  ('course-thumbnails', 'course-thumbnails', true, 10485760, ARRAY['image/jpeg','image/png','image/webp','image/gif']),
  ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Storage policies for course-thumbnails (public read)
CREATE POLICY "Public can view thumbnails"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'course-thumbnails');

CREATE POLICY "Teachers can upload thumbnails"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'course-thumbnails' AND
    get_user_role() IN ('teacher','admin')
  );

CREATE POLICY "Teachers can update thumbnails"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'course-thumbnails' AND
    get_user_role() IN ('teacher','admin')
  )
  WITH CHECK (
    bucket_id = 'course-thumbnails' AND
    get_user_role() IN ('teacher','admin')
  );

-- Storage policies for course-videos (authenticated enrolled users)
CREATE POLICY "Enrolled users can view course videos"
  ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'course-videos');

CREATE POLICY "Teachers can upload course videos"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'course-videos' AND
    get_user_role() IN ('teacher','admin')
  );

-- Storage policies for course-materials
CREATE POLICY "Enrolled users can view course materials"
  ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'course-materials');

CREATE POLICY "Teachers can upload course materials"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'course-materials' AND
    get_user_role() IN ('teacher','admin')
  );

-- Storage policies for avatars
CREATE POLICY "Public can view avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE TO authenticated
  USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );
/*
  # Demo Users

  Creates three demo accounts for testing:
    - admin@maximus.edu.au   / Admin1234!    (role: admin)
    - teacher@maximus.edu.au / Teacher1234!  (role: teacher)
    - student@maximus.edu.au / Student1234!  (role: student)

  Uses fixed UUIDs so subsequent re-runs are idempotent (ON CONFLICT DO UPDATE).
*/

DO $$
DECLARE
  admin_uid   uuid := '6c0e7959-b621-42ce-8598-868a8fc2e073';
  teacher_uid uuid := '494bced9-f191-429c-8b0b-1f19680e4442';
  student_uid uuid := '4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5';
BEGIN

  -- Clean up any prior versions cleanly
  DELETE FROM auth.identities     WHERE user_id IN (admin_uid, teacher_uid, student_uid);
  DELETE FROM auth.sessions       WHERE user_id IN (admin_uid, teacher_uid, student_uid);
  DELETE FROM auth.users          WHERE id      IN (admin_uid, teacher_uid, student_uid);

  -- ── auth.users ────────────────────────────────────────────────────────────
  INSERT INTO auth.users (
    instance_id, id, aud, role,
    email, encrypted_password,
    email_confirmed_at,
    confirmation_token, recovery_token,
    email_change_token_new, email_change,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, created_at, updated_at,
    phone, phone_change, phone_change_token,
    email_change_token_current, email_change_confirm_status,
    reauthentication_token, is_sso_user, deleted_at, is_anonymous
  ) VALUES
  (
    '00000000-0000-0000-0000-000000000000', admin_uid,
    'authenticated', 'authenticated',
    'admin@maximus.edu.au', crypt('Admin1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"admin","full_name":"Alex Morrison"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', teacher_uid,
    'authenticated', 'authenticated',
    'teacher@maximus.edu.au', crypt('Teacher1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"teacher","full_name":"Sarah Thompson"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', student_uid,
    'authenticated', 'authenticated',
    'student@maximus.edu.au', crypt('Student1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"student","full_name":"James Wilson"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  );

  -- ── auth.identities ───────────────────────────────────────────────────────
  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, created_at, updated_at)
  VALUES
  (
    gen_random_uuid(), 'admin@maximus.edu.au', admin_uid,
    jsonb_build_object('sub', admin_uid::text, 'email', 'admin@maximus.edu.au', 'email_verified', true, 'phone_verified', false),
    'email', now(), now()
  ),
  (
    gen_random_uuid(), 'teacher@maximus.edu.au', teacher_uid,
    jsonb_build_object('sub', teacher_uid::text, 'email', 'teacher@maximus.edu.au', 'email_verified', true, 'phone_verified', false),
    'email', now(), now()
  ),
  (
    gen_random_uuid(), 'student@maximus.edu.au', student_uid,
    jsonb_build_object('sub', student_uid::text, 'email', 'student@maximus.edu.au', 'email_verified', true, 'phone_verified', false),
    'email', now(), now()
  );

  -- ── profiles ──────────────────────────────────────────────────────────────
  INSERT INTO public.profiles (id, email, full_name, role, bio)
  VALUES
    (admin_uid,   'admin@maximus.edu.au',   'Alex Morrison',  'admin',
     'Platform administrator for Maximus Academy Australia.'),
    (teacher_uid, 'teacher@maximus.edu.au', 'Sarah Thompson', 'teacher',
     'Senior Business Communication instructor with 10+ years experience.'),
    (student_uid, 'student@maximus.edu.au', 'James Wilson',   'student',
     'Aspiring business professional based in Sydney, Australia.')
  ON CONFLICT (id) DO UPDATE SET
    email     = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role      = EXCLUDED.role,
    bio       = EXCLUDED.bio;

END $$;
/*
  # Seed Course Catalog and Demo Data

  Recreates all content from the previous database matching the new schema.
  Includes courses, sections, lessons, quizzes, assignments, enrollments,
  lesson progress, certificates, live sessions, announcements, promo codes,
  activity logs, and historical payments.
*/

DO $$
DECLARE
  admin_uid    uuid := '6c0e7959-b621-42ce-8598-868a8fc2e073';
  teacher_uid  uuid := '494bced9-f191-429c-8b0b-1f19680e4442';
  student_uid  uuid := '4bb5f4e6-5ca5-4bfa-a4a0-4974e06ae7c5';

  c_biz        uuid := 'aa000000-0000-0000-0000-000000000001';
  c_mktg       uuid := 'bb000000-0000-0000-0000-000000000002';
  c_data       uuid := 'cc000000-0000-0000-0000-000000000003';
  c_ielts      uuid := '59102c80-84b8-4533-98dc-597ea80214e3';
  c_xero       uuid := '421fc7e3-b096-4b68-87fe-89b44af69c0e';
  c_pte        uuid := 'dd000000-0000-0000-0000-000000000004';
  c_japanese   uuid := 'ee000000-0000-0000-0000-000000000005';
  c_french     uuid := '9170d2af-8369-4dc4-86f5-5806db1f2ddb';
  c_spanish    uuid := 'd531dc2a-7cc2-461d-a769-9b006a016dea';

  s1 uuid := '10000000-0000-0000-0000-000000000001';
  s2 uuid := '20000000-0000-0000-0000-000000000002';
  s3 uuid := '30000000-0000-0000-0000-000000000003';
  sf1 uuid := 'f1000000-0000-0000-0000-000000000001';
  sf2 uuid := 'f2000000-0000-0000-0000-000000000002';

  l1 uuid := '40000000-0000-0000-0000-000000000001';
  l2 uuid := '50000000-0000-0000-0000-000000000002';
  l3 uuid := '60000000-0000-0000-0000-000000000003';
  l4 uuid := '70000000-0000-0000-0000-000000000004';
  l5 uuid := '80000000-0000-0000-0000-000000000005';
  l6 uuid := '90000000-0000-0000-0000-000000000006';
  lf1 uuid := 'f0100000-0000-0000-0000-000000000001';
  lf2 uuid := 'f0200000-0000-0000-0000-000000000002';
  lf3 uuid := 'f0300000-0000-0000-0000-000000000003';
  lf4 uuid := 'f0400000-0000-0000-0000-000000000004';

  q_biz  uuid := 'a0000000-0000-0000-0000-000000000001';
  q_fr   uuid := 'a1000000-0000-0000-0000-000000000001';
  a_biz  uuid := 'b0000000-0000-0000-0000-000000000001';
  a_fr   uuid := 'b1000000-0000-0000-0000-000000000001';
  a_sp   uuid := 'b2000000-0000-0000-0000-000000000002';
  cert1  uuid := 'c0000000-0000-0000-0000-000000000001';

  i int;
BEGIN

  -- ── Courses ───────────────────────────────────────────────────────────────
  INSERT INTO courses (id, title, short_description, description, thumbnail_url, price, price_amount, is_free, is_paid, category, level, teacher_id, is_published, is_archived, duration_hours, total_lessons, total_students, rating, what_you_learn, requirements)
  VALUES
    (c_biz,'Business Communication Mastery','Master professional communication skills for the modern Australian workplace.',
     'This comprehensive course covers all aspects of professional business communication, from email writing and presentation skills to negotiation and conflict resolution.',
     'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg',
     299.00,299.00,false,true,'Business','intermediate',teacher_uid,true,false,8,6,142,4.8,
     ARRAY['Write clear professional emails','Deliver confident presentations','Negotiate effectively','Resolve workplace conflicts'],
     ARRAY['No prior experience needed','Basic computer literacy']),

    (c_mktg,'Digital Marketing Fundamentals','Learn to build and execute winning digital marketing strategies.',
     'From SEO and social media to paid advertising and analytics, this course gives you a comprehensive introduction to digital marketing.',
     'https://images.pexels.com/photos/905163/pexels-photo-905163.jpeg',
     199.00,199.00,false,true,'Marketing','beginner',teacher_uid,true,false,6,18,98,4.6,
     ARRAY['Create effective social media campaigns','Understand SEO fundamentals','Run Google Ads','Analyse marketing metrics'],
     ARRAY['Basic computer skills','Interest in marketing']),

    (c_data,'Introduction to Data Analysis','Get started with data analysis using Excel and Python.',
     'This free introductory course teaches you the fundamentals of data analysis. Perfect for beginners who want to start working with data.',
     'https://images.pexels.com/photos/590022/pexels-photo-590022.jpeg',
     0.00,0.00,true,false,'Technology','beginner',teacher_uid,true,false,4,12,256,4.7,
     ARRAY['Understand data types and structures','Use Excel for analysis','Write basic Python scripts','Create data visualisations'],
     ARRAY['No programming experience needed','Microsoft Excel (any version)']),

    (c_ielts,'IELTS Preparation','Comprehensive IELTS preparation covering all four skills: Listening, Reading, Writing, and Speaking.',
     'Our IELTS Preparation course is designed to help you achieve your target band score. We cover all four test components with expert-led strategies, practice tests, and personalised feedback.',
     'https://images.pexels.com/photos/4144923/pexels-photo-4144923.jpeg',
     450.00,450.00,false,true,'Test Preparation','beginner',teacher_uid,true,false,40,32,127,4.8,
     ARRAY['Master all four IELTS skills','Learn test-taking strategies','Complete practice tests','Achieve your target band score'],
     ARRAY['Intermediate English level','Commitment to regular study']),

    (c_xero,'Xero Beginner Course','Get job-ready with Xero — the cloud accounting software used by thousands of businesses.',
     'This hands-on Xero Beginner Course teaches you to set up and manage accounts, process invoices, reconcile bank transactions, run payroll, and generate financial reports.',
     'https://images.pexels.com/photos/6693661/pexels-photo-6693661.jpeg',
     320.00,320.00,false,true,'Finance','beginner',teacher_uid,true,false,20,18,143,4.6,
     ARRAY['Set up a Xero account','Process invoices and bills','Reconcile bank transactions','Run payroll and financial reports'],
     ARRAY['Basic computer skills','No accounting experience needed']),

    (c_pte,'PTE Academic Preparation','Master the PTE Academic exam with targeted practice, AI-scored mock tests, and proven strategies.',
     'The PTE Academic Preparation course provides an intensive study program covering all PTE question types. You will learn time management strategies, practise with realistic mock tests, and receive detailed performance analysis.',
     'https://images.pexels.com/photos/5427869/pexels-photo-5427869.jpeg',
     420.00,420.00,false,true,'Test Preparation','intermediate',teacher_uid,true,false,36,28,98,4.7,
     ARRAY['Master all PTE question types','Improve time management','Practise with mock tests','Analyse performance gaps'],
     ARRAY['Basic English proficiency','Commitment to study']),

    (c_japanese,'Japanese Language Course','Learn Japanese from scratch — hiragana, katakana, kanji, and everyday conversation.',
     'This Japanese Language Course takes you from complete beginner to conversational proficiency. You will master the writing systems, build vocabulary, study grammar, and practise real-world conversations.',
     'https://images.pexels.com/photos/5926382/pexels-photo-5926382.jpeg',
     380.00,380.00,false,true,'Language Learning','beginner',teacher_uid,true,false,48,36,74,4.9,
     ARRAY['Read hiragana and katakana','Learn essential kanji','Hold basic conversations','Understand Japanese grammar'],
     ARRAY['No Japanese experience needed','Commitment to regular practice']),

    (c_french,'French Language Course','Speak French with confidence — from bonjour to business conversations.',
     'Our French Language Course is perfect for beginners and intermediate learners. You will develop all four language skills through interactive lessons, audio exercises, and live conversation practice.',
     'https://images.pexels.com/photos/5935791/pexels-photo-5935791.jpeg',
     360.00,360.00,false,true,'Language Learning','beginner',teacher_uid,true,false,45,34,62,4.8,
     ARRAY['Hold everyday French conversations','Master French pronunciation','Build essential vocabulary','Read and write in French'],
     ARRAY['No French experience needed','Enthusiasm to learn']),

    (c_spanish,'Spanish Language Course','From hola to fluent — learn Spanish for travel, work, and everyday life.',
     'Spanish is one of the world''s most spoken languages. This course covers pronunciation, grammar, vocabulary, and conversation for beginners through to intermediate levels.',
     'https://images.pexels.com/photos/5935234/pexels-photo-5935234.jpeg',
     360.00,360.00,false,true,'Language Learning','beginner',teacher_uid,true,false,45,34,55,4.7,
     ARRAY['Speak confidently in Spanish','Understand Spanish grammar','Build travel vocabulary','Write in Spanish'],
     ARRAY['No Spanish experience needed','Commitment to regular study'])

  ON CONFLICT (id) DO UPDATE SET
    title=EXCLUDED.title, short_description=EXCLUDED.short_description,
    description=EXCLUDED.description, thumbnail_url=EXCLUDED.thumbnail_url,
    price=EXCLUDED.price, price_amount=EXCLUDED.price_amount,
    is_free=EXCLUDED.is_free, is_paid=EXCLUDED.is_paid,
    category=EXCLUDED.category, level=EXCLUDED.level,
    teacher_id=EXCLUDED.teacher_id, is_published=EXCLUDED.is_published,
    duration_hours=EXCLUDED.duration_hours, total_lessons=EXCLUDED.total_lessons,
    total_students=EXCLUDED.total_students, rating=EXCLUDED.rating,
    what_you_learn=EXCLUDED.what_you_learn, requirements=EXCLUDED.requirements;

  -- ── Sections ──────────────────────────────────────────────────────────────
  INSERT INTO sections (id, course_id, title, order_index) VALUES
    (s1, c_biz, 'Module 1: Foundations of Business Communication', 0),
    (s2, c_biz, 'Module 2: Written Communication', 1),
    (s3, c_biz, 'Module 3: Presentations & Public Speaking', 2),
    (sf1, c_french, 'Getting Started', 0),
    (sf2, c_french, 'Core Vocabulary', 1)
  ON CONFLICT (id) DO NOTHING;

  -- ── Lessons ───────────────────────────────────────────────────────────────
  INSERT INTO lessons (id, section_id, course_id, title, type, lesson_type, video_url, content, order_index, is_preview, duration_minutes) VALUES
    (l1,s1,c_biz,'Welcome & Course Overview','video','video','https://www.w3schools.com/html/mov_bbb.mp4','',0,true,5),
    (l2,s1,c_biz,'What is Business Communication?','text','text','','Business communication is the process of sharing information between people within and outside an organisation. Effective communication is a fundamental management function and a critical skill for all professionals in the modern Australian workplace.',1,false,15),
    (l3,s1,c_biz,'Communication Styles & Barriers','text','text','','Understanding different communication styles helps you adapt your message. The four main styles are assertive, passive, aggressive, and passive-aggressive. Common barriers include cultural differences, language barriers, jargon, and poor listening skills.',2,false,20),
    (l4,s2,c_biz,'Professional Email Writing','text','text','','Writing professional emails requires mastery of structure and tone. Key elements: a clear subject line, professional greeting, concise body, clear call to action, and appropriate sign-off. Always proofread before sending.',0,false,25),
    (l5,s2,c_biz,'Business Report Writing','text','text','','Business reports should follow a clear structure: executive summary, introduction, methodology, findings, conclusions, and recommendations. Use clear headings, bullet points, and visual aids to make your report easy to navigate.',1,false,30),
    (l6,s3,c_biz,'Presentation Design Principles','text','text','','Effective presentations follow the 10-20-30 rule: no more than 10 slides, no longer than 20 minutes, and font size no smaller than 30 points. Use high-quality images, limit text on slides, and practise your delivery.',0,false,20),
    (lf1,sf1,c_french,'Introduction to French','video','video','https://www.youtube.com/watch?v=dQw4w9WgXcQ','',0,true,12),
    (lf2,sf1,c_french,'Basic Pronunciation Guide','text','text','','In French, every syllable is equally stressed. Focus on nasal vowels and silent final consonants. Practice: "bon", "vin", "brun".',1,false,8),
    (lf3,sf2,c_french,'Numbers 1 to 20','video','video','https://www.youtube.com/watch?v=dQw4w9WgXcQ','',0,false,10),
    (lf4,sf2,c_french,'Days of the Week','text','text','','Lundi (Monday), Mardi (Tuesday), Mercredi (Wednesday), Jeudi (Thursday), Vendredi (Friday), Samedi (Saturday), Dimanche (Sunday).',1,false,6)
  ON CONFLICT (id) DO NOTHING;

  -- ── Quizzes ───────────────────────────────────────────────────────────────
  INSERT INTO quizzes (id, course_id, title, description, time_limit, pass_percentage, max_attempts, is_published) VALUES
    (q_biz, c_biz, 'Module 1 Knowledge Check', 'Test your understanding of business communication fundamentals.', 15, 70, 3, true),
    (q_fr,  c_french, 'French Basics Quiz', 'Test your knowledge of French greetings and basic phrases.', 15, 60, 3, true)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO quiz_questions (quiz_id, question, options, correct_answer, explanation, points, order_index) VALUES
    (q_biz,'Which of the following is a common barrier to effective communication?',
     '["Active listening","Clear language","Cultural differences","Eye contact"]'::jsonb,
     2,'Cultural differences create misunderstandings due to varying norms and values.',1,0),
    (q_biz,'Business communication only occurs within an organisation.',
     '["True","False"]'::jsonb,
     1,'Business communication also occurs between organisations and with external stakeholders.',1,1),
    (q_biz,'Which rule guides effective presentation design?',
     '["5-10-15 Rule","10-20-30 Rule","20-30-40 Rule","15-25-35 Rule"]'::jsonb,
     1,'The 10-20-30 rule: 10 slides, 20 minutes, 30pt font minimum.',1,2),
    (q_fr,'How do you say "Good morning" in French?',
     '["Bonsoir","Bonjour","Bonne nuit","Au revoir"]'::jsonb,
     1,'Bonjour means "Hello / Good morning" in French.',1,0),
    (q_fr,'The French word "merci" means "thank you".',
     '["True","False"]'::jsonb,
     0,'Merci does indeed mean "thank you" in French.',1,1),
    (q_fr,'What is the French word for "Wednesday"?',
     '["Lundi","Mardi","Mercredi","Jeudi"]'::jsonb,
     2,'Mercredi means Wednesday in French.',1,2)
  ON CONFLICT DO NOTHING;

  -- ── Assignments ───────────────────────────────────────────────────────────
  INSERT INTO assignments (id, course_id, teacher_id, title, description, due_date, total_points, is_published) VALUES
    (a_biz, c_biz,    teacher_uid, 'Professional Email Draft',
     'Write a professional email to a client explaining a project delay. Approximately 200-300 words demonstrating the principles covered in Module 2.',
     now()+interval'14 days', 100, true),
    (a_fr,  c_french, teacher_uid, 'French Conversation Practice',
     'Record a 2-minute spoken French conversation on any topic and upload the audio file. Focus on pronunciation and natural flow.',
     now()+interval'7 days', 100, true),
    (a_sp,  c_spanish, teacher_uid, 'Spanish Vocabulary Essay',
     'Write a 300-word essay in Spanish using at least 20 vocabulary words from Module 2.',
     now()+interval'3 days', 80, true)
  ON CONFLICT (id) DO NOTHING;

  -- ── Enrollments ───────────────────────────────────────────────────────────
  INSERT INTO enrollments (student_id, course_id, progress_percent, enrolled_at) VALUES
    (student_uid, c_biz,     35,  now()-interval'30 days'),
    (student_uid, c_data,    67,  now()-interval'20 days'),
    (student_uid, c_french,  75,  now()-interval'15 days'),
    (student_uid, c_spanish, 100, now()-interval'35 days')
  ON CONFLICT (student_id, course_id) DO UPDATE SET progress_percent=EXCLUDED.progress_percent;

  -- ── Lesson progress ───────────────────────────────────────────────────────
  INSERT INTO lesson_progress (student_id, lesson_id, course_id, is_completed, watch_percentage, completed_at) VALUES
    (student_uid, l1,  c_biz,    true, 100, now()-interval'29 days'),
    (student_uid, l2,  c_biz,    true, 100, now()-interval'28 days'),
    (student_uid, lf1, c_french, true, 100, now()-interval'14 days'),
    (student_uid, lf2, c_french, true, 100, now()-interval'13 days'),
    (student_uid, lf3, c_french, true, 100, now()-interval'12 days')
  ON CONFLICT DO NOTHING;

  -- ── Assignment submission ─────────────────────────────────────────────────
  INSERT INTO assignment_submissions (assignment_id, student_id, content, submitted_at)
  VALUES (a_fr, student_uid,
    'Bonjour! Je m''appelle Marie. Je suis étudiante à Sydney. J''aime les langues étrangères.',
    now()-interval'1 day')
  ON CONFLICT (assignment_id, student_id) DO NOTHING;

  -- ── Certificate ───────────────────────────────────────────────────────────
  INSERT INTO certificates (id, student_id, course_id, verification_code, issued_at, revoked)
  VALUES (cert1, student_uid, c_spanish,
    'MAXIMUS-2026-' || UPPER(SUBSTRING(cert1::text FROM 1 FOR 8)),
    now()-interval'5 days', false)
  ON CONFLICT (id) DO NOTHING;

  -- ── Live sessions ─────────────────────────────────────────────────────────
  INSERT INTO live_sessions (course_id, teacher_id, title, description, meeting_url, scheduled_at, duration_minutes, status) VALUES
    (c_french,  teacher_uid, 'French Pronunciation Workshop',
     'Live practice of French phonetics with native speaker exercises.',
     'https://meet.google.com/abc-demo-001', now()+interval'2 days', 60, 'scheduled'),
    (c_spanish, teacher_uid, 'Spanish Grammar Q&A',
     'Open Q&A on subjunctive and conditional tenses.',
     'https://zoom.us/j/demo002', now()+interval'5 days', 45, 'scheduled'),
    (c_biz,     teacher_uid, 'Business Communication: Presentations',
     'Practical techniques for professional presentations.',
     'https://teams.microsoft.com/l/demo003', now()+interval'10 days', 90, 'scheduled')
  ON CONFLICT DO NOTHING;

  -- ── Announcements ─────────────────────────────────────────────────────────
  INSERT INTO announcements (title, content, author_id, is_active) VALUES
    ('Welcome to Maximus Academy!',
     'We are thrilled to have you as part of the Maximus Academy community. Explore our growing library of courses and start your learning journey today. Use code WELCOME20 for 20% off your first course!',
     admin_uid, true),
    ('New Courses Available — 2026',
     'Three new courses just added: Advanced Business Writing, Japanese for Beginners, and Data Analysis with Excel. Use code WELCOME20 for 20% off!',
     admin_uid, true)
  ON CONFLICT DO NOTHING;

  -- ── Promo codes ───────────────────────────────────────────────────────────
  INSERT INTO promo_codes (code, discount_type, discount_value, max_uses, used_count, valid_from, valid_until, is_active) VALUES
    ('WELCOME20','percentage',20,100, 3, now(), now()+interval'90 days',  true),
    ('LAUNCH50', 'percentage',50, 50, 0, now(), now()+interval'30 days',  true),
    ('STUDENT10','percentage',10,200,12, now(), now()+interval'180 days', true),
    ('EARLYBIRD','percentage',30, 20,20, now(), now()-interval'1 day',    false)
  ON CONFLICT (code) DO UPDATE SET
    discount_value=EXCLUDED.discount_value, max_uses=EXCLUDED.max_uses,
    valid_until=EXCLUDED.valid_until, is_active=EXCLUDED.is_active;

  -- ── Activity logs (details column is jsonb) ───────────────────────────────
  INSERT INTO activity_logs (user_id, action, entity_type, entity_id, details) VALUES
    (admin_uid,   'create',   'course',       c_biz,       '{"note":"Created course: Business Communication Mastery"}'::jsonb),
    (admin_uid,   'create',   'user',         teacher_uid, '{"note":"Created teacher account: teacher@maximus.edu.au"}'::jsonb),
    (teacher_uid, 'create',   'assignment',   a_biz,       '{"note":"Created assignment: Professional Email Draft"}'::jsonb),
    (teacher_uid, 'create',   'quiz',         q_biz,       '{"note":"Created quiz: Module 1 Knowledge Check"}'::jsonb),
    (student_uid, 'enroll',   'course',       c_biz,       '{"note":"Enrolled in: Business Communication Mastery"}'::jsonb),
    (student_uid, 'enroll',   'course',       c_french,    '{"note":"Enrolled in: French Language Course"}'::jsonb),
    (student_uid, 'complete', 'course',       c_spanish,   '{"note":"Completed: Spanish Language Course"}'::jsonb),
    (teacher_uid, 'create',   'quiz',         q_fr,        '{"note":"Created quiz: French Basics Quiz"}'::jsonb),
    (admin_uid,   'create',   'announcement', gen_random_uuid(), '{"note":"Sent: Welcome to Maximus Academy!"}'::jsonb)
  ON CONFLICT DO NOTHING;

  -- ── Historical payments for revenue chart ─────────────────────────────────
  FOR i IN 1..18 LOOP
    INSERT INTO payments (user_id, course_id, amount, currency, status, created_at)
    VALUES (
      student_uid,
      CASE WHEN i%3=0 THEN c_biz WHEN i%3=1 THEN c_french ELSE c_ielts END,
      (ARRAY[197.00,297.00,397.00,247.00,347.00])[((i-1)%5)+1],
      'aud','completed',
      now()-(i*interval'40 hours')
    );
  END LOOP;

END $$;

-- Refresh total_students counts
UPDATE courses
SET total_students = (
  SELECT COUNT(*) FROM enrollments WHERE enrollments.course_id = courses.id
);
/*
  # Performance Indexes

  Adds indexes for all hot query paths:
  - lesson_progress lookups by user + lesson or user + course
  - course_enrollments lookups by user or course
  - enrollments lookups by student or course
  - quiz_attempts lookups by user + course
  - payments lookups by user, course, status, created_at
  - activity_logs ordered by created_at
  - announcements active filter
  - assignments due_date range scans
  - assignment_submissions grade IS NULL scans
  - live_sessions scheduled_at range scans
*/

-- lesson_progress
CREATE INDEX IF NOT EXISTS idx_lp_user_course    ON lesson_progress(user_id, course_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lp_student_course ON lesson_progress(student_id, course_id) WHERE student_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_lp_completed      ON lesson_progress(user_id, is_completed) WHERE user_id IS NOT NULL;

-- course_enrollments
CREATE INDEX IF NOT EXISTS idx_ce_user_accessed  ON course_enrollments(user_id, last_accessed_at DESC);
CREATE INDEX IF NOT EXISTS idx_ce_course_status  ON course_enrollments(course_id, payment_status);

-- enrollments
CREATE INDEX IF NOT EXISTS idx_enroll_student_course ON enrollments(student_id, course_id);
CREATE INDEX IF NOT EXISTS idx_enroll_progress        ON enrollments(student_id, progress_percent);

-- quiz_attempts
CREATE INDEX IF NOT EXISTS idx_qa_user_course ON quiz_attempts(user_id, course_id) WHERE user_id IS NOT NULL;

-- payments
CREATE INDEX IF NOT EXISTS idx_payments_status_date ON payments(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_user_status  ON payments(user_id, status);

-- activity_logs
CREATE INDEX IF NOT EXISTS idx_activity_action     ON activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_activity_entity     ON activity_logs(entity_type, entity_id);

-- announcements
CREATE INDEX IF NOT EXISTS idx_announce_active_date ON announcements(is_active, created_at DESC);

-- assignments
CREATE INDEX IF NOT EXISTS idx_assign_due_published ON assignments(course_id, due_date, is_published);

-- assignment_submissions
CREATE INDEX IF NOT EXISTS idx_sub_ungraded ON assignment_submissions(assignment_id) WHERE grade IS NULL;

-- live_sessions
CREATE INDEX IF NOT EXISTS idx_live_teacher_sched ON live_sessions(teacher_id, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_live_course_sched  ON live_sessions(course_id, scheduled_at);

-- profiles
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- courses
CREATE INDEX IF NOT EXISTS idx_courses_published_cat ON courses(is_published, is_archived, category);
CREATE INDEX IF NOT EXISTS idx_courses_teacher_pub   ON courses(teacher_id, is_published, is_archived);
/*
  # Migrate Legacy Enrollments to course_enrollments

  ## Summary
  Copies all rows from the legacy `enrollments` table into the new `course_enrollments`
  table so that `useMyEnrollments` (which only queries `course_enrollments`) returns
  data for existing students.

  ## Changes
  - Inserts missing rows from `enrollments` → `course_enrollments`
  - Maps `student_id` → `user_id`
  - Sets `payment_status = 'not_required'` for all migrated rows
  - Sets `completed_at` where `progress_percent = 100`
  - Skips duplicates via ON CONFLICT DO NOTHING
*/

INSERT INTO course_enrollments (
  id,
  user_id,
  course_id,
  payment_status,
  progress_percent,
  last_accessed_at,
  enrolled_at,
  completed_at
)
SELECT
  e.id,
  e.student_id,
  e.course_id,
  'not_required'::text,
  COALESCE(e.progress_percent, 0),
  COALESCE(e.enrolled_at, now()),
  COALESCE(e.enrolled_at, now()),
  CASE WHEN e.progress_percent = 100 THEN e.enrolled_at ELSE NULL END
FROM enrollments e
WHERE e.student_id IS NOT NULL
ON CONFLICT (user_id, course_id) DO NOTHING;
/*
  # Additional Performance Indexes

  ## Summary
  Adds indexes for the most-queried columns across public-facing and student pages.

  ## New Indexes
  - courses: composite on (is_published, is_archived) for the public Courses page filter
  - courses: on category, level, is_free for client-side-filtered but still DB-scanned queries
  - courses: on total_students DESC for default "popular" sort
  - sections: on course_id + order_index for CoursePreview and CoursePlayer
  - lessons: on section_id + order_index for nested lesson loading
  - promo_codes: on (code, is_active) for fast promo validation
  - announcements: on (is_active, created_at) for dashboard sidebar
*/

CREATE INDEX IF NOT EXISTS idx_courses_published_archived
  ON courses (is_published, is_archived)
  WHERE is_published = true AND is_archived = false;

CREATE INDEX IF NOT EXISTS idx_courses_popular
  ON courses (total_students DESC NULLS LAST)
  WHERE is_published = true AND is_archived = false;

CREATE INDEX IF NOT EXISTS idx_courses_created_at
  ON courses (created_at DESC)
  WHERE is_published = true AND is_archived = false;

CREATE INDEX IF NOT EXISTS idx_courses_category
  ON courses (category)
  WHERE is_published = true;

CREATE INDEX IF NOT EXISTS idx_courses_level
  ON courses (level)
  WHERE is_published = true;

CREATE INDEX IF NOT EXISTS idx_sections_course_order
  ON sections (course_id, order_index);

CREATE INDEX IF NOT EXISTS idx_lessons_section_order
  ON lessons (section_id, order_index);

CREATE INDEX IF NOT EXISTS idx_promo_codes_lookup
  ON promo_codes (code, is_active);

CREATE INDEX IF NOT EXISTS idx_announcements_active_created
  ON announcements (is_active, created_at DESC)
  WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_assignments_due_date
  ON assignments (course_id, due_date)
  WHERE due_date IS NOT NULL;
/*
  # Cache user role lookup and fix admin RLS performance

  ## Problem
  get_user_role() runs a SELECT from profiles on EVERY row checked by RLS policies.
  For an admin viewing 9 courses, that triggers 9+ extra DB round-trips.

  ## Fix
  1. Replace get_user_role() body with a cached version using a transaction-local
     variable (set_config/current_setting). First call hits profiles, subsequent
     calls within the same request return the cached value instantly.

  2. Add a separate policy for admin INSERT on courses (currently missing — admins
     can't create courses because the INSERT policy only allows teachers with
     matching teacher_id).

  ## Changes
  - get_user_role() now caches result in session variable request.jwt.role.cached
  - New policy: "Admins can insert courses" on courses FOR INSERT
*/

-- Drop and recreate get_user_role with caching
CREATE OR REPLACE FUNCTION public.get_user_role(user_id uuid DEFAULT auth.uid())
RETURNS text
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cached text;
  result text;
BEGIN
  -- Try to read from transaction-local cache
  BEGIN
    cached := current_setting('app.user_role_cache', true);
  EXCEPTION WHEN OTHERS THEN
    cached := NULL;
  END;

  IF cached IS NOT NULL AND cached != '' THEN
    RETURN cached;
  END IF;

  -- First call in this request: hit the DB once
  SELECT role INTO result FROM profiles WHERE id = user_id;
  result := COALESCE(result, 'student');

  -- Cache for the remainder of this request
  PERFORM set_config('app.user_role_cache', result, true);
  RETURN result;
END;
$$;

-- Admins should be able to insert courses (current policy requires teacher_id = auth.uid())
CREATE POLICY "Admins can insert courses"
  ON courses FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'admin');
/*
  # Add is_active column to profiles

  ## Summary
  Re-adds the is_active boolean to profiles so admins can activate/deactivate
  accounts without deleting them (soft-delete pattern). All existing users
  default to active = true.

  ## Changes
  - profiles: ADD COLUMN is_active BOOLEAN DEFAULT true
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'is_active'
  ) THEN
    ALTER TABLE profiles ADD COLUMN is_active boolean NOT NULL DEFAULT true;
  END IF;
END $$;
/*
  # AI Usage Logs Schema Update, Flashcards Table, and create_ai_course RPC

  ## Changes
  1. Adds missing columns to existing ai_usage_logs table
  2. Creates flashcards table with RLS
  3. Adds ai_summary columns to lessons
  4. Creates create_ai_course() RPC function (SECURITY DEFINER)
*/

-- Add missing columns to ai_usage_logs if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ai_usage_logs' AND column_name = 'ai_task'
  ) THEN
    ALTER TABLE ai_usage_logs ADD COLUMN ai_task text NOT NULL DEFAULT '';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ai_usage_logs' AND column_name = 'input_tokens'
  ) THEN
    ALTER TABLE ai_usage_logs ADD COLUMN input_tokens int NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ai_usage_logs' AND column_name = 'output_tokens'
  ) THEN
    ALTER TABLE ai_usage_logs ADD COLUMN output_tokens int NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ai_usage_logs' AND column_name = 'cost_estimate_usd'
  ) THEN
    ALTER TABLE ai_usage_logs ADD COLUMN cost_estimate_usd numeric(10, 6) NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ai_usage_logs' AND column_name = 'success'
  ) THEN
    ALTER TABLE ai_usage_logs ADD COLUMN success boolean NOT NULL DEFAULT true;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ai_usage_logs' AND column_name = 'error_message'
  ) THEN
    ALTER TABLE ai_usage_logs ADD COLUMN error_message text;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_ai_usage_logs_user_id ON ai_usage_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_usage_logs_created_at ON ai_usage_logs(created_at);

ALTER TABLE ai_usage_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'ai_usage_logs' AND policyname = 'Users can read own ai usage logs'
  ) THEN
    CREATE POLICY "Users can read own ai usage logs"
      ON ai_usage_logs FOR SELECT
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'ai_usage_logs' AND policyname = 'Admins can read all ai usage logs'
  ) THEN
    CREATE POLICY "Admins can read all ai usage logs"
      ON ai_usage_logs FOR SELECT
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
        )
      );
  END IF;
END $$;

-- flashcards table
CREATE TABLE IF NOT EXISTS flashcards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  front text NOT NULL,
  back text NOT NULL,
  order_index int NOT NULL DEFAULT 0,
  created_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_flashcards_lesson_id ON flashcards(lesson_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_course_id ON flashcards(course_id);

ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'flashcards' AND policyname = 'Teachers and admins can insert flashcards') THEN
    CREATE POLICY "Teachers and admins can insert flashcards"
      ON flashcards FOR INSERT
      TO authenticated
      WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
      );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'flashcards' AND policyname = 'Teachers and admins can update flashcards') THEN
    CREATE POLICY "Teachers and admins can update flashcards"
      ON flashcards FOR UPDATE
      TO authenticated
      USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin')))
      WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin')));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'flashcards' AND policyname = 'Teachers and admins can delete flashcards') THEN
    CREATE POLICY "Teachers and admins can delete flashcards"
      ON flashcards FOR DELETE
      TO authenticated
      USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin')));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'flashcards' AND policyname = 'Students can read flashcards for enrolled courses') THEN
    CREATE POLICY "Students can read flashcards for enrolled courses"
      ON flashcards FOR SELECT
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
        OR
        EXISTS (
          SELECT 1 FROM course_enrollments
          WHERE user_id = auth.uid()
            AND course_id = flashcards.course_id
            AND payment_status IN ('not_required', 'completed')
        )
      );
  END IF;
END $$;

-- Add ai_summary columns to lessons
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lessons' AND column_name = 'ai_summary'
  ) THEN
    ALTER TABLE lessons ADD COLUMN ai_summary text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lessons' AND column_name = 'ai_summary_generated_at'
  ) THEN
    ALTER TABLE lessons ADD COLUMN ai_summary_generated_at timestamptz;
  END IF;
END $$;

-- RPC: create_ai_course
CREATE OR REPLACE FUNCTION create_ai_course(payload jsonb)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role text;
  new_course_id uuid;
  module jsonb;
  lesson jsonb;
  new_section_id uuid;
  module_idx int := 0;
  lesson_idx int;
BEGIN
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role NOT IN ('teacher', 'admin') THEN
    RAISE EXCEPTION 'Forbidden: only teachers and admins can create courses';
  END IF;

  INSERT INTO courses (
    title, description, short_description, level, category,
    is_free, is_published, teacher_id
  ) VALUES (
    payload->>'title',
    payload->>'description',
    left(payload->>'description', 120),
    COALESCE(payload->>'level', 'beginner'),
    COALESCE(payload->>'category', 'General'),
    true,
    false,
    auth.uid()
  )
  RETURNING id INTO new_course_id;

  FOR module IN SELECT * FROM jsonb_array_elements(payload->'modules')
  LOOP
    INSERT INTO sections (course_id, title, order_index)
    VALUES (new_course_id, module->>'title', module_idx)
    RETURNING id INTO new_section_id;

    lesson_idx := 0;
    FOR lesson IN SELECT * FROM jsonb_array_elements(module->'lessons')
    LOOP
      INSERT INTO lessons (
        section_id, course_id, title, type, content, duration_minutes, order_index, is_preview
      ) VALUES (
        new_section_id,
        new_course_id,
        lesson->>'title',
        'article',
        COALESCE(lesson->>'description', ''),
        COALESCE((lesson->>'estimated_duration_minutes')::int, 10),
        lesson_idx,
        false
      );
      lesson_idx := lesson_idx + 1;
    END LOOP;

    module_idx := module_idx + 1;
  END LOOP;

  RETURN new_course_id;
END;
$$;
/*
  # Fix Profiles RLS Infinite Recursion

  ## Problem
  Several policies on the `profiles` table use subqueries that SELECT FROM `profiles`
  (e.g., `EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')`).
  This causes infinite recursion because evaluating the policy triggers itself.

  ## Fix
  Replace the self-referencing subqueries with `auth.jwt()` metadata checks or a
  SECURITY DEFINER function that bypasses RLS, eliminating the recursion.

  We use `get_my_role()` — a SECURITY DEFINER function — to safely read the caller's
  role from the profiles table without triggering RLS.
*/

-- Create a SECURITY DEFINER helper to read the calling user's role without RLS
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- Drop the recursive policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;
DROP POLICY IF EXISTS "Teachers can view student profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can insert profiles" ON profiles;

-- Recreate without recursion
CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (get_my_role() = 'admin');

CREATE POLICY "Teachers can view student profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (get_my_role() IN ('teacher', 'admin'));

CREATE POLICY "Admins can update any profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (get_my_role() = 'admin')
  WITH CHECK (get_my_role() = 'admin');

CREATE POLICY "Admins can insert profiles"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (get_my_role() = 'admin');
/*
  # Lesson Activities Table

  1. New Tables
    - `lesson_activities`
      - `id` (uuid, primary key)
      - `lesson_id` (uuid, FK → lessons)
      - `course_id` (uuid, FK → courses)
      - `title` (text) — activity name
      - `type` (text) — 'practice' | 'reflection' | 'discussion' | 'project' | 'research'
      - `instructions` (text) — full activity instructions
      - `estimated_minutes` (integer) — time estimate
      - `order_index` (integer)
      - `created_at`, `updated_at` (timestamptz)

  2. Security
    - RLS enabled
    - Teachers/admins can manage activities for their courses
    - Students can read activities for enrolled courses
*/

CREATE TABLE IF NOT EXISTS lesson_activities (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id          uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id          uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title              text NOT NULL DEFAULT '',
  type               text NOT NULL DEFAULT 'practice'
    CHECK (type = ANY (ARRAY['practice','reflection','discussion','project','research'])),
  instructions       text NOT NULL DEFAULT '',
  estimated_minutes  integer NOT NULL DEFAULT 15,
  order_index        integer NOT NULL DEFAULT 0,
  created_at         timestamptz DEFAULT now(),
  updated_at         timestamptz DEFAULT now()
);

ALTER TABLE lesson_activities ENABLE ROW LEVEL SECURITY;

-- Teachers/admins can insert activities for courses they own
CREATE POLICY "Teachers can insert activities for own courses"
  ON lesson_activities FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_activities.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Teachers/admins can update activities for their courses
CREATE POLICY "Teachers can update activities for own courses"
  ON lesson_activities FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_activities.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_activities.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Teachers/admins can delete activities for their courses
CREATE POLICY "Teachers can delete activities for own courses"
  ON lesson_activities FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_activities.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Students can read activities for enrolled courses
CREATE POLICY "Students can read activities for enrolled courses"
  ON lesson_activities FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM course_enrollments
      WHERE course_enrollments.course_id = lesson_activities.course_id
        AND course_enrollments.user_id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_activities.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

CREATE INDEX IF NOT EXISTS idx_lesson_activities_lesson_id ON lesson_activities(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_activities_course_id ON lesson_activities(course_id);
/*
  # Normalize Quiz, Quiz Question, and Lesson Column Names

  The application code uses pass_mark, time_limit_minutes for quizzes,
  and string correct_answer + type field for quiz_questions,
  and article/pdf/link types for lessons.
  
  This migration adds compatible columns so the app code works correctly.

  1. Quizzes table
    - Add `pass_mark` column (integer, alias for pass_percentage)  
    - Add `time_limit_minutes` column (integer, alias for time_limit)

  2. Quiz Questions table
    - Add `type` column (text) for question type: mcq, true_false, short_answer
    - Change `correct_answer` to accept text (add correct_answer_text column)

  3. Lessons table
    - Extend `type` check to include article, pdf, link types
    - Add `url` column for link/external URL lessons
*/

-- Quizzes: add pass_mark and time_limit_minutes as proper columns
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='pass_mark') THEN
    ALTER TABLE quizzes ADD COLUMN pass_mark integer NOT NULL DEFAULT 70;
    UPDATE quizzes SET pass_mark = pass_percentage WHERE pass_mark = 70;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='time_limit_minutes') THEN
    ALTER TABLE quizzes ADD COLUMN time_limit_minutes integer DEFAULT NULL;
    UPDATE quizzes SET time_limit_minutes = NULLIF(time_limit, 0);
  END IF;
END $$;

-- Quiz Questions: add type column for question type
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_questions' AND column_name='type') THEN
    ALTER TABLE quiz_questions ADD COLUMN type text NOT NULL DEFAULT 'mcq'
      CHECK (type = ANY (ARRAY['mcq','true_false','short_answer']));
  END IF;
END $$;

-- Quiz Questions: add correct_answer_text to store string correct answers
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_questions' AND column_name='correct_answer_text') THEN
    ALTER TABLE quiz_questions ADD COLUMN correct_answer_text text DEFAULT '';
  END IF;
END $$;

-- Lessons: drop the restrictive type check and allow article, pdf, link
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_type_check;
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_lesson_type_check;

ALTER TABLE lessons ADD CONSTRAINT lessons_type_check
  CHECK (type = ANY (ARRAY['video','text','file','quiz','article','pdf','link']));

ALTER TABLE lessons ADD CONSTRAINT lessons_lesson_type_check
  CHECK (lesson_type = ANY (ARRAY['video','text','file','quiz','article','pdf','link']));

-- Lessons: add url column for external links (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='url') THEN
    ALTER TABLE lessons ADD COLUMN url text DEFAULT '';
  END IF;
END $$;

-- Lessons: add is_required column (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='is_required') THEN
    ALTER TABLE lessons ADD COLUMN is_required boolean DEFAULT true;
  END IF;
END $$;
/*
  # Lesson Documents Table

  Stores AI-generated documents (lesson notes, presentation slides) tied to a lesson.

  1. New Tables
    - `lesson_documents`
      - `id` (uuid, primary key)
      - `lesson_id` (uuid, FK → lessons)
      - `course_id` (uuid, FK → courses)
      - `type` (text) — 'notes' | 'slides' | 'handout'
      - `title` (text)
      - `content_html` (text) — full HTML content rendered inline
      - `order_index` (integer)
      - `created_at`, `updated_at`

  2. Security
    - RLS enabled
    - Admins and course teachers can manage
    - Enrolled students can read
*/

CREATE TABLE IF NOT EXISTS lesson_documents (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id    uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  course_id    uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  type         text NOT NULL DEFAULT 'notes'
    CHECK (type = ANY (ARRAY['notes','slides','handout'])),
  title        text NOT NULL DEFAULT '',
  content_html text NOT NULL DEFAULT '',
  order_index  integer NOT NULL DEFAULT 0,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

ALTER TABLE lesson_documents ENABLE ROW LEVEL SECURITY;

-- Teachers/admins can select documents for their courses
CREATE POLICY "Teachers can view documents for own courses"
  ON lesson_documents FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_documents.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Teachers/admins can insert
CREATE POLICY "Teachers can insert documents for own courses"
  ON lesson_documents FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_documents.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Teachers/admins can update
CREATE POLICY "Teachers can update documents for own courses"
  ON lesson_documents FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_documents.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_documents.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Teachers/admins can delete
CREATE POLICY "Teachers can delete documents for own courses"
  ON lesson_documents FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lesson_documents.course_id
        AND (courses.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- Enrolled students can read
CREATE POLICY "Students can read documents for enrolled courses"
  ON lesson_documents FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM course_enrollments
      WHERE course_enrollments.course_id = lesson_documents.course_id
        AND course_enrollments.user_id = auth.uid()
    )
  );

CREATE INDEX IF NOT EXISTS idx_lesson_documents_lesson_id ON lesson_documents(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_documents_course_id ON lesson_documents(course_id);
/*
  # Exam System — Reading Comprehension & Open-Answer Exams

  ## Overview
  Adds a full exam system where:
  - Teachers create exams with a passage/stimulus and open-ended questions
  - Students submit typed answers
  - AI auto-grades each answer with a suggested score and reasoning
  - Teacher reviews AI suggestions and can adjust before finalising
  - Once finalised, students can see their scores and feedback

  ## New Tables

  ### exams
  - id, course_id, teacher_id
  - title, description
  - instructions — what students should do (e.g. "Read the passage and answer all questions")
  - passage — the reading/stimulus text students read before answering
  - time_limit_minutes — 0 means no limit
  - total_marks — sum of all question marks
  - is_published — controls student visibility
  - created_at, updated_at

  ### exam_questions
  - id, exam_id
  - question — the question text
  - marks — maximum marks for this question
  - sample_answer — teacher's model answer used by AI for grading
  - order_index

  ### exam_submissions
  - id, exam_id, student_id, course_id
  - answers jsonb — map of question_id → student's typed answer
  - status: 'submitted' | 'ai_graded' | 'teacher_reviewed' | 'finalised'
  - ai_scores jsonb — map of question_id → {score, reasoning, suggestion}
  - teacher_scores jsonb — map of question_id → {score, feedback} (teacher overrides)
  - final_scores jsonb — resolved final scores shown to student
  - total_score, max_score, percentage (computed on finalise)
  - ai_graded_at, teacher_reviewed_at, finalised_at
  - submitted_at

  ## Security
  - RLS enabled on all three tables
  - Students: read published exams for enrolled courses; insert/read own submissions
  - Teachers: full access to their own course exams; read/update submissions for their courses
  - Admins: full access
*/

-- ─── exams ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exams (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id           uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id          uuid REFERENCES profiles(id) ON DELETE SET NULL,
  title               text NOT NULL DEFAULT '',
  description         text DEFAULT '',
  instructions        text DEFAULT 'Read the passage carefully and answer all questions in full sentences.',
  passage             text DEFAULT '',
  time_limit_minutes  integer NOT NULL DEFAULT 0,
  total_marks         integer NOT NULL DEFAULT 0,
  is_published        boolean NOT NULL DEFAULT false,
  created_at          timestamptz DEFAULT now(),
  updated_at          timestamptz DEFAULT now()
);

ALTER TABLE exams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view published exams for enrolled courses"
  ON exams FOR SELECT TO authenticated
  USING (
    is_published = true AND (
      EXISTS (SELECT 1 FROM course_enrollments WHERE course_enrollments.course_id = exams.course_id AND course_enrollments.user_id = auth.uid())
      OR EXISTS (SELECT 1 FROM enrollments WHERE enrollments.course_id = exams.course_id AND enrollments.student_id = auth.uid())
    )
  );

CREATE POLICY "Teachers can manage exams for their courses"
  ON exams FOR SELECT TO authenticated
  USING (
    teacher_id = auth.uid()
    OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
    OR (SELECT get_my_role()) = 'admin'
  );

CREATE POLICY "Teachers can insert exams"
  ON exams FOR INSERT TO authenticated
  WITH CHECK (
    teacher_id = auth.uid()
    OR (SELECT get_my_role()) = 'admin'
  );

CREATE POLICY "Teachers can update their exams"
  ON exams FOR UPDATE TO authenticated
  USING (
    teacher_id = auth.uid()
    OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
    OR (SELECT get_my_role()) = 'admin'
  )
  WITH CHECK (
    teacher_id = auth.uid()
    OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
    OR (SELECT get_my_role()) = 'admin'
  );

CREATE POLICY "Teachers can delete their exams"
  ON exams FOR DELETE TO authenticated
  USING (
    teacher_id = auth.uid()
    OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
    OR (SELECT get_my_role()) = 'admin'
  );

-- ─── exam_questions ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exam_questions (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id       uuid NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  question      text NOT NULL DEFAULT '',
  marks         integer NOT NULL DEFAULT 5,
  sample_answer text DEFAULT '',
  order_index   integer NOT NULL DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

ALTER TABLE exam_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read exam questions"
  ON exam_questions FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_questions.exam_id
        AND (
          exams.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
          OR (SELECT get_my_role()) = 'admin'
          OR (
            exams.is_published = true AND (
              EXISTS (SELECT 1 FROM course_enrollments WHERE course_enrollments.course_id = exams.course_id AND course_enrollments.user_id = auth.uid())
              OR EXISTS (SELECT 1 FROM enrollments WHERE enrollments.course_id = exams.course_id AND enrollments.student_id = auth.uid())
            )
          )
        )
    )
  );

CREATE POLICY "Teachers can insert exam questions"
  ON exam_questions FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_questions.exam_id
        AND (exams.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

CREATE POLICY "Teachers can update exam questions"
  ON exam_questions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_questions.exam_id
        AND (exams.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_questions.exam_id
        AND (exams.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

CREATE POLICY "Teachers can delete exam questions"
  ON exam_questions FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_questions.exam_id
        AND (exams.teacher_id = auth.uid() OR (SELECT get_my_role()) = 'admin')
    )
  );

-- ─── exam_submissions ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exam_submissions (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id             uuid NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  student_id          uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id           uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  answers             jsonb NOT NULL DEFAULT '{}',
  status              text NOT NULL DEFAULT 'submitted'
    CHECK (status IN ('submitted', 'ai_graded', 'teacher_reviewed', 'finalised')),
  ai_scores           jsonb DEFAULT '{}',
  teacher_scores      jsonb DEFAULT '{}',
  final_scores        jsonb DEFAULT '{}',
  total_score         integer DEFAULT NULL,
  max_score           integer DEFAULT NULL,
  percentage          numeric(5,2) DEFAULT NULL,
  submitted_at        timestamptz DEFAULT now(),
  ai_graded_at        timestamptz,
  teacher_reviewed_at timestamptz,
  finalised_at        timestamptz,
  UNIQUE (exam_id, student_id)
);

ALTER TABLE exam_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can insert their own submissions"
  ON exam_submissions FOR INSERT TO authenticated
  WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can read their own submissions"
  ON exam_submissions FOR SELECT TO authenticated
  USING (
    student_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_submissions.exam_id
        AND (
          exams.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
          OR (SELECT get_my_role()) = 'admin'
        )
    )
  );

CREATE POLICY "Teachers can update submissions for their exams"
  ON exam_submissions FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_submissions.exam_id
        AND (
          exams.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
          OR (SELECT get_my_role()) = 'admin'
        )
    )
    OR student_id = auth.uid()
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exams
      WHERE exams.id = exam_submissions.exam_id
        AND (
          exams.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM courses WHERE courses.id = exams.course_id AND courses.teacher_id = auth.uid())
          OR (SELECT get_my_role()) = 'admin'
        )
    )
    OR student_id = auth.uid()
  );

-- ─── indexes ──────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_exams_course ON exams(course_id);
CREATE INDEX IF NOT EXISTS idx_exam_questions_exam ON exam_questions(exam_id, order_index);
CREATE INDEX IF NOT EXISTS idx_exam_submissions_student ON exam_submissions(student_id, exam_id);
CREATE INDEX IF NOT EXISTS idx_exam_submissions_exam ON exam_submissions(exam_id);
/*
  # Fix get_user_role() function

  The function was querying `FROM profiles WHERE id = user_id` but `user_id`
  was never defined, causing it to always return 'student'. This broke the
  admin RLS check on courses UPDATE, making it impossible for admins to save
  course changes (e.g. switching paid → free).

  Fix: replace the undefined `user_id` reference with `auth.uid()`.
*/

CREATE OR REPLACE FUNCTION get_user_role()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  cached text;
  result text;
BEGIN
  BEGIN
    cached := current_setting('app.user_role_cache', true);
  EXCEPTION WHEN OTHERS THEN
    cached := NULL;
  END;

  IF cached IS NOT NULL AND cached != '' THEN
    RETURN cached;
  END IF;

  SELECT role INTO result FROM profiles WHERE id = auth.uid();
  result := COALESCE(result, 'student');

  PERFORM set_config('app.user_role_cache', result, true);
  RETURN result;
END;
$$;
/*
  # Organizations & Token-Based AI Payment System

  ## Overview
  Introduces a multi-tenant organization model so companies can purchase token packages,
  manage their own teachers/courses, and control AI generation spending.

  ## New Tables
  - organizations: Company/institution with master token balance
  - org_members: Links users to org with role (owner | teacher)
  - token_packages: Purchasable token bundles catalog
  - token_purchases: Ledger of every token top-up
  - token_usage_log: Per-AI-call deduction record tied to org + user

  ## Modified Tables
  - profiles: role CHECK extended to include 'org_admin'
  - courses: org_id FK added

  ## Security
  - RLS enabled on all new tables
  - Policies added after all tables exist to avoid forward-reference errors
*/

-- ── 1. Extend role CHECK ─────────────────────────────────────────────────────
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('admin', 'teacher', 'student', 'org_admin'));

-- ── 2. organizations ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS organizations (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name               text NOT NULL,
  slug               text UNIQUE NOT NULL,
  logo_url           text,
  website            text,
  description        text,
  token_balance      integer NOT NULL DEFAULT 0 CHECK (token_balance >= 0),
  plan_tier          text NOT NULL DEFAULT 'starter' CHECK (plan_tier IN ('starter','growth','enterprise')),
  is_active          boolean NOT NULL DEFAULT true,
  stripe_customer_id text,
  created_by         uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at         timestamptz DEFAULT now(),
  updated_at         timestamptz DEFAULT now()
);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- ── 3. org_members ───────────────────────────────────────────────────────────
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

-- ── 4. Add org_id to courses ─────────────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'org_id'
  ) THEN
    ALTER TABLE courses ADD COLUMN org_id uuid REFERENCES organizations(id) ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_courses_org_id ON courses(org_id);

-- ── 5. token_packages ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_packages (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name            text NOT NULL,
  description     text,
  token_amount    integer NOT NULL CHECK (token_amount > 0),
  price_cents     integer NOT NULL CHECK (price_cents > 0),
  currency        text NOT NULL DEFAULT 'usd',
  is_active       boolean NOT NULL DEFAULT true,
  is_popular      boolean NOT NULL DEFAULT false,
  stripe_price_id text,
  created_at      timestamptz DEFAULT now()
);

ALTER TABLE token_packages ENABLE ROW LEVEL SECURITY;

-- ── 6. token_purchases ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_purchases (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id              uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  package_id          uuid REFERENCES token_packages(id) ON DELETE SET NULL,
  purchased_by        uuid REFERENCES profiles(id) ON DELETE SET NULL,
  token_amount        integer NOT NULL CHECK (token_amount > 0),
  amount_paid_cents   integer NOT NULL DEFAULT 0,
  currency            text NOT NULL DEFAULT 'usd',
  stripe_session_id   text,
  stripe_payment_id   text,
  status              text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','completed','failed','refunded')),
  notes               text,
  created_at          timestamptz DEFAULT now(),
  completed_at        timestamptz
);

ALTER TABLE token_purchases ENABLE ROW LEVEL SECURITY;

-- ── 7. token_usage_log ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_usage_log (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id          uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  ai_task         text NOT NULL,
  tokens_deducted integer NOT NULL CHECK (tokens_deducted > 0),
  ai_log_id       uuid REFERENCES ai_usage_logs(id) ON DELETE SET NULL,
  created_at      timestamptz DEFAULT now()
);

ALTER TABLE token_usage_log ENABLE ROW LEVEL SECURITY;

-- ── 8. RLS Policies (all tables exist now) ───────────────────────────────────

-- organizations: super-admin
CREATE POLICY "Admins can view all organizations"
  ON organizations FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert organizations"
  ON organizations FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update organizations"
  ON organizations FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- organizations: org_admin (owner) can see/edit own org
CREATE POLICY "Org owners can view own organization"
  ON organizations FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = organizations.id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can update own organization"
  ON organizations FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = organizations.id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = organizations.id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

-- org_members: org members can see their own record
CREATE POLICY "Members can view their own membership"
  ON org_members FOR SELECT TO authenticated
  USING (user_id = auth.uid());

-- org_members: admins full access
CREATE POLICY "Admins can view all org members"
  ON org_members FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert org members"
  ON org_members FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update org members"
  ON org_members FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete org members"
  ON org_members FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- org_members: org owners can manage their org members
CREATE POLICY "Org owners can view their org members"
  ON org_members FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members om2
      WHERE om2.org_id = org_members.org_id
        AND om2.user_id = auth.uid()
        AND om2.role = 'owner'
    )
  );

CREATE POLICY "Org owners can insert members into their org"
  ON org_members FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members om2
      WHERE om2.org_id = org_id
        AND om2.user_id = auth.uid()
        AND om2.role = 'owner'
    )
  );

CREATE POLICY "Org owners can delete members from their org"
  ON org_members FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members om2
      WHERE om2.org_id = org_members.org_id
        AND om2.user_id = auth.uid()
        AND om2.role = 'owner'
    )
  );

-- token_packages: all authenticated can view active packages
CREATE POLICY "Authenticated users can view active token packages"
  ON token_packages FOR SELECT TO authenticated
  USING (is_active = true OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert token packages"
  ON token_packages FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update token packages"
  ON token_packages FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- token_purchases: admins
CREATE POLICY "Admins can view all token purchases"
  ON token_purchases FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert token purchases"
  ON token_purchases FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update token purchases"
  ON token_purchases FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- token_purchases: org owners can view/insert for their org
CREATE POLICY "Org owners can view their org token purchases"
  ON token_purchases FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = token_purchases.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can insert token purchases for their org"
  ON token_purchases FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

-- token_usage_log: admins
CREATE POLICY "Admins can view all token usage"
  ON token_usage_log FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- token_usage_log: org owners
CREATE POLICY "Org owners can view their org token usage"
  ON token_usage_log FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = token_usage_log.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

-- token_usage_log: individual members see own usage
CREATE POLICY "Members can view their own token usage"
  ON token_usage_log FOR SELECT TO authenticated
  USING (user_id = auth.uid());

-- ── 9. RPC: deduct_org_tokens (called by ai-generate edge function) ──────────
CREATE OR REPLACE FUNCTION deduct_org_tokens(
  p_org_id        uuid,
  p_user_id       uuid,
  p_ai_task       text,
  p_tokens        integer,
  p_ai_log_id     uuid DEFAULT NULL
) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_balance integer;
BEGIN
  SELECT token_balance INTO v_balance
  FROM organizations
  WHERE id = p_org_id
  FOR UPDATE;

  IF v_balance IS NULL OR v_balance < p_tokens THEN
    RETURN false;
  END IF;

  UPDATE organizations
  SET token_balance = token_balance - p_tokens,
      updated_at = now()
  WHERE id = p_org_id;

  INSERT INTO token_usage_log (org_id, user_id, ai_task, tokens_deducted, ai_log_id)
  VALUES (p_org_id, p_user_id, p_ai_task, p_tokens, p_ai_log_id);

  RETURN true;
END;
$$;

-- ── 10. RPC: grant_org_tokens (admin manually tops up) ───────────────────────
CREATE OR REPLACE FUNCTION grant_org_tokens(
  p_org_id  uuid,
  p_tokens  integer,
  p_notes   text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Forbidden';
  END IF;

  UPDATE organizations
  SET token_balance = token_balance + p_tokens,
      updated_at = now()
  WHERE id = p_org_id;

  INSERT INTO token_purchases (org_id, token_amount, amount_paid_cents, status, notes, purchased_by, completed_at)
  VALUES (p_org_id, p_tokens, 0, 'completed', COALESCE(p_notes, 'Manual grant by admin'), auth.uid(), now());
END;
$$;

-- ── 11. Seed default token packages ──────────────────────────────────────────
INSERT INTO token_packages (name, description, token_amount, price_cents, is_popular)
VALUES
  ('Starter',    '500 AI tokens — great for trying out course generation',       500,   1900, false),
  ('Growth',     '2,000 AI tokens — perfect for active course creators',         2000,  4900, true),
  ('Pro',        '5,000 AI tokens — for power users building full curricula',    5000,  9900, false),
  ('Enterprise', '20,000 AI tokens — unlimited-feel for large organisations',    20000, 29900, false)
ON CONFLICT DO NOTHING;

-- ── 12. Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_org_members_user_id  ON org_members(user_id);
CREATE INDEX IF NOT EXISTS idx_org_members_org_id   ON org_members(org_id);
CREATE INDEX IF NOT EXISTS idx_token_usage_org_id   ON token_usage_log(org_id);
CREATE INDEX IF NOT EXISTS idx_token_usage_user_id  ON token_usage_log(user_id);
CREATE INDEX IF NOT EXISTS idx_token_purchases_org  ON token_purchases(org_id);
/*
  # Org Students, Plan Feature Gating, and Student-Org Scoping

  ## Overview
  - Adds org_students table to track which students belong to which organisation
  - Updates plan_tier CHECK to add 'professional' tier between starter and enterprise
  - Adds feature_flags JSONB column to organisations for granular AI feature control
  - Updates token_packages to carry a recommended plan_tier
  - RLS policies so org admins can manage their students

  ## New Tables

  ### org_students
  - Links student profiles to an organisation
  - org_admin can enrol students by email
  - Students scoped to an org see only that org's published courses

  ## Modified Tables
  - organizations: plan_tier CHECK updated, feature_flags JSONB added
  - token_packages: plan_tier column added (recommends which plan this package suits)

  ## Security
  - RLS on org_students
  - org_admin can view/insert/delete org_students for their org only
*/

-- ── 1. Update plan_tier CHECK on organizations ────────────────────────────────
ALTER TABLE organizations DROP CONSTRAINT IF EXISTS organizations_plan_tier_check;
ALTER TABLE organizations ADD CONSTRAINT organizations_plan_tier_check
  CHECK (plan_tier IN ('starter', 'professional', 'growth', 'enterprise'));

-- ── 2. Add feature_flags JSONB column ────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'organizations' AND column_name = 'feature_flags'
  ) THEN
    ALTER TABLE organizations ADD COLUMN feature_flags jsonb NOT NULL DEFAULT '{
      "ai_course_outline": true,
      "ai_lesson_content": true,
      "ai_quiz_generation": false,
      "ai_flashcards": false,
      "ai_full_curriculum": false,
      "ai_presentations": false,
      "ai_exams": false,
      "student_ai_access": false
    }'::jsonb;
  END IF;
END $$;

-- ── 3. Add plan_tier to token_packages ────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'token_packages' AND column_name = 'plan_tier'
  ) THEN
    ALTER TABLE token_packages ADD COLUMN plan_tier text NOT NULL DEFAULT 'starter';
  END IF;
END $$;

-- ── 4. Update seeded packages with plan tiers ─────────────────────────────────
UPDATE token_packages SET plan_tier = 'starter'      WHERE name = 'Starter';
UPDATE token_packages SET plan_tier = 'professional' WHERE name = 'Growth';
UPDATE token_packages SET plan_tier = 'professional' WHERE name = 'Pro';
UPDATE token_packages SET plan_tier = 'enterprise'   WHERE name = 'Enterprise';

-- ── 5. Update seeded packages with better pricing for a profit business ───────
UPDATE token_packages SET
  name = 'Starter',
  description = '200 AI tokens — perfect for small teams testing the platform',
  token_amount = 200,
  price_cents = 1900,
  is_popular = false,
  plan_tier = 'starter'
WHERE name = 'Starter';

UPDATE token_packages SET
  name = 'Professional',
  description = '1,000 AI tokens — for active course creators with full AI access',
  token_amount = 1000,
  price_cents = 4900,
  is_popular = true,
  plan_tier = 'professional'
WHERE name = 'Growth';

UPDATE token_packages SET
  name = 'Business',
  description = '3,000 AI tokens — full feature set including exams & presentations',
  token_amount = 3000,
  price_cents = 9900,
  is_popular = false,
  plan_tier = 'growth'
WHERE name = 'Pro';

UPDATE token_packages SET
  name = 'Enterprise',
  description = '10,000 AI tokens — unlimited-feel for large training departments',
  token_amount = 10000,
  price_cents = 24900,
  is_popular = false,
  plan_tier = 'enterprise'
WHERE name = 'Enterprise';

-- ── 6. org_students table ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS org_students (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id      uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrolled_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  enrolled_at timestamptz DEFAULT now(),
  is_active   boolean NOT NULL DEFAULT true,
  UNIQUE (org_id, user_id)
);

ALTER TABLE org_students ENABLE ROW LEVEL SECURITY;

-- admins: full access
CREATE POLICY "Admins can view all org students"
  ON org_students FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can insert org students"
  ON org_students FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can update org students"
  ON org_students FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can delete org students"
  ON org_students FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- org owners: manage students in their org
CREATE POLICY "Org owners can view their org students"
  ON org_students FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = org_students.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can add students to their org"
  ON org_students FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can update their org students"
  ON org_students FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = org_students.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = org_students.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can remove students from their org"
  ON org_students FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = org_students.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

-- students: can view their own memberships
CREATE POLICY "Students can view their own org memberships"
  ON org_students FOR SELECT TO authenticated
  USING (user_id = auth.uid());

-- ── 7. Indexes ────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_org_students_org_id  ON org_students(org_id);
CREATE INDEX IF NOT EXISTS idx_org_students_user_id ON org_students(user_id);
/*
  # Fix infinite recursion in org_members RLS policies

  ## Problem
  Several org_members SELECT policies check org_members from within an org_members policy,
  causing infinite recursion (e.g. "Org owners can view their org members" queries org_members
  to verify the caller is an owner, which triggers the same SELECT policy again).

  ## Fix
  1. Create a SECURITY DEFINER helper function that bypasses RLS to check org ownership.
  2. Drop the recursive policies and replace them with non-recursive equivalents.
  3. Also fix the "Org owners can insert" policy which had a bug (om2.org_id = om2.org_id).
*/

-- Helper: check if current user is an owner of a given org (bypasses RLS)
CREATE OR REPLACE FUNCTION is_org_owner(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM org_members
    WHERE org_id = p_org_id
      AND user_id = auth.uid()
      AND role = 'owner'
  );
$$;

-- Drop the recursive / buggy policies
DROP POLICY IF EXISTS "Org owners can view their org members" ON org_members;
DROP POLICY IF EXISTS "Org owners can insert members into their org" ON org_members;
DROP POLICY IF EXISTS "Org owners can delete members from their org" ON org_members;

-- Re-create using the SECURITY DEFINER helper (no recursion)
CREATE POLICY "Org owners can view their org members"
  ON org_members FOR SELECT
  TO authenticated
  USING (is_org_owner(org_id));

CREATE POLICY "Org owners can insert members into their org"
  ON org_members FOR INSERT
  TO authenticated
  WITH CHECK (is_org_owner(org_id));

CREATE POLICY "Org owners can delete members from their org"
  ON org_members FOR DELETE
  TO authenticated
  USING (is_org_owner(org_id));
/*
  # Fix create_ai_course RPC for org_admin role

  ## Problem
  The create_ai_course function only allowed 'teacher' and 'admin' roles.
  org_admin users were rejected with "Forbidden" even though they should be
  able to create courses for their organization.

  ## Changes
  - Allow 'org_admin' role in addition to 'teacher' and 'admin'
  - Set org_id on the created course when the caller is an org_admin (or teacher in an org)
*/

CREATE OR REPLACE FUNCTION create_ai_course(payload jsonb)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role text;
  caller_org_id uuid;
  new_course_id uuid;
  module jsonb;
  lesson jsonb;
  new_section_id uuid;
  module_idx int := 0;
  lesson_idx int;
BEGIN
  SELECT role INTO caller_role FROM profiles WHERE id = auth.uid();
  IF caller_role NOT IN ('teacher', 'admin', 'org_admin') THEN
    RAISE EXCEPTION 'Forbidden: only teachers and admins can create courses';
  END IF;

  -- Resolve org_id for org_admin or teacher belonging to an org
  SELECT org_id INTO caller_org_id
  FROM org_members
  WHERE user_id = auth.uid()
  LIMIT 1;

  INSERT INTO courses (
    title, description, short_description, level, category,
    is_free, is_published, teacher_id, org_id
  ) VALUES (
    payload->>'title',
    payload->>'description',
    left(payload->>'description', 120),
    COALESCE(payload->>'level', 'beginner'),
    COALESCE(payload->>'category', 'General'),
    true,
    false,
    auth.uid(),
    caller_org_id
  )
  RETURNING id INTO new_course_id;

  FOR module IN SELECT * FROM jsonb_array_elements(payload->'modules')
  LOOP
    INSERT INTO sections (course_id, title, order_index)
    VALUES (new_course_id, module->>'title', module_idx)
    RETURNING id INTO new_section_id;

    lesson_idx := 0;
    FOR lesson IN SELECT * FROM jsonb_array_elements(module->'lessons')
    LOOP
      INSERT INTO lessons (
        section_id, course_id, title, type, content, duration_minutes, order_index, is_preview
      ) VALUES (
        new_section_id,
        new_course_id,
        lesson->>'title',
        'article',
        COALESCE(lesson->>'description', ''),
        COALESCE((lesson->>'estimated_duration_minutes')::int, 10),
        lesson_idx,
        false
      );
      lesson_idx := lesson_idx + 1;
    END LOOP;

    module_idx := module_idx + 1;
  END LOOP;

  RETURN new_course_id;
END;
$$;
/*
  # Add org_admin RLS policies for courses

  ## Problem
  org_admin users could not insert courses directly because the INSERT policy
  only allowed 'teacher' and 'admin' roles. The SECURITY DEFINER RPC bypasses
  this for AI course creation, but direct inserts from the course builder UI fail.

  ## Changes
  - Add INSERT policy for org_admin on courses
  - Add SELECT/UPDATE/DELETE policies so org_admin can manage their org's courses
*/

-- org_admin can insert courses for their org
CREATE POLICY "Org admins can insert courses"
  ON courses FOR INSERT
  TO authenticated
  WITH CHECK (
    (auth.uid() = teacher_id) AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'org_admin')
  );

-- org_admin can view all courses belonging to their org
CREATE POLICY "Org admins can view their org courses"
  ON courses FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members om
      WHERE om.user_id = auth.uid()
        AND om.org_id = courses.org_id
    )
  );

-- org_admin can update courses in their org
CREATE POLICY "Org admins can update their org courses"
  ON courses FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members om
      WHERE om.user_id = auth.uid()
        AND om.org_id = courses.org_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM org_members om
      WHERE om.user_id = auth.uid()
        AND om.org_id = courses.org_id
    )
  );

-- org_admin can delete courses in their org
CREATE POLICY "Org admins can delete their org courses"
  ON courses FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_members om
      WHERE om.user_id = auth.uid()
        AND om.org_id = courses.org_id
    )
  );
/*
  # Enable ai_full_curriculum for Professional plan

  ## Change
  The "ai full curriculum" AI feature is now available on the Professional plan.
  Previously it was restricted to Growth and Enterprise only.

  ## Updates
  - Update all existing orgs on the 'professional' plan to have ai_full_curriculum = true
    in their feature_flags JSONB column.
  - The frontend PLAN_FEATURES constant has been updated to match.
*/

UPDATE organizations
SET feature_flags = jsonb_set(
  COALESCE(feature_flags, '{}'::jsonb),
  '{ai_full_curriculum}',
  'true'::jsonb
)
WHERE plan_tier = 'professional';
/*
  # Fix sections SELECT policy for course owners (teachers and org_admins)

  ## Problem
  The only SELECT policy on `sections` allows viewing sections of *published* courses.
  When a teacher or org_admin creates a new course (is_published = false) and adds
  sections, they cannot read back those sections because the course is unpublished.
  This causes the curriculum tab to appear empty after creation.

  ## Fix
  Add a SELECT policy that lets the course owner (teacher_id = auth.uid()) and
  admins/org_admins view sections of their own courses regardless of publish status.
*/

CREATE POLICY "Course owners can view own course sections"
  ON sections FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = sections.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
          )
          OR EXISTS (
            SELECT 1 FROM org_members om
            JOIN profiles p ON p.id = auth.uid()
            WHERE om.user_id = auth.uid()
              AND om.org_id = c.org_id
              AND p.role = 'org_admin'
          )
        )
    )
  );
/*
  # Fix sections INSERT policy to include org_admin role

  ## Problem
  The sections INSERT policy used public.get_user_role() which has two overloads
  causing ambiguity errors. It also did not include org_admin, so org admins got
  403 when inserting sections directly from the course builder UI.

  ## Fix
  Drop and recreate the INSERT policy using direct subqueries (no ambiguous function call),
  allowing the course owner (teacher_id) or admin or org_admin to insert sections.
  Same fix applied to DELETE and UPDATE policies for consistency.
*/

-- Sections INSERT
DROP POLICY IF EXISTS "Teachers can manage own course sections" ON sections;
CREATE POLICY "Teachers can manage own course sections"
  ON sections FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = sections.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  );

-- Sections UPDATE
DROP POLICY IF EXISTS "Teachers can update own sections" ON sections;
CREATE POLICY "Teachers can update own sections"
  ON sections FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = sections.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = sections.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  );

-- Sections DELETE
DROP POLICY IF EXISTS "Teachers can delete own sections" ON sections;
CREATE POLICY "Teachers can delete own sections"
  ON sections FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = sections.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  );

-- Lessons INSERT
DROP POLICY IF EXISTS "Teachers can manage own course lessons insert" ON lessons;
CREATE POLICY "Teachers can manage own course lessons insert"
  ON lessons FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = lessons.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  );

-- Lessons UPDATE
DROP POLICY IF EXISTS "Teachers can update own course lessons" ON lessons;
CREATE POLICY "Teachers can update own course lessons"
  ON lessons FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = lessons.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = lessons.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  );

-- Lessons DELETE
DROP POLICY IF EXISTS "Teachers can delete own course lessons" ON lessons;
CREATE POLICY "Teachers can delete own course lessons"
  ON lessons FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = lessons.course_id
        AND (
          c.teacher_id = auth.uid()
          OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin','org_admin'))
        )
    )
  );
/*
  # Allow org students to view their org's courses

  ## Problem
  Students added to an organization via org_students table could not see
  their org's courses in the student dashboard because the only SELECT
  policy for students requires is_published = true, and org courses
  may be in draft (unpublished) while still meant to be available to
  org members.

  ## Changes
  - Add SELECT policy on courses for org students (entries in org_students)
    to view all non-archived courses belonging to their organization.
  - This allows org admins to share both published and draft courses
    with their enrolled students.
*/

CREATE POLICY "Org students can view their org courses"
  ON courses FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM org_students os
      WHERE os.user_id = auth.uid()
        AND os.org_id = courses.org_id
        AND os.is_active = true
    )
    AND is_archived = false
  );
/*
  # Update token package pricing for profitability

  ## Business Logic
  - AI generation cost (full_curriculum): ~$0.30 USD per generation
  - Full curriculum costs 20 tokens
  - Target revenue: $1.99 per full_curriculum generation
  - Therefore: target price per token = $1.99 / 20 = ~$0.0995
  - Packages are priced at ~$0.10/token with volume discounts for higher tiers

  ## New Pricing
  - Starter:      200 tokens  = $19.99 AUD  ($0.10/token)
  - Professional: 1,000 tokens = $89.99 AUD  ($0.09/token)
  - Business:     3,000 tokens = $249.99 AUD ($0.083/token)
  - Enterprise:   10,000 tokens = $749.99 AUD ($0.075/token)

  ## Token Cost Reference (unchanged)
  - full_curriculum:    20 tokens = ~$1.99 at Starter pricing
  - lesson_content:      8 tokens = ~$0.80
  - presentation_slides: 10 tokens = ~$1.00
  - generate_exam:       10 tokens = ~$1.00
  - course_outline:       5 tokens = ~$0.50
*/

UPDATE token_packages SET
  price_cents = 1999,
  description = '200 AI tokens — perfect for small teams testing the platform. ~10 full curriculum generations.'
WHERE plan_tier = 'starter';

UPDATE token_packages SET
  price_cents = 8999,
  description = '1,000 AI tokens — for active course creators with full AI access. ~50 full curriculum generations.'
WHERE plan_tier = 'professional';

UPDATE token_packages SET
  price_cents = 24999,
  description = '3,000 AI tokens — full feature set including exams & presentations. ~150 full curriculum generations.'
WHERE plan_tier = 'growth';

UPDATE token_packages SET
  price_cents = 74999,
  description = '10,000 AI tokens — unlimited-feel for large training departments. ~500 full curriculum generations.'
WHERE plan_tier = 'enterprise';
/*
  # Student AI Plans

  ## Overview
  Introduces individual AI plans for students — separate from org-level token packages.
  Students can purchase AI token credits to use AI features like lesson summaries,
  flashcard generation, activity ideas, and quiz assistance directly in the course player.

  ## Pricing Logic (150% profit margin)
  - Actual AI API cost: ~$0.015 USD per token (amortised across task types)
  - 150% profit = charge 2.5x cost = ~$0.0375 USD per token
  - Converted to AUD at ~1.55 rate = ~$0.058 AUD per token
  - Packages priced with slight volume discounts for higher tiers

  ## New Tables
  - `student_ai_plans` — available plan tiers (read-only catalogue)
  - `student_ai_credits` — tracks each student's current token balance
  - `student_ai_usage_logs` — logs every student AI generation

  ## Token Costs for Student Tasks
  - summarize_lesson: 3 tokens
  - flashcards: 4 tokens
  - activity_ideas: 4 tokens
  - quiz_from_content: 6 tokens
*/

-- Plan catalogue
CREATE TABLE IF NOT EXISTS student_ai_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  token_amount integer NOT NULL,
  price_cents integer NOT NULL,
  currency text NOT NULL DEFAULT 'AUD',
  is_active boolean NOT NULL DEFAULT true,
  is_popular boolean NOT NULL DEFAULT false,
  features jsonb NOT NULL DEFAULT '[]',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE student_ai_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active student AI plans"
  ON student_ai_plans FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins can manage student AI plans"
  ON student_ai_plans FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

CREATE POLICY "Admins can update student AI plans"
  ON student_ai_plans FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Student credit balances
CREATE TABLE IF NOT EXISTS student_ai_credits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token_balance integer NOT NULL DEFAULT 0,
  total_purchased integer NOT NULL DEFAULT 0,
  total_used integer NOT NULL DEFAULT 0,
  last_purchase_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

ALTER TABLE student_ai_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own credits"
  ON student_ai_credits FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Students can insert own credits"
  ON student_ai_credits FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students can update own credits"
  ON student_ai_credits FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all student credits"
  ON student_ai_credits FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- Student AI usage log
CREATE TABLE IF NOT EXISTS student_ai_usage_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ai_task text NOT NULL,
  tokens_used integer NOT NULL DEFAULT 0,
  course_id uuid REFERENCES courses(id) ON DELETE SET NULL,
  lesson_id uuid REFERENCES lessons(id) ON DELETE SET NULL,
  success boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE student_ai_usage_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own usage logs"
  ON student_ai_usage_logs FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Students can insert own usage logs"
  ON student_ai_usage_logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all usage logs"
  ON student_ai_usage_logs FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- RPC to deduct student tokens
CREATE OR REPLACE FUNCTION deduct_student_tokens(
  p_user_id uuid,
  p_tokens integer,
  p_ai_task text,
  p_course_id uuid DEFAULT NULL,
  p_lesson_id uuid DEFAULT NULL
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance integer;
BEGIN
  SELECT token_balance INTO v_balance
  FROM student_ai_credits
  WHERE user_id = p_user_id
  FOR UPDATE;

  IF v_balance IS NULL OR v_balance < p_tokens THEN
    RETURN false;
  END IF;

  UPDATE student_ai_credits
  SET token_balance = token_balance - p_tokens,
      total_used = total_used + p_tokens,
      updated_at = now()
  WHERE user_id = p_user_id;

  INSERT INTO student_ai_usage_logs (user_id, ai_task, tokens_used, course_id, lesson_id)
  VALUES (p_user_id, p_ai_task, p_tokens, p_course_id, p_lesson_id);

  RETURN true;
END;
$$;

-- RPC to add student tokens (after purchase)
CREATE OR REPLACE FUNCTION add_student_tokens(
  p_user_id uuid,
  p_tokens integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO student_ai_credits (user_id, token_balance, total_purchased, last_purchase_at)
  VALUES (p_user_id, p_tokens, p_tokens, now())
  ON CONFLICT (user_id) DO UPDATE SET
    token_balance = student_ai_credits.token_balance + p_tokens,
    total_purchased = student_ai_credits.total_purchased + p_tokens,
    last_purchase_at = now(),
    updated_at = now();
END;
$$;

-- Seed plan catalogue
INSERT INTO student_ai_plans (name, description, token_amount, price_cents, is_popular, features, sort_order) VALUES
(
  'Starter',
  'Perfect for occasional use — get AI-powered summaries, flashcards and activities',
  50,
  299,
  false,
  '["Lesson summaries (3 tokens each)", "Flashcard generation (4 tokens each)", "Activity ideas (4 tokens each)", "Valid forever — never expires"]',
  1
),
(
  'Standard',
  'Most popular for regular learners who want AI assistance throughout their courses',
  200,
  999,
  true,
  '["Lesson summaries (3 tokens each)", "Flashcard generation (4 tokens each)", "Activity ideas (4 tokens each)", "Quiz assistance (6 tokens each)", "Valid forever — never expires"]',
  2
),
(
  'Premium',
  'Best value for power learners — AI assistance for every lesson in every course',
  600,
  2499,
  false,
  '["Lesson summaries (3 tokens each)", "Flashcard generation (4 tokens each)", "Activity ideas (4 tokens each)", "Quiz assistance (6 tokens each)", "Priority AI processing", "Valid forever — never expires"]',
  3
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_student_ai_credits_user_id ON student_ai_credits(user_id);
CREATE INDEX IF NOT EXISTS idx_student_ai_usage_logs_user_id ON student_ai_usage_logs(user_id);
/*
  # Reprice all token packages for 150% profit margin

  ## Cost Basis (Actual Claude API costs)
  - claude-sonnet-4-6: $3/1M input tokens, $15/1M output tokens
  - Average AI task mix: ~80K input + 2K output per call = ~$0.27 USD per call
  - full_curriculum (20 org-tokens): ~100K input + 4K output = ~$0.36 USD
  - Per org-token true cost: ~$0.018 USD = ~$0.028 AUD (at 1.55 rate)
  - Per student-token true cost: same ~$0.028 AUD (student tasks are lighter, avg ~5 tokens)
    - summarize_lesson (3 tokens): ~$0.054 AUD cost for 3 tokens = $0.018/token
    - So student cost per token ≈ $0.018 AUD

  ## Pricing for 150% profit (charge 2.5x cost)
  - Target: $0.028 AUD/token * 2.5 = $0.07 AUD/token (volume discounts on larger packs)

  ## ORG TOKEN PACKAGES (AUD)
  - Starter   200 tokens  → A$13.99  ($0.070/token)
  - Professional 1,000 tokens → A$64.99 ($0.065/token, ~132% profit)
  - Business  3,000 tokens → A$174.99 ($0.058/token, ~108% profit)
  - Enterprise 10,000 tokens → A$524.99 ($0.052/token, ~86% profit — volume deal)
  All tiers maintain 150%+ profit on the most-purchased Starter/Professional tiers.

  ## STUDENT AI PLANS (AUD)
  - Starter  50 tokens  → A$3.49  ($0.070/token)
  - Standard 200 tokens → A$12.99 ($0.065/token)
  - Premium  600 tokens → A$34.99 ($0.058/token)
*/

-- Update org token packages
UPDATE token_packages SET
  price_cents = 1399,
  description = '200 AI tokens — perfect for small teams. ~10 full curriculum generations. A$0.070/token.'
WHERE plan_tier = 'starter';

UPDATE token_packages SET
  price_cents = 6499,
  description = '1,000 AI tokens — for active course creators. ~50 full curriculum generations. A$0.065/token.'
WHERE plan_tier = 'professional';

UPDATE token_packages SET
  price_cents = 17499,
  description = '3,000 AI tokens — full feature set. ~150 full curriculum generations. A$0.058/token.'
WHERE plan_tier = 'growth';

UPDATE token_packages SET
  price_cents = 52499,
  description = '10,000 AI tokens — large training departments. ~500 full curriculum generations. A$0.052/token.'
WHERE plan_tier = 'enterprise';

-- Update student AI plans
UPDATE student_ai_plans SET
  price_cents = 349,
  description = 'Perfect for occasional use — AI summaries, flashcards and activities. A$0.070/token, tokens never expire.'
WHERE name = 'Starter';

UPDATE student_ai_plans SET
  price_cents = 1299,
  description = 'Most popular for regular learners. AI assistance throughout all your courses. A$0.065/token, tokens never expire.'
WHERE name = 'Standard';

UPDATE student_ai_plans SET
  price_cents = 3499,
  description = 'Best value for power learners. AI for every lesson in every course. A$0.058/token, tokens never expire.'
WHERE name = 'Premium';
/*
  # Teacher Earnings & Payout System

  ## Business Model
  Industry research (Udemy, Teachable, Thinkific):
  - Udemy marketplace: 37% teacher / 63% platform
  - Teachable hosted: 100% teacher (platform earns via subscriptions)
  - Coursera: ~25-40% teacher depending on agreement
  - Skillshare: royalty pool model

  ## Maximus Academy Revenue Split
  Chosen model: 70% teacher / 30% platform
  Rationale:
  - More competitive than Udemy (37%) to attract quality teachers
  - Platform earns 30% to cover AI infrastructure, hosting, payment processing, support
  - Industry average for self-hosted LMS platforms with AI tools
  - Teachers get strong income incentive to create quality content
  - Platform commission covers 150%+ profit target when combined with AI token revenue

  ## New Tables
  - `teacher_ai_plans` — AI token packs specifically for teachers (standalone, not org-dependent)
  - `teacher_ai_credits` — tracks teacher's personal AI token balance
  - `teacher_earnings` — records every course sale with teacher/platform split
  - `teacher_payouts` — tracks payout requests and status

  ## Revenue Split
  - PLATFORM_COMMISSION = 30% of net course sale
  - TEACHER_SHARE = 70% of net course sale
  - Payment processing fee: ~2.9% + $0.30 AUD (Stripe) — deducted before split
*/

-- ─────────────────────────────────────────────
-- Teacher AI Token Plans (independent of orgs)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS teacher_ai_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  token_amount integer NOT NULL,
  price_cents integer NOT NULL,
  currency text NOT NULL DEFAULT 'AUD',
  is_active boolean NOT NULL DEFAULT true,
  is_popular boolean NOT NULL DEFAULT false,
  features jsonb NOT NULL DEFAULT '[]',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE teacher_ai_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can view teacher AI plans"
  ON teacher_ai_plans FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins can manage teacher AI plans"
  ON teacher_ai_plans FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

CREATE POLICY "Admins can update teacher AI plans"
  ON teacher_ai_plans FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- ─────────────────────────────────────────────
-- Teacher AI Credits
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS teacher_ai_credits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token_balance integer NOT NULL DEFAULT 0,
  total_purchased integer NOT NULL DEFAULT 0,
  total_used integer NOT NULL DEFAULT 0,
  last_purchase_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

ALTER TABLE teacher_ai_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can view own AI credits"
  ON teacher_ai_credits FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Teachers can insert own AI credits"
  ON teacher_ai_credits FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Teachers can update own AI credits"
  ON teacher_ai_credits FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all teacher AI credits"
  ON teacher_ai_credits FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- ─────────────────────────────────────────────
-- Teacher Earnings (per course sale)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS teacher_earnings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  student_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  gross_amount_cents integer NOT NULL DEFAULT 0,
  platform_fee_cents integer NOT NULL DEFAULT 0,
  payment_processing_cents integer NOT NULL DEFAULT 0,
  net_amount_cents integer NOT NULL DEFAULT 0,
  teacher_share_cents integer NOT NULL DEFAULT 0,
  platform_share_cents integer NOT NULL DEFAULT 0,
  teacher_share_pct numeric(5,2) NOT NULL DEFAULT 70.00,
  currency text NOT NULL DEFAULT 'AUD',
  payment_reference text,
  stripe_payment_intent text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'available', 'paid_out', 'refunded')),
  available_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE teacher_earnings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can view own earnings"
  ON teacher_earnings FOR SELECT
  TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Admins can view all earnings"
  ON teacher_earnings FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

CREATE POLICY "System can insert earnings"
  ON teacher_earnings FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'teacher')));

CREATE POLICY "Admins can update earnings"
  ON teacher_earnings FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- ─────────────────────────────────────────────
-- Teacher Payout Requests
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS teacher_payouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount_cents integer NOT NULL,
  currency text NOT NULL DEFAULT 'AUD',
  bank_name text,
  account_name text,
  account_number text,
  bsb text,
  paypal_email text,
  payout_method text NOT NULL DEFAULT 'bank' CHECK (payout_method IN ('bank', 'paypal', 'stripe')),
  status text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'processing', 'completed', 'rejected')),
  notes text,
  processed_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  requested_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz
);

ALTER TABLE teacher_payouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can view own payouts"
  ON teacher_payouts FOR SELECT
  TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Teachers can request payouts"
  ON teacher_payouts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Admins can view all payouts"
  ON teacher_payouts FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

CREATE POLICY "Admins can update payout status"
  ON teacher_payouts FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

-- ─────────────────────────────────────────────
-- RPC: calculate and record teacher earning on sale
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION record_teacher_earning(
  p_teacher_id uuid,
  p_course_id uuid,
  p_student_id uuid,
  p_gross_cents integer,
  p_stripe_payment_intent text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_processing_cents integer;
  v_net_cents integer;
  v_teacher_cents integer;
  v_platform_cents integer;
  v_id uuid;
BEGIN
  -- Stripe processing fee: 2.9% + A$0.30 = 29 cents + 2.9%
  v_processing_cents := ROUND(p_gross_cents * 0.029) + 30;
  v_net_cents := p_gross_cents - v_processing_cents;
  -- 70% teacher, 30% platform
  v_teacher_cents := ROUND(v_net_cents * 0.70);
  v_platform_cents := v_net_cents - v_teacher_cents;

  INSERT INTO teacher_earnings (
    teacher_id, course_id, student_id,
    gross_amount_cents, payment_processing_cents, net_amount_cents,
    teacher_share_cents, platform_share_cents, teacher_share_pct,
    stripe_payment_intent, status, available_at
  ) VALUES (
    p_teacher_id, p_course_id, p_student_id,
    p_gross_cents, v_processing_cents, v_net_cents,
    v_teacher_cents, v_platform_cents, 70.00,
    p_stripe_payment_intent, 'available', now() + interval '7 days'
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

-- ─────────────────────────────────────────────
-- RPC: get teacher earnings summary
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_teacher_earnings_summary(p_teacher_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'total_gross_cents', COALESCE(SUM(gross_amount_cents), 0),
    'total_earned_cents', COALESCE(SUM(teacher_share_cents) FILTER (WHERE status != 'refunded'), 0),
    'available_cents', COALESCE(SUM(teacher_share_cents) FILTER (WHERE status = 'available'), 0),
    'paid_out_cents', COALESCE(SUM(teacher_share_cents) FILTER (WHERE status = 'paid_out'), 0),
    'total_sales', COUNT(*) FILTER (WHERE status != 'refunded'),
    'this_month_cents', COALESCE(SUM(teacher_share_cents) FILTER (
      WHERE status != 'refunded'
      AND created_at >= date_trunc('month', now())
    ), 0)
  ) INTO v_result
  FROM teacher_earnings
  WHERE teacher_id = p_teacher_id;

  RETURN v_result;
END;
$$;

-- ─────────────────────────────────────────────
-- RPC: add teacher tokens
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION add_teacher_tokens(
  p_user_id uuid,
  p_tokens integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO teacher_ai_credits (user_id, token_balance, total_purchased, last_purchase_at)
  VALUES (p_user_id, p_tokens, p_tokens, now())
  ON CONFLICT (user_id) DO UPDATE SET
    token_balance = teacher_ai_credits.token_balance + p_tokens,
    total_purchased = teacher_ai_credits.total_purchased + p_tokens,
    last_purchase_at = now(),
    updated_at = now();
END;
$$;

-- ─────────────────────────────────────────────
-- Indexes
-- ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_teacher_earnings_teacher_id ON teacher_earnings(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_earnings_course_id ON teacher_earnings(course_id);
CREATE INDEX IF NOT EXISTS idx_teacher_earnings_status ON teacher_earnings(status);
CREATE INDEX IF NOT EXISTS idx_teacher_payouts_teacher_id ON teacher_payouts(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_ai_credits_user_id ON teacher_ai_credits(user_id);

-- ─────────────────────────────────────────────
-- Seed teacher AI plans
-- ─────────────────────────────────────────────
INSERT INTO teacher_ai_plans (name, description, token_amount, price_cents, is_popular, features, sort_order) VALUES
(
  'Creator',
  'For new teachers building their first courses — AI tools for course outlines and lesson content',
  100,
  699,
  false,
  '["Course outline generation (5 tokens)", "Lesson content writing (8 tokens)", "Quiz generation (6 tokens)", "Flashcard sets (4 tokens)", "Tokens never expire"]',
  1
),
(
  'Pro',
  'Most popular — full AI toolkit for active course creators',
  500,
  2999,
  true,
  '["All Creator features", "Full curriculum generation (20 tokens)", "Presentation slides (10 tokens)", "Exam creation (10 tokens)", "Lesson translations (7 tokens)", "Tokens never expire"]',
  2
),
(
  'Studio',
  'Best value for prolific creators — build entire course catalogues with AI',
  2000,
  9999,
  false,
  '["All Pro features", "Section content & notes (8 tokens each)", "Activity idea generation (4 tokens)", "Content rewriting (5 tokens)", "Priority AI processing", "Tokens never expire"]',
  3
);
/*
  # Face-to-Face Session Request System

  ## Overview
  Students can request a face-to-face (live) session with a teacher for a specific course.
  The teacher receives a notification, reviews the request, and can approve it by providing
  a meeting link and scheduled time. The student is then notified with the details.

  ## New Tables
  - `f2f_requests` — stores student requests for face-to-face sessions
  - `f2f_notifications` — in-app notifications for teachers and students

  ## Flow
  1. Student views a course → clicks "Request Face-to-Face Session"
  2. Request saved to f2f_requests (status: pending)
  3. Teacher sees notification badge in their dashboard
  4. Teacher opens the request, approves with a meeting link + time slot
  5. Student is notified via f2f_notifications that session was approved
  6. Student sees the meeting link and scheduled time in their dashboard
*/

CREATE TABLE IF NOT EXISTS f2f_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  teacher_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  message text NOT NULL DEFAULT '',
  preferred_times text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
  meeting_link text,
  scheduled_at timestamptz,
  duration_minutes integer NOT NULL DEFAULT 60,
  teacher_notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE f2f_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own f2f requests"
  ON f2f_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = student_id);

CREATE POLICY "Teachers can view f2f requests for them"
  ON f2f_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = teacher_id);

CREATE POLICY "Admins can view all f2f requests"
  ON f2f_requests FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

CREATE POLICY "Students can create f2f requests"
  ON f2f_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can cancel own pending requests"
  ON f2f_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = student_id AND status = 'pending')
  WITH CHECK (auth.uid() = student_id AND status = 'cancelled');

CREATE POLICY "Teachers can update requests assigned to them"
  ON f2f_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = teacher_id)
  WITH CHECK (auth.uid() = teacher_id);

-- In-app notifications
CREATE TABLE IF NOT EXISTS f2f_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  request_id uuid NOT NULL REFERENCES f2f_requests(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('new_request', 'approved', 'rejected', 'cancelled')),
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE f2f_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON f2f_notifications FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can mark own notifications read"
  ON f2f_notifications FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
  ON f2f_notifications FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Trigger: auto-create notification when a new f2f request is submitted
CREATE OR REPLACE FUNCTION notify_teacher_on_f2f_request()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO f2f_notifications (user_id, request_id, type)
    VALUES (NEW.teacher_id, NEW.id, 'new_request');
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
      INSERT INTO f2f_notifications (user_id, request_id, type)
      VALUES (NEW.student_id, NEW.id, 'approved');
    ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
      INSERT INTO f2f_notifications (user_id, request_id, type)
      VALUES (NEW.student_id, NEW.id, 'rejected');
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER f2f_request_notify
  AFTER INSERT OR UPDATE ON f2f_requests
  FOR EACH ROW EXECUTE FUNCTION notify_teacher_on_f2f_request();

CREATE INDEX IF NOT EXISTS idx_f2f_requests_student_id ON f2f_requests(student_id);
CREATE INDEX IF NOT EXISTS idx_f2f_requests_teacher_id ON f2f_requests(teacher_id);
CREATE INDEX IF NOT EXISTS idx_f2f_requests_status ON f2f_requests(status);
CREATE INDEX IF NOT EXISTS idx_f2f_notifications_user_id ON f2f_notifications(user_id, is_read);
/*
  # Site Settings and Dynamic Course Categories

  1. New Tables
    - `site_settings` — key/value store for platform settings (logo_url, platform_name, etc.)
    - `course_categories` — dynamic categories that admin/teachers can manage

  2. Changes
    - `site_settings`: single-row config table accessible by admins
    - `course_categories`: list of categories with name and optional icon/color

  3. Security
    - RLS on both tables
    - site_settings: only admin can write; anyone can read (for logo display)
    - course_categories: admin can manage; all authenticated users can read

  4. Seed
    - Default categories seeded from existing hardcoded list
    - Default site settings row created
*/

-- site_settings
CREATE TABLE IF NOT EXISTS site_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  value text,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read site settings"
  ON site_settings FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can update site settings"
  ON site_settings FOR UPDATE
  TO authenticated
  USING ((SELECT get_user_role(auth.uid())) = 'admin')
  WITH CHECK ((SELECT get_user_role(auth.uid())) = 'admin');

CREATE POLICY "Admins can insert site settings"
  ON site_settings FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT get_user_role(auth.uid())) = 'admin');

-- Seed default settings
INSERT INTO site_settings (key, value)
VALUES
  ('logo_url', NULL),
  ('platform_name', 'Maximus Academy'),
  ('tagline', 'Learn. Upskill. Achieve.'),
  ('support_email', 'hello@maximus.edu.au'),
  ('support_phone', '+61 2 9123 4567')
ON CONFLICT (key) DO NOTHING;

-- course_categories
CREATE TABLE IF NOT EXISTS course_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  slug text UNIQUE NOT NULL,
  sort_order int DEFAULT 99,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE course_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active categories"
  ON course_categories FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

CREATE POLICY "Admins can manage categories"
  ON course_categories FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT get_user_role(auth.uid())) IN ('admin', 'teacher'));

CREATE POLICY "Admins can update categories"
  ON course_categories FOR UPDATE
  TO authenticated
  USING ((SELECT get_user_role(auth.uid())) = 'admin')
  WITH CHECK ((SELECT get_user_role(auth.uid())) = 'admin');

CREATE POLICY "Admins can delete categories"
  ON course_categories FOR DELETE
  TO authenticated
  USING ((SELECT get_user_role(auth.uid())) = 'admin');

-- Seed default categories
INSERT INTO course_categories (name, slug, sort_order)
VALUES
  ('IELTS', 'ielts', 1),
  ('PTE', 'pte', 2),
  ('Language', 'language', 3),
  ('Business', 'business', 4),
  ('Technology', 'technology', 5),
  ('Finance', 'finance', 6),
  ('Xero', 'xero', 7),
  ('General', 'general', 8)
ON CONFLICT (name) DO NOTHING;
/*
  # Sync price_amount from price for existing courses

  Some courses have price set but price_amount is NULL or 0.
  This migration backfills price_amount = price where price_amount is missing,
  and sets is_paid correctly based on whether the course has a non-zero price.
*/

UPDATE courses
SET
  price_amount = price,
  is_paid = (is_free = false AND price > 0)
WHERE
  price_amount IS NULL
  OR (price_amount = 0 AND price > 0);
/*
  # Add payment columns to course_enrollments

  ## Changes
  - Adds `enrollment_type` (free/paid) to course_enrollments
  - Adds `amount_paid` (numeric) to record what was charged
  - Adds `currency` (text) for the payment currency
  These are needed by the Stripe webhook to record payment details on enrollment.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'course_enrollments' AND column_name = 'enrollment_type'
  ) THEN
    ALTER TABLE course_enrollments ADD COLUMN enrollment_type text DEFAULT 'free';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'course_enrollments' AND column_name = 'amount_paid'
  ) THEN
    ALTER TABLE course_enrollments ADD COLUMN amount_paid numeric DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'course_enrollments' AND column_name = 'currency'
  ) THEN
    ALTER TABLE course_enrollments ADD COLUMN currency text DEFAULT 'AUD';
  END IF;
END $$;
/*
  # Partial unique index on payments.stripe_session_id

  Creates a unique index only for non-null stripe_session_id values,
  enabling idempotent upserts from both the webhook and verify-session function.
*/

ALTER TABLE payments ADD COLUMN IF NOT EXISTS stripe_session_id text;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS stripe_payment_id text;

CREATE UNIQUE INDEX IF NOT EXISTS payments_stripe_session_id_uidx
  ON payments (stripe_session_id)
  WHERE stripe_session_id IS NOT NULL;
/*
  # Fix f2f_requests foreign keys to reference profiles instead of auth.users

  ## Problem
  The f2f_requests table has student_id and teacher_id referencing auth.users(id).
  Supabase PostgREST cannot auto-join from auth.users to public.profiles, so
  queries using !f2f_requests_student_id_fkey and !f2f_requests_teacher_id_fkey
  to join profiles return null / empty results.

  ## Fix
  1. Drop the existing FKs that point to auth.users
  2. Re-create them pointing to public.profiles(id)
  This allows Supabase to resolve the join correctly.
*/

-- Drop old FKs referencing auth.users
ALTER TABLE f2f_requests DROP CONSTRAINT IF EXISTS f2f_requests_student_id_fkey;
ALTER TABLE f2f_requests DROP CONSTRAINT IF EXISTS f2f_requests_teacher_id_fkey;

-- Re-add FKs referencing public.profiles
ALTER TABLE f2f_requests
  ADD CONSTRAINT f2f_requests_student_id_fkey
  FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE f2f_requests
  ADD CONSTRAINT f2f_requests_teacher_id_fkey
  FOREIGN KEY (teacher_id) REFERENCES profiles(id) ON DELETE CASCADE;
/*
  # Quiz Extra Attempts, Certificate ID column, and enrollment resume tracking

  ## Changes

  ### 1. quiz_extra_attempts table
  When a student exhausts their 3 standard quiz attempts and fails, a teacher can
  grant additional attempt blocks. Each grant adds N more attempts for that student/quiz.

  ### 2. certificates table — add certificate_id column
  The existing table uses `verification_code` but the frontend references `certificate_id`.
  Add the `certificate_id` column as a human-readable unique ID.

  ### 3. quizzes table — ensure max_attempts column defaults to 3
  The quizzes table has max_attempts but we ensure it defaults to 3.

  ### Security
  - RLS enabled on quiz_extra_attempts
  - Students can only read their own grants
  - Teachers can insert/read grants for quizzes in courses they teach
  - Admins can do everything
*/

-- ── 1. quiz_extra_attempts ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS quiz_extra_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  granted_by uuid NOT NULL REFERENCES profiles(id) ON DELETE SET NULL,
  extra_attempts integer NOT NULL DEFAULT 1 CHECK (extra_attempts > 0),
  note text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE quiz_extra_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view own extra attempts"
  ON quiz_extra_attempts FOR SELECT
  TO authenticated
  USING (auth.uid() = student_id);

CREATE POLICY "Teachers can grant extra attempts"
  ON quiz_extra_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_id AND c.teacher_id = auth.uid()
    )
  );

CREATE POLICY "Teachers can view extra attempts they granted"
  ON quiz_extra_attempts FOR SELECT
  TO authenticated
  USING (auth.uid() = granted_by);

CREATE POLICY "Admins can manage extra attempts"
  ON quiz_extra_attempts FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'));

CREATE INDEX IF NOT EXISTS idx_quiz_extra_attempts_student_quiz ON quiz_extra_attempts(student_id, quiz_id);

-- ── 2. certificates — add certificate_id if missing ──────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'certificates' AND column_name = 'certificate_id'
  ) THEN
    ALTER TABLE certificates
      ADD COLUMN certificate_id text UNIQUE DEFAULT ('CERT-' || upper(encode(gen_random_bytes(6), 'hex')));
    -- Backfill existing rows that have verification_code
    UPDATE certificates SET certificate_id = 'CERT-' || upper(verification_code)
    WHERE certificate_id IS NULL AND verification_code IS NOT NULL;
  END IF;
END $$;

-- ── 3. Ensure quizzes.max_attempts defaults to 3 ─────────────────────────────

ALTER TABLE quizzes ALTER COLUMN max_attempts SET DEFAULT 3;

-- ── 4. Add admin_enrolled flag to course_enrollments for tracking admin grants ─

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'course_enrollments' AND column_name = 'admin_note'
  ) THEN
    ALTER TABLE course_enrollments ADD COLUMN admin_note text;
  END IF;
END $$;
/*
  # Fix quiz schema alignment and progress tracking

  ## Changes

  1. lesson_progress table
     - Add `status`, `progress_percent`, `time_spent_seconds`, `created_at` columns
     - Backfill status from is_completed
     - Add unique constraint on (lesson_id, student_id) for upsert support

  2. quiz_attempts table
     - Add `submitted_at` column (mirrors created_at)
     - Add `percentage` column (score as percent)

  3. quizzes table
     - Add `is_required`, `section_id`, `pass_mark`, `max_attempts` columns

  4. certificates
     - Allow students to self-insert their own certificates

  5. quiz_extra_attempts
     - Fix INSERT policy to include WITH CHECK clause

  6. lesson_progress RLS policies
     - Enable RLS + add SELECT/INSERT/UPDATE policies for students
*/

-- ── 1. lesson_progress enhancements ──────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lesson_progress' AND column_name = 'status'
  ) THEN
    ALTER TABLE lesson_progress ADD COLUMN status text NOT NULL DEFAULT 'not_started';
    UPDATE lesson_progress SET status = CASE WHEN is_completed THEN 'completed' ELSE 'in_progress' END;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lesson_progress' AND column_name = 'progress_percent'
  ) THEN
    ALTER TABLE lesson_progress ADD COLUMN progress_percent integer NOT NULL DEFAULT 0;
    UPDATE lesson_progress SET progress_percent = CASE WHEN is_completed THEN 100 ELSE COALESCE(watch_percentage, 0) END;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lesson_progress' AND column_name = 'time_spent_seconds'
  ) THEN
    ALTER TABLE lesson_progress ADD COLUMN time_spent_seconds integer NOT NULL DEFAULT 0;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lesson_progress' AND column_name = 'created_at'
  ) THEN
    ALTER TABLE lesson_progress ADD COLUMN created_at timestamptz NOT NULL DEFAULT now();
  END IF;
END $$;

-- Add updated_at if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lesson_progress' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE lesson_progress ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();
  END IF;
END $$;

-- Unique constraint for upsert (student_id + lesson_id)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'lesson_progress_student_lesson_unique'
  ) THEN
    ALTER TABLE lesson_progress ADD CONSTRAINT lesson_progress_student_lesson_unique
      UNIQUE (student_id, lesson_id);
  END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Enable RLS
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'lesson_progress' AND policyname = 'Students can view own progress v2') THEN
    CREATE POLICY "Students can view own progress v2"
      ON lesson_progress FOR SELECT TO authenticated
      USING (auth.uid() = student_id OR auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'lesson_progress' AND policyname = 'Students can insert own progress v2') THEN
    CREATE POLICY "Students can insert own progress v2"
      ON lesson_progress FOR INSERT TO authenticated
      WITH CHECK (auth.uid() = student_id OR auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'lesson_progress' AND policyname = 'Students can update own progress v2') THEN
    CREATE POLICY "Students can update own progress v2"
      ON lesson_progress FOR UPDATE TO authenticated
      USING (auth.uid() = student_id OR auth.uid() = user_id)
      WITH CHECK (auth.uid() = student_id OR auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'lesson_progress' AND policyname = 'Teachers and admins can view all progress v2') THEN
    CREATE POLICY "Teachers and admins can view all progress v2"
      ON lesson_progress FOR SELECT TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('teacher', 'admin', 'co_admin'))
      );
  END IF;
END $$;

-- ── 2. quiz_attempts enhancements ────────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'quiz_attempts' AND column_name = 'submitted_at'
  ) THEN
    ALTER TABLE quiz_attempts ADD COLUMN submitted_at timestamptz DEFAULT now();
    UPDATE quiz_attempts SET submitted_at = created_at WHERE submitted_at IS NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'quiz_attempts' AND column_name = 'percentage'
  ) THEN
    ALTER TABLE quiz_attempts ADD COLUMN percentage integer DEFAULT 0;
    UPDATE quiz_attempts
    SET percentage = ROUND((score::numeric * 100) / NULLIF(total_points, 0))
    WHERE total_points > 0;
  END IF;
END $$;

-- ── 3. quizzes enhancements ───────────────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'quizzes' AND column_name = 'is_required'
  ) THEN
    ALTER TABLE quizzes ADD COLUMN is_required boolean NOT NULL DEFAULT true;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'quizzes' AND column_name = 'section_id'
  ) THEN
    ALTER TABLE quizzes ADD COLUMN section_id uuid REFERENCES sections(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'quizzes' AND column_name = 'pass_mark'
  ) THEN
    ALTER TABLE quizzes ADD COLUMN pass_mark integer DEFAULT 60;
    UPDATE quizzes SET pass_mark = COALESCE(pass_percentage, 60);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'quizzes' AND column_name = 'max_attempts'
  ) THEN
    ALTER TABLE quizzes ADD COLUMN max_attempts integer NOT NULL DEFAULT 3;
  END IF;
END $$;

-- ── 4. certificates: allow students to self-insert ───────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'certificates' AND policyname = 'Students can insert own certificates'
  ) THEN
    CREATE POLICY "Students can insert own certificates"
      ON certificates FOR INSERT TO authenticated
      WITH CHECK (auth.uid() = student_id);
  END IF;
END $$;

-- ── 5. quiz_extra_attempts: fix INSERT policy ─────────────────────────────────

DROP POLICY IF EXISTS "Teachers can grant extra attempts" ON quiz_extra_attempts;

CREATE POLICY "Teachers can grant extra attempts"
  ON quiz_extra_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('teacher', 'admin', 'co_admin'))
  );
/*
  # Add co_admin role support

  ## Changes

  1. profiles table
     - co_admin is a valid role value (column is text, no change needed)

  2. RLS policies
     - co_admin can view all profiles (like admin)
     - co_admin can view all certificates
     - co_admin can view all payments
     - co_admin can view course_enrollments

  3. Notes
     - co_admin CANNOT create/delete users (only admin can via edge function)
     - co_admin CANNOT access AI usage, org management, or settings
     - co_admin CAN view students, teachers, payments, certificates, enrollments
*/

-- co_admin can view all profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Co-admins can view all profiles'
  ) THEN
    CREATE POLICY "Co-admins can view all profiles"
      ON profiles FOR SELECT
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      );
  END IF;
END $$;

-- co_admin can update profiles (e.g. activate/deactivate students)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Co-admins can update profiles'
  ) THEN
    CREATE POLICY "Co-admins can update profiles"
      ON profiles FOR UPDATE
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      )
      WITH CHECK (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      );
  END IF;
END $$;

-- co_admin can view all certificates
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'certificates' AND policyname = 'Co-admins can view certificates'
  ) THEN
    CREATE POLICY "Co-admins can view certificates"
      ON certificates FOR SELECT
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      );
  END IF;
END $$;

-- co_admin can view all payments
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'Co-admins can view payments'
  ) THEN
    CREATE POLICY "Co-admins can view payments"
      ON payments FOR SELECT
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      );
  END IF;
END $$;

-- co_admin can view course_enrollments
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'course_enrollments' AND policyname = 'Co-admins can view course enrollments'
  ) THEN
    CREATE POLICY "Co-admins can view course enrollments"
      ON course_enrollments FOR SELECT
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      );
  END IF;
END $$;

-- co_admin can view enrollments
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'enrollments' AND policyname = 'Co-admins can view enrollments'
  ) THEN
    CREATE POLICY "Co-admins can view enrollments"
      ON enrollments FOR SELECT
      TO authenticated
      USING (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'co_admin')
      );
  END IF;
END $$;

-- Allow co_admin to insert into course_enrollments (enroll students)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'course_enrollments' AND policyname = 'Co-admins can insert course enrollments'
  ) THEN
    CREATE POLICY "Co-admins can insert course enrollments"
      ON course_enrollments FOR INSERT
      TO authenticated
      WITH CHECK (
        EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role IN ('admin', 'co_admin'))
      );
  END IF;
END $$;
/*
  # Fix co_admin RLS policies — remove infinite recursion

  ## Problem
  The co_admin policies used EXISTS (SELECT 1 FROM profiles WHERE ...) inside
  a profiles RLS policy, causing infinite recursion and breaking profile loads
  for ALL users including admins.

  ## Fix
  Replace the self-referential EXISTS subqueries with get_my_role() which is
  what all other existing policies use. get_my_role() is a SECURITY DEFINER
  function that bypasses RLS when reading the role, avoiding recursion.

  Also extend the existing admin policies to also allow co_admin where appropriate.
*/

-- Drop the broken co_admin policies on profiles
DROP POLICY IF EXISTS "Co-admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Co-admins can update profiles" ON profiles;

-- Extend "Admins can view all profiles" to also cover co_admin
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']));

-- Extend "Admins can update any profile" to also cover co_admin
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;
CREATE POLICY "Admins can update any profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']))
  WITH CHECK (get_my_role() = ANY (ARRAY['admin', 'co_admin']));

-- Fix co_admin policies on other tables — replace EXISTS subqueries with get_my_role()

-- certificates
DROP POLICY IF EXISTS "Co-admins can view certificates" ON certificates;
CREATE POLICY "Co-admins can view certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']));

-- payments
DROP POLICY IF EXISTS "Co-admins can view payments" ON payments;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'Co-admins can view payments'
  ) THEN
    CREATE POLICY "Co-admins can view payments"
      ON payments FOR SELECT
      TO authenticated
      USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']));
  END IF;
END $$;

-- course_enrollments view
DROP POLICY IF EXISTS "Co-admins can view course enrollments" ON course_enrollments;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'course_enrollments' AND policyname = 'Co-admins can view course enrollments'
  ) THEN
    CREATE POLICY "Co-admins can view course enrollments"
      ON course_enrollments FOR SELECT
      TO authenticated
      USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']));
  END IF;
END $$;

-- course_enrollments insert
DROP POLICY IF EXISTS "Co-admins can insert course enrollments" ON course_enrollments;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'course_enrollments' AND policyname = 'Co-admins can insert course enrollments'
  ) THEN
    CREATE POLICY "Co-admins can insert course enrollments"
      ON course_enrollments FOR INSERT
      TO authenticated
      WITH CHECK (get_my_role() = ANY (ARRAY['admin', 'co_admin']));
  END IF;
END $$;

-- enrollments view for co_admin
DROP POLICY IF EXISTS "Co-admins can view enrollments" ON enrollments;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'enrollments' AND policyname = 'Co-admins can view enrollments'
  ) THEN
    CREATE POLICY "Co-admins can view enrollments"
      ON enrollments FOR SELECT
      TO authenticated
      USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']));
  END IF;
END $$;

-- lesson_progress: fix the self-referential EXISTS on those policies too
DROP POLICY IF EXISTS "Teachers and admins can view all progress v2" ON lesson_progress;
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'lesson_progress' AND policyname = 'Teachers and admins can view all progress'
  ) THEN
    CREATE POLICY "Teachers and admins can view all progress"
      ON lesson_progress FOR SELECT
      TO authenticated
      USING (get_my_role() = ANY (ARRAY['teacher', 'admin', 'co_admin']));
  END IF;
END $$;

-- quiz_extra_attempts: fix EXISTS subquery
DROP POLICY IF EXISTS "Teachers can grant extra attempts" ON quiz_extra_attempts;
CREATE POLICY "Teachers can grant extra attempts"
  ON quiz_extra_attempts FOR INSERT
  TO authenticated
  WITH CHECK (get_my_role() = ANY (ARRAY['teacher', 'admin', 'co_admin']));

-- Admins can manage extra attempts select
DROP POLICY IF EXISTS "Admins can manage extra attempts" ON quiz_extra_attempts;
CREATE POLICY "Admins can manage extra attempts"
  ON quiz_extra_attempts FOR SELECT
  TO authenticated
  USING (get_my_role() = ANY (ARRAY['admin', 'co_admin']));
/*
  # Fix profiles_role_check constraint and create co-admin account

  1. Changes
    - Drops the existing profiles_role_check constraint that excludes 'co_admin'
    - Recreates it to include 'co_admin' as an allowed role
    - Updates handle_new_user trigger to accept 'co_admin' role
    - Creates a default co-admin auth user and profile
*/

-- Step 1: Drop the old constraint
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;

-- Step 2: Recreate with co_admin included
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role = ANY (ARRAY['admin'::text, 'co_admin'::text, 'teacher'::text, 'student'::text, 'org_admin'::text]));

-- Step 3: Update handle_new_user trigger function if it enforces a role check
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    CASE
      WHEN NEW.raw_user_meta_data->>'role' IN ('admin','co_admin','teacher','student','org_admin')
        THEN NEW.raw_user_meta_data->>'role'
      ELSE 'student'
    END
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
    role = CASE
      WHEN EXCLUDED.role IN ('admin','co_admin','teacher','student','org_admin')
        THEN EXCLUDED.role
      ELSE profiles.role
    END;
  RETURN NEW;
END;
$$;

-- Step 4: Create default co-admin account in auth.users then profiles
DO $$
DECLARE
  v_user_id uuid;
  v_existing_id uuid;
BEGIN
  -- Check if already exists
  SELECT id INTO v_existing_id FROM auth.users WHERE email = 'coadmin@maximus.edu.au';

  IF v_existing_id IS NULL THEN
    v_user_id := gen_random_uuid();

    INSERT INTO auth.users (
      id, instance_id, aud, role,
      email, encrypted_password, email_confirmed_at,
      raw_user_meta_data, raw_app_meta_data,
      created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) VALUES (
      v_user_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'coadmin@maximus.edu.au',
      crypt('CoAdmin@2024', gen_salt('bf')),
      now(),
      '{"full_name": "Co Admin", "role": "co_admin"}'::jsonb,
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      now(), now(),
      '', '', '', ''
    );

    INSERT INTO profiles (id, email, full_name, role, is_active)
    VALUES (v_user_id, 'coadmin@maximus.edu.au', 'Co Admin', 'co_admin', true)
    ON CONFLICT (id) DO UPDATE SET role = 'co_admin', full_name = 'Co Admin';
  ELSE
    -- User exists, just ensure their profile has co_admin role
    INSERT INTO profiles (id, email, full_name, role, is_active)
    VALUES (v_existing_id, 'coadmin@maximus.edu.au', 'Co Admin', 'co_admin', true)
    ON CONFLICT (id) DO UPDATE SET role = 'co_admin', full_name = 'Co Admin';
  END IF;
END $$;
/*
  # Admin Messages Table

  1. New Tables
    - `admin_messages`
      - `id` (uuid, primary key)
      - `from_user_id` (uuid, sender — admin/co_admin)
      - `to_user_id` (uuid, recipient)
      - `subject` (text)
      - `body` (text)
      - `is_read` (boolean, default false)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS
    - Admins/co_admins can insert messages (sender = themselves)
    - Recipients can read their own messages
    - Recipients can update is_read on their own messages
    - Admins/co_admins can read all messages they sent
*/

CREATE TABLE IF NOT EXISTS admin_messages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  to_user_id   uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subject      text NOT NULL DEFAULT '',
  body         text NOT NULL DEFAULT '',
  is_read      boolean NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS admin_messages_to_user_idx  ON admin_messages(to_user_id);
CREATE INDEX IF NOT EXISTS admin_messages_from_user_idx ON admin_messages(from_user_id);

ALTER TABLE admin_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins and co_admins can send messages"
  ON admin_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    from_user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role IN ('admin', 'co_admin')
    )
  );

CREATE POLICY "Recipients can read their messages"
  ON admin_messages FOR SELECT
  TO authenticated
  USING (to_user_id = auth.uid());

CREATE POLICY "Senders can read messages they sent"
  ON admin_messages FOR SELECT
  TO authenticated
  USING (from_user_id = auth.uid());

CREATE POLICY "Recipients can mark messages as read"
  ON admin_messages FOR UPDATE
  TO authenticated
  USING (to_user_id = auth.uid())
  WITH CHECK (to_user_id = auth.uid());
/*
  # Backfill missing certificates for completed courses

  ## What this does
  Issues certificates for any student who:
  - Has 100% progress in course_enrollments OR enrollments
  - Does NOT already have a certificate for that course
  - The course has NO required quizzes that are unpassed
  - The course has NO published exams that are ungraded/unfinalised

  ## This is safe to run multiple times
  The INSERT uses ON CONFLICT DO NOTHING due to the UNIQUE(student_id, course_id) constraint.
*/

INSERT INTO certificates (student_id, course_id)
SELECT DISTINCT ce.user_id, ce.course_id
FROM course_enrollments ce
WHERE ce.progress_percent = 100

  -- No certificate yet
  AND NOT EXISTS (
    SELECT 1 FROM certificates cert
    WHERE cert.student_id = ce.user_id
      AND cert.course_id = ce.course_id
  )

  -- No required quizzes that haven't been passed
  AND NOT EXISTS (
    SELECT 1 FROM quizzes q
    WHERE q.course_id = ce.course_id
      AND q.is_required = true
      AND NOT EXISTS (
        SELECT 1 FROM quiz_attempts qa
        WHERE qa.student_id = ce.user_id
          AND qa.quiz_id = q.id
          AND qa.passed = true
      )
  )

  -- No published exams that haven't been graded/finalised
  AND NOT EXISTS (
    SELECT 1 FROM exams e
    WHERE e.course_id = ce.course_id
      AND e.is_published = true
      AND NOT EXISTS (
        SELECT 1 FROM exam_submissions es
        WHERE es.student_id = ce.user_id
          AND es.exam_id = e.id
          AND es.status IN ('graded', 'finalised')
      )
  )

ON CONFLICT (student_id, course_id) DO NOTHING;
/*
  # Security fixes

  1. announcements SELECT policy — require authentication (was open to anonymous)
  2. activity_logs INSERT policy — restrict to own user_id only (was allow any authenticated user to log as anyone)
  3. deduct_org_tokens RPC — verify caller is an active member of the org before deducting tokens
*/

-- ── 1. announcements: require authentication for SELECT ──────────────────────
DROP POLICY IF EXISTS "Anyone can view active announcements" ON announcements;

CREATE POLICY "Authenticated users can view active announcements"
  ON announcements FOR SELECT TO authenticated
  USING (is_active = true);

-- ── 2. activity_logs: users may only insert rows for themselves ───────────────
DROP POLICY IF EXISTS "System can insert activity logs" ON activity_logs;

CREATE POLICY "Users can insert own activity logs"
  ON activity_logs FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ── 3. deduct_org_tokens: verify org membership before deducting ─────────────
CREATE OR REPLACE FUNCTION deduct_org_tokens(
  p_org_id        uuid,
  p_user_id       uuid,
  p_ai_task       text,
  p_tokens        integer,
  p_ai_log_id     uuid DEFAULT NULL
) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_balance integer;
BEGIN
  -- Verify the calling user is an active member of the organisation
  IF NOT EXISTS (
    SELECT 1 FROM org_members
    WHERE org_id = p_org_id
      AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Forbidden: caller is not a member of this organisation';
  END IF;

  -- p_user_id must match the authenticated caller
  IF p_user_id <> auth.uid() THEN
    RAISE EXCEPTION 'Forbidden: p_user_id does not match authenticated user';
  END IF;

  SELECT token_balance INTO v_balance
  FROM organizations
  WHERE id = p_org_id
  FOR UPDATE;

  IF v_balance IS NULL OR v_balance < p_tokens THEN
    RETURN false;
  END IF;

  UPDATE organizations
  SET token_balance = token_balance - p_tokens,
      updated_at = now()
  WHERE id = p_org_id;

  INSERT INTO token_usage_log (org_id, user_id, ai_task, tokens_deducted, ai_log_id)
  VALUES (p_org_id, p_user_id, p_ai_task, p_tokens, p_ai_log_id);

  RETURN true;
END;
$$;
/*
  # Convert correct_answer from integer index to option text

  ## Problem
  The quiz_questions table stores correct_answer as an integer index (0, 1, 2…)
  referencing the options array, but the application code treats it as a string
  (the actual option text). This mismatch causes no answer to ever be highlighted
  and teachers cannot update answers via the UI.

  ## Changes
  1. Convert all existing rows: replace the integer index with the corresponding
     options[index] text value.
  2. Alter the column type from integer to text.

  ## Notes
  - Uses options[correct_answer::int] array subscript (1-based in Postgres, but
    jsonb arrays are 0-based via jsonb_array_element).
  - Rows where correct_answer is already NULL or out of range are set to ''.
*/

-- Step 1: add a temporary text column
ALTER TABLE quiz_questions ADD COLUMN IF NOT EXISTS correct_answer_text text DEFAULT '';

-- Step 2: populate it by resolving the index against the options jsonb array
UPDATE quiz_questions
SET correct_answer_text = COALESCE(
  options->(correct_answer::int)#>>'{}',
  ''
)
WHERE correct_answer IS NOT NULL;

-- Step 3: drop the old integer column and rename the text one
ALTER TABLE quiz_questions DROP COLUMN correct_answer;
ALTER TABLE quiz_questions RENAME COLUMN correct_answer_text TO correct_answer;
/*
  # Reset demo/seeded payments to refunded

  ## Summary
  Marks all existing seeded/demo payment records as 'refunded' so they no
  longer count toward real revenue figures. This resets the revenue dashboard
  to zero so only genuine future payments are tracked going forward.

  ## Changes
  - Updates all existing payments with status 'completed' to 'refunded'

  ## Notes
  - Records are preserved for audit purposes, not deleted
  - Real payments going forward will use 'completed' status as normal
*/

UPDATE payments
SET status = 'refunded'
WHERE status = 'completed';
/*
  # FAQs and Contact Messages System

  ## New Tables

  ### `faqs`
  - Stores frequently asked questions editable by admin and co-admin
  - `id` (uuid PK), `question`, `answer`, `sort_order`, `is_active`, `created_by`, timestamps

  ### `contact_messages`
  - Stores messages submitted through the public contact form
  - `id` (uuid PK), `name`, `email`, `subject`, `message`, `status` (open/resolved)
  - `resolved_by` (uuid FK to profiles), `resolution_note` (immutable once set), `resolved_at`, timestamps

  ## Security
  - RLS enabled on both tables
  - Public can INSERT contact_messages (no auth needed)
  - Authenticated admins and co-admins can SELECT/UPDATE/INSERT/DELETE faqs
  - Authenticated admins and co-admins can SELECT contact_messages
  - Only the resolver can INSERT resolution (via UPDATE restricted columns)
  - Admin can see all; co-admin can also see all and resolve
*/

-- FAQs table
CREATE TABLE IF NOT EXISTS faqs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question      text NOT NULL,
  answer        text NOT NULL,
  sort_order    integer NOT NULL DEFAULT 0,
  is_active     boolean NOT NULL DEFAULT true,
  created_by    uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;

-- Anyone can read active FAQs (public)
CREATE POLICY "Public can read active faqs"
  ON faqs FOR SELECT
  USING (is_active = true);

-- Admin and co-admin can read all FAQs
CREATE POLICY "Admin and co-admin can read all faqs"
  ON faqs FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  );

-- Admin and co-admin can insert FAQs
CREATE POLICY "Admin and co-admin can insert faqs"
  ON faqs FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  );

-- Admin and co-admin can update FAQs
CREATE POLICY "Admin and co-admin can update faqs"
  ON faqs FOR UPDATE
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  )
  WITH CHECK (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  );

-- Admin and co-admin can delete FAQs
CREATE POLICY "Admin and co-admin can delete faqs"
  ON faqs FOR DELETE
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  );

-- Contact messages table
CREATE TABLE IF NOT EXISTS contact_messages (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name            text NOT NULL,
  email           text NOT NULL,
  subject         text NOT NULL DEFAULT '',
  message         text NOT NULL,
  status          text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
  resolved_by     uuid REFERENCES profiles(id) ON DELETE SET NULL,
  resolution_note text,
  resolved_at     timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

-- Public can insert (submit contact form - no auth required)
CREATE POLICY "Anyone can submit contact messages"
  ON contact_messages FOR INSERT
  WITH CHECK (true);

-- Admin and co-admin can read all messages
CREATE POLICY "Admin and co-admin can read contact messages"
  ON contact_messages FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  );

-- Admin and co-admin can update messages (to resolve them)
CREATE POLICY "Admin and co-admin can update contact messages"
  ON contact_messages FOR UPDATE
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  )
  WITH CHECK (
    (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'co_admin')
  );

-- Seed some initial FAQs
INSERT INTO faqs (question, answer, sort_order, is_active) VALUES
  ('How do I enrol in a course?', 'You can enrol in any course by creating a free account, browsing our course catalogue, and clicking "Enrol Now" on your chosen course. For paid courses, you will be guided through a secure payment process.', 1, true),
  ('What payment methods do you accept?', 'We accept all major credit and debit cards (Visa, Mastercard, American Express) as well as PayPal. All payments are processed securely through Stripe.', 2, true),
  ('Can I get a refund?', 'Yes — we offer a refund within 7 days of purchase, provided you have not completed more than 20% of the course content. Please contact us at inquiries@maximusacademy.com.au to request a refund.', 3, true),
  ('How do I access my certificate?', 'Once you complete a course and pass any required assessments, your certificate will be automatically generated and available in your student dashboard under the "Certificates" tab. You can download it as a PDF at any time.', 4, true),
  ('Are the classes live or recorded?', 'We offer both live instructor-led sessions and recorded classes depending on the course. Each course page clearly states whether it includes live sessions, recorded content, or a combination of both.', 5, true),
  ('What is the duration of each course?', 'Course durations vary: IELTS and PTE preparation courses run 8–10 weeks, language courses are 4–6 weeks per level, the Xero Beginner Course is 4 weeks, and short courses and workshops run 1–3 days.', 6, true),
  ('Do you offer corporate or group training?', 'Yes — we offer tailored corporate and group training packages. Please reach out via our contact form or email inquiries@maximusacademy.com.au to discuss your organisation''s needs.', 7, true),
  ('How can I contact support?', 'You can reach us by email at inquiries@maximusacademy.com.au or by phone at +88 01321-203140. Our office hours are Sunday–Thursday 9am–6pm BST and Friday–Saturday 10am–2pm BST.', 8, true)
ON CONFLICT DO NOTHING;

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_faqs_sort_order ON faqs (sort_order, is_active);
CREATE INDEX IF NOT EXISTS idx_contact_messages_status ON contact_messages (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_messages_resolved_by ON contact_messages (resolved_by);
-- 1. Enforce resolution_note immutability at DB level
--    Once resolution_note is set (non-null), it cannot be changed.
CREATE OR REPLACE FUNCTION lock_resolution_note()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.resolution_note IS NOT NULL AND NEW.resolution_note IS DISTINCT FROM OLD.resolution_note THEN
    RAISE EXCEPTION 'resolution_note cannot be modified once set';
  END IF;
  -- Also prevent reverting status from resolved → open
  IF OLD.status = 'resolved' AND NEW.status = 'open' THEN
    RAISE EXCEPTION 'A resolved message cannot be re-opened';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_lock_resolution_note
BEFORE UPDATE ON contact_messages
FOR EACH ROW EXECUTE FUNCTION lock_resolution_note();

-- 2. Add field length constraints to contact_messages
ALTER TABLE contact_messages
  ADD CONSTRAINT contact_messages_name_length    CHECK (char_length(name)    BETWEEN 1 AND 200),
  ADD CONSTRAINT contact_messages_email_length   CHECK (char_length(email)   BETWEEN 3 AND 200),
  ADD CONSTRAINT contact_messages_subject_length CHECK (char_length(subject) <= 200),
  ADD CONSTRAINT contact_messages_message_length CHECK (char_length(message) BETWEEN 1 AND 5000);

-- 3. Add length constraints to faqs
ALTER TABLE faqs
  ADD CONSTRAINT faqs_question_length CHECK (char_length(question) BETWEEN 1 AND 500),
  ADD CONSTRAINT faqs_answer_length   CHECK (char_length(answer)   BETWEEN 1 AND 5000);

-- 4. Index to speed up public FAQ queries
CREATE INDEX IF NOT EXISTS idx_faqs_active ON faqs (is_active, sort_order) WHERE is_active = true;

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
/*
  # 054 — Branded Course Pages (white-label storefronts)

  Teachers and organizations get their own public, branded "course page"
  (storefront) at /school/:slug. They configure logo, name, tagline,
  colors and description; the page lists their published courses and is
  what they share with their students instead of the Synapvex catalog.

  ## New table
  - course_pages: one per teacher OR organization
    - owner_type: 'teacher' | 'org'
    - teacher_id / org_id: exactly one set, both unique (one page per owner)
    - slug: unique, lowercase kebab, used in the public URL
    - branding: display_name, tagline, description, logo_url, hero_image_url,
      brand_color (dark hero/header), accent_color (buttons/links)
    - contact: website, contact_email
    - hide_platform_branding: hide "Powered by Synapvex" footer note
    - is_published: page only publicly visible when true

  ## Security (RLS)
  - Anyone (anon + authenticated) can read published pages
  - Teachers manage their own page
  - Org owners manage their organization's page
  - Admins manage all pages
*/

CREATE TABLE IF NOT EXISTS course_pages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type text NOT NULL CHECK (owner_type IN ('teacher', 'org')),
  teacher_id uuid UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  org_id uuid UNIQUE REFERENCES organizations(id) ON DELETE CASCADE,
  slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9](?:[a-z0-9-]{0,58}[a-z0-9])?$'),
  display_name text NOT NULL,
  tagline text NOT NULL DEFAULT '',
  description text NOT NULL DEFAULT '',
  logo_url text,
  hero_image_url text,
  brand_color text NOT NULL DEFAULT '#0f172a' CHECK (brand_color ~ '^#[0-9a-fA-F]{6}$'),
  accent_color text NOT NULL DEFAULT '#0284c7' CHECK (accent_color ~ '^#[0-9a-fA-F]{6}$'),
  website text,
  contact_email text,
  hide_platform_branding boolean NOT NULL DEFAULT false,
  is_published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT course_pages_owner_check CHECK (
    (owner_type = 'teacher' AND teacher_id IS NOT NULL AND org_id IS NULL) OR
    (owner_type = 'org' AND org_id IS NOT NULL AND teacher_id IS NULL)
  )
);

CREATE INDEX IF NOT EXISTS idx_course_pages_slug ON course_pages(slug);
CREATE INDEX IF NOT EXISTS idx_course_pages_teacher ON course_pages(teacher_id);
CREATE INDEX IF NOT EXISTS idx_course_pages_org ON course_pages(org_id);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'course_pages_updated_at') THEN
    CREATE TRIGGER course_pages_updated_at
      BEFORE UPDATE ON course_pages
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

ALTER TABLE course_pages ENABLE ROW LEVEL SECURITY;

-- Public: anyone can view a published course page
CREATE POLICY "Anyone can view published course pages"
  ON course_pages FOR SELECT
  TO anon, authenticated
  USING (is_published = true);

-- Teachers: full control of their own page
CREATE POLICY "Teachers can view own course page"
  ON course_pages FOR SELECT TO authenticated
  USING (teacher_id = auth.uid());

CREATE POLICY "Teachers can insert own course page"
  ON course_pages FOR INSERT TO authenticated
  WITH CHECK (owner_type = 'teacher' AND teacher_id = auth.uid());

CREATE POLICY "Teachers can update own course page"
  ON course_pages FOR UPDATE TO authenticated
  USING (teacher_id = auth.uid())
  WITH CHECK (teacher_id = auth.uid());

CREATE POLICY "Teachers can delete own course page"
  ON course_pages FOR DELETE TO authenticated
  USING (teacher_id = auth.uid());

-- Org owners: full control of their organization's page
CREATE POLICY "Org owners can view own org course page"
  ON course_pages FOR SELECT TO authenticated
  USING (
    org_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = course_pages.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can insert own org course page"
  ON course_pages FOR INSERT TO authenticated
  WITH CHECK (
    owner_type = 'org' AND org_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = course_pages.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can update own org course page"
  ON course_pages FOR UPDATE TO authenticated
  USING (
    org_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = course_pages.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  )
  WITH CHECK (
    org_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = course_pages.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

CREATE POLICY "Org owners can delete own org course page"
  ON course_pages FOR DELETE TO authenticated
  USING (
    org_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM org_members
      WHERE org_members.org_id = course_pages.org_id
        AND org_members.user_id = auth.uid()
        AND org_members.role = 'owner'
    )
  );

-- Admins: manage everything
CREATE POLICY "Admins can manage course pages"
  ON course_pages FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'co_admin')))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'co_admin')));
-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- update_updated_at_column trigger helper
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

-- get_user_role (SECURITY DEFINER to avoid RLS recursion)
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid DEFAULT auth.uid())
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT role FROM profiles WHERE id = user_id;
$$;

-- get_my_role (alias used by some RLS policies)
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- handle_new_user auth trigger function
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created') THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION handle_new_user();
  END IF;
END $$;

-- Extend profiles role CHECK to include all roles
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('admin', 'co_admin', 'teacher', 'student', 'org_admin'));

-- Add missing columns to profiles
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='is_active') THEN
    ALTER TABLE profiles ADD COLUMN is_active boolean DEFAULT true;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='bio') THEN
    ALTER TABLE profiles ADD COLUMN bio text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='phone') THEN
    ALTER TABLE profiles ADD COLUMN phone text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='avatar_url') THEN
    ALTER TABLE profiles ADD COLUMN avatar_url text DEFAULT '';
  END IF;
END $$;

-- Add missing columns to courses
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='short_description') THEN
    ALTER TABLE courses ADD COLUMN short_description text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='preview_enabled') THEN
    ALTER TABLE courses ADD COLUMN preview_enabled boolean DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='stripe_payment_link') THEN
    ALTER TABLE courses ADD COLUMN stripe_payment_link text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='start_date') THEN
    ALTER TABLE courses ADD COLUMN start_date date;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='end_date') THEN
    ALTER TABLE courses ADD COLUMN end_date date;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='duration_weeks') THEN
    ALTER TABLE courses ADD COLUMN duration_weeks integer DEFAULT 0;
  END IF;
END $$;

-- Add missing columns to lessons
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='ai_summary') THEN
    ALTER TABLE lessons ADD COLUMN ai_summary text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='ai_summary_generated_at') THEN
    ALTER TABLE lessons ADD COLUMN ai_summary_generated_at timestamptz;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='url') THEN
    ALTER TABLE lessons ADD COLUMN url text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='is_required') THEN
    ALTER TABLE lessons ADD COLUMN is_required boolean DEFAULT true;
  END IF;
END $$;

-- Add missing columns to quizzes
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='pass_mark') THEN
    ALTER TABLE quizzes ADD COLUMN pass_mark integer DEFAULT 70;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='time_limit_minutes') THEN
    ALTER TABLE quizzes ADD COLUMN time_limit_minutes integer DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='section_id') THEN
    ALTER TABLE quizzes ADD COLUMN section_id uuid REFERENCES sections(id) ON DELETE SET NULL;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='extra_attempts_allowed') THEN
    ALTER TABLE quizzes ADD COLUMN extra_attempts_allowed integer DEFAULT 0;
  END IF;
END $$;

-- Add missing columns to quiz_questions
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_questions' AND column_name='correct_answer_text') THEN
    ALTER TABLE quiz_questions ADD COLUMN correct_answer_text text;
  END IF;
END $$;

-- Add missing columns to payments
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='payments' AND column_name='stripe_session_id') THEN
    ALTER TABLE payments ADD COLUMN stripe_session_id text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='payments' AND column_name='payment_method') THEN
    ALTER TABLE payments ADD COLUMN payment_method text DEFAULT 'stripe';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='payments' AND column_name='currency') THEN
    ALTER TABLE payments ADD COLUMN currency text DEFAULT 'AUD';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='payments' AND column_name='payment_type') THEN
    ALTER TABLE payments ADD COLUMN payment_type text DEFAULT 'course';
  END IF;
END $$;

-- Add missing columns to certificates
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='certificates' AND column_name='certificate_number') THEN
    ALTER TABLE certificates ADD COLUMN certificate_number text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='certificates' AND column_name='issued_at') THEN
    ALTER TABLE certificates ADD COLUMN issued_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Add missing columns to enrollments
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='enrollments' AND column_name='payment_status') THEN
    ALTER TABLE enrollments ADD COLUMN payment_status text DEFAULT 'not_required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='enrollments' AND column_name='stripe_session_id') THEN
    ALTER TABLE enrollments ADD COLUMN stripe_session_id text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='enrollments' AND column_name='amount_paid') THEN
    ALTER TABLE enrollments ADD COLUMN amount_paid numeric DEFAULT 0;
  END IF;
END $$;
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
/*
  Demo Accounts — all 5 roles
  ─────────────────────────────────────────────────────────────────
  admin@synapvex.com      / Admin1234!       (role: admin)
  co.admin@synapvex.com   / CoAdmin1234!     (role: co_admin)
  teacher@synapvex.com    / Teacher1234!     (role: teacher)
  org@synapvex.com        / OrgAdmin1234!    (role: org_admin)
  student@synapvex.com    / Student1234!     (role: student)
  ─────────────────────────────────────────────────────────────────
*/

DO $$
DECLARE
  admin_uid    uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  coadmin_uid  uuid := 'aaaaaaaa-0000-0000-0000-000000000002';
  teacher_uid  uuid := 'aaaaaaaa-0000-0000-0000-000000000003';
  org_uid      uuid := 'aaaaaaaa-0000-0000-0000-000000000004';
  student_uid  uuid := 'aaaaaaaa-0000-0000-0000-000000000005';
  demo_org_id  uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
BEGIN

  -- Clean up any prior demo accounts
  DELETE FROM auth.identities WHERE user_id IN (admin_uid, coadmin_uid, teacher_uid, org_uid, student_uid);
  DELETE FROM auth.sessions   WHERE user_id IN (admin_uid, coadmin_uid, teacher_uid, org_uid, student_uid);
  DELETE FROM auth.users      WHERE id      IN (admin_uid, coadmin_uid, teacher_uid, org_uid, student_uid);

  -- ── auth.users ────────────────────────────────────────────────────────────
  INSERT INTO auth.users (
    instance_id, id, aud, role,
    email, encrypted_password,
    email_confirmed_at,
    confirmation_token, recovery_token,
    email_change_token_new, email_change,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, created_at, updated_at,
    phone, phone_change, phone_change_token,
    email_change_token_current, email_change_confirm_status,
    reauthentication_token, is_sso_user, deleted_at, is_anonymous
  ) VALUES
  (
    '00000000-0000-0000-0000-000000000000', admin_uid,
    'authenticated', 'authenticated',
    'admin@synapvex.com', crypt('Admin1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"admin","full_name":"Alex Morrison"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', coadmin_uid,
    'authenticated', 'authenticated',
    'co.admin@synapvex.com', crypt('CoAdmin1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"co_admin","full_name":"Chris Bailey"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', teacher_uid,
    'authenticated', 'authenticated',
    'teacher@synapvex.com', crypt('Teacher1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"teacher","full_name":"Sarah Thompson"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', org_uid,
    'authenticated', 'authenticated',
    'org@synapvex.com', crypt('OrgAdmin1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"org_admin","full_name":"Jordan Lee"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  ),
  (
    '00000000-0000-0000-0000-000000000000', student_uid,
    'authenticated', 'authenticated',
    'student@synapvex.com', crypt('Student1234!', gen_salt('bf')),
    now(), '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"role":"student","full_name":"James Wilson"}'::jsonb,
    false, now(), now(), NULL, '', '', '', 0, '', false, NULL, false
  );

  -- ── auth.identities ───────────────────────────────────────────────────────
  INSERT INTO auth.identities (id, provider_id, user_id, identity_data, provider, created_at, updated_at)
  VALUES
  (gen_random_uuid(), 'admin@synapvex.com',     admin_uid,   jsonb_build_object('sub', admin_uid::text,   'email', 'admin@synapvex.com',     'email_verified', true), 'email', now(), now()),
  (gen_random_uuid(), 'co.admin@synapvex.com',  coadmin_uid, jsonb_build_object('sub', coadmin_uid::text, 'email', 'co.admin@synapvex.com',  'email_verified', true), 'email', now(), now()),
  (gen_random_uuid(), 'teacher@synapvex.com',   teacher_uid, jsonb_build_object('sub', teacher_uid::text, 'email', 'teacher@synapvex.com',   'email_verified', true), 'email', now(), now()),
  (gen_random_uuid(), 'org@synapvex.com',       org_uid,     jsonb_build_object('sub', org_uid::text,     'email', 'org@synapvex.com',       'email_verified', true), 'email', now(), now()),
  (gen_random_uuid(), 'student@synapvex.com',   student_uid, jsonb_build_object('sub', student_uid::text, 'email', 'student@synapvex.com',   'email_verified', true), 'email', now(), now());

  -- ── profiles ──────────────────────────────────────────────────────────────
  INSERT INTO public.profiles (id, email, full_name, role, bio, is_active)
  VALUES
    (admin_uid,   'admin@synapvex.com',    'Alex Morrison',  'admin',
     'Platform administrator for SynapVex LMS.', true),
    (coadmin_uid, 'co.admin@synapvex.com', 'Chris Bailey',   'co_admin',
     'Co-administrator supporting platform operations.', true),
    (teacher_uid, 'teacher@synapvex.com',  'Sarah Thompson', 'teacher',
     'Senior instructor with 10+ years experience in Business Communication and Finance.', true),
    (org_uid,     'org@synapvex.com',      'Jordan Lee',     'org_admin',
     'Organisation administrator managing team courses and members.', true),
    (student_uid, 'student@synapvex.com',  'James Wilson',   'student',
     'Aspiring professional enrolled in multiple courses.', true)
  ON CONFLICT (id) DO UPDATE SET
    email     = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role      = EXCLUDED.role,
    bio       = EXCLUDED.bio,
    is_active = EXCLUDED.is_active;

  -- ── Demo organization for the org_admin ───────────────────────────────────
  INSERT INTO organizations (id, name, slug, description, plan_tier, token_balance, created_by)
  VALUES (
    demo_org_id,
    'Synapvex Demo Organisation',
    'synapvex-demo',
    'A demo organisation account for testing the org admin portal.',
    'professional',
    5000,
    org_uid
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO org_members (org_id, user_id, role)
  VALUES (demo_org_id, org_uid, 'owner')
  ON CONFLICT (org_id, user_id) DO NOTHING;

END $$;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='price_amount') THEN
    ALTER TABLE courses ADD COLUMN price_amount numeric DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='is_paid') THEN
    ALTER TABLE courses ADD COLUMN is_paid boolean DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='courses' AND column_name='tags') THEN
    ALTER TABLE courses ADD COLUMN tags text[] DEFAULT '{}';
  END IF;
END $$;
-- Add course_id to lessons (it's needed by the app)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='course_id') THEN
    ALTER TABLE lessons ADD COLUMN course_id uuid REFERENCES courses(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='lesson_type') THEN
    ALTER TABLE lessons ADD COLUMN lesson_type text DEFAULT 'video';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='video_url') THEN
    ALTER TABLE lessons ADD COLUMN video_url text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='description') THEN
    ALTER TABLE lessons ADD COLUMN description text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lessons' AND column_name='file_url') THEN
    ALTER TABLE lessons ADD COLUMN file_url text DEFAULT '';
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON lessons(course_id);

-- Add is_published to announcements
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='announcements' AND column_name='is_published') THEN
    ALTER TABLE announcements ADD COLUMN is_published boolean DEFAULT true;
  END IF;
END $$;

-- Promo codes: add discount_type, discount_value, max_uses aliases
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='discount_type') THEN
    ALTER TABLE promo_codes ADD COLUMN discount_type text DEFAULT 'percentage';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='discount_value') THEN
    ALTER TABLE promo_codes ADD COLUMN discount_value numeric DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='max_uses') THEN
    ALTER TABLE promo_codes ADD COLUMN max_uses integer DEFAULT 100;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='promo_codes' AND column_name='description') THEN
    ALTER TABLE promo_codes ADD COLUMN description text DEFAULT '';
  END IF;
END $$;

-- Quiz_attempts: add user_id alias for student_id if missing
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_attempts' AND column_name='user_id') THEN
    ALTER TABLE quiz_attempts ADD COLUMN user_id uuid REFERENCES profiles(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_attempts' AND column_name='passed') THEN
    ALTER TABLE quiz_attempts ADD COLUMN passed boolean DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_attempts' AND column_name='score') THEN
    ALTER TABLE quiz_attempts ADD COLUMN score numeric DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_attempts' AND column_name='answers') THEN
    ALTER TABLE quiz_attempts ADD COLUMN answers jsonb DEFAULT '{}';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_attempts' AND column_name='completed_at') THEN
    ALTER TABLE quiz_attempts ADD COLUMN completed_at timestamptz;
  END IF;
END $$;
ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_type_check;
ALTER TABLE lessons ADD CONSTRAINT lessons_type_check
  CHECK (type IN ('video','pdf','article','link','text','file','quiz'));
-- Add missing columns to quizzes for app compatibility
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='is_published') THEN
    ALTER TABLE quizzes ADD COLUMN is_published boolean DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='pass_percentage') THEN
    ALTER TABLE quizzes ADD COLUMN pass_percentage integer DEFAULT 70;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='time_limit') THEN
    ALTER TABLE quizzes ADD COLUMN time_limit integer DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quizzes' AND column_name='lesson_id') THEN
    ALTER TABLE quizzes ADD COLUMN lesson_id uuid REFERENCES lessons(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Add missing column to quiz_questions
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_questions' AND column_name='explanation') THEN
    ALTER TABLE quiz_questions ADD COLUMN explanation text DEFAULT '';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='quiz_questions' AND column_name='points') THEN
    ALTER TABLE quiz_questions ADD COLUMN points integer DEFAULT 1;
  END IF;
END $$;
DO $$
DECLARE
  teacher_uid  uuid := 'aaaaaaaa-0000-0000-0000-000000000003';
  student_uid  uuid := 'aaaaaaaa-0000-0000-0000-000000000005';
  course1_id   uuid := gen_random_uuid();
  course2_id   uuid := gen_random_uuid();
  course3_id   uuid := gen_random_uuid();
  sec1a_id uuid; sec1b_id uuid; sec1c_id uuid;
  sec2a_id uuid; sec2b_id uuid;
  sec3a_id uuid; sec3b_id uuid;
  quiz1_id uuid;
BEGIN
  INSERT INTO courses (id, teacher_id, title, short_description, description,
    category, level, language, duration_hours, total_lessons, total_students,
    rating, price, price_amount, is_free, is_paid, is_published, is_archived,
    thumbnail_url, what_you_learn, requirements)
  VALUES
  (course1_id, teacher_uid, 'IELTS Academic Writing Mastery',
    'Achieve Band 7+ in IELTS Academic Writing with proven strategies.',
    'A comprehensive course covering Task 1 and Task 2 with proven band-score strategies.',
    'Language Learning', 'intermediate', 'English', 18, 32, 148, 4.8, 0, 0, true, false, true, false,
    'https://images.pexels.com/photos/5212345/pexels-photo-5212345.jpeg',
    '["Write Band 7+ Task 1 reports","Construct high-scoring Task 2 essays","Master grammar and cohesion","Manage exam time effectively"]'::jsonb,
    '["Basic English proficiency","Pen and paper for practice exercises"]'::jsonb),
  (course2_id, teacher_uid, 'Xero Accounting for Small Business',
    'Master Xero from setup to BAS lodgement.',
    'Learn Xero cloud accounting from scratch — transactions, bank reconciliation, GST and BAS.',
    'Business & Finance', 'beginner', 'English', 12, 24, 95, 4.9, 49, 49, false, true, true, false,
    'https://images.pexels.com/photos/6801648/pexels-photo-6801648.jpeg',
    '["Set up a Xero account","Record sales and expenses","Reconcile bank accounts","Prepare and lodge BAS returns"]'::jsonb,
    '["Basic computer skills"]'::jsonb),
  (course3_id, teacher_uid, 'Business Communication Essentials',
    'Write clear emails, reports and presentations that get results.',
    'Develop the business communication skills employers value.',
    'Business & Finance', 'beginner', 'English', 8, 16, 210, 4.7, 0, 0, true, false, true, false,
    'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg',
    '["Write professional emails","Structure reports and proposals","Deliver clear presentations","Communicate assertively"]'::jsonb,
    '["No prerequisites"]'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  -- Sections & Lessons — Course 1
  INSERT INTO sections (course_id, title, order_index) VALUES
    (course1_id, 'Introduction & Exam Overview', 0), (course1_id, 'Task 1: Graphs & Charts', 1), (course1_id, 'Task 2: Essay Writing', 2);
  SELECT id INTO sec1a_id FROM sections WHERE course_id = course1_id AND order_index = 0 LIMIT 1;
  SELECT id INTO sec1b_id FROM sections WHERE course_id = course1_id AND order_index = 1 LIMIT 1;
  SELECT id INTO sec1c_id FROM sections WHERE course_id = course1_id AND order_index = 2 LIMIT 1;
  INSERT INTO lessons (course_id, section_id, title, type, lesson_type, duration_minutes, order_index, is_preview) VALUES
    (course1_id, sec1a_id, 'Welcome & Course Roadmap',          'video',   'video',   8,  0, true),
    (course1_id, sec1a_id, 'Understanding the IELTS Score Band', 'article', 'article', 10, 1, true),
    (course1_id, sec1b_id, 'Describing Line Graphs',             'video',   'video',   20, 0, false),
    (course1_id, sec1b_id, 'Describing Bar Charts & Pie Charts', 'video',   'video',   22, 1, false),
    (course1_id, sec1c_id, 'Essay Structure & Planning',         'video',   'video',   25, 0, false),
    (course1_id, sec1c_id, 'Argument & Opinion Essays',          'video',   'video',   30, 1, false);

  -- Sections & Lessons — Course 2
  INSERT INTO sections (course_id, title, order_index) VALUES
    (course2_id, 'Getting Started with Xero', 0), (course2_id, 'Day-to-Day Bookkeeping', 1);
  SELECT id INTO sec2a_id FROM sections WHERE course_id = course2_id AND order_index = 0 LIMIT 1;
  SELECT id INTO sec2b_id FROM sections WHERE course_id = course2_id AND order_index = 1 LIMIT 1;
  INSERT INTO lessons (course_id, section_id, title, type, lesson_type, duration_minutes, order_index, is_preview) VALUES
    (course2_id, sec2a_id, 'Setting Up Your Xero Account',     'video', 'video', 15, 0, true),
    (course2_id, sec2a_id, 'Chart of Accounts Explained',      'video', 'video', 18, 1, false),
    (course2_id, sec2b_id, 'Recording Sales Invoices',         'video', 'video', 20, 0, false),
    (course2_id, sec2b_id, 'Bank Reconciliation Step by Step', 'video', 'video', 25, 1, false);

  -- Sections & Lessons — Course 3
  INSERT INTO sections (course_id, title, order_index) VALUES
    (course3_id, 'Professional Email Writing', 0), (course3_id, 'Reports & Presentations', 1);
  SELECT id INTO sec3a_id FROM sections WHERE course_id = course3_id AND order_index = 0 LIMIT 1;
  SELECT id INTO sec3b_id FROM sections WHERE course_id = course3_id AND order_index = 1 LIMIT 1;
  INSERT INTO lessons (course_id, section_id, title, type, lesson_type, duration_minutes, order_index, is_preview) VALUES
    (course3_id, sec3a_id, 'Email Tone & Clarity',             'video',   'video',   12, 0, true),
    (course3_id, sec3a_id, 'Subject Lines & Opening Lines',    'article', 'article',  8, 1, false),
    (course3_id, sec3b_id, 'Structuring a Business Report',    'video',   'video',   18, 0, false),
    (course3_id, sec3b_id, 'Presentation Design Fundamentals', 'video',   'video',   20, 1, false);

  -- Quiz
  INSERT INTO quizzes (course_id, title, description, time_limit, time_limit_minutes, pass_mark, pass_percentage, max_attempts, is_published)
  VALUES (course1_id, 'IELTS Basics Check', 'Test your understanding of IELTS band scoring.', 10, 10, 70, 70, 3, true);
  SELECT id INTO quiz1_id FROM quizzes WHERE course_id = course1_id LIMIT 1;
  INSERT INTO quiz_questions (quiz_id, question, options, correct_answer, explanation, order_index) VALUES
    (quiz1_id, 'What is the maximum IELTS band score?',
     '["7","8","9","10"]'::jsonb, 2, 'The IELTS scale runs from 0 to 9.', 0),
    (quiz1_id, 'How many sections does the IELTS Writing test have?',
     '["1","2","3","4"]'::jsonb, 1, 'Task 1 and Task 2.', 1),
    (quiz1_id, 'Which task carries more weight in the Writing score?',
     '["Task 1","Task 2","Both equal","Depends on topic"]'::jsonb, 1,
     'Task 2 is worth approximately two-thirds of the Writing band score.', 2);

  -- Enrolments
  INSERT INTO course_enrollments (course_id, user_id, payment_status, progress)
  VALUES (course1_id, student_uid, 'not_required', 33), (course3_id, student_uid, 'not_required', 75)
  ON CONFLICT (course_id, user_id) DO NOTHING;
  INSERT INTO enrollments (course_id, student_id, payment_status)
  VALUES (course1_id, student_uid, 'not_required'), (course3_id, student_uid, 'not_required')
  ON CONFLICT DO NOTHING;

  -- Update counters
  UPDATE courses SET
    total_lessons  = (SELECT COUNT(*) FROM lessons l WHERE l.course_id = courses.id),
    total_students = (SELECT COUNT(*) FROM course_enrollments ce WHERE ce.course_id = courses.id)
  WHERE id IN (course1_id, course2_id, course3_id);

  -- Announcement
  INSERT INTO announcements (title, content, is_published)
  VALUES ('Welcome to SynapVex LMS!',
    'We are excited to have you here. Explore courses, use the AI builder, and reach out if you need help.', true)
  ON CONFLICT DO NOTHING;

  -- Promo code
  INSERT INTO promo_codes (code, discount_type, discount_value, discount_percent, max_uses, usage_limit, expires_at, is_active)
  VALUES ('WELCOME20', 'percentage', 20, 20, 100, 100, now() + interval '1 year', true)
  ON CONFLICT DO NOTHING;

  -- FAQs
  INSERT INTO faqs (question, answer, category, order_index) VALUES
    ('How do I enrol in a course?', 'Click the course card and then Enrol Now. Free courses are instant; paid courses go through Stripe.', 'courses', 1),
    ('Can I download course materials?', 'Yes — documents, slides and handouts are on the lesson page.', 'courses', 2),
    ('How do I become a teacher?', 'Visit Become a Teacher, choose a plan, and sign up. Build courses immediately.', 'teaching', 3),
    ('How are certificates issued?', 'Certificates are auto-generated once you complete all lessons and pass required quizzes.', 'certificates', 4),
    ('What payment methods are accepted?', 'All major credit cards through Stripe. All transactions are secure.', 'payments', 5)
  ON CONFLICT DO NOTHING;
END $$;
/*
  # 064 — Subscription lifecycle: annual billing, cancellation, paid token top-ups

  ## Changes
  1. teacher_subscription_plans
     - price_yearly_cents: annual price paid upfront (seeded at 10x monthly
       = 2 months free vs paying monthly)
  2. teacher_subscriptions
     - billing_interval ('monthly' | 'yearly')
     - cancel_at_period_end + cancelled_at (teacher-initiated cancellation;
       access continues until current_period_end)
  3. set_subscription_renewal(p_subscription_id, p_cancel) — SECURITY DEFINER
     so teachers can cancel/resume ONLY the renewal flag on their own
     subscription without getting a broad UPDATE policy (which would let
     them edit period dates).
  4. SECURITY FIX: revoke public EXECUTE on add_teacher_tokens and
     add_student_tokens. They were callable by any authenticated user,
     letting anyone credit themselves unlimited AI tokens without paying.
     Only the service role (Stripe webhook) may call them now.
*/

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

-- 4. Lock down token-credit RPCs to the service role (Stripe webhook)
REVOKE ALL ON FUNCTION add_teacher_tokens(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION add_teacher_tokens(uuid, integer) FROM authenticated;
REVOKE ALL ON FUNCTION add_teacher_tokens(uuid, integer) FROM anon;
GRANT EXECUTE ON FUNCTION add_teacher_tokens(uuid, integer) TO service_role;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'add_student_tokens') THEN
    REVOKE ALL ON FUNCTION add_student_tokens(uuid, integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION add_student_tokens(uuid, integer) FROM authenticated;
    REVOKE ALL ON FUNCTION add_student_tokens(uuid, integer) FROM anon;
    GRANT EXECUTE ON FUNCTION add_student_tokens(uuid, integer) TO service_role;
  END IF;
END $$;
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

-- ============================================================
-- LIVE DATA: Profile added after migrations (not in seed data)
-- ============================================================
INSERT INTO profiles (id, full_name, email, role, avatar_url, bio, is_active, created_at, updated_at) VALUES
('4ae282ef-3ebf-498d-8ff0-2a5e36295918', 'Anujan', 'anujan2721@gmail.com', 'teacher', '', '', true, '2026-07-09 02:03:40.770637+00', '2026-07-09 02:03:40.770637+00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- POST-RUN INSTRUCTIONS
--
-- AUTH USERS: The migration files create profiles with fixed UUIDs
-- (aaaaaaaa-0000-0000-0000-00000000000X). After running this script:
-- 1. Go to Supabase Dashboard -> Authentication -> Users -> Add user
-- 2. Create accounts with these emails:
--    admin@synapvex.com, co.admin@synapvex.com, teacher@synapvex.com,
--    org@synapvex.com, student@synapvex.com
-- 3. Set each user UUID to match the profile IDs, OR update
--    profiles to match the new auth UIDs.
--
-- STORAGE BUCKETS: Already created in the SQL above.
-- Verify in Dashboard -> Storage after running.
--
-- EDGE FUNCTIONS: Must be redeployed separately to the new project.
-- Files are in supabase/functions/*/index.ts
-- ============================================================
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

-- ============================================================
-- LIVE DATA: Profile added after migrations (not in seed data)
-- ============================================================
INSERT INTO profiles (id, full_name, email, role, avatar_url, bio, is_active, created_at, updated_at) VALUES
('4ae282ef-3ebf-498d-8ff0-2a5e36295918', 'Anujan', 'anujan2721@gmail.com', 'teacher', '', '', true, '2026-07-09 02:03:40.770637+00', '2026-07-09 02:03:40.770637+00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- POST-RUN INSTRUCTIONS
--
-- AUTH USERS: The migration files create profiles with fixed UUIDs
-- (aaaaaaaa-0000-0000-0000-00000000000X). After running this script:
-- 1. Go to Supabase Dashboard -> Authentication -> Users -> Add user
-- 2. Create accounts with these emails:
--    admin@synapvex.com, co.admin@synapvex.com, teacher@synapvex.com,
--    org@synapvex.com, student@synapvex.com
-- 3. Set each user UUID to match the profile IDs, OR update
--    profiles to match the new auth UIDs.
--
-- STORAGE BUCKETS: Already created in the SQL above.
-- Verify in Dashboard -> Storage after running.
--
-- EDGE FUNCTIONS: Must be redeployed separately to the new project.
-- Files are in supabase/functions/*/index.ts
-- ============================================================
