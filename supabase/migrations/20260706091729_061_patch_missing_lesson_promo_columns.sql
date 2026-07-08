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
