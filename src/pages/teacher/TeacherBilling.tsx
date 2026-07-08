import { useState, useEffect, useCallback } from 'react';
import { useSearchParams } from 'react-router-dom';
import {
  CreditCard, CalendarClock, CheckCircle, AlertTriangle, Sparkles,
  RefreshCw, XCircle, Zap, BadgePercent,
} from 'lucide-react';
import { toast } from 'sonner';
import DashboardLayout from '../../components/layout/DashboardLayout';
import { teacherNavItems } from './teacherNav';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';

interface SubPlan {
  id: string;
  name: string;
  slug: string;
  price_monthly_cents: number;
  price_yearly_cents: number | null;
  max_courses: number;
  max_students: number;
  ai_tokens_monthly: number;
  features: string[];
  sort_order: number;
}

interface Subscription {
  id: string;
  plan_id: string;
  status: string;
  billing_interval: 'monthly' | 'yearly';
  cancel_at_period_end: boolean;
  amount_paid_cents: number | null;
  current_period_start: string | null;
  current_period_end: string | null;
  plan?: SubPlan;
}

interface TokenPack {
  id: string;
  name: string;
  description: string | null;
  token_amount: number;
  price_cents: number;
  is_popular: boolean;
}

const fmtDate = (iso: string) =>
  new Date(iso).toLocaleDateString('en-AU', { day: 'numeric', month: 'long', year: 'numeric' });

const daysLeft = (iso: string) =>
  Math.max(0, Math.ceil((new Date(iso).getTime() - Date.now()) / (24 * 60 * 60 * 1000)));

export default function TeacherBilling() {
  const { user } = useAuth();
  const [searchParams] = useSearchParams();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [plans, setPlans] = useState<SubPlan[]>([]);
  const [packs, setPacks] = useState<TokenPack[]>([]);
  const [tokenBalance, setTokenBalance] = useState<number>(0);
  const [loading, setLoading] = useState(true);
  const [interval, setInterval_] = useState<'monthly' | 'yearly'>('monthly');
  const [working, setWorking] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!user) return;
    const [subRes, plansRes, packsRes, creditsRes] = await Promise.all([
      supabase
        .from('teacher_subscriptions')
        .select('*, plan:teacher_subscription_plans(*)')
        .eq('teacher_id', user.id)
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle(),
      supabase.from('teacher_subscription_plans').select('*').eq('is_active', true).order('sort_order'),
      supabase.from('teacher_ai_plans').select('id, name, description, token_amount, price_cents, is_popular').eq('is_active', true).order('sort_order'),
      supabase.from('teacher_ai_credits').select('token_balance').eq('user_id', user.id).maybeSingle(),
    ]);
    if (subRes.data) {
      const sub = subRes.data as Subscription;
      setSubscription(sub);
      if (sub.billing_interval) setInterval_(sub.billing_interval);
    }
    if (plansRes.data) setPlans(plansRes.data as SubPlan[]);
    if (packsRes.data) setPacks(packsRes.data as TokenPack[]);
    setTokenBalance(creditsRes.data?.token_balance ?? 0);
    setLoading(false);
  }, [user]);

  useEffect(() => { load(); }, [load]);

  useEffect(() => {
    if (searchParams.get('tokens') === 'success') {
      toast.success('Payment received — your AI credits will appear shortly.');
    }
    if (searchParams.get('subscription') === 'success') {
      toast.success('Payment received — your plan is being activated.');
    }
  }, [searchParams]);

  const startCheckout = async (body: Record<string, unknown>, workingKey: string) => {
    setWorking(workingKey);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;
      if (!token) { toast.error('Please sign in again.'); return; }
      const resp = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/stripe-create-checkout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify(body),
      });
      const data = await resp.json();
      if (data.url) { window.location.href = data.url; return; }
      toast.error(data.error || 'Could not start checkout. Please try again.');
    } catch {
      toast.error('Could not reach the payment service.');
    } finally {
      setWorking(null);
    }
  };

  const handleRenewal = async (cancel: boolean) => {
    if (!subscription) return;
    setWorking('renewal');
    const { error } = await supabase.rpc('set_subscription_renewal', {
      p_subscription_id: subscription.id,
      p_cancel: cancel,
    });
    if (error) {
      toast.error('Could not update your subscription. Please try again.');
    } else {
      toast.success(cancel
        ? 'Subscription cancelled. You keep full access until your plan period ends.'
        : 'Welcome back! Your subscription is set to continue.');
      await load();
    }
    setWorking(null);
  };

  const active = subscription?.status === 'active';
  const periodEnd = subscription?.current_period_end;
  const expired = !!periodEnd && new Date(periodEnd).getTime() < Date.now();

  const planPrice = (plan: SubPlan) => interval === 'yearly'
    ? (plan.price_yearly_cents ?? plan.price_monthly_cents * 10)
    : plan.price_monthly_cents;

  return (
    <DashboardLayout navItems={teacherNavItems} title="Plan & Billing" subtitle="Your subscription, billing period and AI credits">
      <div className="space-y-6 max-w-5xl">

        {/* ── Current plan ── */}
        {loading ? (
          <div className="card h-40 animate-pulse" />
        ) : subscription && active && periodEnd && !expired ? (
          <div className="card p-6">
            <div className="flex flex-wrap items-start justify-between gap-4">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-bold text-slate-900 dark:text-white text-lg">{subscription.plan?.name} Plan</h3>
                  <span className="text-xs font-bold uppercase tracking-wide bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full">Active</span>
                  <span className="text-xs font-semibold capitalize bg-slate-100 dark:bg-navy-700 text-slate-600 dark:text-slate-300 px-2 py-0.5 rounded-full">
                    {subscription.billing_interval} billing
                  </span>
                </div>
                <p className="flex items-center gap-1.5 text-sm text-slate-600 dark:text-slate-300">
                  <CalendarClock className="w-4 h-4 text-slate-400" />
                  Active until <strong>{fmtDate(periodEnd)}</strong>
                  <span className="text-slate-400">({daysLeft(periodEnd)} days left)</span>
                </p>
                {subscription.cancel_at_period_end ? (
                  <p className="mt-2 text-sm text-amber-600 flex items-center gap-1.5">
                    <AlertTriangle className="w-4 h-4 shrink-0" />
                    Cancelled — your plan ends on {fmtDate(periodEnd)} and won't renew.
                  </p>
                ) : (
                  <p className="mt-2 text-sm text-slate-500">
                    Plans are paid per period — renew below before {fmtDate(periodEnd)} to keep your plan active.
                  </p>
                )}
              </div>
              <div className="flex flex-col gap-2">
                {subscription.cancel_at_period_end ? (
                  <button
                    onClick={() => handleRenewal(false)}
                    disabled={working === 'renewal'}
                    className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-bold rounded-xl transition-colors disabled:opacity-60 flex items-center gap-2"
                  >
                    <RefreshCw className="w-4 h-4" /> Resume Subscription
                  </button>
                ) : (
                  <button
                    onClick={() => handleRenewal(true)}
                    disabled={working === 'renewal'}
                    className="px-5 py-2.5 border-2 border-red-200 text-red-600 hover:bg-red-50 text-sm font-bold rounded-xl transition-colors disabled:opacity-60 flex items-center gap-2"
                  >
                    <XCircle className="w-4 h-4" /> Cancel Subscription
                  </button>
                )}
              </div>
            </div>
          </div>
        ) : (
          <div className="card p-6 border-amber-200 bg-amber-50/50 dark:bg-amber-900/10">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-amber-500 shrink-0 mt-0.5" />
              <div>
                <h3 className="font-bold text-slate-900 dark:text-white">
                  {expired ? 'Your plan has expired' : 'No active plan'}
                </h3>
                <p className="text-sm text-slate-500 mt-1">
                  {expired && periodEnd
                    ? `Your ${subscription?.plan?.name ?? ''} plan ended on ${fmtDate(periodEnd)}. Choose a plan below to continue.`
                    : 'Choose a plan below to activate your teaching account.'}
                </p>
              </div>
            </div>
          </div>
        )}

        {/* ── Choose / renew plan ── */}
        <div className="card p-6">
          <div className="flex flex-wrap items-center justify-between gap-3 mb-5">
            <div>
              <h3 className="font-bold text-slate-900 dark:text-white">
                {active && !expired ? 'Renew or change plan' : 'Choose a plan'}
              </h3>
              <p className="text-xs text-slate-400 mt-0.5">Pay per period — no lock-in. Annual is paid upfront and saves 2 months.</p>
            </div>
            <div className="flex items-center bg-slate-100 dark:bg-navy-700 rounded-xl p-1">
              {(['monthly', 'yearly'] as const).map(i => (
                <button
                  key={i}
                  onClick={() => setInterval_(i)}
                  className={`px-4 py-1.5 rounded-lg text-sm font-bold transition-colors flex items-center gap-1.5 ${
                    interval === i ? 'bg-white dark:bg-navy-900 text-slate-900 dark:text-white shadow-sm' : 'text-slate-500'
                  }`}
                >
                  {i === 'monthly' ? 'Monthly' : 'Annual'}
                  {i === 'yearly' && <span className="text-[10px] font-bold text-emerald-600 bg-emerald-100 px-1.5 py-0.5 rounded-full">2 months free</span>}
                </button>
              ))}
            </div>
          </div>

          <div className="grid md:grid-cols-3 gap-4">
            {plans.map(plan => {
              const price = planPrice(plan);
              const monthlyEquiv = interval === 'yearly' ? price / 12 : price;
              const isCurrent = active && !expired && subscription?.plan_id === plan.id;
              return (
                <div key={plan.id} className={`rounded-2xl border-2 p-5 flex flex-col ${isCurrent ? 'border-emerald-300 bg-emerald-50/40 dark:bg-emerald-900/10' : 'border-slate-200 dark:border-navy-600'}`}>
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="font-bold text-slate-900 dark:text-white">{plan.name}</h4>
                    {isCurrent && <span className="text-[10px] font-bold uppercase bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full">Current</span>}
                  </div>
                  <p className="mb-1">
                    <span className="text-2xl font-black text-slate-900 dark:text-white">${(price / 100).toFixed(0)}</span>
                    <span className="text-slate-400 text-sm">/{interval === 'yearly' ? 'year' : 'month'}</span>
                  </p>
                  {interval === 'yearly' && (
                    <p className="text-xs text-emerald-600 font-semibold mb-2 flex items-center gap-1">
                      <BadgePercent className="w-3.5 h-3.5" /> ≈ ${(monthlyEquiv / 100).toFixed(2)}/month, paid upfront
                    </p>
                  )}
                  <ul className="text-xs text-slate-500 space-y-1.5 my-3 flex-1">
                    <li className="flex gap-1.5"><CheckCircle className="w-3.5 h-3.5 text-sky-500 shrink-0" />{plan.max_courses === -1 ? 'Unlimited' : `Up to ${plan.max_courses}`} courses</li>
                    <li className="flex gap-1.5"><CheckCircle className="w-3.5 h-3.5 text-sky-500 shrink-0" />{plan.max_students === -1 ? 'Unlimited' : `Up to ${plan.max_students}`} students</li>
                    <li className="flex gap-1.5"><CheckCircle className="w-3.5 h-3.5 text-sky-500 shrink-0" />{plan.ai_tokens_monthly.toLocaleString()} AI credits/month</li>
                  </ul>
                  <button
                    onClick={() => startCheckout({ type: 'teacher_subscription', plan_id: plan.id, billing_interval: interval }, `plan-${plan.id}`)}
                    disabled={working === `plan-${plan.id}`}
                    className={`w-full py-2.5 rounded-xl text-sm font-bold transition-colors disabled:opacity-60 ${
                      isCurrent
                        ? 'bg-emerald-600 hover:bg-emerald-700 text-white'
                        : 'bg-sky-600 hover:bg-sky-700 text-white'
                    }`}
                  >
                    {working === `plan-${plan.id}` ? 'Redirecting…' : isCurrent ? `Renew (${interval})` : `Switch to ${plan.name}`}
                  </button>
                </div>
              );
            })}
          </div>
        </div>

        {/* ── AI credits ── */}
        <div className="card p-6">
          <div className="flex flex-wrap items-center justify-between gap-3 mb-5">
            <div>
              <h3 className="font-bold text-slate-900 dark:text-white flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-violet-500" /> AI Credits
              </h3>
              <p className="text-xs text-slate-400 mt-0.5">Top up anytime — purchased credits never expire.</p>
            </div>
            <div className="text-right">
              <p className="text-2xl font-black text-slate-900 dark:text-white">{tokenBalance.toLocaleString()}</p>
              <p className="text-xs text-slate-400">credits available</p>
            </div>
          </div>
          <div className="grid sm:grid-cols-3 gap-4">
            {packs.map(pack => (
              <div key={pack.id} className={`rounded-2xl border-2 p-5 flex flex-col ${pack.is_popular ? 'border-violet-300' : 'border-slate-200 dark:border-navy-600'}`}>
                <div className="flex items-center justify-between mb-1">
                  <h4 className="font-bold text-slate-900 dark:text-white text-sm">{pack.name}</h4>
                  {pack.is_popular && <span className="text-[10px] font-bold uppercase bg-violet-100 text-violet-700 px-2 py-0.5 rounded-full">Popular</span>}
                </div>
                <p className="mb-2">
                  <span className="text-xl font-black text-slate-900 dark:text-white">${(pack.price_cents / 100).toFixed(0)}</span>
                  <span className="text-slate-400 text-xs"> · {pack.token_amount.toLocaleString()} credits</span>
                </p>
                {pack.description && <p className="text-xs text-slate-500 mb-3 flex-1">{pack.description}</p>}
                <button
                  onClick={() => startCheckout({ type: 'teacher_ai_plan', plan_id: pack.id }, `pack-${pack.id}`)}
                  disabled={working === `pack-${pack.id}`}
                  className="w-full py-2.5 bg-violet-600 hover:bg-violet-700 text-white rounded-xl text-sm font-bold transition-colors disabled:opacity-60 flex items-center justify-center gap-1.5"
                >
                  <Zap className="w-3.5 h-3.5" />
                  {working === `pack-${pack.id}` ? 'Redirecting…' : 'Buy Credits'}
                </button>
              </div>
            ))}
          </div>
        </div>

        <p className="text-xs text-slate-400 flex items-center gap-1.5">
          <CreditCard className="w-3.5 h-3.5" />
          Payments are processed securely. Refunds are handled under our refund policy — cancel anytime and keep access until your period ends.
        </p>
      </div>
    </DashboardLayout>
  );
}
