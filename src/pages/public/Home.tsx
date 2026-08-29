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
        <section className="relative overflow-hidden bg-slate-950 pt-36 pb-20 sm:pt-40 sm:pb-24 lg:pt-44 lg:pb-28">
          <div className="absolute inset-0 corporate-grid opacity-40" aria-hidden="true" />
          <div className="absolute inset-y-0 right-0 w-1/2 bg-gradient-to-l from-sky-900/30 to-transparent" aria-hidden="true" />

          <div className="relative mx-auto grid max-w-7xl items-center gap-14 px-4 sm:px-6 lg:grid-cols-[1.08fr_0.92fr] lg:px-8">
            <div className="max-w-3xl">
              <div className="mb-7 inline-flex items-center gap-2 border-l-2 border-sky-400 pl-3 text-sm font-semibold tracking-wide text-sky-200">
                Technology products and delivery services
              </div>
              <h1 className="max-w-3xl text-4xl font-bold leading-[1.08] tracking-[-0.035em] text-white sm:text-5xl lg:text-6xl">
                Technology that moves your organisation forward.
              </h1>
              <p className="mt-6 max-w-2xl text-lg leading-8 text-slate-300">
                SynapVex builds digital products and delivers the software, cloud, security and support capabilities organisations need to modernise with confidence.
              </p>
              <div className="mt-9 flex flex-col gap-3 sm:flex-row">
                <Link to="/contact" className="inline-flex items-center justify-center gap-2 rounded-md bg-sky-500 px-6 py-3.5 text-sm font-bold text-white shadow-lg shadow-sky-950/30 transition-colors hover:bg-sky-400 focus:outline-none focus:ring-2 focus:ring-sky-300 focus:ring-offset-2 focus:ring-offset-slate-950">
                  Discuss your project <ArrowRight className="h-4 w-4" />
                </Link>
                <Link to="/products" className="inline-flex items-center justify-center gap-2 rounded-md border border-slate-600 bg-white/5 px-6 py-3.5 text-sm font-bold text-white transition-colors hover:border-slate-400 hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-slate-300">
                  Explore our platforms
                </Link>
              </div>
            </div>

            <div className="border border-slate-700 bg-slate-900/90 shadow-2xl shadow-black/30">
              <div className="flex items-center justify-between border-b border-slate-700 px-6 py-5">
                <div>
                  <p className="text-xs font-bold uppercase tracking-[0.18em] text-sky-300">SynapVex portfolio</p>
                  <p className="mt-1 text-sm text-slate-400">Products and delivery capabilities</p>
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-emerald-300">
                  <span className="h-2 w-2 rounded-full bg-emerald-400" />
                  {liveProducts.length} live platforms
                </div>
              </div>

              <div className="p-6">
                <p className="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-500">Product platforms</p>
                <div className="space-y-2">
                  {PRODUCTS.map(product => (
                    <div key={product.key} className="flex items-center gap-4 border border-slate-700/80 bg-slate-950/50 px-4 py-3.5">
                      <div className={`flex h-10 w-10 shrink-0 items-center justify-center bg-gradient-to-br ${product.gradient}`}>
                        <product.icon className="h-5 w-5 text-white" />
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-bold text-white">{product.name}</p>
                        <p className="truncate text-xs text-slate-400">{product.tagline}</p>
                      </div>
                      <span className={`text-[10px] font-bold uppercase tracking-wider ${product.status === 'live' ? 'text-emerald-300' : 'text-slate-500'}`}>
                        {product.status === 'live' ? 'Live' : 'In development'}
                      </span>
                    </div>
                  ))}
                </div>

                <div className="mt-6 grid grid-cols-2 gap-px border border-slate-700 bg-slate-700">
                  {['Software engineering', 'Cloud & infrastructure', 'Cybersecurity', 'Managed support'].map(item => (
                    <div key={item} className="bg-slate-900 px-3 py-3 text-xs font-medium text-slate-300">{item}</div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="border-b border-slate-200 bg-white" aria-label="Delivery presence">
          <div className="mx-auto grid max-w-7xl divide-y divide-slate-200 px-4 sm:grid-cols-3 sm:divide-x sm:divide-y-0 sm:px-6 lg:px-8">
            {[
              ['Australia', 'Client relationships and regional growth'],
              ['Sri Lanka', 'Product and delivery capability'],
              ['Bangladesh', 'Engineering and operational support'],
            ].map(([region, detail]) => (
              <div key={region} className="px-0 py-6 sm:px-6 first:sm:pl-0 last:sm:pr-0">
                <p className="text-sm font-bold text-slate-900">{region}</p>
                <p className="mt-1 text-sm text-slate-500">{detail}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="bg-slate-50 py-20 sm:py-24">
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

            <div className="mt-12 grid gap-5 lg:grid-cols-3">
              {PRODUCTS.map((product, index) => {
                const live = product.status === 'live';
                const content = (
                  <article className="flex h-full flex-col border border-slate-200 bg-white p-7 transition-colors hover:border-sky-300">
                    <div className="flex items-start justify-between gap-4">
                      <div className={`flex h-12 w-12 items-center justify-center bg-gradient-to-br ${product.gradient}`}>
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

        <section className="bg-white py-20 sm:py-24">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Core capabilities</p>
              <h2 className="corporate-heading mt-3">One accountable partner across the technology lifecycle.</h2>
              <p className="mt-5 text-base leading-7 text-slate-600">
                Engage SynapVex for a focused project or a connected programme spanning product development, infrastructure and ongoing support.
              </p>
            </Reveal>

            <div className="mt-12 grid border-l border-t border-slate-200 sm:grid-cols-2 lg:grid-cols-3">
              {CAPABILITIES.map((capability, index) => (
                <Reveal key={capability.title} delay={(index % 3) * 60} className="border-b border-r border-slate-200 bg-white p-7 lg:p-8">
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

        <section className="border-y border-slate-200 bg-slate-50 py-20 sm:py-24">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="grid gap-12 lg:grid-cols-[0.72fr_1.28fr]">
              <Reveal>
                <p className="corporate-eyebrow">How we deliver</p>
                <h2 className="corporate-heading mt-3">Structured delivery. Clear decisions.</h2>
                <p className="mt-5 text-base leading-7 text-slate-600">
                  A straightforward engagement model keeps teams aligned from the first conversation through launch and continuous improvement.
                </p>
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

        <section className="bg-white py-20 sm:py-24">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="corporate-eyebrow">Why SynapVex</p>
              <h2 className="corporate-heading mt-3">Technical depth with a business point of view.</h2>
            </Reveal>

            <div className="mt-12 grid gap-8 md:grid-cols-2">
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

        <section className="bg-sky-700 py-16 sm:py-20">
          <div className="mx-auto flex max-w-7xl flex-col gap-8 px-4 sm:px-6 lg:flex-row lg:items-center lg:justify-between lg:px-8">
            <div className="max-w-3xl">
              <div className="flex items-center gap-2 text-sm font-semibold text-sky-100">
                <GraduationCap className="h-5 w-5" /> Product engineering and technology delivery
              </div>
              <h2 className="mt-3 text-3xl font-bold tracking-tight text-white sm:text-4xl">Let’s turn your next technology priority into a clear plan.</h2>
            </div>
            <Link to="/contact" className="inline-flex shrink-0 items-center justify-center gap-2 rounded-md bg-white px-6 py-3.5 text-sm font-bold text-sky-800 transition-colors hover:bg-sky-50 focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-sky-700">
              Start a conversation <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </section>
      </main>

      <PublicFooter />
    </div>
  );
}
