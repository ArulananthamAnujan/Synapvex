import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const DEFAULT_DESCRIPTION = 'SynapVex builds digital products and provides software, cloud, cybersecurity, infrastructure and managed technology services.';
const PUBLIC_META: Record<string, { title: string; description: string }> = {
  '/': { title: 'SynapVex Technologies | Digital Products & Technology Services', description: DEFAULT_DESCRIPTION },
  '/products': { title: 'Digital Products | SynapVex Technologies', description: 'Explore practical digital products from SynapVex, built to improve learning and business operations.' },
  '/products/learn': { title: 'SynapVex Learn | AI-Powered Learning Platform', description: 'Create, deliver and manage engaging online learning with AI-assisted course tools.' },
  '/courses': { title: 'Online Courses | SynapVex Learn', description: 'Browse online courses from independent educators and organisations using SynapVex Learn.' },
  '/teach': { title: 'Teach Online | SynapVex Learn', description: 'Build courses, assessments and learning materials with an AI-assisted teaching workspace.' },
  '/teach/register': { title: 'Create Your Educator Account | SynapVex Learn', description: 'Start creating and delivering online courses with SynapVex Learn.' },
  '/about': { title: 'About SynapVex Technologies', description: 'Learn about SynapVex Technologies, our capabilities and our approach to dependable digital delivery.' },
  '/our-mission': { title: 'Our Mission | SynapVex Technologies', description: 'Discover the mission and principles guiding SynapVex products and technology services.' },
  '/contact': { title: 'Contact SynapVex Technologies', description: 'Contact the SynapVex team about products, learning solutions or technology services.' },
  '/book-online': { title: 'Book a Consultation | SynapVex Technologies', description: 'Book a conversation with SynapVex about your product or technology needs.' },
  '/verify': { title: 'Verify a Certificate | SynapVex Learn', description: 'Verify the authenticity of a SynapVex Learn course certificate.' },
  '/privacy': { title: 'Privacy Policy | SynapVex', description: 'Read the SynapVex privacy policy.' },
  '/terms': { title: 'Terms of Service | SynapVex', description: 'Read the SynapVex terms of service.' },
  '/refund-policy': { title: 'Refund Policy | SynapVex', description: 'Read the SynapVex refund policy.' },
};

function setMeta(selector: string, attribute: string, value: string) {
  let element = document.head.querySelector<HTMLMetaElement>(selector);
  if (!element) {
    element = document.createElement('meta');
    const [key, raw] = attribute.split('=');
    element.setAttribute(key, raw.replace(/"/g, ''));
    document.head.appendChild(element);
  }
  element.setAttribute('content', value);
}

export default function SeoManager() {
  const { pathname } = useLocation();

  useEffect(() => {
    const basePath = pathname.startsWith('/courses/') ? '/courses' : pathname.startsWith('/verify/') ? '/verify' : pathname;
    const meta = PUBLIC_META[basePath] ?? { title: 'SynapVex Learn', description: DEFAULT_DESCRIPTION };
    const isPrivate = /^\/(admin|co-admin|org|teacher|student|dashboard|login|register|forgot-password)(\/|$)/.test(pathname);
    const canonicalUrl = `https://synapvex.com.au${pathname === '/' ? '/' : pathname.replace(/\/$/, '')}`;

    document.title = meta.title;
    setMeta('meta[name="description"]', 'name=description', meta.description);
    setMeta('meta[name="robots"]', 'name=robots', isPrivate ? 'noindex, nofollow' : 'index, follow');
    setMeta('meta[property="og:title"]', 'property=og:title', meta.title);
    setMeta('meta[property="og:description"]', 'property=og:description', meta.description);
    setMeta('meta[property="og:url"]', 'property=og:url', canonicalUrl);
    document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]')?.setAttribute('href', canonicalUrl);
  }, [pathname]);

  return null;
}
