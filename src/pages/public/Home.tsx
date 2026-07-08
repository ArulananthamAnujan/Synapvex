import { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Code2, Globe, Smartphone, Palette, Network, Cloud, ShieldCheck,
  Headphones, BarChart2, Lightbulb, ChevronRight, ArrowRight, Mail,
  CheckCircle, BookOpen, Users, Star, Zap, Award, TrendingUp, GraduationCap,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
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

const STATS = [
  { value: '200+', label: 'Projects Delivered' },
  { value: '50+', label: 'Business Clients' },
  { value: '10+', label: 'Services Offered' },
  { value: '98%', label: 'Client Satisfaction' },
];

export default function Home() {
  const [email, setEmail] = useState('');
  const [subscribed, setSubscribed] = useState(false);
  const [activeService, setActiveService] = useState<number | null>(null);

  return (
    <div className="min-h-screen bg-white dark:bg-navy-950">
      <PublicHeader />

      {/* Hero */}
      <section className="relative min-h-screen flex items-center overflow-hidden">
        <div className="absolute inset-0">
          <img
            src="https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg"
            alt="Technology team at work"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-slate-900/95 via-slate-900/80 to-slate-900/40" />
        </div>
        <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-sky-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-sky-400/10 rounded-full blur-3xl" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-36">
          <div className="max-w-3xl">
            <div className="inline-flex items-center gap-2 bg-sky-500/20 border border-sky-500/30 rounded-full px-4 py-1.5 mb-6">
              <span className="w-2 h-2 bg-sky-400 rounded-full animate-pulse" />
              <span className="text-sky-300 text-sm font-semibold">Technology Products & Services</span>
            </div>
            <h1 className="font-playfair text-5xl sm:text-6xl lg:text-7xl font-bold text-white leading-tight mb-5">
              Powering Your<br />
              <span className="text-sky-400">Digital Future</span>
            </h1>
            <p className="text-xl text-slate-200 font-semibold mb-3">SynapVex Technologies</p>
            <p className="text-lg text-slate-300 leading-relaxed mb-10 max-w-2xl">
              We build software products businesses run on — starting with Synapvex Learn, our course
              platform — alongside full-spectrum technology services, from custom software and
              cybersecurity to cloud and digital marketing.
            </p>
            <div className="flex flex-wrap gap-4">
              <Link to="/products" className="flex items-center gap-2 px-8 py-3.5 rounded-xl bg-sky-600 hover:bg-sky-500 text-white font-bold transition-all text-base shadow-lg shadow-sky-600/30">
                Explore Our Products <ArrowRight className="w-5 h-5" />
              </Link>
              <Link to="/contact" className="flex items-center gap-2 px-8 py-3.5 rounded-xl border-2 border-white/30 text-white font-bold hover:border-white/60 hover:bg-white/10 transition-all text-base">
                Get a Free Consultation <ChevronRight className="w-5 h-5" />
              </Link>
            </div>

            <div className="flex flex-wrap gap-10 mt-14">
              {STATS.map(stat => (
                <div key={stat.label}>
                  <p className="text-3xl font-bold text-white font-playfair">{stat.value}</p>
                  <p className="text-slate-400 text-sm mt-0.5 font-medium">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Our Products */}
      <section id="products" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Our Products</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-4">One company, a growing family of products</h2>
            <p className="text-slate-500 max-w-2xl mx-auto leading-relaxed">
              Like the tools you already rely on every day, Synapvex products share one account and one
              standard of quality — starting with Synapvex Learn, live today.
            </p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {PRODUCTS.map(product => {
              const live = product.status === 'live';
              const card = (
                <div
                  className={`h-full rounded-2xl border p-6 transition-all duration-300 ${
                    live
                      ? 'border-sky-200 bg-gradient-to-b from-sky-50 to-white shadow-md hover:shadow-xl hover:-translate-y-1 ring-1 ring-sky-100'
                      : 'border-slate-100 bg-slate-50/60'
                  }`}
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${live ? product.accentBg : 'bg-slate-200'}`}>
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
              return live && product.href
                ? <Link key={product.key} to={product.href} className="block h-full">{card}</Link>
                : <div key={product.key} className="h-full">{card}</div>;
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
      <section id="services" className="py-20 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">What We Do</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-4">Our Services</h2>
            <p className="text-slate-500 max-w-2xl mx-auto leading-relaxed">
              SynapVex Technologies delivers end-to-end technology solutions designed to modernise your operations, strengthen your security, and accelerate your growth.
            </p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {SERVICES.map((svc, i) => (
              <div
                key={svc.title}
                className={`group rounded-2xl border p-6 cursor-pointer transition-all duration-300 hover:shadow-xl hover:-translate-y-1 ${svc.color} ${svc.border} ${activeService === i ? 'shadow-xl -translate-y-1' : ''}`}
                onClick={() => setActiveService(activeService === i ? null : i)}
              >
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center mb-4 ${svc.iconBg} ${svc.iconColor}`}>
                  <svc.icon className="w-6 h-6" />
                </div>
                <h3 className="font-bold text-slate-900 text-base mb-2 leading-snug">{svc.title}</h3>
                <p className="text-sm text-slate-500 leading-relaxed mb-4">{svc.desc}</p>
                <ul className={`space-y-1.5 overflow-hidden transition-all duration-300 ${activeService === i ? 'max-h-40 opacity-100' : 'max-h-0 opacity-0'}`}>
                  {svc.highlights.map(h => (
                    <li key={h} className="flex items-center gap-2 text-xs text-slate-600">
                      <CheckCircle className={`w-3.5 h-3.5 shrink-0 ${svc.iconColor}`} />
                      {h}
                    </li>
                  ))}
                </ul>
                <div className={`flex items-center gap-1 mt-3 text-xs font-semibold ${svc.iconColor}`}>
                  {activeService === i ? 'Less info' : 'Learn more'}
                  <ChevronRight className={`w-3.5 h-3.5 transition-transform ${activeService === i ? 'rotate-90' : 'group-hover:translate-x-1'}`} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Product: LMS */}
      <section className="py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-14 items-center">
            <div>
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
                <Link to="/products/learn" className="px-6 py-3 rounded-xl bg-sky-600 hover:bg-sky-700 text-white font-bold transition-colors flex items-center gap-2">
                  <GraduationCap className="w-4 h-4" /> Discover Synapvex Learn
                </Link>
                <Link to="/teach/register" className="px-6 py-3 rounded-xl border-2 border-slate-200 text-slate-700 font-bold hover:border-sky-400 hover:text-sky-600 transition-colors flex items-center gap-2">
                  <Users className="w-4 h-4" /> View Pricing Plans
                </Link>
              </div>
            </div>
            <div className="relative">
              <div className="rounded-3xl overflow-hidden shadow-2xl">
                <img
                  src="https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg"
                  alt="LMS Platform"
                  className="w-full h-96 object-cover"
                />
                <div className="absolute inset-0 rounded-3xl bg-gradient-to-t from-slate-900/60 via-transparent to-transparent" />
              </div>
              <div className="absolute bottom-6 left-6 right-6 bg-white/95 backdrop-blur-sm rounded-2xl p-4 shadow-xl border border-slate-100">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 bg-sky-600 rounded-xl flex items-center justify-center">
                    <GraduationCap className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 text-sm">Synapvex Learn</p>
                    <p className="text-xs text-slate-500">Create & Sell Courses</p>
                  </div>
                </div>
                <div className="grid grid-cols-3 gap-3 text-center">
                  {[
                    { val: 'Unlimited', lbl: 'Course Types' },
                    { val: 'AI', lbl: 'Course Builder' },
                    { val: '$29', lbl: 'From/Month' },
                  ].map(s => (
                    <div key={s.lbl} className="bg-slate-50 rounded-xl py-2">
                      <p className="font-bold text-slate-900 text-sm">{s.val}</p>
                      <p className="text-xs text-slate-400">{s.lbl}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Why Choose SynapVex */}
      <section className="py-20 relative overflow-hidden bg-slate-900">
        <div className="absolute inset-0">
          <img
            src="https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg"
            alt="Team collaborating"
            className="w-full h-full object-cover opacity-10"
          />
          <div className="absolute inset-0 bg-slate-900/90" />
        </div>
        <div className="absolute top-0 right-0 w-96 h-96 bg-sky-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 w-64 h-64 bg-sky-400/10 rounded-full blur-3xl" />
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-400 font-semibold text-sm uppercase tracking-widest mb-2">Our Difference</p>
            <h2 className="font-playfair text-4xl font-bold text-white mb-4">Why Choose SynapVex Technologies?</h2>
            <p className="text-slate-400 max-w-xl mx-auto leading-relaxed">We are a partner in your success — delivering technology that works, scales, and evolves with your business.</p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {WHY_US.map((item, i) => (
              <div key={i} className="p-6 rounded-2xl bg-white/8 border border-white/10 hover:bg-white/12 hover:border-sky-500/40 transition-all duration-300 group">
                <div className="w-11 h-11 bg-sky-500/20 border border-sky-500/30 rounded-xl flex items-center justify-center mb-4 group-hover:bg-sky-500/30 transition-colors">
                  <item.icon className="w-5 h-5 text-sky-400" />
                </div>
                <h3 className="font-bold text-white text-lg mb-2">{item.title}</h3>
                <p className="text-sm text-slate-400 leading-relaxed">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Tech Stack / Gallery */}
      <section className="py-20 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Our Work</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900">Technology in Action</h2>
            <p className="text-slate-500 mt-3 max-w-lg mx-auto">A glimpse into the environments and solutions we create for our clients.</p>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {[
              'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg',
              'https://images.pexels.com/photos/1181271/pexels-photo-1181271.jpeg',
              'https://images.pexels.com/photos/3184339/pexels-photo-3184339.jpeg',
              'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg',
              'https://images.pexels.com/photos/3861958/pexels-photo-3861958.jpeg',
              'https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg',
            ].map((src, i) => (
              <div key={i} className={`overflow-hidden rounded-2xl ${i === 0 ? 'md:col-span-2' : ''}`}>
                <img
                  src={src}
                  alt={`SynapVex work ${i + 1}`}
                  className="w-full h-52 object-cover hover:scale-105 transition-transform duration-500"
                />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonial */}
      <section className="py-20 bg-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-8">Client Stories</p>
          <div className="relative">
            <div className="w-12 h-12 bg-sky-100 rounded-2xl flex items-center justify-center mx-auto mb-6">
              <Star className="w-6 h-6 text-sky-600" />
            </div>
            <blockquote className="font-playfair text-2xl sm:text-3xl text-slate-900 font-medium leading-relaxed mb-8 italic">
              "SynapVex Technologies completely transformed our IT infrastructure. Their team is professional, responsive, and genuinely committed to delivering results."
            </blockquote>
            <div className="flex items-center justify-center gap-4">
              <div className="w-16 h-16 rounded-full overflow-hidden border-4 border-sky-100">
                <img
                  src="https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg"
                  alt="Client"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="text-left">
                <p className="font-semibold text-slate-900">James Mitchell</p>
                <p className="text-sm text-slate-500">Operations Director, TechBridge Solutions</p>
                <div className="flex items-center gap-0.5 mt-1">
                  {[1, 2, 3, 4, 5].map(i => (
                    <Star key={i} className="w-4 h-4 fill-amber-400 text-amber-400" />
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Newsletter / Contact CTA */}
      <section className="py-20 bg-sky-600">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div className="w-16 h-16 bg-white/15 rounded-2xl flex items-center justify-center mx-auto mb-6">
            <Mail className="w-8 h-8 text-white" />
          </div>
          <h2 className="font-playfair text-4xl font-bold text-white mb-4">Stay Connected</h2>
          <p className="text-sky-100 mb-8">
            Subscribe for technology insights, industry news, product updates, and exclusive offers from SynapVex Technologies.
          </p>
          {subscribed ? (
            <div className="flex items-center justify-center gap-3 text-white font-semibold">
              <CheckCircle className="w-6 h-6" />
              Thank you for subscribing! We will be in touch soon.
            </div>
          ) : (
            <form
              onSubmit={(e) => { e.preventDefault(); if (email) setSubscribed(true); }}
              className="flex flex-col sm:flex-row gap-3 max-w-lg mx-auto"
            >
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="Enter your email address"
                required
                className="flex-1 px-5 py-3.5 rounded-xl bg-white/15 border border-white/30 text-white placeholder:text-sky-200 focus:outline-none focus:border-white focus:bg-white/20 transition-colors"
              />
              <button type="submit" className="px-6 py-3.5 bg-white text-sky-700 font-bold rounded-xl hover:bg-sky-50 transition-colors whitespace-nowrap flex items-center gap-2">
                Subscribe <ArrowRight className="w-4 h-4" />
              </button>
            </form>
          )}
          <p className="text-sky-200 text-xs mt-4">We respect your privacy. Unsubscribe at any time.</p>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="py-16 bg-slate-900 relative overflow-hidden">
        <div className="absolute inset-0">
          <img src="https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg" alt="Technology" className="w-full h-full object-cover opacity-10" />
        </div>
        <div className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="font-playfair text-3xl sm:text-4xl font-bold text-white mb-4">
            Ready to Transform Your Business with Technology?
          </h2>
          <p className="text-slate-300 mb-8 text-lg max-w-2xl mx-auto">
            Partner with SynapVex Technologies for innovative, reliable, and cost-effective IT solutions that drive real results.
          </p>
          <div className="flex flex-wrap gap-4 justify-center">
            <Link to="/contact" className="px-8 py-3.5 bg-sky-600 hover:bg-sky-500 text-white font-bold rounded-xl transition-colors flex items-center gap-2">
              <Zap className="w-5 h-5" /> Get a Free Consultation
            </Link>
            <Link to="/teach" className="px-8 py-3.5 border-2 border-white/30 text-white font-bold rounded-xl hover:border-white/60 hover:bg-white/10 transition-colors flex items-center gap-2">
              <BookOpen className="w-5 h-5" /> Start Creating Courses
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
