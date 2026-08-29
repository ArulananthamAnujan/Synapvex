import { Link } from 'react-router-dom';
import {
  ArrowRight, Briefcase, CheckCircle2, Cloud, Code2, ExternalLink, Globe2, GraduationCap,
  LockKeyhole, ShieldCheck, Smartphone,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';
import ProductMotionVisual from '../../components/ui/ProductMotionVisual';
import ProductSystemExperience from '../../components/ui/ProductSystemExperience';
import { PRODUCTS } from '../../lib/products';

const CAPABILITIES = [
  { icon: Code2, title: 'Replace manual work', description: 'Turn spreadsheets, repeated administration and disconnected processes into one dependable application.' },
  { icon: Globe2, title: 'Create a better digital front door', description: 'Give customers a faster, clearer way to discover, purchase and engage with your organisation.' },
  { icon: Smartphone, title: 'Work from anywhere', description: 'Put the workflows your team relies on into a responsive product that works across devices.' },
  { icon: Cloud, title: 'Modernise without disruption', description: 'Move systems, collaboration and continuity forward with a practical transition plan.' },
  { icon: LockKeyhole, title: 'Reduce operational risk', description: 'Design security, backup, maintainability and support into the solution from the start.' },
  { icon: Briefcase, title: 'Make the next decision clearer', description: 'Translate business priorities into a realistic technology roadmap, scope and delivery sequence.' },
];

const DELIVERY_STEPS = [
  { number: '01', title: 'Understand', description: 'We clarify the business problem, users, risks and measures of success.' },
  { number: '02', title: 'Plan', description: 'We define a practical scope, delivery roadmap and technical approach.' },
  { number: '03', title: 'Deliver', description: 'We design, build and test in focused stages with clear progress updates.' },
  { number: '04', title: 'Improve', description: 'We support the launch, measure performance and strengthen the solution over time.' },
];

const BUYER_EVIDENCE = [
  {
    label: 'Live product',
    title: 'SynapVex Learn',
    description: 'Inspect the public product page, teacher onboarding and the end-to-end course commerce proposition.',
    facts: ['AI-assisted course, quiz and exam building', 'Branded course storefronts', 'Payments, progress and certificates'],
    href: '/products/learn',
    external: false,
  },
  {
    label: 'Live product',
    title: 'SynapVex PTE',
    description: 'Open the deployed exam-preparation platform and evaluate the learner experience directly.',
    facts: ['Speaking, writing, reading and listening practice', 'AI feedback for productive skills', 'Mock tests and progress tracking'],
    href: '/products/pte',
    external: false,
  },
  {
    label: 'Delivery evidence',
    title: 'One connected engineering model',
    description: 'The capabilities offered to clients are the same disciplines required to operate our own products.',
    facts: ['Product design and software engineering', 'Cloud, security and operational continuity', 'Launch support and continuous improvement'],
    href: '/about',
    external: false,
  },
];

const MODEL_COMPARISON = [
  ['Accountability', 'A defined project handover', 'Build, operate and continuously improve'],
  ['Product judgement', 'Based mainly on client briefs', 'Informed by operating live platforms'],
  ['Delivery scope', 'Often split between several suppliers', 'Product, cloud, security and support together'],
  ['Success measure', 'Features shipped', 'Operational adoption and business outcomes'],
];

export default function Home() {
  const liveProducts = PRODUCTS.filter(product => product.status === 'live');

  return (
    <div className="min-h-screen bg-white text-slate-900 dark:bg-navy-950 dark:text-white">
      <PublicHeader />

      <main>
        <section className="relative overflow-hidden bg-gradient-to-br from-[#fffdf8] via-[#f7fafb] to-[#edf5f8] pt-36 pb-28 sm:pt-40 sm:pb-32 lg:pt-48 lg:pb-40">
          <div className="absolute -left-36 top-0 h-[34rem] w-[34rem] rounded-full bg-amber-300/18 blur-[115px]" aria-hidden="true" />
          <div className="absolute -right-28 top-0 h-[40rem] w-[40rem] rounded-full bg-sky-300/20 blur-[125px]" aria-hidden="true" />

          <div className="relative mx-auto grid max-w-7xl items-center gap-14 px-4 sm:px-6 lg:grid-cols-[1.08fr_0.92fr] lg:px-8">
            <div className="max-w-3xl">
              <div className="mb-8 inline-flex items-center gap-2 rounded-full border border-sky-200 bg-white/75 px-4 py-2 text-xs font-bold uppercase tracking-[0.18em] text-sky-800 shadow-[0_8px_24px_-14px_rgba(32,92,133,0.35)] backdrop-blur-sm">
                Products that solve real operational problems
              </div>
              <h1 className="max-w-4xl font-display text-5xl font-semibold leading-[0.98] tracking-[-0.045em] text-[#102d48] sm:text-6xl lg:text-8xl">
                Technology, <span className="bg-gradient-to-r from-sky-800 via-sky-600 to-amber-500 bg-clip-text text-transparent">engineered forward.</span>
              </h1>
              <p className="mt-10 max-w-xl text-lg leading-8 text-slate-600">
                Bring us the process that wastes time, the customer journey that underperforms or the product idea that needs to become real. We design, build and keep it working.
              </p>
              <div className="mt-12 flex flex-col gap-4 sm:flex-row">
                <Link to="/book-online" className="luxury-button-primary gap-2">
                  Start a project <ArrowRight className="h-4 w-4" />
                </Link>
                <Link to="/products" className="luxury-button-light gap-2">
                  Explore our platforms
                </Link>
              </div>
            </div>

            <div className="luxury-surface relative overflow-hidden rounded-[26px] border border-white bg-white/92 backdrop-blur-xl lg:rotate-[1deg] lg:transition-transform lg:duration-500 lg:hover:rotate-0 lg:hover:scale-[1.015]">
              <div className="absolute right-[-5rem] top-[-5rem] h-52 w-52 rounded-full bg-amber-300/20 blur-3xl" />
              <div className="relative flex items-center gap-2 border-b border-slate-200/80 bg-slate-50/90 px-5 py-3">
                <span className="h-2.5 w-2.5 rounded-full bg-rose-300" /><span className="h-2.5 w-2.5 rounded-full bg-amber-300" /><span className="h-2.5 w-2.5 rounded-full bg-emerald-300" />
                <div className="mx-auto rounded-lg border border-slate-200 bg-white px-6 py-1.5 text-[10px] font-semibold tracking-wide text-slate-400">synapvex.com.au / product portfolio</div>
              </div>
              <div className="flex items-center justify-between border-b border-sky-100 px-6 py-5">
                <div>
                  <p className="text-xs font-bold uppercase tracking-[0.18em] text-sky-700">SynapVex portfolio</p>
                  <p className="mt-1 text-sm text-slate-500">Products and delivery capabilities</p>
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700">
                  <span className="h-2 w-2 rounded-full bg-emerald-400" />
                  {liveProducts.length} live platforms
                </div>
              </div>

              <div className="relative p-6">
                <div className="pointer-events-none absolute -right-20 -top-20 h-36 w-44 opacity-20 mix-blend-multiply">
                  <ProductMotionVisual variant="network" compact />
                </div>
                <p className="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-500">Product platforms</p>
                <div className="space-y-2">
                  {PRODUCTS.map(product => (
                    <div key={product.key} className="flex items-center gap-4 rounded-2xl border border-sky-100 bg-gradient-to-r from-white to-sky-50/60 px-4 py-4 shadow-[0_10px_28px_-22px_rgba(26,78,115,0.45)] transition-all hover:-translate-y-0.5 hover:border-amber-300 hover:shadow-[0_18px_34px_-22px_rgba(245,158,54,0.45)]">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-[#123a59] to-sky-600 shadow-[inset_0_1px_0_rgba(255,255,255,0.3)]">
                        <product.icon className="h-5 w-5 text-white" />
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-bold text-[#102d48]">{product.name}</p>
                        <p className="truncate text-xs text-slate-500">{product.tagline}</p>
                      </div>
                      <span className={`text-[10px] font-bold uppercase tracking-wider ${product.status === 'live' ? 'text-emerald-700' : 'text-slate-500'}`}>
                        {product.status === 'live' ? 'Live' : 'In development'}
                      </span>
                    </div>
                  ))}
                </div>

                <div className="mt-6 grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-sky-100 bg-sky-100">
                  {['Software engineering', 'Cloud & infrastructure', 'Cybersecurity', 'Managed support'].map(item => (
                    <div key={item} className="bg-white/90 px-3 py-3 text-xs font-semibold text-slate-600">{item}</div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="border-b border-sky-100 bg-white py-8" aria-label="What happens after you start a project">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="mb-5 flex flex-col justify-between gap-2 sm:flex-row sm:items-center">
              <p className="text-xs font-bold uppercase tracking-[0.18em] text-sky-800">After you start a project</p>
              <p className="text-xs font-semibold text-slate-500">A real person responds within one business day.</p>
            </div>
            <div className="grid gap-px overflow-hidden rounded-2xl bg-sky-100 sm:grid-cols-3">
            {[
              ['01', 'Tell us the problem', 'Share the workflow, customer issue or product idea—no technical brief required.'],
              ['02', 'We prepare the conversation', 'We review your enquiry and bring the right product or technical lead.'],
              ['03', 'Leave with a useful next step', 'Receive a recommendation, scope direction or focused discovery plan.'],
            ].map(([value, label, detail]) => (
              <div key={label} className="bg-white px-6 py-7">
                <p className="font-mono text-xs font-bold text-sky-700">{value}</p>
                <p className="mt-3 text-sm font-bold text-[#102d48]">{label}</p>
                <p className="mt-3 max-w-sm text-sm leading-6 text-slate-500">{detail}</p>
              </div>
            ))}
            </div>
          </div>
        </section>

        <section className="bg-gradient-to-b from-slate-50 via-white to-blue-50/40 py-28 sm:py-40">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="grid gap-6 lg:grid-cols-[0.8fr_1.2fr] lg:items-end">
              <div>
                <p className="corporate-eyebrow">Choose a product journey</p>
                <h2 className="corporate-heading mt-3">See how the SynapVex system works.</h2>
              </div>
              <p className="max-w-2xl text-base leading-7 text-slate-600 lg:justify-self-end">
                Select a platform to explore the customer problem, the working journey and the outcome it is designed to create.
              </p>
            </Reveal>

            <Reveal className="mt-20"><ProductSystemExperience /></Reveal>
          </div>
        </section>

        <section className="relative overflow-hidden bg-[#071a2b] py-28 text-white sm:py-40">
          <div className="absolute left-1/2 top-0 h-[34rem] w-[52rem] -translate-x-1/2 rounded-full bg-sky-500/10 blur-[120px]" aria-hidden="true" />
          <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="grid gap-8 lg:grid-cols-[0.82fr_1.18fr] lg:items-end">
              <div>
                <p className="text-xs font-bold uppercase tracking-[0.2em] text-sky-300">Evidence before promises</p>
                <h2 className="mt-4 max-w-3xl font-display text-4xl font-semibold leading-[1.04] tracking-[-0.04em] sm:text-6xl">
                  Evaluate what we have already built.
                </h2>
              </div>
              <p className="max-w-2xl text-base leading-7 text-slate-300 lg:justify-self-end">
                Serious technology decisions need more than a services list. These are the products, workflows and delivery capabilities a prospective client can inspect today.
              </p>
            </Reveal>

            <div className="mt-16 grid gap-5 lg:grid-cols-3">
              {BUYER_EVIDENCE.map((item, index) => {
                const content = (
                  <article className="group flex h-full flex-col rounded-2xl border border-white/10 bg-white/[0.055] p-7 backdrop-blur-sm transition duration-300 hover:-translate-y-1 hover:border-sky-400/50 hover:bg-white/[0.08]">
                    <div className="flex items-center justify-between gap-4">
                      <span className="rounded-full border border-sky-300/25 bg-sky-300/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-sky-200">{item.label}</span>
                      {item.external ? <ExternalLink className="h-4 w-4 text-slate-500 transition group-hover:text-sky-300" /> : <ArrowRight className="h-4 w-4 text-slate-500 transition group-hover:translate-x-1 group-hover:text-sky-300" />}
                    </div>
                    <h3 className="mt-7 text-xl font-bold text-white">{item.title}</h3>
                    <p className="mt-3 text-sm leading-6 text-slate-300">{item.description}</p>
                    <ul className="mt-7 space-y-3 border-t border-white/10 pt-6">
                      {item.facts.map(fact => (
                        <li key={fact} className="flex gap-3 text-sm leading-5 text-slate-200">
                          <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-emerald-400" /> {fact}
                        </li>
                      ))}
                    </ul>
                    <span className="mt-8 text-sm font-bold text-sky-300">Inspect the evidence</span>
                  </article>
                );

                return (
                  <Reveal key={item.title} delay={index * 70} className="h-full">
                    {item.external ? (
                      <a href={item.href} target="_blank" rel="noopener noreferrer" className="block h-full">{content}</a>
                    ) : (
                      <Link to={item.href} className="block h-full">{content}</Link>
                    )}
                  </Reveal>
                );
              })}
            </div>

            <Reveal className="mt-20 overflow-hidden rounded-2xl border border-white/10 bg-white/[0.045]">
              <div className="grid gap-5 border-b border-white/10 p-7 lg:grid-cols-[0.8fr_1.2fr] lg:items-center lg:p-10">
                <div>
                  <div className="flex items-center gap-3 text-sky-300"><ShieldCheck className="h-5 w-5" /><span className="text-xs font-bold uppercase tracking-[0.18em]">The SynapVex difference</span></div>
                  <h3 className="mt-4 font-display text-3xl font-semibold tracking-[-0.03em]">Not simply another project supplier.</h3>
                </div>
                <p className="max-w-2xl text-sm leading-6 text-slate-300 lg:justify-self-end">
                  We bring the operating discipline of a product company into client delivery—so decisions account for launch, adoption, security, maintenance and growth from the beginning.
                </p>
              </div>
              <div className="hidden grid-cols-[0.7fr_1fr_1fr] border-b border-white/10 px-7 py-4 text-[10px] font-bold uppercase tracking-[0.15em] text-slate-500 md:grid lg:px-10">
                <span>Decision area</span><span>Project-only model</span><span className="text-sky-300">SynapVex model</span>
              </div>
              {MODEL_COMPARISON.map(([area, typical, synapvex]) => (
                <div key={area} className="grid gap-3 border-b border-white/10 px-7 py-6 last:border-b-0 md:grid-cols-[0.7fr_1fr_1fr] md:gap-8 lg:px-10">
                  <span className="text-sm font-bold text-white">{area}</span>
                  <span className="text-sm leading-6 text-slate-400">{typical}</span>
                  <span className="flex gap-2 text-sm font-semibold leading-6 text-sky-100"><CheckCircle2 className="mt-1 h-4 w-4 shrink-0 text-emerald-400" />{synapvex}</span>
                </div>
              ))}
            </Reveal>
          </div>
        </section>

        <section className="bg-white py-28 sm:py-40">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Core capabilities</p>
              <h2 className="corporate-heading mt-3">Tell us what is slowing you down.</h2>
              <p className="mt-5 text-base leading-7 text-slate-600">
                You do not need to arrive with a technical specification. Start with the customer problem, operational bottleneck or growth priority.
              </p>
            </Reveal>

            <div className="mt-20 grid border-l border-t border-slate-200 sm:grid-cols-2 lg:grid-cols-3">
              {CAPABILITIES.map((capability, index) => (
                <Reveal key={capability.title} delay={(index % 3) * 60} className="border-b border-r border-slate-200 bg-white p-9 lg:p-12">
                  <capability.icon className="h-6 w-6 text-sky-700" />
                  <h3 className="mt-5 text-lg font-bold text-slate-900">{capability.title}</h3>
                  <p className="mt-3 text-sm leading-6 text-slate-600">{capability.description}</p>
                </Reveal>
              ))}
            </div>

            <div className="mt-8">
              <Link to="/about" className="inline-flex items-center gap-2 text-sm font-bold text-sky-700 hover:text-sky-800">
                Explore all services <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>
        </section>

        <section className="border-y border-slate-200 bg-slate-50 py-28 sm:py-40">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="grid gap-16 lg:grid-cols-[0.68fr_1.32fr] lg:items-center">
              <Reveal>
                <p className="corporate-eyebrow">How we deliver</p>
                <h2 className="corporate-heading mt-3">Structured delivery. Clear decisions.</h2>
                <p className="mt-5 text-base leading-7 text-slate-600">
                  A straightforward engagement model keeps teams aligned from the first conversation through launch and continuous improvement.
                </p>
                <div className="mt-9 overflow-hidden rounded-2xl shadow-[0_25px_65px_-35px_rgba(3,105,161,.7)]">
                  <ProductMotionVisual variant="network" />
                </div>
              </Reveal>

              <div className="divide-y divide-slate-200 border-y border-slate-200">
                {DELIVERY_STEPS.map((step, index) => (
                  <Reveal key={step.number} delay={index * 60} className="grid gap-3 py-6 sm:grid-cols-[64px_150px_1fr] sm:items-start">
                    <span className="text-sm font-bold text-sky-700">{step.number}</span>
                    <h3 className="text-base font-bold text-slate-900">{step.title}</h3>
                    <p className="text-sm leading-6 text-slate-600">{step.description}</p>
                  </Reveal>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section className="bg-slate-950 py-24 sm:py-32">
          <div className="mx-auto flex max-w-7xl flex-col gap-8 px-4 sm:px-6 lg:flex-row lg:items-center lg:justify-between lg:px-8">
            <div className="max-w-3xl">
              <div className="flex items-center gap-2 text-sm font-semibold text-sky-100">
                <GraduationCap className="h-5 w-5" /> Product engineering and technology delivery
              </div>
              <h2 className="mt-5 font-display text-4xl font-semibold leading-tight tracking-[-0.035em] text-white sm:text-6xl">Let’s turn your next technology priority into a clear plan.</h2>
            </div>
            <Link to="/book-online" className="luxury-button-light shrink-0 gap-2 !px-7 !py-4">
              Start a project <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </section>
      </main>

      <PublicFooter />
    </div>
  );
}
