import { Link } from 'react-router-dom';
import { ArrowUpRight, Mail, MapPin, Phone } from 'lucide-react';
import MaximusLogo from '../ui/MaximusLogo';
import { PRODUCTS } from '../../lib/products';
import { LOCATIONS } from '../../lib/locations';

const COMPANY_LINKS = [
  { label: 'Capabilities', href: '/about' },
  { label: 'Mission', href: '/our-mission' },
  { label: 'Contact', href: '/contact' },
  { label: 'Start project', href: '/book-online' },
];

const SUPPORT_LINKS = [
  { label: 'Sign in', href: '/login' },
  { label: 'Verify', href: '/verify' },
  { label: 'Privacy', href: '/privacy' },
  { label: 'Terms', href: '/terms' },
  { label: 'Refunds', href: '/refund-policy' },
];

export default function PublicFooter() {
  return (
    <footer className="compact-site-footer relative overflow-hidden border-t border-sky-400/20 bg-[#020617] text-slate-300">
      <div className="pointer-events-none absolute inset-x-[8%] top-0 h-px bg-gradient-to-r from-transparent via-amber-300/65 to-transparent" />
      <div className="pointer-events-none absolute -left-24 top-0 h-48 w-48 rounded-full bg-blue-600/10 blur-[80px]" />
      <div className="pointer-events-none absolute right-0 top-0 h-48 w-48 rounded-full bg-cyan-500/10 blur-[80px]" />

      <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-3 gap-x-4 gap-y-6 py-7 sm:gap-8 sm:py-9 lg:grid-cols-[1.35fr_.8fr_.8fr_1fr]">
          <div className="col-span-3 grid grid-cols-[auto_1fr] items-center gap-x-4 lg:col-span-1 lg:block">
            <Link to="/" className="row-span-2 inline-flex" aria-label="SynapVex home">
              <MaximusLogo height={46} variant="light" brand="corporate" />
            </Link>
            <p className="hidden text-xs leading-5 text-slate-400 lg:mt-3 lg:block">
              Digital products and technology delivery for modern organisations.
            </p>
            <div className="space-y-1.5 lg:mt-4">
              <a href="mailto:info@synapvex.com" className="flex items-center gap-2 text-[10px] text-slate-300 transition-colors hover:text-white sm:text-xs">
                <Mail className="h-3.5 w-3.5 text-sky-400" /> info@synapvex.com
              </a>
              <a href="tel:+8801321203140" className="flex items-center gap-2 text-[10px] text-slate-300 transition-colors hover:text-white sm:text-xs">
                <Phone className="h-3.5 w-3.5 text-sky-400" /> +88 01321-203140
              </a>
            </div>
          </div>

          <div className="min-w-0">
            <h2>Products</h2>
            <ul>
              {PRODUCTS.map(product => (
                <li key={product.key}>
                  {product.status === 'live' && product.href && product.external ? (
                    <a href={product.href} target="_blank" rel="noopener noreferrer">
                      {product.name.replace('SynapVex ', '')} <ArrowUpRight className="h-3 w-3" />
                    </a>
                  ) : product.status === 'live' && product.href ? (
                    <Link to={product.href}>{product.name.replace('SynapVex ', '')}</Link>
                  ) : (
                    <Link to={`/products#${product.key}`}>{product.name.replace('SynapVex ', '')}</Link>
                  )}
                </li>
              ))}
            </ul>
          </div>

          <div className="min-w-0">
            <h2>Company</h2>
            <ul>
              {COMPANY_LINKS.map(link => (
                <li key={link.href}><Link to={link.href}>{link.label}</Link></li>
              ))}
            </ul>
          </div>

          <div className="min-w-0">
            <h2>Presence</h2>
            <ul>
              {LOCATIONS.map(location => (
                <li key={location.key}>
                  <span className="inline-flex items-start gap-1">
                    <MapPin className="mt-0.5 h-3 w-3 shrink-0 text-sky-400" />
                    <span>{location.city}</span>
                  </span>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="flex flex-col gap-2 border-t border-slate-800/90 py-4 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-[9px] text-slate-500 sm:text-[10px]">&copy; {new Date().getFullYear()} SynapVex Technologies.</p>
          <nav className="flex flex-wrap gap-x-3 gap-y-1" aria-label="Legal and support">
            {SUPPORT_LINKS.map(link => (
              <Link key={link.href} to={link.href} className="text-[9px] text-slate-500 transition-colors hover:text-slate-300 sm:text-[10px]">{link.label}</Link>
            ))}
          </nav>
        </div>
      </div>
    </footer>
  );
}
