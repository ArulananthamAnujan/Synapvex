import { Link } from 'react-router-dom';
import { ArrowRight, Check, Cloud, Code2, LockKeyhole, Sparkles } from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';
import { PRODUCTS } from '../../lib/products';

const CAPABILITIES = [
  { icon: Code2, label: 'Product engineering' },
  { icon: Cloud, label: 'Cloud systems' },
  { icon: LockKeyhole, label: 'Security & support' },
];

export default function Home() {
  return (
    <div className="min-h-screen overflow-x-hidden bg-[#f5f8fa] text-slate-950">
      <PublicHeader />

      <main>
        <section className="premium-home-hero relative flex min-h-[92svh] items-center overflow-hidden pt-28 pb-20 sm:pt-36 sm:pb-28">
          <div className="premium-orb premium-orb-left" aria-hidden="true" />
          <div className="premium-orb premium-orb-right" aria-hidden="true" />

          <div className="relative mx-auto w-full max-w-7xl px-5 sm:px-7 lg:px-8">
            <div className="grid items-center gap-14 lg:grid-cols-[1.1fr_.9fr] lg:gap-20">
              <Reveal className="max-w-4xl">
                <div className="premium-kicker">
                  <Sparkles className="h-3.5 w-3.5" />
                  Digital products. Thoughtfully engineered.
                </div>

                <h1 className="mt-8 max-w-4xl font-display text-[3.35rem] font-semibold leading-[.94] tracking-[-.055em] text-[#0b2940] sm:text-7xl lg:text-[6.4rem]">
                  Technology with
                  <span className="block premium-title-gradient">clarity and purpose.</span>
                </h1>

                <p className="mt-8 max-w-xl text-base leading-7 text-slate-600 sm:text-lg sm:leading-8">
                  SynapVex creates refined digital platforms and dependable technology systems for organisations ready to move forward.
                </p>

                <div className="mt-10 flex flex-col gap-3 sm:flex-row">
                  <Link to="/contact" className="luxury-button-primary glass-touch gap-2">
                    Discuss your project <ArrowRight className="h-4 w-4" />
                  </Link>
                  <Link to="/products" className="luxury-button-light glass-touch">
                    Explore our products
                  </Link>
                </div>

                <p className="mt-8 flex items-center gap-2 text-xs font-semibold uppercase tracking-[.16em] text-slate-400">
                  <span className="h-px w-8 bg-sky-300" />
                  Australia · Sri Lanka · Bangladesh
                </p>
              </Reveal>

              <Reveal delay={120} className="hidden lg:block">
                <div className="premium-hero-object" aria-label="SynapVex product ecosystem">
                  <div className="premium-hero-ring premium-hero-ring-one" />
                  <div className="premium-hero-ring premium-hero-ring-two" />
                  <div className="premium-core-mark">
                    <span className="text-xs font-bold uppercase tracking-[.24em] text-sky-800">SynapVex</span>
                    <span className="mt-2 font-display text-2xl font-semibold text-[#0b2940]">Built as one system.</span>
                  </div>
                  {PRODUCTS.map((product, index) => (
                    <div key={product.key} className={`premium-product-node premium-product-node-${index + 1}`}>
                      <product.icon className="h-5 w-5" />
                      <span>{product.name.replace('SynapVex ', '')}</span>
                    </div>
                  ))}
                </div>
              </Reveal>
            </div>
          </div>
        </section>

        <section className="relative bg-[#071522] py-24 text-white sm:py-32">
          <div className="mx-auto max-w-7xl px-5 sm:px-7 lg:px-8">
            <Reveal className="max-w-3xl">
              <p className="text-xs font-bold uppercase tracking-[.24em] text-sky-300">Our platforms</p>
              <h2 className="mt-4 font-display text-4xl font-semibold leading-tight tracking-[-.04em] sm:text-6xl">
                Three products. One exacting standard.
              </h2>
            </Reveal>

            <div className="mt-14 grid gap-5 lg:grid-cols-3">
              {PRODUCTS.map((product, index) => {
                const live = product.status === 'live';
                const card = (
                  <article className="premium-product-card glass-touch h-full">
                    <div className="flex items-start justify-between gap-4">
                      <div className="premium-product-icon">
                        <product.icon className="h-6 w-6" />
                      </div>
                      <span className={`rounded-full border px-3 py-1 text-[9px] font-bold uppercase tracking-[.16em] ${live ? 'border-emerald-300/25 bg-emerald-300/10 text-emerald-200' : 'border-white/10 bg-white/5 text-slate-400'}`}>
                        {live ? 'Available' : 'In development'}
                      </span>
                    </div>
                    <h3 className="mt-10 font-display text-3xl font-semibold tracking-[-.035em]">{product.name}</h3>
                    <p className="mt-3 text-sm leading-6 text-slate-300">{product.tagline}</p>
                    <div className="mt-10 inline-flex items-center gap-2 text-sm font-bold text-sky-200">
                      {live ? 'View platform' : 'View roadmap'} <ArrowRight className="h-4 w-4" />
                    </div>
                  </article>
                );

                return (
                  <Reveal key={product.key} delay={index * 70} className="h-full">
                    {live && product.href && product.external ? (
                      <a href={product.href} target="_blank" rel="noopener noreferrer" className="block h-full">{card}</a>
                    ) : live && product.href ? (
                      <Link to={product.href} className="block h-full">{card}</Link>
                    ) : card}
                  </Reveal>
                );
              })}
            </div>
          </div>
        </section>

        <section className="border-b border-sky-100/70 bg-white/75 py-8 backdrop-blur-xl">
          <div className="mx-auto grid max-w-7xl gap-3 px-5 sm:grid-cols-3 sm:px-7 lg:px-8">
            {CAPABILITIES.map(item => (
              <div key={item.label} className="premium-capability">
                <item.icon className="h-5 w-5 text-sky-700" />
                <span>{item.label}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="bg-[#f5f8fa] py-24 sm:py-36">
          <div className="mx-auto grid max-w-7xl gap-14 px-5 sm:px-7 lg:grid-cols-[.86fr_1.14fr] lg:items-center lg:gap-24 lg:px-8">
            <Reveal>
              <p className="corporate-eyebrow">Why SynapVex</p>
              <h2 className="mt-4 font-display text-4xl font-semibold leading-[1.05] tracking-[-.045em] text-[#0b2940] sm:text-6xl">
                Product thinking, not agency theatre.
              </h2>
            </Reveal>

            <Reveal delay={100} className="premium-proof-panel">
              <p className="text-lg leading-8 text-slate-600 sm:text-xl sm:leading-9">
                We build and operate our own platforms. Every client engagement benefits from the same practical discipline: fewer layers, clearer decisions and technology designed to last.
              </p>
              <div className="mt-8 space-y-4">
                {[
                  'Direct access to the people doing the work',
                  'Security and maintainability built in from day one',
                  'A clear path from first conversation to delivery',
                ].map(item => (
                  <div key={item} className="flex items-start gap-3 text-sm font-semibold text-[#17384f]">
                    <span className="mt-0.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-sky-100 text-sky-700">
                      <Check className="h-3.5 w-3.5" />
                    </span>
                    <span className="pt-0.5">{item}</span>
                  </div>
                ))}
              </div>
            </Reveal>
          </div>
        </section>

        <section className="px-4 pb-5 sm:px-6 sm:pb-7">
          <Reveal className="premium-cta mx-auto max-w-7xl">
            <div className="max-w-3xl">
              <p className="text-xs font-bold uppercase tracking-[.22em] text-sky-200">Begin with a conversation</p>
              <h2 className="mt-5 font-display text-4xl font-semibold leading-tight tracking-[-.04em] text-white sm:text-6xl">
                Make the next move feel clear.
              </h2>
            </div>
            <Link to="/contact" className="luxury-button-light glass-touch shrink-0 gap-2">
              Start a project <ArrowRight className="h-4 w-4" />
            </Link>
          </Reveal>
        </section>
      </main>

      <PublicFooter />
    </div>
  );
}
