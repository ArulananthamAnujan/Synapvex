import { useQuery } from '@tanstack/react-query';
import { supabase } from '../lib/supabase';
import type { Course, CoursePage } from '../types';

/** Slugs that would collide with app routes or look official. */
export const RESERVED_SLUGS = [
  'admin', 'co-admin', 'org', 'teacher', 'student', 'login', 'register',
  'courses', 'course', 'about', 'contact', 'school', 'schools', 'dashboard',
  'settings', 'api', 'app', 'www', 'synapvex', 'maximus', 'support', 'help',
  'verify', 'teach', 'notifications', 'book-online', 'our-mission',
];

export function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 60);
}

export function validateSlug(slug: string): string | null {
  if (!slug) return 'A page link is required';
  if (slug.length < 3) return 'Link must be at least 3 characters';
  if (!/^[a-z0-9](?:[a-z0-9-]{0,58}[a-z0-9])?$/.test(slug)) {
    return 'Use only lowercase letters, numbers and hyphens (no leading/trailing hyphen)';
  }
  if (RESERVED_SLUGS.includes(slug)) return 'This link is reserved, please choose another';
  return null;
}

export function coursePageUrl(slug: string): string {
  return `${window.location.origin}/school/${slug}`;
}

export function coursePageCourseUrl(slug: string, courseId: string): string {
  return `${window.location.origin}/school/${slug}/courses/${courseId}`;
}

/** Public: fetch a published course page by slug, with its published courses. */
export function usePublicCoursePage(slug: string | undefined) {
  return useQuery({
    queryKey: ['course-page', slug],
    enabled: !!slug,
    queryFn: async (): Promise<{ page: CoursePage; courses: Course[] } | null> => {
      const { data: page, error } = await supabase
        .from('course_pages')
        .select('*')
        .eq('slug', slug!)
        .eq('is_published', true)
        .maybeSingle();
      if (error) throw error;
      if (!page) return null;

      let query = supabase
        .from('courses')
        .select('*, teacher:profiles(full_name, avatar_url)')
        .eq('is_published', true)
        .eq('is_archived', false)
        .order('created_at', { ascending: false });
      query = page.owner_type === 'teacher'
        ? query.eq('teacher_id', page.teacher_id)
        : query.eq('org_id', page.org_id);

      const { data: courses, error: coursesError } = await query;
      if (coursesError) throw coursesError;
      return { page: page as CoursePage, courses: (courses ?? []) as Course[] };
    },
  });
}

export type CoursePageOwner =
  | { type: 'teacher'; teacherId: string }
  | { type: 'org'; orgId: string };

/** Owner: fetch own course page (published or not). */
export function useOwnCoursePage(owner: CoursePageOwner | null) {
  const ownerId = owner ? (owner.type === 'teacher' ? owner.teacherId : owner.orgId) : null;
  return useQuery({
    queryKey: ['own-course-page', owner?.type, ownerId],
    enabled: !!owner && !!ownerId,
    queryFn: async (): Promise<CoursePage | null> => {
      const column = owner!.type === 'teacher' ? 'teacher_id' : 'org_id';
      const { data, error } = await supabase
        .from('course_pages')
        .select('*')
        .eq(column, ownerId!)
        .maybeSingle();
      if (error) throw error;
      return data as CoursePage | null;
    },
  });
}

/** Owner: check whether a slug is already taken by another page. */
export async function isSlugTaken(slug: string, excludeId?: string): Promise<boolean> {
  let query = supabase.from('course_pages').select('id').eq('slug', slug);
  if (excludeId) query = query.neq('id', excludeId);
  const { data } = await query.maybeSingle();
  return !!data;
}
