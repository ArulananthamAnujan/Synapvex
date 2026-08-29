import { Link } from 'react-router-dom';
import { ArrowUpRight, Mail, MapPin, Phone } from 'lucide-react';
import MaximusLogo from '../ui/MaximusLogo';
import { PRODUCTS } from '../../lib/products';
import { LOCATIONS } from '../../lib/locations';

const COMPANY_LINKS = [
  { label: 'Capabilities', href: '/about' },
  { label: 'Our mission', href: '/our-mission' },
  { label: 'Contact', href: '/contact' },
  { label: 'Start a project', href: '/book-online' },
];

const SUPPORT_LINKS = [
  { label: 'Sign in', href: '/login' },
  { label: 'Verify certificate', href: '/verify' },
  { label: 'Privacy policy', href: '/privacy' },
  { label: 'Terms of service', href: '/terms' },
  { label: 'Refund policy', href: '/refund-policy' },
];

export default function PublicFooter() {
  return (
    <footer className="relative overflow-hidden border-t border-sky-400/20 bg-[#020617] text-slate-300">
      <div className="pointer-events-none absolute inset-x-[8%] top-0 h-px bg-gradient-to-r from-transparent via-amber-300/70 to-transparent" />
      <div className="pointer-events-none absolute -left-32 top-0 h-80 w-80 rounded-full bg-blue-600/10 blur-[100px]" />
      <div className="pointer-events-none absolute right-0 top-10 h-72 w-72 rounded-full bg-cyan-500/10 blur-[100px]" />
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid gap-12 py-20 sm:py-24 lg:grid-cols-[1.4fr_0.8fr_0.8fr_1fr]">
          <div className="max-w-md">
            <Link to="/" className="inline-flex" aria-label="SynapVex home">
              <MaximusLogo height={72} variant="light" brand="corporate" />
            </Link>
            <p className="mt-6 text-sm leading-6 text-slate-400">
              Technology products and delivery services for organisations modernising their operations, customer experiences and digital infrastructure.
            </p>
            <div className="mt-7 space-y-3">
              <a href="mailto:info@synapvex.com" className="flex items-center gap-3 text-sm text-slate-300 transition-colors hover:text-white">
                <Mail className="h-4 w-4 text-sky-400" /> info@synapvex.com
              </a>
              <a href="tel:+8801321203140" className="flex items-center gap-3 text-sm text-slate-300 transition-colors hover:text-white">
                <Phone className="h-4 w-4 text-sky-400" /> +88 01321-203140
              </a>
            </div>
          </div>

          <div>
            <h2 className="text-xs font-bold uppercase tracking-[0.16em] text-white">Products</h2>
            <ul className="mt-5 space-y-3">
              {PRODUCTS.map(product => (
                <li key={product.key}>
                  {product.status === 'live' && product.href && product.external ? (
                    <a href={product.href} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1.5 text-sm text-slate-400 transition-colors hover:text-white">
                      {product.name} <ArrowUpRight className="h-3.5 w-3.5" />
                    </a>
                  ) : product.status === 'live' && product.href ? (
                    <Link to={product.href} className="text-sm text-slate-400 transition-colors hover:text-white">{product.name}</Link>
                  ) : (
                    <span className="text-sm text-slate-500">{product.name} · In development</span>
                  )}
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-xs font-bold uppercase tracking-[0.16em] text-white">Company</h2>
            <ul className="mt-5 space-y-3">
              {COMPANY_LINKS.map(link => (
                <li key={link.href}><Link to={link.href} className="text-sm text-slate-400 transition-colors hover:text-white">{link.label}</Link></li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="text-xs font-bold uppercase tracking-[0.16em] text-white">Delivery presence</h2>
            <ul className="mt-5 space-y-3">
              {LOCATIONS.map(location => (
                <li key={location.key} className="flex items-start gap-2.5 text-sm text-slate-400">
                  <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-sky-400" />
                  <span>{location.city}, {location.country}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="flex flex-col gap-5 border-t border-slate-800 py-7 lg:flex-row lg:items-center lg:justify-between">
          <p className="text-xs text-slate-500">&copy; {new Date().getFullYear()} SynapVex Technologies. All rights reserved.</p>
          <nav className="flex flex-wrap gap-x-5 gap-y-2" aria-label="Legal and support">
            {SUPPORT_LINKS.map(link => (
              <Link key={link.href} to={link.href} className="text-xs text-slate-500 transition-colors hover:text-slate-300">{link.label}</Link>
            ))}
          </nav>
        </div>
      </div>
    </footer>
  );
}
