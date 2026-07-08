import { useEffect, useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { Menu, X, Globe, Mail } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import type { CoursePage } from '../../types';

/**
 * White-label chrome for a creator's public course page.
 * Shows ONLY the creator's branding (logo, name, colors) — the platform
 * appears at most as a small "Powered by Synapvex" footer note.
 */
export default function StorefrontLayout({ page, children }: { page: CoursePage; children: React.ReactNode }) {
  const { user, profile } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const previousTitle = document.title;
    document.title = page.display_name;
    return () => { document.title = previousTitle; };
  }, [page.display_name]);

  const homeHref = `/school/${page.slug}`;

  const handleAccount = () => {
    // send visitors back to this branded page after signing in
    if (!user || !profile) { navigate(`/login?next=${encodeURIComponent(location.pathname)}`); return; }
    if (profile.role === 'admin') navigate('/admin');
    else if (profile.role === 'co_admin') navigate('/co-admin');
    else if (profile.role === 'org_admin') navigate('/org');
    else if (profile.role === 'teacher') navigate('/teacher');
    else navigate('/student');
  };

  const logo = page.logo_url ? (
    <img src={page.logo_url} alt={page.display_name} className="h-10 w-auto object-contain" />
  ) : (
    <div
      className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold text-lg"
      style={{ backgroundColor: page.accent_color }}
    >
      {page.display_name.charAt(0).toUpperCase()}
    </div>
  );

  return (
    <div className="min-h-screen bg-white flex flex-col">
      <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16 sm:h-20">
            <Link to={homeHref} className="flex items-center gap-3 min-w-0">
              {logo}
              <span className="font-bold text-slate-900 text-lg truncate">{page.display_name}</span>
            </Link>

            <nav className="hidden md:flex items-center gap-2">
              <Link
                to={homeHref}
                className="px-3.5 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 transition-colors"
              >
                Courses
              </Link>
              {page.website && (
                <a
                  href={page.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-3.5 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 transition-colors flex items-center gap-1.5"
                >
                  <Globe className="w-4 h-4" /> Website
                </a>
              )}
              {page.contact_email && (
                <a
                  href={`mailto:${page.contact_email}`}
                  className="px-3.5 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 transition-colors flex items-center gap-1.5"
                >
                  <Mail className="w-4 h-4" /> Contact
                </a>
              )}
              <button
                onClick={handleAccount}
                className="ml-2 px-5 py-2 text-sm font-bold text-white rounded-lg transition-opacity hover:opacity-90"
                style={{ backgroundColor: page.accent_color }}
              >
                {user ? 'My Learning' : 'Sign In'}
              </button>
            </nav>

            <button onClick={() => setMenuOpen(!menuOpen)} className="md:hidden p-2 text-slate-600 hover:bg-slate-100 rounded-lg">
              {menuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>

          {menuOpen && (
            <div className="md:hidden border-t border-slate-100 py-3 space-y-1">
              <Link to={homeHref} onClick={() => setMenuOpen(false)} className="block px-4 py-2.5 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100">
                Courses
              </Link>
              {page.website && (
                <a href={page.website} target="_blank" rel="noopener noreferrer" className="block px-4 py-2.5 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100">
                  Website
                </a>
              )}
              {page.contact_email && (
                <a href={`mailto:${page.contact_email}`} className="block px-4 py-2.5 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100">
                  Contact
                </a>
              )}
              <button
                onClick={handleAccount}
                className="w-full mt-1 px-4 py-2.5 text-sm font-bold text-white rounded-lg"
                style={{ backgroundColor: page.accent_color }}
              >
                {user ? 'My Learning' : 'Sign In'}
              </button>
            </div>
          )}
        </div>
      </header>

      <main className="flex-1">{children}</main>

      <footer className="border-t border-slate-200 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
            <div className="flex items-center gap-3">
              {logo}
              <div>
                <p className="font-bold text-slate-900">{page.display_name}</p>
                {page.tagline && <p className="text-xs text-slate-500">{page.tagline}</p>}
              </div>
            </div>
            <div className="text-sm text-slate-500 space-y-1">
              {page.contact_email && (
                <a href={`mailto:${page.contact_email}`} className="flex items-center gap-2 hover:text-slate-700">
                  <Mail className="w-4 h-4" /> {page.contact_email}
                </a>
              )}
              {page.website && (
                <a href={page.website} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 hover:text-slate-700">
                  <Globe className="w-4 h-4" /> {page.website.replace(/^https?:\/\//, '')}
                </a>
              )}
            </div>
          </div>
          <div className="mt-8 pt-6 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-slate-400">
            <p>© {new Date().getFullYear()} {page.display_name}. All rights reserved.</p>
            {!page.hide_platform_branding && (
              <p>
                Powered by <a href="/" className="font-semibold hover:text-slate-600">Synapvex</a>
              </p>
            )}
          </div>
        </div>
      </footer>
    </div>
  );
}
