import type { LucideIcon } from 'lucide-react';
import type { ReactNode } from 'react';

interface Props {
  icon: LucideIcon;
  title: string;
  description?: string;
  action?: ReactNode;
}

/** Modern first-run / empty-state panel used across the dashboard. */
export default function EmptyState({ icon: Icon, title, description, action }: Props) {
  return (
    <div className="relative overflow-hidden rounded-3xl border border-slate-200 dark:border-navy-700 bg-gradient-to-br from-white to-slate-50 dark:from-navy-800 dark:to-navy-900">
      <div className="absolute -top-16 -right-10 w-72 h-72 bg-sky-400/10 rounded-full blur-3xl" />
      <div className="relative px-6 py-14 text-center max-w-md mx-auto">
        <div className="w-16 h-16 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-sky-500 to-blue-700 flex items-center justify-center shadow-lg shadow-sky-500/30">
          <Icon className="w-8 h-8 text-white" />
        </div>
        <h3 className="text-xl font-bold text-slate-900 dark:text-white mb-2">{title}</h3>
        {description && <p className="text-sm text-slate-500 dark:text-slate-400 mb-6">{description}</p>}
        {action}
      </div>
    </div>
  );
}
