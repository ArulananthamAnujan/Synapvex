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
