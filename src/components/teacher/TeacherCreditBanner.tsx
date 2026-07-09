import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { Sparkles, ArrowRight, Gift, AlertTriangle } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';

interface Credits {
  token_balance: number;
  total_purchased: number;
  free_credits_granted: number;
}

/**
 * Freemium nudge for solo teachers exploring on free credits.
 * - Depleted  → "credits used up, subscribe"
 * - Half used → "you're halfway, subscribe to keep building"
 * - Otherwise → a light "free credits" indicator
 * Hidden entirely once the teacher has purchased/subscribed.
 */
export default function TeacherCreditBanner() {
  const { user } = useAuth();

  const { data: credits } = useQuery({
    queryKey: ['teacher-credits-banner', user?.id],
    enabled: !!user,
    queryFn: async (): Promise<Credits | null> => {
      const { data } = await supabase
        .from('teacher_ai_credits')
        .select('token_balance, total_purchased, free_credits_granted')
        .eq('user_id', user!.id)
        .maybeSingle();
      return data as Credits | null;
    },
  });

  // Only relevant while still on the free plan (nothing purchased yet).
  if (!credits || credits.total_purchased > 0 || credits.free_credits_granted <= 0) return null;

  const { token_balance, free_credits_granted } = credits;
  const half = free_credits_granted / 2;
  const used = Math.max(0, free_credits_granted - token_balance);
  const pctLeft = Math.max(0, Math.min(100, Math.round((token_balance / free_credits_granted) * 100)));

  // Depleted
  if (token_balance <= 0) {
    return (
      <div className="rounded-2xl border border-amber-200 bg-amber-50 dark:bg-amber-900/10 p-5 flex flex-col sm:flex-row sm:items-center gap-4">
        <div className="w-11 h-11 rounded-xl bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center shrink-0">
          <AlertTriangle className="w-5 h-5 text-amber-600" />
        </div>
        <div className="flex-1">
          <p className="font-bold text-slate-900 dark:text-white">Your free AI credits are used up</p>
          <p className="text-sm text-slate-500">Subscribe to a monthly or annual plan to keep building courses with AI — or top up your credits.</p>
        </div>
        <Link to="/teacher/billing" className="shrink-0 px-5 py-2.5 bg-sky-600 hover:bg-sky-700 text-white text-sm font-bold rounded-xl transition-colors flex items-center gap-2">
          Choose a Plan <ArrowRight className="w-4 h-4" />
        </Link>
      </div>
    );
  }

  // Half (or more) used
  if (token_balance <= half) {
    return (
      <div className="rounded-2xl border border-sky-200 bg-gradient-to-r from-sky-50 to-white dark:from-sky-900/10 dark:to-transparent p-5">
        <div className="flex flex-col sm:flex-row sm:items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-sky-100 dark:bg-sky-900/30 flex items-center justify-center shrink-0">
            <Sparkles className="w-5 h-5 text-sky-600" />
          </div>
          <div className="flex-1">
            <p className="font-bold text-slate-900 dark:text-white">You're halfway through your free credits</p>
            <p className="text-sm text-slate-500">
              {token_balance} of {free_credits_granted} free AI credits left. Subscribe now to keep the momentum going — from $29/mo, cancel anytime.
            </p>
            <div className="mt-2.5 h-1.5 w-full max-w-xs bg-slate-200 dark:bg-navy-700 rounded-full overflow-hidden">
              <div className="h-full bg-sky-500 rounded-full transition-all" style={{ width: `${pctLeft}%` }} />
            </div>
          </div>
          <Link to="/teacher/billing" className="shrink-0 px-5 py-2.5 bg-sky-600 hover:bg-sky-700 text-white text-sm font-bold rounded-xl transition-colors flex items-center gap-2">
            View Plans <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    );
  }

  // Healthy — light indicator
  return (
    <div className="rounded-2xl border border-emerald-200 bg-emerald-50/60 dark:bg-emerald-900/10 p-4 flex items-center gap-3">
      <div className="w-9 h-9 rounded-xl bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center shrink-0">
        <Gift className="w-4.5 h-4.5 text-emerald-600" />
      </div>
      <div className="flex-1 text-sm">
        <span className="font-semibold text-slate-900 dark:text-white">{token_balance} free AI credits</span>
        <span className="text-slate-500"> to explore — you've used {used}. </span>
        <Link to="/teacher/billing" className="text-sky-600 hover:text-sky-700 font-semibold">See plans</Link>
      </div>
    </div>
  );
}
