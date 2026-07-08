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
