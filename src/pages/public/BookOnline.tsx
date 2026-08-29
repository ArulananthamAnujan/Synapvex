import { Link } from 'react-router-dom';
import { ArrowRight, Check, Code2, Compass, Layers3, ShieldCheck } from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';

const CONVERSATIONS = [
  { icon: Compass, title: 'Technology advisory', detail: 'Clarify priorities, risks and the most practical route forward.' },
  { icon: Code2, title: 'Software or product build', detail: 'Discuss a new platform, integration, website or mobile experience.' },
  { icon: ShieldCheck, title: 'Cloud, security or support', detail: 'Review infrastructure, resilience and ongoing operational needs.' },
  { icon: Layers3, title: 'Product demonstration', detail: 'See SynapVex Learn or another live platform in the context of your team.' },
];

export default function BookOnline() {
  return <div className="min-h-screen bg-white text-slate-950"><PublicHeader /><main className="pt-20">
    <section className="premium-page-hero py-24 sm:py-32"><div className="corporate-grid absolute inset-0 opacity-30" aria-hidden="true" /><div className="relative mx-auto grid max-w-7xl gap-10 px-4 sm:px-6 lg:grid-cols-[1fr_0.72fr] lg:items-end lg:px-8"><div><p className="text-xs font-bold uppercase tracking-[0.2em] text-sky-800">Start a project</p><h1 className="mt-5 max-w-4xl font-display text-5xl font-semibold leading-[1.05] tracking-[-0.045em] text-[#102d48] sm:text-7xl">Begin with a focused conversation.</h1></div><p className="max-w-xl text-lg leading-8 text-slate-600 lg:justify-self-end">Tell us what you are trying to change. We will route your enquiry to the right capability and agree a useful next step—without a sales script.</p></div></section>
    <section className="py-16 sm:py-24"><div className="mx-auto grid max-w-7xl gap-12 px-4 sm:px-6 lg:grid-cols-[1fr_0.7fr] lg:px-8"><div><p className="corporate-eyebrow">Choose the right conversation</p><h2 className="corporate-heading mt-3">What would you like to move forward?</h2><div className="mt-9 grid gap-px border border-slate-200 bg-slate-200 sm:grid-cols-2">{CONVERSATIONS.map(item => <article key={item.title} className="bg-white p-7"><item.icon className="h-6 w-6 text-sky-700" /><h3 className="mt-5 text-lg font-bold">{item.title}</h3><p className="mt-2 text-sm leading-6 text-slate-600">{item.detail}</p></article>)}</div></div>
      <aside className="luxury-surface self-start rounded-3xl border border-white bg-gradient-to-br from-white to-sky-50/70 p-7 sm:p-9"><p className="text-xs font-bold uppercase tracking-[0.18em] text-sky-700">What happens next</p><ol className="mt-6 space-y-5">{['Send a short project brief through our secure contact form.', 'A team member reviews it and confirms the best next step.', 'We arrange a conversation at a mutually suitable time.'].map((step, index) => <li key={step} className="flex gap-3 text-sm leading-6 text-slate-700"><span className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-sky-800 to-sky-500 text-xs font-bold text-white shadow-md">{index + 1}</span>{step}</li>)}</ol><div className="mt-8 border-t border-sky-100 pt-7"><Link to="/contact" className="luxury-button-primary w-full gap-2">Send your brief <ArrowRight className="h-4 w-4" /></Link><p className="mt-4 flex gap-2 text-xs leading-5 text-slate-500"><Check className="mt-0.5 h-4 w-4 shrink-0 text-emerald-600" />No payment or account is required to make an enquiry.</p></div></aside>
    </div></section>
  </main><PublicFooter /></div>;
}
