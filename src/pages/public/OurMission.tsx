import { lazy, Suspense } from 'react';
import { Link } from 'react-router-dom';
import { Target, Heart, Globe, Star, CheckCircle, ArrowRight, Users, Package, Briefcase } from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';

const InteractiveOrbitalScene = lazy(() => import('../../components/ui/InteractiveOrbitalScene'));

const PILLARS = [
  {
    icon: Star,
    title: 'Innovation First',
    desc: 'We build products and solutions on modern, proven technology — bringing AI, automation and cloud capability within reach of every business.',
    color: 'text-sky-600', bg: 'bg-sky-50', border: 'border-sky-100',
  },
  {
    icon: Target,
    title: 'Outcomes Over Output',
    desc: 'Every project and product is measured by the results it delivers — efficiency gained, revenue grown, risk reduced — not by lines of code.',
    color: 'text-emerald-600', bg: 'bg-emerald-50', border: 'border-emerald-100',
  },
  {
    icon: Heart,
    title: 'Partners, Not Vendors',
    desc: 'We work alongside our clients with transparent communication, honest timelines and long-term support — your success is our success.',
    color: 'text-amber-500', bg: 'bg-amber-50', border: 'border-amber-100',
  },
  {
    icon: Globe,
    title: 'Built to Scale Globally',
    desc: 'From a single storefront to an international academy, everything we ship is secure, reliable and ready to grow across borders.',
    color: 'text-rose-500', bg: 'bg-rose-50', border: 'border-rose-100',
  },
];

const GOALS = [
  'Build software products that businesses genuinely run on every day',
  'Make enterprise-grade technology affordable for small and medium businesses',
  'Empower educators and creators to build businesses under their own brand',
  'Deliver every service engagement with transparency and measurable results',
  'Keep security and reliability at the core of everything we ship',
  'Grow a family of products that work better together',
];

export default function OurMission() {
  return (
    <div className="min-h-screen bg-white">
      <PublicHeader />

      {/* Hero */}
      <section className="premium-page-hero pt-40 pb-28 sm:pt-44 sm:pb-36">
        <div className="absolute inset-0 corporate-grid opacity-30" />
        <div className="absolute top-[-6rem] right-[-4rem] w-[30rem] h-[30rem] bg-sky-400/20 rounded-full blur-3xl animate-blob" />
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-amber-300/20 rounded-full blur-3xl animate-blob" style={{ animationDelay: '5s' }} />
        <div className="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div className="inline-flex items-center gap-2 bg-white/75 border border-sky-200 rounded-full px-4 py-2 mb-7 shadow-sm backdrop-blur-sm">
            <Target className="w-4 h-4 text-sky-700" />
            <span className="text-sky-800 text-xs font-bold uppercase tracking-[0.16em]">Our Mission & Values</span>
          </div>
          <h1 className="font-display text-5xl sm:text-7xl font-semibold text-[#102d48] mb-7 leading-tight tracking-[-0.045em]">
            Build. Empower. Grow.
          </h1>
          <p className="text-lg sm:text-xl text-slate-600 leading-relaxed max-w-3xl mx-auto">
            SynapVex Technologies exists to put powerful, reliable software in the hands of every
            business — through the products we build and the services we deliver.
          </p>
        </div>
      </section>

      {/* Mission */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <div>
              <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-3">Why We Exist</p>
              <h2 className="font-sans text-4xl font-bold text-slate-900 mb-6">Our Mission</h2>
              <div className="space-y-5 text-slate-600 leading-relaxed">
                <p>
                  Great technology shouldn't be reserved for big enterprises. We started SynapVex to
                  give growing businesses the same calibre of software, security and strategy — without
                  the enterprise price tag or complexity.
                </p>
                <p>
                  We do it two ways: hands-on services — custom software, websites, apps, cloud and
                  cybersecurity — and a growing family of our own products, led by SynapVex Learn,
                  that let businesses and creators launch under their own brand in days, not months.
                </p>
                <p>
                  Everything we ship carries the same promise: honest communication, dependable
                  engineering, and technology that keeps working long after launch.
                </p>
              </div>
              <div className="mt-8 flex gap-4 flex-wrap">
                <Link to="/products" className="luxury-button-primary gap-2 !px-6 !py-3">
                  Explore Our Products <ArrowRight className="w-4 h-4" />
                </Link>
                <Link to="/about" className="px-6 py-3 border-2 border-slate-200 text-slate-700 font-bold rounded-xl hover:border-sky-400 hover:text-sky-600 transition-colors">
                  Our Services
                </Link>
              </div>
            </div>
            <div className="relative">
              <div className="absolute -inset-6 rounded-[2.5rem] bg-gradient-to-tr from-amber-200/40 to-sky-300/35 blur-3xl" />
              <Suspense fallback={<div className="luxury-surface relative aspect-[3/2] w-full animate-pulse rounded-[2rem] border border-white bg-amber-50" />}>
                <InteractiveOrbitalScene ariaLabel="Interactive journey from ideas to connected technology outcomes" className="luxury-surface relative aspect-[3/2] w-full border border-white bg-gradient-to-br from-amber-50 via-white to-sky-50" />
              </Suspense>
            </div>
          </div>
        </div>
      </section>

      {/* Core values */}
      <section className="py-20 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">How We Work</p>
            <h2 className="font-sans text-4xl font-bold text-slate-900 mb-4">Our Core Values</h2>
            <p className="text-slate-500 max-w-2xl mx-auto">
              Four principles guide every product we build and every engagement we take on.
            </p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {PILLARS.map((v, i) => (
              <div key={i} className={`p-6 rounded-2xl ${v.bg} border ${v.border} hover:shadow-lg transition-all duration-300 hover:-translate-y-1`}>
                <div className="w-12 h-12 rounded-xl bg-white flex items-center justify-center mb-4 shadow-sm">
                  <v.icon className={`w-6 h-6 ${v.color}`} />
                </div>
                <h3 className="font-bold text-slate-900 text-lg mb-2">{v.title}</h3>
                <p className="text-sm text-slate-600 leading-relaxed">{v.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Goals */}
      <section className="py-20 bg-slate-900 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-96 h-96 bg-sky-500/5 rounded-full blur-3xl" />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <div>
              <p className="text-sky-400 font-semibold text-sm uppercase tracking-wider mb-3">What We Aim For</p>
              <h2 className="font-sans text-4xl font-bold text-white mb-6">Our Goals</h2>
              <div className="space-y-4">
                {GOALS.map((goal, i) => (
                  <div key={i} className="flex items-start gap-3">
                    <CheckCircle className="w-5 h-5 text-sky-400 shrink-0 mt-0.5" />
                    <p className="text-slate-300">{goal}</p>
                  </div>
                ))}
              </div>
            </div>
            <div className="grid grid-cols-3 gap-4">
              {[
                { icon: Package, label: 'Products', value: 'Learn live, more building' },
                { icon: Briefcase, label: 'Services', value: '10 specialist areas' },
                { icon: Users, label: 'Support', value: 'Direct to our team' },
              ].map((stat, i) => (
                <div key={i} className="bg-white/5 border border-white/10 rounded-2xl p-6 text-center hover:bg-white/10 transition-colors">
                  <stat.icon className="w-8 h-8 text-sky-400 mx-auto mb-3" />
                  <p className="font-bold text-white mb-1">{stat.label}</p>
                  <p className="text-slate-400 text-sm">{stat.value}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-16 bg-sky-600">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="font-sans text-3xl font-bold text-white mb-4">Build the Future with Us</h2>
          <p className="text-sky-100 mb-8 text-lg">
            Whether you need a technology partner or a product to power your business, we're ready when you are.
          </p>
          <div className="flex flex-wrap gap-4 justify-center">
            <Link to="/contact" className="px-8 py-3.5 bg-white text-sky-700 font-bold rounded-xl hover:bg-sky-50 transition-colors">
              Get in Touch
            </Link>
            <Link to="/products" className="px-8 py-3.5 border-2 border-white/50 text-white font-bold rounded-xl hover:border-white hover:bg-white/10 transition-colors">
              See Our Products
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
