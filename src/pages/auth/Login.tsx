import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { Eye, EyeOff, AlertCircle, Chrome as Google, ArrowLeft } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { useToast } from '../../contexts/ToastContext';
import { safeInternalPath } from '../../lib/utils';
import DarkModeToggle from '../../components/ui/DarkModeToggle';
import MaximusLogo from '../../components/ui/MaximusLogo';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { signIn, signInWithGoogle, signInWithMicrosoft } = useAuth();
  const { toast } = useToast();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  // Where to return after signing in (e.g. a teacher's branded course page)
  const next = safeInternalPath(searchParams.get('next'));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) { setError('Please fill in all fields.'); return; }
    setLoading(true);
    setError('');
    const { error } = await signIn(email, password);
    if (error) {
      setError('Invalid email or password. Please try again.');
      setLoading(false);
    } else {
      toast.success('Welcome back!');
      navigate(next ?? '/dashboard');
    }
  };

  const handleOAuth = async (provider: 'google' | 'microsoft') => {
    setError('');
    const { error } = provider === 'google'
      ? await signInWithGoogle(next ?? undefined)
      : await signInWithMicrosoft(next ?? undefined);
    if (error) {
      setError(`Could not start ${provider === 'google' ? 'Google' : 'Microsoft'} sign-in: ${error.message}`);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-navy-950 flex">
      <div className="hidden lg:flex lg:w-1/2 bg-sky-600 relative overflow-hidden">
        <div className="absolute inset-0 opacity-10" style={{backgroundImage: 'radial-gradient(circle at 25% 25%, white 1px, transparent 1px), radial-gradient(circle at 75% 75%, white 1px, transparent 1px)', backgroundSize: '40px 40px'}} />
        <div className="absolute bottom-0 left-0 right-0 h-64 bg-gradient-to-t from-sky-800/60 to-transparent" />
        <div className="relative z-10 flex flex-col justify-center p-16">
          <Link to="/" className="mb-16 self-start rounded-xl border border-white/15 bg-white/10 px-4 py-3 backdrop-blur-sm">
            <MaximusLogo height={48} variant="light" brand="learn" />
          </Link>
          <h2 className="font-sans text-4xl font-bold text-white mb-6 leading-tight">
            Welcome back to SynapVex Learn
          </h2>
          <p className="text-sky-100 text-lg leading-relaxed mb-10">
            Sign in to keep learning, teaching, or managing your courses — everything is right where you left it.
          </p>
          <div className="grid grid-cols-3 gap-6">
            {[['AI', 'Course Builder'], ['Verified', 'Certificates'], ['Anywhere', 'Any Device']].map(([val, label]) => (
              <div key={label} className="text-center bg-white/10 rounded-xl py-4 px-2 backdrop-blur-sm">
                <p className="text-2xl font-bold text-white font-sans">{val}</p>
                <p className="text-sky-100 text-sm mt-1">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="flex-1 flex flex-col">
        <div className="flex justify-between items-center p-4">
          <div className="flex items-center gap-3">
            <Link
              to="/"
              className="flex items-center gap-1.5 text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors"
            >
              <ArrowLeft className="w-4 h-4" />
              <span className="hidden sm:inline">Back to home</span>
            </Link>
            <Link to="/" className="lg:hidden flex items-center gap-2 ml-2">
            <MaximusLogo height={38} variant="dark" brand="learn" />
            </Link>
          </div>
          <DarkModeToggle />
        </div>

        <div className="flex-1 flex items-center justify-center p-8">
          <div className="w-full max-w-md">
            <h1 className="text-3xl font-bold text-navy-900 dark:text-white mb-2">Welcome back</h1>
            <p className="text-gray-500 dark:text-gray-400 mb-8">Sign in to your SynapVex Learn account</p>

            <div className="flex gap-3 mb-6">
              <button
                onClick={() => handleOAuth('google')}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 border border-gray-200 dark:border-navy-600 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-navy-700 transition-colors"
              >
                <Google className="w-4 h-4" />
                Google
              </button>
              <button
                onClick={() => handleOAuth('microsoft')}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 border border-gray-200 dark:border-navy-600 rounded-lg text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-navy-700 transition-colors"
              >
                <svg className="w-4 h-4" viewBox="0 0 24 24"><rect x="1" y="1" width="10" height="10" fill="#F25022"/><rect x="13" y="1" width="10" height="10" fill="#7FBA00"/><rect x="1" y="13" width="10" height="10" fill="#00A4EF"/><rect x="13" y="13" width="10" height="10" fill="#FFB900"/></svg>
                Microsoft
              </button>
            </div>

            <div className="flex items-center gap-3 mb-6">
              <div className="flex-1 h-px bg-gray-200 dark:bg-navy-600" />
              <span className="text-xs text-gray-400">or continue with email</span>
              <div className="flex-1 h-px bg-gray-200 dark:bg-navy-600" />
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              {error && (
                <div className="flex items-center gap-2 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
                  <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                  <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Email address</label>
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  className="input-field"
                  placeholder="you@example.com"
                  required
                />
              </div>

              <div>
                <div className="flex justify-between items-center mb-1.5">
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Password</label>
                  <Link to="/forgot-password" className="text-xs text-gold-600 hover:text-gold-700">Forgot password?</Link>
                </div>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    className="input-field pr-10"
                    placeholder="••••••••"
                    required
                  />
                  <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full btn-primary text-center disabled:opacity-60 disabled:cursor-not-allowed"
              >
                {loading ? 'Signing in...' : 'Sign In'}
              </button>
            </form>

            <p className="mt-6 text-center text-sm text-gray-500 dark:text-gray-400">
              Don't have an account?{' '}
              <Link to={next ? `/register?next=${encodeURIComponent(next)}` : '/register'} className="text-gold-600 hover:text-gold-700 font-medium">Create account</Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
