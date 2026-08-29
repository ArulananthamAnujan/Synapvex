import { Link } from 'react-router-dom';
import {
  ArrowRight, Briefcase, Cloud, Code2, Globe2, GraduationCap,
  Layers3, LockKeyhole, Smartphone, Target, Workflow,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';
import ProductMotionVisual from '../../components/ui/ProductMotionVisual';
import { PRODUCTS } from '../../lib/products';

const CAPABILITIES = [
  { icon: Code2, title: 'Custom software', description: 'Purpose-built business applications, SaaS products, APIs and system integrations.' },
  { icon: Globe2, title: 'Digital platforms', description: 'Corporate websites, commerce experiences and responsive web applications.' },
  { icon: Smartphone, title: 'Mobile products', description: 'Cross-platform mobile applications designed around real customer workflows.' },
  { icon: Cloud, title: 'Cloud & infrastructure', description: 'Cloud migration, collaboration platforms, networking, backup and continuity.' },
  { icon: LockKeyhole, title: 'Security & support', description: 'Security assessments, endpoint protection and dependable managed IT support.' },
  { icon: Briefcase, title: 'Technology advisory', description: 'Practical technology strategy, delivery planning and digital transformation guidance.' },
];

const DELIVERY_STEPS = [
  { number: '01', title: 'Understand', description: 'We clarify the business problem, users, risks and measures of success.' },
  { number: '02', title: 'Plan', description: 'We define a practical scope, delivery roadmap and technical approach.' },
  { number: '03', title: 'Deliver', description: 'We design, build and test in focused stages with clear progress updates.' },
  { number: '04', title: 'Improve', description: 'We support the launch, measure performance and strengthen the solution over time.' },
];

const DIFFERENTIATORS = [
  { icon: Layers3, title: 'Product-led thinking', description: 'We apply the same product discipline used to build our own platforms to every client engagement.' },
  { icon: Workflow, title: 'End-to-end delivery', description: 'Strategy, design, engineering, infrastructure and support work as one connected programme.' },
  { icon: LockKeyhole, title: 'Built for resilience', description: 'Security, maintainability and operational continuity are considered from the beginning.' },
  { icon: Target, title: 'Commercially focused', description: 'Every recommendation is tied to a clear operational need or business outcome.' },
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
                Technology products and delivery services
              </div>
              <h1 className="max-w-4xl font-display text-5xl font-semibold leading-[0.98] tracking-[-0.045em] text-[#102d48] sm:text-6xl lg:text-8xl">
                Technology, <span className="bg-gradient-to-r from-sky-800 via-sky-600 to-amber-500 bg-clip-text text-transparent">engineered forward.</span>
              </h1>
              <p className="mt-10 max-w-xl text-lg leading-8 text-slate-600">
                SynapVex builds digital products and delivers the software, cloud, security and support capabilities organisations need to modernise with confidence.
              </p>
              <div className="mt-12 flex flex-col gap-4 sm:flex-row">
                <Link to="/contact" className="luxury-button-primary gap-2">
                  Discuss your project <ArrowRight className="h-4 w-4" />
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

        <section className="border-b border-white/10 bg-slate-950" aria-label="Delivery presence">
          <div className="mx-auto grid max-w-7xl divide-y divide-white/10 px-4 sm:grid-cols-3 sm:divide-x sm:divide-y-0 sm:px-6 lg:px-8">
            {[
              ['Australia', 'Client relationships and regional growth'],
              ['Sri Lanka', 'Product and delivery capability'],
              ['Bangladesh', 'Engineering and operational support'],
            ].map(([region, detail]) => (
              <div key={region} className="px-0 py-9 sm:px-8 first:sm:pl-0 last:sm:pr-0">
                <p className="text-sm font-bold tracking-wide text-white">{region}</p>
                <p className="mt-2 text-sm leading-6 text-slate-400">{detail}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="border-b border-sky-100 bg-white" aria-label="Company proof points">
          <div className="mx-auto grid max-w-7xl gap-px bg-sky-100 px-4 sm:grid-cols-3 sm:px-6 lg:px-8">
            {[
              ['02', 'Live product platforms', 'Products operated by the same team that delivers for clients.'],
              ['03', 'Delivery regions', 'A connected presence across Australia, Sri Lanka and Bangladesh.'],
              ['06', 'Core capabilities', 'From product engineering and cloud through security and support.'],
            ].map(([value, label, detail]) => (
              <div key={label} className="bg-white px-7 py-12 sm:py-14">
                <p className="font-display text-5xl font-semibold tracking-[-0.05em] text-[#102d48]">{value}</p>
                <p className="mt-3 text-sm font-bold uppercase tracking-[0.13em] text-sky-800">{label}</p>
                <p className="mt-3 max-w-sm text-sm leading-6 text-slate-500">{detail}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="bg-gradient-to-b from-slate-50 via-white to-blue-50/40 py-28 sm:py-40">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="grid gap-6 lg:grid-cols-[0.8fr_1.2fr] lg:items-end">
              <div>
                <p className="corporate-eyebrow">Our product portfolio</p>
                <h2 className="corporate-heading mt-3">We build and operate products of our own.</h2>
              </div>
              <p className="max-w-2xl text-base leading-7 text-slate-600 lg:justify-self-end">
                Our platforms keep us close to the realities of product strategy, engineering, operations and customer support. That experience directly informs how we deliver for clients.
              </p>
            </Reveal>

            <div className="mt-20 grid gap-8 lg:grid-cols-3">
              {PRODUCTS.map((product, index) => {
                const live = product.status === 'live';
                const content = (
                  <article className="group flex h-full flex-col overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-[0_22px_60px_-40px_rgba(15,23,42,0.55)] transition-all duration-300 hover:-translate-y-1.5 hover:border-sky-300 hover:shadow-[0_30px_70px_-35px_rgba(2,132,199,0.4)]">
                    <div className="m-3 mb-0 overflow-hidden rounded-xl transition-transform duration-500 group-hover:scale-[1.02]">
                      <ProductMotionVisual variant={product.key === 'learn' ? 'learn' : product.key === 'pte' ? 'pte' : 'crm'} compact />
                    </div>
                    <div className="flex flex-1 flex-col p-7 pt-6">
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-[#123a59] to-sky-600 shadow-[inset_0_1px_0_rgba(255,255,255,0.28)]">
                        <product.icon className="h-6 w-6 text-white" />
                      </div>
                      <span className={`text-[10px] font-bold uppercase tracking-[0.16em] ${live ? 'text-emerald-700' : 'text-slate-400'}`}>
                        {live ? 'Available now' : 'In development'}
                      </span>
                    </div>
                    <h3 className="mt-7 text-xl font-bold text-slate-900">{product.name}</h3>
                    <p className="mt-3 flex-1 text-sm leading-6 text-slate-600">{product.description}</p>
                    <div className="mt-6 flex items-center gap-2 text-sm font-bold text-sky-700">
                      {live ? 'View platform' : 'Product roadmap'} {live && <ArrowRight className="h-4 w-4" />}
                    </div>
                    </div>
                  </article>
                );

                return (
                  <Reveal key={product.key} delay={index * 80} className="h-full">
                    {live && product.href && product.external ? (
                      <a href={product.href} target="_blank" rel="noopener noreferrer" className="block h-full">{content}</a>
                    ) : live && product.href ? (
                      <Link to={product.href} className="block h-full">{content}</Link>
                    ) : content}
                  </Reveal>
                );
              })}
            </div>
          </div>
        </section>

        <section className="bg-white py-28 sm:py-40">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Core capabilities</p>
              <h2 className="corporate-heading mt-3">One accountable partner across the technology lifecycle.</h2>
              <p className="mt-5 text-base leading-7 text-slate-600">
                Engage SynapVex for a focused project or a connected programme spanning product development, infrastructure and ongoing support.
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

        <section className="bg-white py-28 sm:py-40">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Why SynapVex</p>
              <h2 className="corporate-heading mt-3">Technical depth with a business point of view.</h2>
            </Reveal>

            <div className="mt-20 grid gap-12 md:grid-cols-2">
              {DIFFERENTIATORS.map((item, index) => (
                <Reveal key={item.title} delay={(index % 2) * 70} className="flex gap-5 border-t border-slate-200 pt-6">
                  <div className="flex h-11 w-11 shrink-0 items-center justify-center bg-sky-50 text-sky-700">
                    <item.icon className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="text-lg font-bold text-slate-900">{item.title}</h3>
                    <p className="mt-2 text-sm leading-6 text-slate-600">{item.description}</p>
                  </div>
                </Reveal>
              ))}
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
            <Link to="/contact" className="luxury-button-light shrink-0 gap-2 !px-7 !py-4">
              Start a conversation <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </section>
      </main>

      <PublicFooter />
    </div>
  );
}
