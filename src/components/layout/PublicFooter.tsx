import { Link } from 'react-router-dom';
import { Mail, Phone, MapPin, Facebook, Instagram, Linkedin, Twitter } from 'lucide-react';
import MaximusLogo from '../ui/MaximusLogo';

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
            <ul className="space-y-3 mb-6">
              <li className="flex items-start gap-3">
                <MapPin className="w-4 h-4 text-sky-600 mt-0.5 shrink-0" />
                <span className="text-sm text-slate-500">Building 33, Level 4, Suite 4A, Shah Makhdum Avenue,<br />Sector-12, Uttara, Dhaka, Bangladesh, 1230</span>
              </li>
              <li className="flex items-center gap-3">
                <Phone className="w-4 h-4 text-sky-600 shrink-0" />
                <a href="tel:+8801321203140" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">+88 01321-203140</a>
              </li>
              <li className="flex items-center gap-3">
                <Mail className="w-4 h-4 text-sky-600 shrink-0" />
                <a href="mailto:info@synapvex.com" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">info@synapvex.com</a>
              </li>
            </ul>
            <div className="flex gap-3">
              <a href="#" className="w-9 h-9 bg-slate-100 hover:bg-sky-600 rounded-lg flex items-center justify-center transition-colors group" aria-label="Facebook">
                <Facebook className="w-4 h-4 text-slate-500 group-hover:text-white transition-colors" />
              </a>
              <a href="#" className="w-9 h-9 bg-slate-100 hover:bg-sky-600 rounded-lg flex items-center justify-center transition-colors group" aria-label="Instagram">
                <Instagram className="w-4 h-4 text-slate-500 group-hover:text-white transition-colors" />
              </a>
              <a href="#" className="w-9 h-9 bg-slate-100 hover:bg-sky-600 rounded-lg flex items-center justify-center transition-colors group" aria-label="LinkedIn">
                <Linkedin className="w-4 h-4 text-slate-500 group-hover:text-white transition-colors" />
              </a>
              <a href="#" className="w-9 h-9 bg-slate-100 hover:bg-sky-600 rounded-lg flex items-center justify-center transition-colors group" aria-label="Twitter">
                <Twitter className="w-4 h-4 text-slate-500 group-hover:text-white transition-colors" />
              </a>
            </div>
          </div>

          <div>
            <h4 className="text-slate-900 font-bold mb-5 text-sm uppercase tracking-wider">Quick Links</h4>
            <ul className="space-y-3">
              {[
                { label: 'Home', href: '/' },
                { label: 'Products', href: '/products' },
                { label: 'Services', href: '/about' },
                { label: 'Our Mission', href: '/our-mission' },
                { label: 'Become a Teacher', href: '/teach' },
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
              <li>
                <Link to="/products/learn" className="text-sm text-slate-500 hover:text-sky-600 transition-colors font-semibold">Synapvex Learn</Link>
              </li>
              <li>
                <Link to="/products" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">All Products</Link>
              </li>
              <li>
                <Link to="/teach" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">Become a Teacher</Link>
              </li>
              <li>
                <Link to="/teach/register" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">Teacher Pricing</Link>
              </li>
              {['Synapvex Sites', 'Synapvex Desk', 'Synapvex Shield'].map(p => (
                <li key={p} className="flex items-center gap-2">
                  <span className="text-sm text-slate-400">{p}</span>
                  <span className="text-[9px] font-bold uppercase tracking-wider bg-slate-100 text-slate-400 px-1.5 py-0.5 rounded">Soon</span>
                </li>
              ))}
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
                { label: 'Student Portal', href: '/student' },
                { label: 'Verify Certificate', href: '/verify' },
                { label: 'Notifications', href: '/notifications' },
              ].map(link => (
                <li key={link.label}>
                  <Link to={link.href} className="text-sm text-slate-500 hover:text-sky-600 transition-colors">{link.label}</Link>
                </li>
              ))}
            </ul>
            <h4 className="text-slate-900 font-bold mb-4 text-sm uppercase tracking-wider">Policies</h4>
            <ul className="space-y-3">
              {['Privacy Policy', 'Terms of Service', 'Refund Policy'].map(item => (
                <li key={item}>
                  <a href="#" className="text-sm text-slate-500 hover:text-sky-600 transition-colors">{item}</a>
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
