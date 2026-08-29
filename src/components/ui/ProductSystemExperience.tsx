import { useState } from 'react';
import { ArrowRight, CheckCircle2, ExternalLink, GraduationCap, Languages, Users2 } from 'lucide-react';
import { Link } from 'react-router-dom';
import ProductMotionVisual from './ProductMotionVisual';

const EXPERIENCES = [
  {
    key: 'learn',
    name: 'Learn',
    fullName: 'SynapVex Learn',
    icon: GraduationCap,
    status: 'Live',
    eyebrow: 'For educators and academies',
    headline: 'Turn your expertise into a course people can buy and complete.',
    description: 'Create the learning experience, publish it under your brand, accept payment and follow every learner from enrolment to certificate.',
    journey: ['Build with AI', 'Publish your storefront', 'Sell securely', 'Track completion'],
    outcome: 'One place to create, sell and deliver learning.',
    href: '/products/learn',
    external: false,
  },
  {
    key: 'pte',
    name: 'PTE',
    fullName: 'SynapVex PTE',
    icon: Languages,
    status: 'Live',
    eyebrow: 'For ambitious PTE learners',
    headline: 'Practise with purpose—not guesswork.',
    description: 'Work across all four skills, receive focused AI feedback and see where to improve before the pressure of test day.',
    journey: ['Choose a skill', 'Complete timed practice', 'Receive feedback', 'Improve your score'],
    outcome: 'A clearer path from practice to exam readiness.',
    href: 'https://synapvexpte.netlify.app',
    external: true,
  },
  {
    key: 'crm',
    name: 'CRM',
    fullName: 'SynapVex CRM',
    icon: Users2,
    status: 'In development',
    eyebrow: 'For service teams with complex cases',
    headline: 'Keep every client, task and decision moving together.',
    description: 'A connected workspace designed to reduce tab-switching, missed follow-ups and fragmented client histories.',
    journey: ['Capture the enquiry', 'Assign the case', 'Coordinate the work', 'Keep the full history'],
    outcome: 'A calmer, more accountable client operation.',
    href: '',
    external: false,
  },
] as const;

export default function ProductSystemExperience() {
  const [activeKey, setActiveKey] = useState<(typeof EXPERIENCES)[number]['key']>('learn');
  const active = EXPERIENCES.find(product => product.key === activeKey) ?? EXPERIENCES[0];

  return (
    <div className="overflow-hidden rounded-[28px] border border-slate-200 bg-[#081d30] shadow-[0_40px_100px_-50px_rgba(2,41,69,.7)]">
      <div className="flex flex-col border-b border-white/10 px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-7">
        <div className="flex items-center gap-3">
          <span className="h-2 w-2 rounded-full bg-emerald-400 shadow-[0_0_12px_rgba(52,211,153,.8)]" />
          <span className="text-xs font-bold uppercase tracking-[0.17em] text-slate-300">Explore the SynapVex system</span>
        </div>
        <div className="mt-4 flex rounded-xl border border-white/10 bg-white/[0.055] p-1 sm:mt-0" role="tablist" aria-label="SynapVex products">
          {EXPERIENCES.map(product => {
            const Icon = product.icon;
            const selected = product.key === active.key;
            return (
              <button
                key={product.key}
                type="button"
                role="tab"
                aria-selected={selected}
                onClick={() => setActiveKey(product.key)}
                className={`flex items-center gap-2 rounded-lg px-3 py-2 text-xs font-bold transition-all duration-300 sm:px-4 ${selected ? 'bg-white text-[#0b2d49] shadow-lg' : 'text-slate-400 hover:bg-white/10 hover:text-white'}`}
              >
                <Icon className="h-3.5 w-3.5" /> {product.name}
              </button>
            );
          })}
        </div>
      </div>

      <div key={active.key} className="grid animate-fade-in lg:grid-cols-[0.92fr_1.08fr]">
        <div className="relative overflow-hidden border-b border-white/10 p-6 sm:p-9 lg:border-b-0 lg:border-r lg:p-12">
          <div className="absolute -left-24 -top-24 h-72 w-72 rounded-full bg-sky-400/10 blur-[80px]" />
          <div className="relative">
            <div className="flex items-center justify-between gap-4">
              <span className="text-xs font-bold uppercase tracking-[0.17em] text-sky-300">{active.eyebrow}</span>
              <span className={`rounded-full border px-3 py-1 text-[10px] font-bold uppercase tracking-[0.14em] ${active.status === 'Live' ? 'border-emerald-300/25 bg-emerald-300/10 text-emerald-300' : 'border-white/10 bg-white/5 text-slate-400'}`}>{active.status}</span>
            </div>
            <h3 className="mt-7 max-w-xl font-display text-4xl font-semibold leading-[1.06] tracking-[-0.04em] text-white sm:text-5xl">{active.headline}</h3>
            <p className="mt-6 max-w-xl text-base leading-7 text-slate-300">{active.description}</p>

            <div className="mt-9 grid gap-2 sm:grid-cols-2">
              {active.journey.map((step, index) => (
                <div key={step} className="flex items-center gap-3 rounded-xl border border-white/10 bg-white/[0.045] px-4 py-3 text-sm font-semibold text-slate-200">
                  <span className="font-mono text-[10px] text-sky-400">0{index + 1}</span>{step}
                </div>
              ))}
            </div>

            <div className="mt-9 flex items-start gap-3 border-t border-white/10 pt-7 text-sm font-semibold leading-6 text-sky-100">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-emerald-400" /> {active.outcome}
            </div>

            {active.href ? active.external ? (
              <a href={active.href} target="_blank" rel="noopener noreferrer" className="mt-8 inline-flex items-center gap-2 text-sm font-bold text-sky-300 transition hover:text-white">
                Open the live platform <ExternalLink className="h-4 w-4" />
              </a>
            ) : (
              <Link to={active.href} className="mt-8 inline-flex items-center gap-2 text-sm font-bold text-sky-300 transition hover:text-white">
                Explore {active.fullName} <ArrowRight className="h-4 w-4" />
              </Link>
            ) : (
              <span className="mt-8 inline-flex text-sm font-bold text-slate-500">Development preview</span>
            )}
          </div>
        </div>

        <div className="relative flex min-h-[420px] items-center justify-center bg-gradient-to-br from-[#0b2942] via-[#0d3656] to-[#071a2b] p-6 sm:p-10 lg:min-h-[600px]">
          <div className="absolute inset-0 opacity-25 [background-image:linear-gradient(rgba(125,211,252,.12)_1px,transparent_1px),linear-gradient(90deg,rgba(125,211,252,.12)_1px,transparent_1px)] [background-size:40px_40px]" />
          <div className="relative w-full max-w-lg transition-all duration-500 hover:scale-[1.025]">
            <ProductMotionVisual variant={active.key} />
            <div className="mx-auto -mt-4 h-8 w-[72%] rounded-[50%] bg-black/35 blur-xl" />
          </div>
        </div>
      </div>
    </div>
  );
}
