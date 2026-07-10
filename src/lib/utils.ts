import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Validate a ?next= redirect target: only same-app absolute paths are
 * allowed, so external URLs can't hijack the post-login redirect.
 */
export function safeInternalPath(raw: string | null | undefined): string | null {
  if (!raw) return null;
  if (!raw.startsWith('/') || raw.startsWith('//')) return null;
  return raw;
}

/** Human-facing label for a role value. The course-creator role is stored
 *  as 'teacher' internally but shown to users as 'Client'. */
export function roleLabel(role?: string | null): string {
  switch (role) {
    case 'teacher': return 'Client';
    case 'org_admin': return 'Organisation';
    case 'co_admin': return 'Co-admin';
    case 'admin': return 'Admin';
    case 'student': return 'Student';
    default: return role ?? '';
  }
}

/** Display AI credits with the branded "M" suffix (e.g. 200 -> "200M").
 *  Purely cosmetic — the underlying values are unchanged. */
export function formatCredits(n: number | null | undefined): string {
  return `${(n ?? 0).toLocaleString()}M`;
}
