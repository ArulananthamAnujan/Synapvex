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
  { icon: Code2, title: 'Custom software', description: 'Business applications, SaaS products and connected systems.' },
  { icon: Globe2, title: 'Digital platforms', description: 'Websites, commerce and responsive customer experiences.' },
  { icon: Smartphone, title: 'Mobile products', description: 'Cross-platform applications built around real workflows.' },
  { icon: Cloud, title: 'Cloud systems', description: 'Migration, infrastructure, backup and continuity.' },
  { icon: LockKeyhole, title: 'Security & support', description: 'Protection, assessment and dependable managed support.' },
  { icon: Briefcase, title: 'Advisory', description: 'Practical strategy, planning and transformation guidance.' },
];

const DELIVERY_STEPS = [
  ['01', 'Understand', 'Clarify the problem, users and outcome.'],
  ['02', 'Plan', 'Define scope, roadmap and approach.'],
  ['03', 'Deliver', 'Build and test in focused stages.'],
  ['04', 'Improve', 'Support, measure and strengthen.'],
];

const DIFFERENTIATORS = [
  { icon: Layers3, title: 'Product-led', description: 'The discipline used for our own platforms.' },
  { icon: Workflow, title: 'End to end', description: 'One connected delivery programme.' },
  { icon: LockKeyhole, title: 'Resilient', description: 'Security and maintainability from day one.' },
  { icon: Target, title: 'Commercial', description: 'Every decision tied to an outcome.' },
];

export default function Home() {
  return (
    <div className="min-h-screen overflow-x-hidden bg-[#eef7fa] text-slate-950">
      <PublicHeader />

      <main className="compact-home">
        <section className="compact-hero relative overflow-hidden pt-32 pb-8 sm:pt-40 sm:pb-14">
          <div className="compact-home-orb compact-home-orb-a" />
          <div className="compact-home-orb compact-home-orb-b" />
          <img src="/images/company/digital-ecosystem.webp" alt="" aria-hidden="true" className="pointer-events-none absolute inset-y-0 right-0 h-full w-[68%] object-cover object-center opacity-[0.11] mix-blend-multiply [mask-image:linear-gradient(to_left,black,transparent)]" />
          <div className="relative mx-auto max-w-7xl px-3 sm:px-6 lg:px-8">
            <div className="compact-kicker">Technology products and delivery services</div>

            <div className="mt-4 grid grid-cols-2 gap-3 sm:mt-7 sm:gap-6 lg:gap-12">
              <Reveal className="compact-hero-copy">
                <h1 className="font-display text-[2.05rem] font-semibold leading-[.98] tracking-[-.045em] text-[#102d48] sm:text-5xl lg:text-7xl">
                  Technology, <span className="bg-gradient-to-r from-sky-800 via-sky-600 to-amber-500 bg-clip-text text-transparent">engineered forward.</span>
                </h1>
                <p className="mt-4 text-[11px] leading-5 text-slate-600 sm:mt-7 sm:text-base sm:leading-7">
                  Digital products and dependable technology systems for organisations ready to modernise.
                </p>
                <div className="mt-5 flex flex-col gap-2 sm:mt-8 sm:flex-row">
                  <Link to="/contact" className="compact-primary-action glass-touch">
                    Discuss project <ArrowRight className="h-3.5 w-3.5" />
                  </Link>
                  <Link to="/products" className="compact-secondary-action glass-touch">
                    All products
                  </Link>
                </div>
              </Reveal>

              <Reveal delay={80} className="min-w-0">
                <div className="mb-2 flex items-center justify-between gap-2">
                  <h2 className="font-display text-sm font-semibold text-[#102d48] sm:text-xl">Choose a platform</h2>
                  <Link to="/products" className="hidden text-xs font-bold text-sky-700 sm:inline-flex">View all</Link>
                </div>
                <div className="space-y-2">
                  {PRODUCTS.map(product => {
                    const card = (
                      <div className="compact-product-card group">
                        <div className={`compact-product-icon bg-gradient-to-br ${product.gradient}`}>
                          <product.icon className="h-4 w-4 text-white sm:h-5 sm:w-5" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <h3 className="truncate text-[11px] font-bold text-[#102d48] sm:text-sm">{product.name.replace('SynapVex ', '')}</h3>
                          <p className="mt-0.5 hidden truncate text-[10px] text-slate-500 sm:block">{product.tagline}</p>
                        </div>
                        <ArrowRight className="h-3.5 w-3.5 shrink-0 text-sky-700/70 transition-transform group-hover:translate-x-0.5" />
                      </div>
                    );
                    return product.href && product.external ? (
                      <a key={product.key} href={product.href} target="_blank" rel="noopener noreferrer" className="block rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-400">{card}</a>
                    ) : (
                      <Link key={product.key} to={product.href || `/products#${product.key}`} className="block rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-400">{card}</Link>
                    );
                  })}
                </div>
              </Reveal>
            </div>
          </div>
        </section>

        <section className="px-3 py-3 sm:px-6 sm:py-6">
          <Reveal className="compact-capability-band mx-auto max-w-7xl">
            <div className="compact-section-intro">
              <p className="compact-eyebrow">Core capabilities</p>
              <h2 className="compact-section-title">One accountable technology partner.</h2>
              <Link to="/about" className="compact-text-link">Explore services <ArrowRight className="h-3.5 w-3.5" /></Link>
            </div>
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
              {CAPABILITIES.map(capability => (
                <Link key={capability.title} to="/about" className="compact-capability-card glass-touch">
                  <capability.icon className="h-4 w-4 text-sky-700" />
                  <div>
                    <h3>{capability.title}</h3>
                    <p>{capability.description}</p>
                  </div>
                </Link>
              ))}
            </div>
          </Reveal>
        </section>

        <section className="px-3 py-3 sm:px-6 sm:py-6">
          <div className="mx-auto grid max-w-7xl grid-cols-2 gap-3 sm:gap-6">
            <Reveal className="compact-lower-panel compact-delivery-panel">
              <p className="compact-eyebrow">How we deliver</p>
              <h2 className="compact-section-title">Structured delivery. Clear decisions.</h2>
              <div className="mt-4 grid gap-2">
                {DELIVERY_STEPS.map(([number, title, description]) => (
                  <div key={number} className="compact-step">
                    <span>{number}</span>
                    <div><h3>{title}</h3><p>{description}</p></div>
                  </div>
                ))}
              </div>
            </Reveal>

            <Reveal delay={80} className="compact-lower-panel compact-why-panel">
              <p className="compact-eyebrow">Why SynapVex</p>
              <h2 className="compact-section-title">Technical depth. Business focus.</h2>
              <div className="mt-4 grid gap-2">
                {DIFFERENTIATORS.map(item => (
                  <div key={item.title} className="compact-proof">
                    <item.icon className="h-4 w-4 text-sky-700" />
                    <div><h3>{item.title}</h3><p>{item.description}</p></div>
                  </div>
                ))}
              </div>
            </Reveal>
          </div>
        </section>

        <section className="px-3 pt-3 pb-5 sm:px-6 sm:pt-6 sm:pb-8">
          <Reveal className="compact-cta mx-auto max-w-7xl">
            <div>
              <div className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-[.16em] text-sky-200">
                <GraduationCap className="h-4 w-4" /> Technology delivery
              </div>
              <h2>Turn your next priority into a clear plan.</h2>
            </div>
            <Link to="/contact" className="compact-cta-link glass-touch">Start a conversation <ArrowRight className="h-4 w-4" /></Link>
          </Reveal>
        </section>
      </main>

      <PublicFooter />
    </div>
  );
}
