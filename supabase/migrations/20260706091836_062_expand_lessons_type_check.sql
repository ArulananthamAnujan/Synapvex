ALTER TABLE lessons DROP CONSTRAINT IF EXISTS lessons_type_check;
ALTER TABLE lessons ADD CONSTRAINT lessons_type_check
  CHECK (type IN ('video','pdf','article','link','text','file','quiz'));
