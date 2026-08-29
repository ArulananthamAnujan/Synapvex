import { Link } from 'react-router-dom';
import {
  ArrowRight, Briefcase, Cloud, Code2, Globe2, GraduationCap,
  Layers3, LockKeyhole, Smartphone, Target, Workflow,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';
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
        <section className="relative overflow-hidden bg-gradient-to-br from-[#fcfdff] via-[#eef8fc] to-[#f8fafc] pt-36 pb-28 sm:pt-40 sm:pb-32 lg:pt-48 lg:pb-40">
          <div className="absolute -left-36 top-0 h-[34rem] w-[34rem] rounded-full bg-amber-400/25 blur-[105px]" aria-hidden="true" />
          <div className="absolute -right-28 top-0 h-[40rem] w-[40rem] rounded-full bg-sky-400/30 blur-[115px]" aria-hidden="true" />
          <div className="absolute bottom-[-20rem] left-[40%] h-[36rem] w-[36rem] rounded-full bg-emerald-300/10 blur-[120px]" aria-hidden="true" />

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

            <div className="luxury-surface relative overflow-hidden rounded-[26px] border border-white/90 bg-white/90 backdrop-blur-xl">
              <div className="absolute right-[-5rem] top-[-5rem] h-52 w-52 rounded-full bg-amber-300/20 blur-3xl" />
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

              <div className="p-6">
                <p className="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-500">Product platforms</p>
                <div className="space-y-2">
                  {PRODUCTS.map(product => {
                    const row = (
                      <div className="premium-clickable-product flex items-center gap-4 rounded-2xl px-4 py-4">
                        <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br ${product.gradient}`}>
                          <product.icon className="h-5 w-5 text-white" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <p className="truncate text-sm font-bold text-[#102d48]">{product.name}</p>
                          <p className="truncate text-xs text-slate-500">{product.tagline}</p>
                        </div>
                        <span className={`shrink-0 text-[9px] font-bold uppercase tracking-wider ${product.status === 'live' ? 'text-emerald-700' : 'text-slate-500'}`}>
                          {product.status === 'live' ? 'Open' : 'Preview'}
                        </span>
                        <ArrowRight className="h-4 w-4 shrink-0 text-sky-700" />
                      </div>
                    );

                    return product.href && product.external ? (
                      <a key={product.key} href={product.href} target="_blank" rel="noopener noreferrer" className="block rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-400">
                        {row}
                      </a>
                    ) : (
                      <Link key={product.key} to={product.href || `/products#${product.key}`} className="block rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-400">
                        {row}
                      </Link>
                    );
                  })}
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

        <section className="bg-white py-20 sm:py-28">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Core capabilities</p>
              <h2 className="corporate-heading mt-3">One accountable partner across the technology lifecycle.</h2>
              <p className="mt-5 text-base leading-7 text-slate-600">
                Engage SynapVex for a focused project or a connected programme spanning product development, infrastructure and ongoing support.
              </p>
            </Reveal>

            <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {CAPABILITIES.map((capability, index) => (
                <Reveal key={capability.title} delay={(index % 3) * 60} className="premium-capability-card rounded-[22px] p-6 sm:p-7">
                  <div className="premium-capability-icon"><capability.icon className="h-5 w-5" /></div>
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

        <section className="premium-delivery-section border-y border-sky-100/70 py-20 sm:py-28">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="grid gap-20 lg:grid-cols-[0.72fr_1.28fr]">
              <Reveal>
                <p className="corporate-eyebrow">How we deliver</p>
                <h2 className="corporate-heading mt-3">Structured delivery. Clear decisions.</h2>
                <p className="mt-5 text-base leading-7 text-slate-600">
                  A straightforward engagement model keeps teams aligned from the first conversation through launch and continuous improvement.
                </p>
              </Reveal>

              <div className="grid gap-3 sm:grid-cols-2">
                {DELIVERY_STEPS.map((step, index) => (
                  <Reveal key={step.number} delay={index * 60} className="premium-delivery-step rounded-[20px] p-5 sm:p-6">
                    <div className="flex items-center gap-3"><span className="premium-step-number">{step.number}</span><h3 className="text-base font-bold text-slate-900">{step.title}</h3></div>
                    <p className="mt-4 text-sm leading-6 text-slate-600">{step.description}</p>
                  </Reveal>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section className="bg-white py-20 sm:py-28">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Why SynapVex</p>
              <h2 className="corporate-heading mt-3">Technical depth with a business point of view.</h2>
            </Reveal>

            <div className="mt-20 grid gap-12 md:grid-cols-2">
              {DIFFERENTIATORS.map((item, index) => (
                <Reveal key={item.title} delay={(index % 2) * 70} className="premium-difference-card rounded-[22px] p-5 sm:p-6">
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
