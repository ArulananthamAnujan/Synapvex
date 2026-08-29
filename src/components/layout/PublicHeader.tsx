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
    ? 'bg-slate-950/95 shadow-2xl shadow-slate-950/20 border-b border-white/10 backdrop-blur-xl'
    : 'bg-slate-950/85 backdrop-blur-xl border-b border-white/10';

  return (
    <header className={`fixed top-0 left-0 right-0 z-40 transition-all duration-300 ${headerBg}`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex h-20 items-center justify-between">
          <Link to="/" className="flex items-center shrink-0">
            <MaximusLogo height={56} variant="light" brand="corporate" />
          </Link>

          <nav className="hidden items-center gap-7 lg:flex" aria-label="Primary navigation">
            {navLinks.map(link => (
              <Link
                key={link.href}
                to={link.href}
                className={`relative py-2 text-sm font-semibold transition-colors whitespace-nowrap ${
                  isActive(link.href)
                    ? 'text-white after:absolute after:inset-x-0 after:-bottom-1 after:h-0.5 after:bg-gradient-to-r after:from-sky-400 after:to-cyan-300'
                    : 'text-slate-300 hover:text-white'
                }`}
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div ref={menuRef} className="hidden lg:flex items-center gap-2 shrink-0">
            <button onClick={user && profile ? handleDashboard : () => navigate('/login')} className="inline-flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-300 transition-colors hover:text-white">
              {user && profile && <LayoutDashboard className="h-4 w-4" />}{user && profile ? 'Workspace' : 'Client portal'}
            </button>
            <Link to="/book-online" className="inline-flex items-center gap-2 rounded-xl border border-sky-300/30 bg-gradient-to-r from-blue-600 via-sky-500 to-cyan-400 px-5 py-2.5 text-sm font-bold text-white shadow-lg shadow-sky-950/40 transition-all hover:-translate-y-0.5 hover:shadow-sky-500/25">
              Start a project <ArrowUpRight className="h-4 w-4" />
            </Link>
          </div>

          <button
            onClick={() => setIsOpen(!isOpen)}
            className="rounded-lg p-2 text-slate-300 transition-colors hover:bg-white/10 hover:text-white lg:hidden"
            aria-label={isOpen ? 'Close navigation menu' : 'Open navigation menu'}
            aria-expanded={isOpen}
            aria-controls="mobile-navigation"
          >
            {isOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>

        {isOpen && (
          <div id="mobile-navigation" className="space-y-1 border-t border-white/10 py-4 lg:hidden animate-slide-down">
            {navLinks.map(link => (
              <Link
                key={link.href}
                to={link.href}
                className={`block px-4 py-2.5 rounded-lg text-sm font-semibold transition-colors ${
                  isActive(link.href)
                    ? 'bg-sky-500/15 text-sky-300'
                    : 'text-slate-300 hover:bg-white/10 hover:text-white'
                }`}
              >
                {link.label}
              </Link>
            ))}
            <div className="pt-3 border-t border-white/10 flex flex-col gap-2">
              <button onClick={user && profile ? handleDashboard : () => navigate('/login')} className="block w-full rounded-xl border border-white/15 px-4 py-2.5 text-center text-sm font-semibold text-white transition-colors hover:bg-white/10">{user && profile ? 'Open workspace' : 'Client portal'}</button>
              <Link to="/book-online" className="block rounded-xl bg-gradient-to-r from-blue-600 to-cyan-400 px-4 py-2.5 text-center text-sm font-bold text-white">Start a project</Link>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
