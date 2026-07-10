import {
  LayoutDashboard, BookOpen, Layers, HelpCircle, FileText, Users, Award, ClipboardList, Store, CreditCard,
} from 'lucide-react';
import type { NavItem } from '../../components/layout/DashboardLayout';

// Lean create-and-deliver dashboard. Live Sessions, Discussions, F2F
// Requests and Earnings/Payouts were removed from the nav (clients handle
// their own payments and don't run live/forum features here). Their pages
// still exist in the codebase, so they're easy to re-enable.
export const teacherNavItems: NavItem[] = [
  { label: 'Dashboard',      href: '/teacher',            icon: LayoutDashboard, group: 'Overview' },
  { label: 'My Courses',     href: '/teacher/courses',    icon: BookOpen,        group: 'Courses' },
  { label: 'Course Builder', href: '/teacher/builder',    icon: Layers,          group: 'Courses' },
  { label: 'My Course Page', href: '/teacher/course-page', icon: Store,          group: 'Courses' },
  { label: 'Quizzes',        href: '/teacher/quizzes',    icon: HelpCircle,      group: 'Teaching' },
  { label: 'Exams',          href: '/teacher/exams',      icon: ClipboardList,   group: 'Teaching' },
  { label: 'Assignments',    href: '/teacher/assignments', icon: FileText,       group: 'Teaching' },
  { label: 'Students',       href: '/teacher/students',   icon: Users,           group: 'Teaching' },
  { label: 'Certificates',   href: '/teacher/certificates', icon: Award,         group: 'Teaching' },
  { label: 'Plan & Billing', href: '/teacher/billing',    icon: CreditCard,      group: 'Account' },
];
