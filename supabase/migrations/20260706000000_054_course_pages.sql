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
