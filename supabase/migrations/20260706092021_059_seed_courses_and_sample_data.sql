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
