import { GraduationCap, Globe, Briefcase, ShieldCheck, type LucideIcon } from 'lucide-react';

/**
 * Central registry of Synapvex products.
 * Synapvex is a multi-product technology company — the LMS (Synapvex Learn)
 * is the first live product; upcoming products are listed as "coming soon"
 * and only need a status flip + href here to go live everywhere (home page,
 * products page, footer).
 */
export interface SynapvexProduct {
  key: string;
  name: string;
  tagline: string;
  description: string;
  icon: LucideIcon;
  status: 'live' | 'coming_soon';
  /** Landing page for the product (only for live products). */
  href?: string;
  accent: string;       // tailwind text color
  accentBg: string;     // tailwind bg color for icon chip
  gradient: string;     // card header gradient
  features: string[];
}

export const PRODUCTS: SynapvexProduct[] = [
  {
    key: 'learn',
    name: 'Synapvex Learn',
    tagline: 'Create, brand & sell your courses',
    description:
      'A complete Learning Management System for independent teachers, academies and organisations. Build courses with AI, get your own branded course page, share one link from your website — your students land on your page and learn here.',
    icon: GraduationCap,
    status: 'live',
    href: '/products/learn',
    accent: 'text-sky-600',
    accentBg: 'bg-sky-600',
    gradient: 'from-sky-600 to-blue-700',
    features: [
      'Your own branded course page (white-label)',
      'AI course, quiz & exam builder',
      'Sell courses with secure online payments',
      'Progress tracking & auto certificates',
    ],
  },
  {
    key: 'sites',
    name: 'Synapvex Sites',
    tagline: 'Business websites, built & hosted',
    description:
      'Launch a professional business website in days — designed, developed and managed by Synapvex, with hosting, SEO and updates handled for you.',
    icon: Globe,
    status: 'coming_soon',
    accent: 'text-emerald-600',
    accentBg: 'bg-emerald-600',
    gradient: 'from-emerald-600 to-teal-700',
    features: ['Custom design & development', 'Managed hosting & updates', 'SEO-ready from day one'],
  },
  {
    key: 'desk',
    name: 'Synapvex Desk',
    tagline: 'Run your business in one place',
    description:
      'A lightweight business suite for small teams — client management, bookings, invoicing and support tickets under one roof.',
    icon: Briefcase,
    status: 'coming_soon',
    accent: 'text-violet-600',
    accentBg: 'bg-violet-600',
    gradient: 'from-violet-600 to-purple-700',
    features: ['CRM & client portal', 'Bookings & invoicing', 'Support ticketing'],
  },
  {
    key: 'shield',
    name: 'Synapvex Shield',
    tagline: 'Security monitoring for SMEs',
    description:
      'Continuous security monitoring, vulnerability alerts and best-practice hardening for small and medium businesses.',
    icon: ShieldCheck,
    status: 'coming_soon',
    accent: 'text-rose-600',
    accentBg: 'bg-rose-600',
    gradient: 'from-rose-600 to-red-700',
    features: ['Vulnerability scanning', 'Security alerts', 'Compliance reports'],
  },
];

export const LIVE_PRODUCTS = PRODUCTS.filter(p => p.status === 'live');
