import { useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { AlertCircle, CheckCircle2, Info, ArrowLeft, ShieldCheck } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { safeInternalPath } from '../../lib/utils';
import DarkModeToggle from '../../components/ui/DarkModeToggle';
import MaximusLogo from '../../components/ui/MaximusLogo';

function GoogleIcon({ className = 'w-5 h-5' }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" aria-hidden="true">
      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.27-4.74 3.27-8.1z"/>
      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84A11 11 0 0 0 12 23z"/>
      <path fill="#FBBC05" d="M5.84 14.1a6.6 6.6 0 0 1 0-4.2V7.06H2.18a11 11 0 0 0 0 9.88l3.66-2.84z"/>
      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1A11 11 0 0 0 2.18 7.06l3.66 2.84C6.71 7.31 9.14 5.38 12 5.38z"/>
    </svg>
  );
}

export default function Register() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { signInWithGoogle } = useAuth();
  const [searchParams] = useSearchParams();
  const next = safeInternalPath(searchParams.get('next'));

  const handleGoogle = async () => {
    setError('');
    setLoading(true);
    const { error } = await signInWithGoogle(next ?? undefined);
    if (error) {
      setError(`Could not start Google sign-up: ${error.message}`);
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-navy-950 flex">
      {/* Brand panel */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-sky-700 via-blue-700 to-indigo-800 relative overflow-hidden">
        <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'radial-gradient(circle at 25% 25%, white 1px, transparent 1px), radial-gradient(circle at 75% 75%, white 1px, transparent 1px)', backgroundSize: '40px 40px' }} />
        <div className="absolute bottom-0 left-0 right-0 h-64 bg-gradient-to-t from-slate-950/50 to-transparent" />
        <div className="relative z-10 flex flex-col justify-center p-16">
          <Link to="/" className="inline-flex items-center gap-3 mb-16 bg-white rounded-2xl px-5 py-3.5 self-start shadow-lg">
            <MaximusLogo height={44} variant="dark" />
          </Link>
          <h2 className="font-playfair text-4xl font-bold text-white mb-6">
            Start your journey with SynapVex
          </h2>
          <p className="text-sky-100 text-lg leading-relaxed mb-8">
            Create your account in seconds and start learning — courses built by real teachers, with progress tracking and certificates included.
          </p>
          <div className="space-y-4">
            {[
              'Courses from independent teachers & academies',
              'Learn at your own pace',
              'AI-powered study tools',
              'Earn industry-recognised certificates',
            ].map(item => (
              <div key={item} className="flex items-center gap-3">
                <div className="w-6 h-6 rounded-full bg-white/20 border border-white/40 flex items-center justify-center shrink-0">
                  <CheckCircle2 className="w-4 h-4 text-white" />
                </div>
                <span className="text-white font-medium">{item}</span>
              </div>
            ))}
          </div>

          {/* Client access note */}
          <div className="mt-10 p-4 rounded-xl bg-white/10 border border-white/20">
            <div className="flex items-start gap-3">
              <Info className="w-4 h-4 text-sky-100 shrink-0 mt-0.5" />
              <div>
                <p className="text-white font-semibold text-sm">Are you a client?</p>
                <p className="text-sky-100 text-xs mt-1 leading-relaxed">
                  Clients get their own course builder, student management and billing dashboard.{' '}
                  <a href="/teach" className="text-white underline hover:text-sky-200 font-semibold">View client plans →</a>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Sign-up panel */}
      <div className="flex-1 flex flex-col bg-white dark:bg-navy-900">
        <div className="flex justify-between items-center p-4">
          <div className="flex items-center gap-3">
            <Link to="/" className="flex items-center gap-1.5 text-sm font-medium text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white transition-colors">
              <ArrowLeft className="w-4 h-4" />
              <span className="hidden sm:inline">Back to home</span>
            </Link>
            <Link to="/" className="lg:hidden flex items-center gap-2 ml-2">
              <MaximusLogo height={40} variant="dark" />
            </Link>
          </div>
          <DarkModeToggle />
        </div>

        <div className="flex-1 flex items-center justify-center p-8">
          <div className="w-full max-w-md">
            <div className="mb-8">
              <h1 className="text-3xl font-bold text-slate-900 dark:text-white mb-2">Create your account</h1>
              <p className="text-slate-500 dark:text-slate-400">Join SynapVex in seconds with your Google account.</p>
            </div>

            {error && (
              <div className="flex items-center gap-2 p-3 mb-5 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
                <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
              </div>
            )}

            <button
              onClick={handleGoogle}
              disabled={loading}
              className="w-full flex items-center justify-center gap-3 px-4 py-3.5 bg-white dark:bg-navy-800 border border-slate-300 dark:border-navy-600 rounded-xl text-[15px] font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-navy-700 hover:border-slate-400 transition-colors shadow-sm disabled:opacity-60 disabled:cursor-not-allowed"
            >
              <GoogleIcon />
              {loading ? 'Redirecting to Google…' : 'Sign up with Google'}
            </button>

            <div className="mt-6 flex items-start gap-2.5 text-xs text-slate-400 dark:text-slate-500">
              <ShieldCheck className="w-4 h-4 shrink-0 mt-px text-slate-400" />
              <p>Secure sign-up with your Google account — no password to create or remember. Your free AI credits are added automatically.</p>
            </div>

            {/* Client access note for mobile */}
            <div className="lg:hidden mt-5 p-3 rounded-xl bg-sky-50 dark:bg-sky-900/20 border border-sky-200 dark:border-sky-800">
              <div className="flex items-start gap-2">
                <Info className="w-4 h-4 text-sky-600 dark:text-sky-400 shrink-0 mt-0.5" />
                <p className="text-xs text-sky-700 dark:text-sky-300">
                  Want to build and sell courses?{' '}
                  <Link to="/teach" className="underline font-semibold">View client plans →</Link>
                </p>
              </div>
            </div>

            <p className="mt-8 text-center text-xs text-slate-400 dark:text-slate-500">
              By continuing you agree to our{' '}
              <Link to="/terms" className="text-sky-600 hover:text-sky-700 font-medium">Terms of Service</Link> and{' '}
              <Link to="/privacy" className="text-sky-600 hover:text-sky-700 font-medium">Privacy Policy</Link>.
            </p>

            <p className="mt-4 text-center text-sm text-slate-500 dark:text-slate-400">
              Already have an account?{' '}
              <Link to={next ? `/login?next=${encodeURIComponent(next)}` : '/login'} className="text-sky-600 hover:text-sky-700 font-medium">Sign in</Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
