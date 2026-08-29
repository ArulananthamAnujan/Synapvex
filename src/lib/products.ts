import { GraduationCap, Languages, Users, type LucideIcon } from 'lucide-react';

/**
 * Central registry of SynapVex products.
 *
 * SynapVex is a multi-product technology company. SynapVex Learn (the LMS)
 * is built into this site, so its card links internally. SynapVex PTE and
 * SynapVex CRM are separate applications deployed to their own Netlify URLs,
 * so their cards link out (external, opens in a new tab).
 *
 * To point a product at its live app, set its `href` below. External products
 * whose `href` is still empty automatically render as "Launching soon" so we
 * never ship a dead link.
 */

// --- Live app URLs (paste the Netlify links here) ---------------------------
const PTE_URL = 'https://synapvexpte.netlify.app/home'; // SynapVex PTE
const CRM_URL = ''; // TODO: https://<your-crm-app>.netlify.app

export interface SynapVexProduct {
  key: string;
  name: string;
  tagline: string;
  description: string;
  icon: LucideIcon;
  status: 'live' | 'coming_soon';
  /** Landing/app URL. Internal path (starts with "/") or full external URL. */
  href?: string;
  /** When true the href points to a separate app and opens in a new tab. */
  external?: boolean;
  accent: string;       // tailwind text color
  accentBg: string;     // tailwind bg color for icon chip
  gradient: string;     // card header gradient
  features: string[];
}

export const PRODUCTS: SynapVexProduct[] = [
  {
    key: 'learn',
    name: 'SynapVex Learn',
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
    key: 'pte',
    name: 'SynapVex PTE',
    tagline: 'Practise & master the PTE exam',
    description:
      'A focused PTE preparation platform — realistic scored practice across speaking, writing, reading and listening, with instant AI feedback so learners know exactly what to improve before test day.',
    icon: Languages,
    status: PTE_URL ? 'live' : 'coming_soon',
    href: PTE_URL || undefined,
    external: true,
    accent: 'text-emerald-600',
    accentBg: 'bg-emerald-600',
    gradient: 'from-emerald-600 to-teal-700',
    features: [
      'Full-length scored mock tests',
      'AI feedback on speaking & writing',
      'Question bank across all four skills',
      'Track your score progress over time',
    ],
  },
  {
    key: 'crm',
    name: 'SynapVex CRM',
    tagline: 'Manage clients, deals & pipeline',
    description:
      'A lightweight CRM for growing teams — keep every contact, lead and deal in one place, track your pipeline, and never let a follow-up slip through the cracks.',
    icon: Users,
    status: CRM_URL ? 'live' : 'coming_soon',
    href: CRM_URL || undefined,
    external: true,
    accent: 'text-violet-600',
    accentBg: 'bg-violet-600',
    gradient: 'from-violet-600 to-purple-700',
    features: [
      'Contact & lead management',
      'Visual deal pipeline',
      'Tasks, notes & follow-up reminders',
      'Team-wide activity in one workspace',
    ],
  },
];

export const LIVE_PRODUCTS = PRODUCTS.filter(p => p.status === 'live');
