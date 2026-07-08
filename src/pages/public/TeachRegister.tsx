import { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { Eye, EyeOff, AlertCircle, CheckCircle2, ArrowLeft, CheckCircle, Zap } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { useToast } from '../../contexts/ToastContext';
import { supabase } from '../../lib/supabase';
import MaximusLogo from '../../components/ui/MaximusLogo';
import DarkModeToggle from '../../components/ui/DarkModeToggle';

interface Plan {
  id: string;
  name: string;
  slug: string;
  price_monthly_cents: number;
  price_yearly_cents: number | null;
  max_courses: number;
  max_students: number;
  ai_tokens_monthly: number;
  features: string[];
}

export default function TeachRegister() {
  const [searchParams] = useSearchParams();
  const planSlug = searchParams.get('plan') || 'professional';

  const [plans, setPlans] = useState<Plan[]>([]);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [formData, setFormData] = useState({ fullName: '', email: '', password: '', confirmPassword: '' });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [step, setStep] = useState<'plan' | 'register'>('plan');
  const [billingInterval, setBillingInterval] = useState<'monthly' | 'yearly'>('monthly');

  const { signUp, user, profile, signOut } = useAuth();
  const { toast } = useToast();
  const navigate = useNavigate();

  // Existing teachers subscribe with their current account instead of
  // creating a duplicate one.
  const [hasActiveSub, setHasActiveSub] = useState<boolean | null>(null);
  useEffect(() => {
    if (user && profile?.role === 'teacher') {
      supabase
        .from('teacher_subscriptions')
        .select('id')
        .eq('teacher_id', user.id)
        .eq('status', 'active')
        .maybeSingle()
        .then(({ data }) => setHasActiveSub(!!data));
    } else {
      setHasActiveSub(null);
    }
  }, [user, profile]);

  useEffect(() => {
    supabase
      .from('teacher_subscription_plans')
      .select('*')
      .eq('is_active', true)
      .order('sort_order')
      .then(({ data }) => {
        if (data) {
          setPlans(data as Plan[]);
          const found = (data as Plan[]).find(p => p.slug === planSlug) ?? (data as Plan[])[1] ?? (data as Plan[])[0];
          if (found) setSelectedPlan(found);
        }
      });
  }, [planSlug]);

  const passwordChecks = [
    { label: 'At least 8 characters', ok: formData.password.length >= 8 },
    { label: 'Contains uppercase letter', ok: /[A-Z]/.test(formData.password) },
    { label: 'Contains number', ok: /\d/.test(formData.password) },
  ];

  const handleChange = (field: string) => (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({ ...prev, [field]: e.target.value }));
    setError('');
  };

  const planPriceCents = (plan: Plan) => billingInterval === 'yearly'
    ? (plan.price_yearly_cents ?? plan.price_monthly_cents * 10)
    : plan.price_monthly_cents;
  const intervalSuffix = billingInterval === 'yearly' ? '/yr' : '/mo';
  const periodDays = billingInterval === 'yearly' ? 365 : 30;

  // Start a subscription checkout for an already-signed-in teacher.
  const handleSubscribeExisting = async () => {
    if (!selectedPlan || !user) return;
    setLoading(true);
    setError('');
    await supabase.from('teacher_subscriptions').insert({
      teacher_id: user.id,
      plan_id: selectedPlan.id,
      status: 'pending',
      billing_interval: billingInterval,
      current_period_start: new Date().toISOString(),
      current_period_end: new Date(Date.now() + periodDays * 24 * 60 * 60 * 1000).toISOString(),
    });
    try {
      const session = await supabase.auth.getSession();
      const token = session.data.session?.access_token;
      if (token) {
        const resp = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/stripe-create-checkout`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
          body: JSON.stringify({ type: 'teacher_subscription', plan_id: selectedPlan.id, billing_interval: billingInterval }),
        });
        const data = await resp.json();
        if (data.url) {
          window.location.href = data.url;
          return;
        }
      }
    } catch {
      // Stripe not configured — admin can verify the subscription manually
    }
    toast.success('Plan selected! Your subscription is being set up.');
    navigate('/teacher');
  };

  const handleRegisterAndCheckout = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPlan) { setError('Please select a plan first.'); return; }
    if (!formData.fullName || !formData.email || !formData.password) {
      setError('Please fill in all fields.'); return;
    }
    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match.'); return;
    }
    if (formData.password.length < 8) {
      setError('Password must be at least 8 characters.'); return;
    }

    setLoading(true);
    setError('');

    // 1. Create account as teacher
    const { error: signUpError, data: signUpData } = await signUp(
      formData.email, formData.password, formData.fullName, 'teacher'
    );

    if (signUpError) {
      setError(signUpError.message || 'Registration failed. Please try again.');
      setLoading(false);
      return;
    }

    // 2. Create pending subscription record
    const userId = signUpData?.user?.id;
    if (userId) {
      await supabase.from('teacher_subscriptions').insert({
        teacher_id: userId,
        plan_id: selectedPlan.id,
        status: 'pending',
        billing_interval: billingInterval,
        current_period_start: new Date().toISOString(),
        current_period_end: new Date(Date.now() + periodDays * 24 * 60 * 60 * 1000).toISOString(),
      });
    }

    // 3. Trigger Stripe checkout for the subscription
    try {
      const session = await supabase.auth.getSession();
      const token = session.data.session?.access_token;
      if (token) {
        const resp = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/stripe-create-checkout`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
          body: JSON.stringify({ type: 'teacher_subscription', plan_id: selectedPlan.id, billing_interval: billingInterval }),
        });
        const data = await resp.json();
        if (data.url) {
          window.location.href = data.url;
          return;
        }
      }
    } catch {
      // Stripe not configured — still let them in as teacher (admin can verify subscription)
    }

    toast.success(`Welcome aboard! Your teacher account is active. Set up your first course.`);
    navigate('/teacher');
  };

  // Signed in with a non-teacher account: don't offer the signup form —
  // signing up while logged in would clash with the current session.
  if (user && profile && profile.role !== 'teacher') {
    return (
      <div className="min-h-screen bg-slate-50 flex flex-col">
        <div className="flex items-center justify-between p-4 bg-white border-b border-slate-200">
          <Link to="/teach" className="flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors">
            <ArrowLeft className="w-4 h-4" /> Back
          </Link>
          <Link to="/"><MaximusLogo height={44} variant="dark" /></Link>
          <DarkModeToggle />
        </div>
        <div className="flex-1 flex items-center justify-center p-6">
          <div className="bg-white rounded-2xl shadow-lg border border-slate-200 p-8 max-w-md w-full text-center">
            <div className="w-14 h-14 rounded-full bg-sky-100 flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="w-7 h-7 text-sky-600" />
            </div>
            <h2 className="text-xl font-bold text-slate-900 mb-2">You're already signed in</h2>
            <p className="text-sm text-slate-500 mb-6">
              You're signed in as <strong>{profile.email}</strong> ({profile.role.replace('_', ' ')} account).
              To create a separate teacher account, sign out first — or head back to your dashboard.
            </p>
            <div className="flex flex-col gap-2.5">
              <button onClick={() => navigate('/dashboard')} className="btn-primary w-full">Go to My Dashboard</button>
              <button
                onClick={async () => { await signOut(); }}
                className="w-full px-6 py-2.5 border-2 border-slate-200 text-slate-600 text-sm font-semibold rounded-xl hover:border-slate-300 transition-colors"
              >
                Sign out & create a teacher account
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Teacher with an active plan: nothing to buy here.
  if (user && profile?.role === 'teacher' && hasActiveSub) {
    return (
      <div className="min-h-screen bg-slate-50 flex flex-col">
        <div className="flex items-center justify-between p-4 bg-white border-b border-slate-200">
          <Link to="/teach" className="flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors">
            <ArrowLeft className="w-4 h-4" /> Back
          </Link>
          <Link to="/"><MaximusLogo height={44} variant="dark" /></Link>
          <DarkModeToggle />
        </div>
        <div className="flex-1 flex items-center justify-center p-6">
          <div className="bg-white rounded-2xl shadow-lg border border-slate-200 p-8 max-w-md w-full text-center">
            <div className="w-14 h-14 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
              <CheckCircle2 className="w-7 h-7 text-emerald-600" />
            </div>
            <h2 className="text-xl font-bold text-slate-900 mb-2">Your plan is already active</h2>
            <p className="text-sm text-slate-500 mb-6">
              You're signed in as <strong>{profile.email}</strong> with an active teaching plan.
              Manage your plan and earnings from your dashboard.
            </p>
            <button onClick={() => navigate('/teacher')} className="btn-primary w-full">Go to Teacher Dashboard</button>
          </div>
        </div>
      </div>
    );
  }

  if (step === 'plan') {
    return (
      <div className="min-h-screen bg-slate-50">
        <div className="flex items-center justify-between p-4 bg-white border-b border-slate-200">
          <Link to="/teach" className="flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors">
            <ArrowLeft className="w-4 h-4" /> Back
          </Link>
          <Link to="/"><MaximusLogo height={44} variant="dark" /></Link>
          <DarkModeToggle />
        </div>

        <div className="max-w-5xl mx-auto px-4 py-16">
          <div className="text-center mb-12">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Step 1 of 2</p>
            <h1 className="font-playfair text-4xl font-bold text-slate-900 mb-3">Choose Your Teaching Plan</h1>
            <p className="text-slate-500 max-w-lg mx-auto">Pay monthly, or pay for the year upfront and save two months. Cancel anytime.</p>
            <div className="inline-flex items-center bg-white border border-slate-200 rounded-xl p-1 mt-6">
              {(['monthly', 'yearly'] as const).map(i => (
                <button
                  key={i}
                  type="button"
                  onClick={() => setBillingInterval(i)}
                  className={`px-5 py-2 rounded-lg text-sm font-bold transition-colors flex items-center gap-1.5 ${
                    billingInterval === i ? 'bg-sky-600 text-white shadow-sm' : 'text-slate-500 hover:text-slate-700'
                  }`}
                >
                  {i === 'monthly' ? 'Monthly' : 'Annual'}
                  {i === 'yearly' && (
                    <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full ${billingInterval === i ? 'bg-white/20 text-white' : 'bg-emerald-100 text-emerald-700'}`}>
                      2 months free
                    </span>
                  )}
                </button>
              ))}
            </div>
          </div>

          {plans.length === 0 ? (
            <div className="grid md:grid-cols-3 gap-6">
              {[1,2,3].map(i => <div key={i} className="h-80 bg-slate-200 rounded-2xl animate-pulse" />)}
            </div>
          ) : (
            <div className="grid md:grid-cols-3 gap-5 items-start">
              {plans.map(plan => {
                const isSelected = selectedPlan?.id === plan.id;
                const isPopular = plan.slug === 'professional';
                return (
                  <button
                    key={plan.id}
                    type="button"
                    onClick={() => setSelectedPlan(plan)}
                    className={`relative rounded-2xl border-2 p-6 text-left w-full transition-all duration-200 ${
                      isSelected
                        ? 'border-sky-600 bg-sky-50 shadow-xl shadow-sky-100'
                        : 'border-slate-200 bg-white hover:border-sky-300 hover:shadow-md'
                    } ${isPopular ? 'ring-2 ring-sky-200' : ''}`}
                  >
                    {isPopular && (
                      <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-sky-600 text-white text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-wider">
                        Most Popular
                      </div>
                    )}
                    {isSelected && (
                      <div className="absolute top-4 right-4 w-6 h-6 bg-sky-600 rounded-full flex items-center justify-center">
                        <CheckCircle2 className="w-4 h-4 text-white" />
                      </div>
                    )}
                    <h3 className="font-bold text-slate-900 text-lg mb-1">{plan.name}</h3>
                    <div className="flex items-end gap-1 mb-1">
                      <span className="font-black text-3xl text-slate-900">${(planPriceCents(plan) / 100).toFixed(0)}</span>
                      <span className="text-slate-400 text-sm mb-0.5">{intervalSuffix}</span>
                    </div>
                    {billingInterval === 'yearly' ? (
                      <p className="text-xs text-emerald-600 font-semibold mb-4">≈ ${(planPriceCents(plan) / 1200).toFixed(2)}/month, paid upfront for the year</p>
                    ) : (
                      <div className="mb-4" />
                    )}
                    <ul className="space-y-2">
                      {(plan.features as string[]).slice(0, 5).map(f => (
                        <li key={f} className="flex items-start gap-2 text-xs text-slate-600">
                          <CheckCircle className={`w-3.5 h-3.5 shrink-0 mt-0.5 ${isSelected ? 'text-sky-600' : 'text-emerald-500'}`} />
                          {f}
                        </li>
                      ))}
                      {(plan.features as string[]).length > 5 && (
                        <li className="text-xs text-slate-400">+{(plan.features as string[]).length - 5} more features</li>
                      )}
                    </ul>
                  </button>
                );
              })}
            </div>
          )}

          <div className="mt-10 text-center">
            <button
              disabled={!selectedPlan}
              onClick={() => setStep('register')}
              className="px-10 py-4 bg-sky-600 hover:bg-sky-700 text-white font-bold rounded-xl transition-colors disabled:opacity-50 flex items-center gap-2 mx-auto"
            >
              Continue with {selectedPlan?.name ?? '...'} <ArrowLeft className="w-5 h-5 rotate-180" />
            </button>
            <p className="text-sm text-slate-400 mt-3">
              Already have an account? <Link to="/login" className="text-sky-600 hover:underline font-medium">Sign in</Link>
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Signed-in teacher without an active plan: subscribe with the existing
  // account — no second registration.
  if (user && profile?.role === 'teacher') {
    return (
      <div className="min-h-screen bg-slate-50 flex flex-col">
        <div className="flex items-center justify-between p-4 bg-white border-b border-slate-200">
          <button onClick={() => setStep('plan')} className="flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors">
            <ArrowLeft className="w-4 h-4" /> Back to plan selection
          </button>
          <Link to="/"><MaximusLogo height={44} variant="dark" /></Link>
          <DarkModeToggle />
        </div>
        <div className="flex-1 flex items-center justify-center p-6">
          <div className="bg-white rounded-2xl shadow-lg border border-slate-200 p-8 max-w-md w-full">
            <p className="text-sky-600 text-sm font-semibold uppercase tracking-wider mb-1">Step 2 of 2</p>
            <h2 className="text-2xl font-bold text-slate-900 mb-2">Activate your plan</h2>
            <p className="text-sm text-slate-500 mb-6">
              You're signed in as <strong>{profile.email}</strong> — no new account needed.
              Continue to payment to activate your plan.
            </p>
            {error && (
              <div className="flex items-center gap-2 p-3 mb-4 bg-red-50 border border-red-200 rounded-lg">
                <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                <p className="text-sm text-red-600">{error}</p>
              </div>
            )}
            {selectedPlan && (
              <div className="p-4 rounded-xl bg-sky-50 border border-sky-200 mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sky-800 font-semibold">{selectedPlan.name} Plan</span>
                  <span className="text-sky-700 font-black">${(planPriceCents(selectedPlan) / 100).toFixed(0)}{intervalSuffix}</span>
                </div>
                <ul className="space-y-1.5">
                  {(selectedPlan.features as string[]).slice(0, 5).map(f => (
                    <li key={f} className="flex items-center gap-2 text-xs text-slate-600">
                      <CheckCircle className="w-3.5 h-3.5 text-sky-600 shrink-0" /> {f}
                    </li>
                  ))}
                </ul>
                <button type="button" onClick={() => setStep('plan')} className="mt-3 text-xs text-sky-600 hover:underline">Change plan</button>
              </div>
            )}
            <button
              onClick={handleSubscribeExisting}
              disabled={loading || !selectedPlan}
              className="btn-primary w-full disabled:opacity-60"
            >
              {loading ? 'Redirecting to payment...' : 'Subscribe & Continue to Payment'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Left panel */}
      <div className="hidden lg:flex lg:w-5/12 bg-slate-900 relative overflow-hidden flex-col justify-between p-12">
        <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'radial-gradient(circle at 25% 25%, white 1px, transparent 1px)', backgroundSize: '40px 40px' }} />
        <div className="absolute top-0 right-0 w-96 h-96 bg-sky-500/10 rounded-full blur-3xl" />
        <div className="relative z-10">
          <Link to="/" className="inline-flex mb-10 bg-white rounded-xl px-4 py-3">
            <MaximusLogo height={52} variant="dark" />
          </Link>
          <h2 className="font-playfair text-3xl font-bold text-white mb-4">
            You're signing up as a<br />
            <span className="text-sky-400">{selectedPlan?.name} Teacher</span>
          </h2>
          <p className="text-slate-400 mb-8 leading-relaxed">
            Create courses, share your link, and build your teaching business on Synapvex Learn.
          </p>
          {selectedPlan && (
            <div className="bg-white/10 border border-white/20 rounded-2xl p-5 mb-6">
              <div className="flex items-center justify-between mb-3">
                <span className="text-white font-bold">{selectedPlan.name} Plan</span>
                <span className="text-sky-300 font-black">${(planPriceCents(selectedPlan) / 100).toFixed(0)}{intervalSuffix}</span>
              </div>
              <ul className="space-y-1.5">
                {(selectedPlan.features as string[]).map(f => (
                  <li key={f} className="flex items-center gap-2 text-xs text-slate-300">
                    <CheckCircle className="w-3.5 h-3.5 text-sky-400 shrink-0" />
                    {f}
                  </li>
                ))}
              </ul>
              <button
                type="button"
                onClick={() => setStep('plan')}
                className="mt-4 text-xs text-sky-400 hover:text-sky-300 underline"
              >
                Change plan
              </button>
            </div>
          )}
          <div className="flex items-center gap-2 text-sky-300 text-sm">
            <Zap className="w-4 h-4" />
            <span>Cancel anytime — you keep access until the end of your paid period.</span>
          </div>
        </div>
        <p className="relative z-10 text-xs text-slate-600">
          SynapVex Technologies — All rights reserved.
        </p>
      </div>

      {/* Right panel */}
      <div className="flex-1 flex flex-col bg-white">
        <div className="flex justify-between items-center p-4">
          <button
            onClick={() => setStep('plan')}
            className="flex items-center gap-1.5 text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" /> Back to plan selection
          </button>
          <DarkModeToggle />
        </div>

        <div className="flex-1 flex items-center justify-center p-8">
          <div className="w-full max-w-md">
            <div className="mb-6">
              <p className="text-sky-600 text-sm font-semibold uppercase tracking-wider mb-1">Step 2 of 2</p>
              <h1 className="text-3xl font-bold text-slate-900 mb-2">Create Your Teacher Account</h1>
              <p className="text-gray-500 text-sm">You'll be redirected to payment to activate your plan.</p>
            </div>

            <form onSubmit={handleRegisterAndCheckout} className="space-y-4">
              {error && (
                <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
                  <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                  <p className="text-sm text-red-600">{error}</p>
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Full Name</label>
                <input type="text" value={formData.fullName} onChange={handleChange('fullName')} className="input-field" placeholder="Jane Smith" required />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Email Address</label>
                <input type="email" value={formData.email} onChange={handleChange('email')} className="input-field" placeholder="you@example.com" required />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Password</label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={formData.password}
                    onChange={handleChange('password')}
                    className="input-field pr-10"
                    placeholder="Create a strong password"
                    required
                  />
                  <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
                {formData.password && (
                  <div className="mt-2 space-y-1">
                    {passwordChecks.map(check => (
                      <div key={check.label} className="flex items-center gap-2">
                        <div className={`w-3.5 h-3.5 rounded-full flex items-center justify-center ${check.ok ? 'bg-green-500' : 'bg-gray-200'}`}>
                          {check.ok && <CheckCircle2 className="w-2.5 h-2.5 text-white" />}
                        </div>
                        <span className={`text-xs ${check.ok ? 'text-green-600' : 'text-gray-400'}`}>{check.label}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Confirm Password</label>
                <input
                  type="password"
                  value={formData.confirmPassword}
                  onChange={handleChange('confirmPassword')}
                  className="input-field"
                  placeholder="Repeat your password"
                  required
                />
              </div>

              {/* Mobile plan summary */}
              {selectedPlan && (
                <div className="lg:hidden p-4 rounded-xl bg-sky-50 border border-sky-200">
                  <div className="flex items-center justify-between">
                    <span className="text-sky-800 font-semibold text-sm">{selectedPlan.name} Plan</span>
                    <span className="text-sky-700 font-bold">${(planPriceCents(selectedPlan) / 100).toFixed(0)}{intervalSuffix}</span>
                  </div>
                  <button type="button" onClick={() => setStep('plan')} className="text-xs text-sky-600 hover:underline mt-1">Change plan</button>
                </div>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full py-3.5 bg-sky-600 hover:bg-sky-700 text-white font-bold rounded-xl transition-colors disabled:opacity-60 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {loading ? 'Creating account...' : `Create Account & Subscribe`}
              </button>
            </form>

            <p className="mt-4 text-center text-xs text-gray-400">
              By creating an account you agree to our{' '}
              <a href="#" className="text-sky-600 hover:underline">Terms of Service</a> and{' '}
              <a href="#" className="text-sky-600 hover:underline">Privacy Policy</a>.
            </p>
            <p className="mt-3 text-center text-sm text-gray-500">
              Already have an account?{' '}
              <Link to="/login" className="text-sky-600 hover:text-sky-700 font-medium">Sign in</Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
