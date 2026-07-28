import { Link } from 'react-router-dom';
import { Mail, Phone, MapPin, ExternalLink } from 'lucide-react';
import MaximusLogo from '../ui/MaximusLogo';
import { PRODUCTS } from '../../lib/products';
import { LOCATIONS } from '../../lib/locations';

export default function PublicFooter() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-white border-t border-slate-200 text-slate-700">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="py-16 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-10">
          <div className="lg:col-span-2">
            <Link to="/" className="inline-flex items-center gap-3 mb-5">
              <MaximusLogo height={52} variant="dark" />
            </Link>
            <p className="text-sm text-slate-500 leading-relaxed mb-5">
              Innovative, reliable, and cost-effective technology solutions that empower businesses to thrive in the digital age. Your full-spectrum IT partner.
            </p>
            <div className="mb-5">
              <p className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">Our Offices</p>
              <ul className="space-y-3">
                {LOCATIONS.map(loc => (
                  <li key={loc.key} className="flex items-start gap-3">
                    <MapPin className="w-4 h-4 text-sky-600 mt-0.5 shrink-0" />
                    <span className="text-sm text-slate-500">
                      <span className="font-semibold text-slate-700">{loc.flag} {loc.city}, {loc.country}</span>
                      <br />{loc.lines[0]}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
            <ul className="space-y-3 mb-6">
              <li className="flex items-center gap-3">
                <Phone className="w-4 h-4 text-sky-600 shrink-0" />
                <span className="text-sm text-slate-500">
                  <a href="tel:+61481782313" className="hover:text-sky-600 transition-colors">+61 481 782 313</a>
                  <span className="text-slate-300 mx-1.5">·</span>
                  <a href="tel:+61433198567" className="hover:text-sky-600 transition-colors">+61 433 198 567</a>
                </span>
              </li>
              <li className="flex items-center gap-3">
                <Mail className="w-4 h-4 text-sky-600 shrink-0" />
                <a href="mailto:info@synapvex.com" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">info@synapvex.com</a>
              </li>
            </ul>
            {/* Social icons removed until real profile URLs exist — dead
                links undermine trust on a corporate site. Add them back as
                <a href="https://..."> when the profiles are live. */}
          </div>

          <div>
            <h4 className="text-slate-900 font-bold mb-5 text-sm uppercase tracking-wider">Quick Links</h4>
            <ul className="space-y-3">
              {[
                { label: 'Home', href: '/' },
                { label: 'Products', href: '/products' },
                { label: 'Services', href: '/about' },
                { label: 'Our Mission', href: '/our-mission' },
                { label: 'Contact Us', href: '/contact' },
                { label: 'Book Online', href: '/book-online' },
              ].map(link => (
                <li key={link.href}>
                  <Link to={link.href} className="text-sm text-slate-500 hover:text-sky-600 transition-colors">{link.label}</Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-slate-900 font-bold mb-5 text-sm uppercase tracking-wider">Products</h4>
            <ul className="space-y-3">
              {PRODUCTS.map(p => {
                const live = p.status === 'live';
                if (live && p.external && p.href) {
                  return (
                    <li key={p.key}>
                      <a
                        href={p.href}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-sm text-slate-500 hover:text-sky-600 transition-colors font-semibold inline-flex items-center gap-1"
                      >
                        {p.name} <ExternalLink className="w-3 h-3" />
                      </a>
                    </li>
                  );
                }
                if (live && p.href) {
                  return (
                    <li key={p.key}>
                      <Link to={p.href} className="text-sm text-slate-500 hover:text-sky-600 transition-colors font-semibold">{p.name}</Link>
                    </li>
                  );
                }
                return (
                  <li key={p.key} className="flex items-center gap-2">
                    <span className="text-sm text-slate-400">{p.name}</span>
                    <span className="text-[9px] font-bold uppercase tracking-wider bg-slate-100 text-slate-400 px-1.5 py-0.5 rounded">Soon</span>
                  </li>
                );
              })}
              <li>
                <Link to="/products" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">All Products</Link>
              </li>
            </ul>
          </div>

          <div>
            <h4 className="text-slate-900 font-bold mb-5 text-sm uppercase tracking-wider">Our Services</h4>
            <ul className="space-y-3">
              {[
                'Software Development',
                'Website Design',
                'Mobile App Development',
                'Cybersecurity Services',
                'Cloud Solutions',
                'IT Support & Managed Services',
                'Digital Marketing',
                'IT Consulting',
              ].map(service => (
                <li key={service}>
                  <Link to="/about" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">{service}</Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-slate-900 font-bold mb-5 text-sm uppercase tracking-wider">Support</h4>
            <ul className="space-y-3 mb-6">
              {[
                { label: 'Why Choose Us', href: '/about' },
                { label: 'FAQs', href: '/contact' },
                { label: 'Verify Certificate', href: '/verify' },
                { label: 'Sign In', href: '/login' },
              ].map(link => (
                <li key={link.label}>
                  <Link to={link.href} className="text-sm text-slate-500 hover:text-sky-600 transition-colors">{link.label}</Link>
                </li>
              ))}
            </ul>
            <h4 className="text-slate-900 font-bold mb-4 text-sm uppercase tracking-wider">Policies</h4>
            <ul className="space-y-3">
              {[
                { label: 'Privacy Policy', href: '/privacy' },
                { label: 'Terms of Service', href: '/terms' },
                { label: 'Refund Policy', href: '/refund-policy' },
              ].map(item => (
                <li key={item.href}>
                  <Link to={item.href} className="text-sm text-slate-500 hover:text-sky-600 transition-colors">{item.label}</Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="py-6 border-t border-slate-200 flex flex-col md:flex-row items-center justify-between gap-4">
          <p className="text-sm text-slate-400">&copy; {currentYear} SynapVex Technologies. All rights reserved.</p>
          <p className="text-sm text-slate-400">Empowering businesses to thrive in the digital age.</p>
        </div>
      </div>
    </footer>
  );
}
