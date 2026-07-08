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
