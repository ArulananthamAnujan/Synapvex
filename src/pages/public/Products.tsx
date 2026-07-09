import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle, Clock, Sparkles } from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';
import { PRODUCTS } from '../../lib/products';

export default function Products() {
  return (
    <div className="bg-white min-h-screen">
      <PublicHeader />
      <div className="pt-20 lg:pt-24">
        {/* Hero */}
        <section className="bg-mesh py-24 relative overflow-hidden">
          <div className="absolute inset-0 bg-grid" />
          <div className="absolute top-[-6rem] right-[-4rem] w-[30rem] h-[30rem] bg-sky-500/15 rounded-full blur-3xl animate-blob" />
          <div className="absolute bottom-0 left-0 w-96 h-96 bg-indigo-500/12 rounded-full blur-3xl animate-blob" style={{ animationDelay: '5s' }} />
          <Reveal className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <div className="inline-flex items-center gap-2 glass-card rounded-full px-4 py-1.5 mb-6">
              <Sparkles className="w-4 h-4 text-sky-300" />
              <span className="text-sky-200 text-sm font-semibold">The Synapvex Product Family</span>
            </div>
            <h1 className="font-playfair text-4xl lg:text-6xl font-bold text-white mb-5">
              Products built to<br /><span className="text-gradient-sky">power your growth</span>
            </h1>
            <p className="text-slate-300 text-lg max-w-2xl mx-auto">
              Synapvex is more than services — we build software products businesses run on.
              One account, a growing family of tools.
            </p>
          </Reveal>
        </section>

        {/* Product cards */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="grid md:grid-cols-2 gap-8">
            {PRODUCTS.map((product, idx) => {
              const live = product.status === 'live';
              return (
                <Reveal
                  as="div"
                  key={product.key}
                  delay={(idx % 2) * 100}
                  className={`rounded-3xl border overflow-hidden transition-all duration-300 ${
                    live
                      ? 'border-sky-200 shadow-lg hover:shadow-2xl hover:-translate-y-1.5'
                      : 'border-slate-200 opacity-90 hover:opacity-100'
                  }`}
                >
                  <div className={`bg-gradient-to-br ${product.gradient} px-7 py-6 flex items-center justify-between`}>
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 bg-white/15 border border-white/25 rounded-2xl flex items-center justify-center">
                        <product.icon className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <h2 className="font-bold text-white text-xl">{product.name}</h2>
                        <p className="text-white/70 text-sm">{product.tagline}</p>
                      </div>
                    </div>
                    {live ? (
                      <span className="bg-white text-slate-900 text-xs font-bold px-3 py-1 rounded-full shrink-0">LIVE</span>
                    ) : (
                      <span className="bg-white/20 text-white text-xs font-bold px-3 py-1 rounded-full flex items-center gap-1 shrink-0">
                        <Clock className="w-3 h-3" /> COMING SOON
                      </span>
                    )}
                  </div>
                  <div className="p-7">
                    <p className="text-slate-600 text-sm leading-relaxed mb-5">{product.description}</p>
                    <ul className="space-y-2 mb-6">
                      {product.features.map(f => (
                        <li key={f} className="flex items-start gap-2.5 text-sm text-slate-700">
                          <CheckCircle className={`w-4 h-4 shrink-0 mt-0.5 ${product.accent}`} />
                          {f}
                        </li>
                      ))}
                    </ul>
                    {live && product.href ? (
                      <div className="flex flex-wrap gap-3">
                        <Link
                          to={product.href}
                          className={`px-6 py-2.5 ${product.accentBg} text-white text-sm font-bold rounded-xl hover:opacity-90 transition-opacity flex items-center gap-2`}
                        >
                          Explore {product.name} <ArrowRight className="w-4 h-4" />
                        </Link>
                        <Link
                          to="/teach/register"
                          className="px-6 py-2.5 border-2 border-slate-200 text-slate-700 text-sm font-bold rounded-xl hover:border-sky-400 hover:text-sky-600 transition-colors"
                        >
                          View Pricing
                        </Link>
                      </div>
                    ) : (
                      <Link
                        to="/contact"
                        className="inline-flex items-center gap-2 px-6 py-2.5 border-2 border-slate-200 text-slate-500 text-sm font-bold rounded-xl hover:border-slate-300 transition-colors"
                      >
                        Get notified at launch
                      </Link>
                    )}
                  </div>
                </Reveal>
              );
            })}
          </div>
        </section>

        {/* CTA */}
        <section className="bg-slate-50 border-t border-slate-100 py-16">
          <div className="max-w-3xl mx-auto px-4 text-center">
            <h2 className="font-playfair text-3xl font-bold text-slate-900 mb-3">Need something custom?</h2>
            <p className="text-slate-500 mb-7">
              Beyond our products, Synapvex builds custom software, websites and apps for businesses of every size.
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Link to="/about" className="px-7 py-3 bg-slate-900 text-white font-bold rounded-xl hover:bg-slate-800 transition-colors">
                Explore Our Services
              </Link>
              <Link to="/contact" className="px-7 py-3 border-2 border-slate-200 text-slate-700 font-bold rounded-xl hover:border-sky-400 hover:text-sky-600 transition-colors">
                Talk to Us
              </Link>
            </div>
          </div>
        </section>
      </div>
      <PublicFooter />
    </div>
  );
}
