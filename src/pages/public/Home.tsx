import { Link } from 'react-router-dom';
import {
  Code2, Globe, Smartphone, Palette, Network, Cloud, ShieldCheck,
  Headphones, BarChart2, Lightbulb, ChevronRight, ArrowRight,
  CheckCircle, BookOpen, Users, Zap, Award, TrendingUp, GraduationCap, Sparkles,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';
import { PRODUCTS } from '../../lib/products';

const SERVICES = [
  {
    icon: Code2,
    title: 'Software Development',
    desc: 'Custom software solutions designed to streamline business operations, improve productivity, and support growth.',
    color: 'bg-sky-50',
    iconBg: 'bg-sky-100',
    iconColor: 'text-sky-600',
    border: 'border-sky-100',
    highlights: ['Custom Business Applications', 'SaaS Product Development', 'API Development & Integration', 'ERP & CRM Solutions'],
  },
  {
    icon: Globe,
    title: 'Website Design & Development',
    desc: 'Professional, responsive, and user-friendly websites tailored to your business needs and brand identity.',
    color: 'bg-emerald-50',
    iconBg: 'bg-emerald-100',
    iconColor: 'text-emerald-600',
    border: 'border-emerald-100',
    highlights: ['Corporate & E-commerce Websites', 'Custom Web Applications', 'WordPress Development', 'SEO Optimisation'],
  },
  {
    icon: Smartphone,
    title: 'Mobile App Development',
    desc: 'Innovative mobile applications for businesses seeking to engage customers and improve accessibility.',
    color: 'bg-violet-50',
    iconBg: 'bg-violet-100',
    iconColor: 'text-violet-600',
    border: 'border-violet-100',
    highlights: ['iOS App Development', 'Android App Development', 'Cross-Platform Apps', 'Business Process Automation'],
  },
  {
    icon: Palette,
    title: 'Graphic Design & Branding',
    desc: 'Creative design solutions that strengthen your brand identity and elevate your marketing presence.',
    color: 'bg-amber-50',
    iconBg: 'bg-amber-100',
    iconColor: 'text-amber-600',
    border: 'border-amber-100',
    highlights: ['Logo & Corporate Branding', 'Marketing Materials', 'Social Media Graphics', 'UI/UX Design'],
  },
  {
    icon: Network,
    title: 'Network Solutions',
    desc: 'Reliable network infrastructure and support services to keep your business connected and secure.',
    color: 'bg-cyan-50',
    iconBg: 'bg-cyan-100',
    iconColor: 'text-cyan-600',
    border: 'border-cyan-100',
    highlights: ['Network Design & Implementation', 'LAN/WAN Setup', 'VPN Configuration', 'Structured Cabling'],
  },
  {
    icon: Cloud,
    title: 'Cloud Solutions',
    desc: 'Flexible and scalable cloud services to improve collaboration, security, and operational efficiency.',
    color: 'bg-blue-50',
    iconBg: 'bg-blue-100',
    iconColor: 'text-blue-600',
    border: 'border-blue-100',
    highlights: ['Cloud Migration', 'Microsoft 365 & Google Workspace', 'Cloud Infrastructure Management', 'Backup & Disaster Recovery'],
  },
  {
    icon: ShieldCheck,
    title: 'Cybersecurity Services',
    desc: 'Protecting businesses from cyber threats through proactive security measures and best practices.',
    color: 'bg-rose-50',
    iconBg: 'bg-rose-100',
    iconColor: 'text-rose-600',
    border: 'border-rose-100',
    highlights: ['Security Assessments', 'Vulnerability Testing', 'Endpoint Protection', 'Incident Response Support'],
  },
  {
    icon: Headphones,
    title: 'IT Support & Managed Services',
    desc: 'Comprehensive IT support to ensure your technology operates smoothly and efficiently at all times.',
    color: 'bg-teal-50',
    iconBg: 'bg-teal-100',
    iconColor: 'text-teal-600',
    border: 'border-teal-100',
    highlights: ['Help Desk Support', 'Remote & On-Site Support', 'Server Administration', 'Managed IT Services'],
  },
  {
    icon: BarChart2,
    title: 'Digital Marketing',
    desc: 'Helping businesses increase visibility and generate leads through strategic digital marketing.',
    color: 'bg-orange-50',
    iconBg: 'bg-orange-100',
    iconColor: 'text-orange-600',
    border: 'border-orange-100',
    highlights: ['SEO & Content Marketing', 'Social Media Marketing', 'PPC Advertising', 'Email Marketing'],
  },
  {
    icon: Lightbulb,
    title: 'IT Consulting',
    desc: 'Expert advice to help businesses leverage technology for growth, efficiency, and innovation.',
    color: 'bg-yellow-50',
    iconBg: 'bg-yellow-100',
    iconColor: 'text-yellow-600',
    border: 'border-yellow-100',
    highlights: ['Technology Strategy & Planning', 'Digital Transformation', 'IT Project Management', 'Business Process Automation'],
    link: null,
  },
];

const WHY_US = [
  { icon: Users, title: 'Experienced Professionals', desc: 'A team of certified technology experts with deep industry knowledge across all service areas.' },
  { icon: Zap, title: 'Customised Solutions', desc: 'We tailor every solution to your unique business goals — no one-size-fits-all approaches.' },
  { icon: Globe, title: 'End-to-End IT Services', desc: 'From consulting and design through deployment and ongoing support, we cover the full technology lifecycle.' },
  { icon: ShieldCheck, title: 'Security & Performance Focus', desc: 'We build with security and performance at the core, not as an afterthought.' },
  { icon: TrendingUp, title: 'Scalable & Future-Ready', desc: 'Solutions designed to grow with your business, adapting to new challenges and opportunities.' },
  { icon: Award, title: 'Transparent Communication', desc: 'Competitive pricing, clear timelines, and honest communication throughout every engagement.' },
];

export default function Home() {
  return (
    <div className="min-h-screen bg-white dark:bg-navy-950">
      <PublicHeader />

      {/* Hero */}
      <section className="relative min-h-screen flex items-center overflow-hidden bg-mesh">
        <div className="absolute inset-0 bg-grid" />
        {/* animated ambient blobs */}
        <div className="absolute top-[-8rem] right-[-6rem] w-[36rem] h-[36rem] bg-sky-500/20 rounded-full blur-3xl animate-blob" />
        <div className="absolute bottom-[-10rem] left-[-6rem] w-[30rem] h-[30rem] bg-indigo-500/20 rounded-full blur-3xl animate-blob" style={{ animationDelay: '6s' }} />
        <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-transparent to-slate-950/40" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-32 lg:py-40 w-full">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Left: copy */}
            <div>
              <div className="inline-flex items-center gap-2 glass-card rounded-full px-4 py-1.5 mb-6 animate-rise">
                <span className="w-2 h-2 bg-sky-400 rounded-full animate-pulse" />
                <span className="text-sky-200 text-sm font-semibold">Technology Products &amp; Services</span>
              </div>
              <h1 className="font-playfair text-5xl sm:text-6xl lg:text-7xl font-bold text-white leading-[1.05] mb-5 animate-rise" style={{ animationDelay: '80ms' }}>
                Powering Your<br />
                <span className="text-gradient-sky">Digital Future</span>
              </h1>
              <p className="text-lg text-slate-300 leading-relaxed mb-9 max-w-xl animate-rise" style={{ animationDelay: '160ms' }}>
                We build software products businesses run on — led by Synapvex Learn — and deliver
                the technology services to match.
              </p>
              <div className="flex flex-wrap gap-4 animate-rise" style={{ animationDelay: '240ms' }}>
                <Link to="/products" className="group flex items-center gap-2 px-8 py-3.5 rounded-xl bg-sky-500 hover:bg-sky-400 text-white font-bold transition-all text-base shadow-lg shadow-sky-500/30 hover:shadow-sky-500/50 hover:-translate-y-0.5">
                  Explore Our Products <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </Link>
                <Link to="/contact" className="flex items-center gap-2 px-8 py-3.5 rounded-xl glass-card text-white font-bold hover:bg-white/15 transition-all text-base">
                  Get a Free Consultation <ChevronRight className="w-5 h-5" />
                </Link>
              </div>
            </div>

            {/* Right: floating product-family mockup */}
            <div className="hidden lg:block animate-rise" style={{ animationDelay: '320ms' }}>
              <div className="relative animate-float-slow">
                {/* soft glow behind the panel */}
                <div className="absolute -inset-6 bg-gradient-to-tr from-sky-500/30 via-blue-500/20 to-indigo-500/20 blur-3xl rounded-[2.5rem]" />

                <div className="relative rounded-[1.75rem] p-[1px] bg-gradient-to-b from-white/25 to-white/5 shadow-2xl">
                  <div className="rounded-[1.7rem] bg-slate-900/80 backdrop-blur-xl p-6">
                    {/* header */}
                    <div className="flex items-center justify-between mb-5">
                      <div className="flex items-center gap-2.5">
                        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-sky-400 to-blue-600 flex items-center justify-center font-black text-white text-sm shadow-lg shadow-sky-500/30">S</div>
                        <span className="text-white font-bold text-[15px]">Synapvex Product Family</span>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      {PRODUCTS.slice(0, 4).map(p => {
                        const live = p.status === 'live';
                        return (
                          <div
                            key={p.key}
                            className={`relative rounded-2xl p-4 border transition-colors ${
                              live
                                ? 'border-sky-400/40 bg-gradient-to-br from-sky-500/15 to-indigo-500/10 shadow-lg shadow-sky-500/10'
                                : 'border-white/10 bg-white/[0.03]'
                            }`}
                          >
                            {/* status pill */}
                            <span className={`absolute top-3 right-3 text-[8px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded-full ${
                              live ? 'bg-emerald-400/20 text-emerald-300' : 'bg-white/10 text-slate-400'
                            }`}>
                              {live ? 'Live' : 'Soon'}
                            </span>
                            <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-3 ${
                              live ? `bg-gradient-to-br ${p.gradient} shadow-lg` : 'bg-white/[0.06]'
                            }`}>
                              <p.icon className={`w-5 h-5 ${live ? 'text-white' : 'text-slate-400'}`} />
                            </div>
                            <p className={`text-[13px] font-bold leading-tight ${live ? 'text-white' : 'text-slate-300'}`}>{p.name}</p>
                            <p className="text-slate-400 text-[10px] mt-1 leading-snug line-clamp-2">{p.tagline}</p>
                          </div>
                        );
                      })}
                    </div>

                    {/* free-trial strip inside the panel */}
                    <div className="mt-4 flex items-center justify-between rounded-2xl bg-gradient-to-r from-sky-500/20 to-transparent border border-sky-400/25 px-4 py-3">
                      <div className="flex items-center gap-2.5">
                        <Sparkles className="w-4 h-4 text-sky-300 shrink-0" />
                        <p className="text-[13px] text-white font-semibold">Synapvex Learn — free trial</p>
                      </div>
                      <span className="text-[11px] text-sky-300 font-bold whitespace-nowrap">No card →</span>
                    </div>
                  </div>
                </div>

                {/* floating accent chip */}
                <div className="absolute -bottom-5 -left-5 rounded-2xl bg-white px-4 py-3 shadow-2xl animate-float" style={{ animationDelay: '1.5s' }}>
                  <div className="flex items-center gap-2.5">
                    <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-sky-500 to-blue-700 flex items-center justify-center">
                      <GraduationCap className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="text-slate-900 text-sm font-bold leading-none">Start teaching free</p>
                      <p className="text-slate-400 text-[11px] mt-1">Free AI credits included</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Our Products */}
      <section id="products" className="py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <Reveal className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Our Products</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-4">One company, a growing family of products</h2>
            <p className="text-slate-500 max-w-2xl mx-auto leading-relaxed">
              Like the tools you already rely on every day, Synapvex products share one account and one
              standard of quality — starting with Synapvex Learn, live today.
            </p>
          </Reveal>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {PRODUCTS.map((product, idx) => {
              const live = product.status === 'live';
              const card = (
                <div
                  className={`h-full rounded-2xl border p-6 transition-all duration-300 ${
                    live
                      ? 'border-sky-200 bg-gradient-to-b from-sky-50 to-white shadow-md hover:shadow-2xl hover:-translate-y-1.5 ring-1 ring-sky-100'
                      : 'border-slate-100 bg-slate-50/60 hover:shadow-lg hover:-translate-y-0.5'
                  }`}
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center transition-transform duration-300 group-hover:scale-110 ${live ? product.accentBg : 'bg-slate-200'}`}>
                      <product.icon className={`w-6 h-6 ${live ? 'text-white' : 'text-slate-500'}`} />
                    </div>
                    {live ? (
                      <span className="bg-emerald-100 text-emerald-700 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider">Live</span>
                    ) : (
                      <span className="bg-slate-200 text-slate-500 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider">Coming Soon</span>
                    )}
                  </div>
                  <h3 className={`font-bold text-base mb-1 ${live ? 'text-slate-900' : 'text-slate-600'}`}>{product.name}</h3>
                  <p className={`text-sm leading-relaxed ${live ? 'text-slate-500' : 'text-slate-400'}`}>{product.tagline}</p>
                  {live && (
                    <span className="inline-flex items-center gap-1 mt-4 text-xs font-bold text-sky-600">
                      Explore <ArrowRight className="w-3.5 h-3.5" />
                    </span>
                  )}
                </div>
              );
              return (
                <Reveal key={product.key} delay={idx * 90} className="group h-full">
                  {live && product.href
                    ? <Link to={product.href} className="block h-full">{card}</Link>
                    : <div className="h-full">{card}</div>}
                </Reveal>
              );
            })}
          </div>
          <div className="text-center mt-10">
            <Link to="/products" className="inline-flex items-center gap-2 text-sm font-bold text-sky-600 hover:text-sky-700 transition-colors">
              See all products <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </section>

      {/* Services Overview */}
      <section id="services" className="py-24 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <Reveal className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">What We Do</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-4">Our Services</h2>
            <p className="text-slate-500 max-w-xl mx-auto leading-relaxed">
              End-to-end technology solutions to modernise, secure and grow your business.
            </p>
          </Reveal>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {SERVICES.map((svc, i) => (
              <Reveal
                as="div"
                key={svc.title}
                delay={(i % 4) * 70}
                className={`group rounded-2xl border p-6 transition-all duration-300 hover:shadow-lg hover:-translate-y-1 ${svc.color} ${svc.border}`}
              >
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center mb-4 ${svc.iconBg} ${svc.iconColor}`}>
                  <svc.icon className="w-6 h-6" />
                </div>
                <h3 className="font-bold text-slate-900 text-base mb-1.5 leading-snug">{svc.title}</h3>
                <p className="text-sm text-slate-500 leading-relaxed">{svc.desc}</p>
              </Reveal>
            ))}
          </div>
          <Reveal className="text-center mt-10">
            <Link to="/about" className="inline-flex items-center gap-2 text-sm font-bold text-sky-600 hover:text-sky-700 transition-colors">
              See all services <ArrowRight className="w-4 h-4" />
            </Link>
          </Reveal>
        </div>
      </section>

      {/* Featured Product: LMS */}
      <section className="py-24 bg-gradient-to-b from-white to-slate-50 overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-14 items-center">
            <Reveal direction="right">
              <div className="inline-flex items-center gap-2 bg-sky-50 border border-sky-200 rounded-full px-4 py-1.5 mb-5">
                <BookOpen className="w-4 h-4 text-sky-600" />
                <span className="text-sky-700 text-sm font-semibold">Flagship Product · Live Now</span>
              </div>
              <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-5 leading-tight">
                Synapvex Learn —<br />
                <span className="text-sky-600">Sell courses from your own website</span>
              </h2>
              <p className="text-slate-500 leading-relaxed mb-6">
                Built for independent teachers, academies and corporate trainers. Create your courses
                here, get your own branded course page with your logo and colors, and share one link
                from your website — your students land on <em>your</em> page, enrol, pay and learn,
                while Synapvex runs everything behind the scenes.
              </p>
              <div className="grid sm:grid-cols-2 gap-3 mb-8">
                {[
                  'Your own branded course page',
                  'AI-powered course & quiz builder',
                  'One link from your website — students enrol directly',
                  'Set your price & collect payments',
                  'Automated certificate generation',
                  'Quizzes, exams & assignments',
                  'Student progress tracking & analytics',
                  'Live session booking',
                ].map((f, i) => (
                  <div key={i} className="flex items-center gap-2.5">
                    <CheckCircle className="w-4 h-4 text-sky-500 shrink-0" />
                    <span className="text-sm text-slate-700">{f}</span>
                  </div>
                ))}
              </div>
              <div className="flex flex-wrap gap-4">
                <Link to="/products/learn" className="group px-6 py-3 rounded-xl bg-sky-600 hover:bg-sky-700 text-white font-bold transition-all hover:-translate-y-0.5 shadow-lg shadow-sky-600/25 flex items-center gap-2">
                  <GraduationCap className="w-4 h-4" /> Discover Synapvex Learn
                </Link>
                <Link to="/products" className="px-6 py-3 rounded-xl border-2 border-slate-200 text-slate-700 font-bold hover:border-sky-400 hover:text-sky-600 transition-colors flex items-center gap-2">
                  <Users className="w-4 h-4" /> View All Products
                </Link>
              </div>
            </Reveal>

            {/* Designed browser mockup of a branded course storefront */}
            <Reveal direction="left" delay={120} className="relative">
              <div className="absolute -inset-6 bg-gradient-to-tr from-sky-400/20 to-indigo-400/20 blur-3xl rounded-[2.5rem]" />
              <div className="relative rounded-3xl bg-white border border-slate-200 shadow-2xl overflow-hidden animate-float-slow">
                {/* browser chrome */}
                <div className="flex items-center gap-2 px-4 py-3 bg-slate-100 border-b border-slate-200">
                  <span className="w-3 h-3 rounded-full bg-red-400" />
                  <span className="w-3 h-3 rounded-full bg-amber-400" />
                  <span className="w-3 h-3 rounded-full bg-emerald-400" />
                  <div className="ml-3 flex items-center gap-1.5 bg-white rounded-md px-3 py-1 text-xs text-slate-400 flex-1 truncate">
                    synapvex.com/school/<span className="text-slate-700 font-semibold">your-academy</span>
                  </div>
                </div>
                {/* branded hero */}
                <div className="px-6 py-8 text-center bg-gradient-to-br from-sky-600 to-indigo-700">
                  <div className="w-12 h-12 bg-white rounded-2xl mx-auto mb-3 flex items-center justify-center font-black text-sky-600 text-xl shadow-lg">Y</div>
                  <p className="text-white font-bold text-lg">Your Academy</p>
                  <p className="text-white/70 text-xs">Your logo · Your colors · Your courses</p>
                </div>
                {/* course grid */}
                <div className="p-5 grid grid-cols-3 gap-3">
                  {['Fundamentals', 'Advanced', 'Masterclass'].map((c, i) => (
                    <div key={c} className="rounded-xl border border-slate-100 overflow-hidden shadow-sm">
                      <div className={`h-16 bg-gradient-to-br ${['from-sky-100 to-sky-50', 'from-indigo-100 to-indigo-50', 'from-emerald-100 to-emerald-50'][i]}`} />
                      <div className="p-2">
                        <p className="text-[10px] font-bold text-slate-700 truncate">{c}</p>
                        <p className="text-[9px] text-sky-600 font-bold mt-1">Enrol →</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              {/* floating stat chip */}
              <div className="absolute -bottom-5 -left-5 bg-white rounded-2xl px-4 py-3 shadow-xl border border-slate-100 animate-float" style={{ animationDelay: '2s' }}>
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 bg-sky-600 rounded-xl flex items-center justify-center">
                    <GraduationCap className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 text-sm leading-none">From $29/mo</p>
                    <p className="text-xs text-slate-400 mt-0.5">Students join free</p>
                  </div>
                </div>
              </div>
            </Reveal>
          </div>
        </div>
      </section>

      {/* Why Choose SynapVex */}
      <section className="py-24 relative overflow-hidden bg-mesh">
        <div className="absolute inset-0 bg-grid" />
        <div className="absolute top-0 right-0 w-96 h-96 bg-sky-500/15 rounded-full blur-3xl animate-blob" />
        <div className="absolute bottom-0 left-0 w-72 h-72 bg-indigo-500/15 rounded-full blur-3xl animate-blob" style={{ animationDelay: '5s' }} />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <Reveal className="text-center mb-14">
            <p className="text-sky-400 font-semibold text-sm uppercase tracking-widest mb-2">Our Difference</p>
            <h2 className="font-playfair text-4xl font-bold text-white mb-4">Why Choose SynapVex Technologies?</h2>
            <p className="text-slate-400 max-w-xl mx-auto leading-relaxed">We are a partner in your success — delivering technology that works, scales, and evolves with your business.</p>
          </Reveal>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {WHY_US.map((item, i) => (
              <Reveal as="div" key={i} delay={(i % 3) * 90} className="p-6 rounded-2xl glass-card hover:bg-white/12 hover:border-sky-500/40 transition-all duration-300 group hover:-translate-y-1">
                <div className="w-11 h-11 bg-sky-500/20 border border-sky-500/30 rounded-xl flex items-center justify-center mb-4 group-hover:bg-sky-500/30 group-hover:scale-110 transition-all">
                  <item.icon className="w-5 h-5 text-sky-400" />
                </div>
                <h3 className="font-bold text-white text-lg mb-2">{item.title}</h3>
                <p className="text-sm text-slate-400 leading-relaxed">{item.desc}</p>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="py-20 bg-mesh relative overflow-hidden">
        <div className="absolute inset-0 bg-grid" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[40rem] h-[40rem] bg-sky-500/10 rounded-full blur-3xl animate-blob" />
        <Reveal className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="font-playfair text-3xl sm:text-4xl font-bold text-white mb-4">
            Ready to Transform Your Business with Technology?
          </h2>
          <p className="text-slate-300 mb-8 text-lg max-w-2xl mx-auto">
            Partner with SynapVex Technologies for innovative, reliable, and cost-effective IT solutions that drive real results.
          </p>
          <div className="flex flex-wrap gap-4 justify-center">
            <Link to="/contact" className="px-8 py-3.5 bg-sky-500 hover:bg-sky-400 text-white font-bold rounded-xl transition-all hover:-translate-y-0.5 shadow-lg shadow-sky-500/30 flex items-center gap-2">
              <Zap className="w-5 h-5" /> Get a Free Consultation
            </Link>
            <Link to="/products" className="px-8 py-3.5 glass-card text-white font-bold rounded-xl hover:bg-white/15 transition-colors flex items-center gap-2">
              <BookOpen className="w-5 h-5" /> Explore Our Products
            </Link>
          </div>
        </Reveal>
      </section>

      <PublicFooter />
    </div>
  );
}
