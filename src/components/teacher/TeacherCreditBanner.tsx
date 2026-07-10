import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { Sparkles, Plus, Zap } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';
import { formatCredits } from '../../lib/utils';

interface CreditInfo {
  token_balance: number;
  topup_balance: number;
  free_credits_granted: number;
  total_purchased: number;
  planName: string | null;
}

/**
 * Compact plan + credits card for the client dashboard. Shows the current
 * plan and remaining AI credits (styled in "M"), with a subtle low-credit
 * hint and a top-up action — not an intrusive banner.
 */
export default function TeacherCreditBanner() {
  const { user } = useAuth();

  const { data } = useQuery({
    queryKey: ['teacher-plan-credits', user?.id],
    enabled: !!user,
    queryFn: async (): Promise<CreditInfo | null> => {
      const [creditsRes, subRes] = await Promise.all([
        supabase
          .from('teacher_ai_credits')
          .select('token_balance, topup_balance, free_credits_granted, total_purchased')
          .eq('user_id', user!.id)
          .maybeSingle(),
        supabase
          .from('teacher_subscriptions')
          .select('current_period_end, status, plan:teacher_subscription_plans(name)')
          .eq('teacher_id', user!.id)
          .eq('status', 'active')
          .order('current_period_end', { ascending: false })
          .limit(1)
          .maybeSingle(),
      ]);
      const c = creditsRes.data;
      const sub = subRes.data as { current_period_end?: string; plan?: { name?: string } } | null;
      const active = sub && sub.current_period_end && new Date(sub.current_period_end).getTime() > Date.now();
      return {
        token_balance: c?.token_balance ?? 0,
        topup_balance: c?.topup_balance ?? 0,
        free_credits_granted: c?.free_credits_granted ?? 0,
        total_purchased: c?.total_purchased ?? 0,
        planName: active ? (sub?.plan?.name ?? 'Active plan') : null,
      };
    },
  });

  if (!data) return null;

  const total = data.token_balance + data.topup_balance;
  const onFree = !data.planName && data.total_purchased === 0;
  const planLabel = data.planName ?? 'Free plan';
  const pctLeft = data.free_credits_granted > 0
    ? Math.max(0, Math.min(100, Math.round((data.token_balance / data.free_credits_granted) * 100)))
    : 100;
  const low = onFree && data.free_credits_granted > 0 && data.token_balance <= data.free_credits_granted / 2;

  return (
    <div className="rounded-2xl border border-slate-200 dark:border-navy-700 bg-white dark:bg-navy-800 p-4 sm:p-5">
      <div className="flex flex-wrap items-center gap-4">
        {/* Plan */}
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-sky-500 to-blue-700 flex items-center justify-center shrink-0">
            <Zap className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="text-xs text-slate-400">Current plan</p>
            <p className="font-bold text-slate-900 dark:text-white leading-tight">{planLabel}</p>
          </div>
        </div>

        <div className="hidden sm:block w-px h-10 bg-slate-200 dark:bg-navy-700" />

        {/* Credits */}
        <div className="flex-1 min-w-[160px]">
          <div className="flex items-baseline gap-2">
            <span className="text-xs text-slate-400">AI credits left</span>
            {low && <span className="text-[10px] font-bold text-amber-600 bg-amber-100 dark:bg-amber-900/30 px-1.5 py-0.5 rounded-full">Running low</span>}
          </div>
          <div className="flex items-center gap-2 mt-0.5">
            <span className="text-xl font-black text-slate-900 dark:text-white">{formatCredits(total)}</span>
            {onFree && data.free_credits_granted > 0 && (
              <span className="text-xs text-slate-400">of {formatCredits(data.free_credits_granted)} free</span>
            )}
            {data.topup_balance > 0 && (
              <span className="text-xs text-violet-600 dark:text-violet-400 font-semibold">· {formatCredits(data.topup_balance)} top-up (2×)</span>
            )}
          </div>
          {onFree && data.free_credits_granted > 0 && (
            <div className="mt-2 h-1.5 w-full max-w-xs bg-slate-100 dark:bg-navy-700 rounded-full overflow-hidden">
              <div className={`h-full rounded-full transition-all ${low ? 'bg-amber-500' : 'bg-sky-500'}`} style={{ width: `${pctLeft}%` }} />
            </div>
          )}
        </div>

        {/* Action */}
        <Link
          to="/teacher/billing"
          className="shrink-0 inline-flex items-center gap-1.5 px-4 py-2.5 bg-sky-600 hover:bg-sky-700 text-white text-sm font-bold rounded-xl transition-colors"
        >
          {onFree ? <><Sparkles className="w-4 h-4" /> Upgrade</> : <><Plus className="w-4 h-4" /> Top up</>}
        </Link>
      </div>
    </div>
  );
}
