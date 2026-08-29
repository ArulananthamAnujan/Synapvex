import { useState, useEffect, useRef } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { ArrowUpRight, LayoutDashboard, Menu, X } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import MaximusLogo from '../ui/MaximusLogo';

export default function PublicHeader() {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const { user, profile } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    setIsOpen(false);
  }, [location]);

  const navLinks = [
    { label: 'Home', href: '/' },
    { label: 'Products', href: '/products' },
    { label: 'Capabilities', href: '/about' },
    { label: 'Company', href: '/our-mission' },
    { label: 'Contact', href: '/contact' },
  ];

  const handleDashboard = () => {
    if (profile?.role === 'admin') navigate('/admin');
    else if (profile?.role === 'teacher') navigate('/teacher');
    else navigate('/student');
  };

  const isActive = (href: string) => {
    if (href === '/') return location.pathname === '/';
    return location.pathname.startsWith(href);
  };

  const headerBg = scrolled || isOpen
    ? 'bg-white/95 shadow-[0_14px_40px_-28px_rgba(24,72,112,0.45)] border-b border-sky-100/80 backdrop-blur-xl'
    : 'bg-white/80 backdrop-blur-xl border-b border-white/70';

  return (
    <header className={`fixed top-0 left-0 right-0 z-40 transition-all duration-300 ${headerBg}`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex h-20 items-center justify-between">
          <Link to="/" className="flex items-center shrink-0">
            <MaximusLogo height={56} variant="dark" brand="corporate" />
          </Link>

          <nav className="hidden items-center gap-7 lg:flex" aria-label="Primary navigation">
            {navLinks.map(link => (
              <Link
                key={link.href}
                to={link.href}
                className={`relative py-2 text-sm font-semibold transition-colors whitespace-nowrap ${
                  isActive(link.href)
                    ? 'text-sky-800 after:absolute after:inset-x-0 after:-bottom-1 after:h-0.5 after:bg-gradient-to-r after:from-sky-600 after:to-amber-400'
                    : 'text-slate-600 hover:text-sky-900'
                }`}
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div ref={menuRef} className="hidden lg:flex items-center gap-2 shrink-0">
            <button onClick={user && profile ? handleDashboard : () => navigate('/login')} className="inline-flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 transition-colors hover:text-sky-900">
              {user && profile && <LayoutDashboard className="h-4 w-4" />}{user && profile ? 'Workspace' : 'Client portal'}
            </button>
            <Link to="/book-online" className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-r from-sky-800 to-sky-500 px-5 py-2.5 text-sm font-bold text-white shadow-[0_12px_28px_-12px_rgba(18,91,137,0.65)] transition-all hover:-translate-y-0.5 hover:shadow-sky-500/30">
              Start a project <ArrowUpRight className="h-4 w-4" />
            </Link>
          </div>

          <button
            onClick={() => setIsOpen(!isOpen)}
            className="rounded-lg p-2 text-slate-600 transition-colors hover:bg-sky-50 hover:text-sky-900 lg:hidden"
            aria-label={isOpen ? 'Close navigation menu' : 'Open navigation menu'}
            aria-expanded={isOpen}
            aria-controls="mobile-navigation"
          >
            {isOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>

        {isOpen && (
          <div id="mobile-navigation" className="space-y-1 border-t border-sky-100 py-4 lg:hidden animate-slide-down">
            {navLinks.map(link => (
              <Link
                key={link.href}
                to={link.href}
                className={`block px-4 py-2.5 rounded-lg text-sm font-semibold transition-colors ${
                  isActive(link.href)
                    ? 'bg-sky-50 text-sky-800'
                    : 'text-slate-700 hover:bg-sky-50 hover:text-sky-900'
                }`}
              >
                {link.label}
              </Link>
            ))}
            <div className="pt-3 border-t border-sky-100 flex flex-col gap-2">
              <button onClick={user && profile ? handleDashboard : () => navigate('/login')} className="block w-full rounded-xl border border-slate-200 px-4 py-2.5 text-center text-sm font-semibold text-slate-700 transition-colors hover:bg-sky-50">{user && profile ? 'Open workspace' : 'Client portal'}</button>
              <Link to="/book-online" className="block rounded-xl bg-gradient-to-r from-blue-600 to-cyan-400 px-4 py-2.5 text-center text-sm font-bold text-white">Start a project</Link>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
