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
    { label: 'About', href: '/about' },
    { label: 'Mission', href: '/our-mission' },
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

  const shellStyle = scrolled || isOpen
    ? 'border-white/90 bg-white/95 shadow-[0_22px_55px_-24px_rgba(8,65,101,0.42)]'
    : 'border-white/80 bg-white/[0.78] shadow-[0_18px_45px_-28px_rgba(8,65,101,0.34)]';

  return (
    <header className="fixed left-0 right-0 top-0 z-40 px-3 pt-3 sm:px-5 sm:pt-4">
      <div className={`relative mx-auto max-w-7xl overflow-hidden rounded-[22px] border px-4 backdrop-blur-2xl transition-all duration-300 sm:px-6 lg:px-7 ${shellStyle}`}>
        <div className="pointer-events-none absolute inset-x-16 top-0 h-px bg-gradient-to-r from-transparent via-amber-300/80 to-transparent" />
        <div className="pointer-events-none absolute -right-12 -top-20 h-36 w-36 rounded-full bg-sky-300/20 blur-3xl" />
        <div className="flex h-[74px] items-center justify-between">
          <Link to="/" className="glass-logo-shell group relative flex shrink-0 items-center rounded-2xl px-2.5 py-1.5">
            <span className="absolute -inset-3 rounded-2xl bg-gradient-to-r from-sky-100/0 via-sky-100/70 to-amber-100/0 opacity-0 blur-xl transition-opacity duration-300 group-hover:opacity-100" />
            <MaximusLogo height={52} variant="dark" brand="corporate" />
          </Link>

          <nav className="hidden items-center gap-1 rounded-2xl border border-white/75 bg-white/55 p-1 shadow-[inset_0_1px_0_rgba(255,255,255,.95),0_10px_26px_-22px_rgba(8,65,101,.55)] backdrop-blur-xl md:flex lg:p-1.5" aria-label="Primary navigation">
            {navLinks.map(link => (
              <Link
                key={link.href}
                to={link.href}
                className={`glass-nav-link relative whitespace-nowrap rounded-xl px-2.5 py-2 text-[11px] font-bold tracking-[0.01em] transition-all duration-300 lg:px-3.5 lg:text-[13px] ${
                  isActive(link.href)
                    ? 'bg-gradient-to-b from-white to-sky-50 text-sky-900 shadow-[0_7px_18px_-12px_rgba(2,82,126,0.65),inset_0_0_0_1px_rgba(125,211,252,0.3)] after:absolute after:bottom-1 after:left-1/2 after:h-1 after:w-1 after:-translate-x-1/2 after:rounded-full after:bg-amber-400'
                    : 'text-slate-600 hover:bg-white/75 hover:text-sky-900'
                }`}
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div ref={menuRef} className="hidden shrink-0 items-center gap-3 lg:flex">
            <button onClick={user && profile ? handleDashboard : () => navigate('/login')} className="inline-flex items-center gap-2 rounded-xl px-3 py-2 text-xs font-bold uppercase tracking-[0.08em] text-slate-500 transition-all hover:bg-white/70 hover:text-sky-900">
              {user && profile && <LayoutDashboard className="h-4 w-4" />}{user && profile ? 'Workspace' : 'Client portal'}
            </button>
            <Link to="/book-online" className="luxury-button-primary gap-2 !rounded-xl !px-5 !py-2.5">
              Start a project <ArrowUpRight className="h-4 w-4" />
            </Link>
          </div>

          <button
            onClick={() => setIsOpen(!isOpen)}
            className="rounded-xl border border-slate-200/80 bg-white/70 p-2.5 text-slate-600 shadow-sm transition-colors hover:bg-sky-50 hover:text-sky-900 md:hidden"
            aria-label={isOpen ? 'Close navigation menu' : 'Open navigation menu'}
            aria-expanded={isOpen}
            aria-controls="mobile-navigation"
          >
            {isOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
        </div>

        {isOpen && (
          <div id="mobile-navigation" className="space-y-1 border-t border-sky-100/80 py-4 md:hidden animate-slide-down">
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
              <Link to="/book-online" className="luxury-button-primary block !rounded-xl !px-4 !py-2.5 text-center">Start a project</Link>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
