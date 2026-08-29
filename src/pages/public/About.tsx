import {
  Code2, Globe, Smartphone, Palette, Network, Cloud, ShieldCheck,
  Headphones, BarChart2, Lightbulb, GraduationCap, CheckCircle, ArrowRight,
  Users, Zap, Award, TrendingUp,
} from 'lucide-react';
import { Link } from 'react-router-dom';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';

const SERVICES = [
  {
    icon: Code2,
    title: 'Software Development',
    color: 'text-sky-600', bg: 'bg-sky-50', border: 'border-sky-100',
    items: [
      'Custom Business Applications',
      'Enterprise Software Solutions',
      'CRM & ERP Development',
      'SaaS Product Development',
      'API Development & Integration',
      'Software Maintenance & Support',
    ],
  },
  {
    icon: Globe,
    title: 'Website Design & Development',
    color: 'text-emerald-600', bg: 'bg-emerald-50', border: 'border-emerald-100',
    items: [
      'Corporate Websites',
      'E-commerce Websites',
      'Custom Web Applications',
      'WordPress Development',
      'Website Redesign & Modernization',
      'Website Maintenance & Hosting',
      'Search Engine Optimization (SEO)',
    ],
  },
  {
    icon: Smartphone,
    title: 'Mobile App Development',
    color: 'text-violet-600', bg: 'bg-violet-50', border: 'border-violet-100',
    items: [
      'iOS App Development',
      'Android App Development',
      'Cross-Platform App Development',
      'Business Process Automation Apps',
      'App Maintenance & Updates',
    ],
  },
  {
    icon: Palette,
    title: 'Graphic Design & Branding',
    color: 'text-amber-600', bg: 'bg-amber-50', border: 'border-amber-100',
    items: [
      'Logo Design',
      'Corporate Branding',
      'Marketing Materials',
      'Social Media Graphics',
      'Brochures & Flyers',
      'Business Cards',
      'Presentation Design',
      'UI/UX Design',
    ],
  },
  {
    icon: Network,
    title: 'Network Solutions',
    color: 'text-cyan-600', bg: 'bg-cyan-50', border: 'border-cyan-100',
    items: [
      'Network Design & Implementation',
      'LAN/WAN Setup',
      'Wireless Network Solutions',
      'Network Monitoring',
      'VPN Configuration',
      'Structured Cabling',
      'Network Troubleshooting & Support',
    ],
  },
  {
    icon: Cloud,
    title: 'Cloud Solutions',
    color: 'text-blue-600', bg: 'bg-blue-50', border: 'border-blue-100',
    items: [
      'Cloud Migration',
      'Microsoft 365 Solutions',
      'Google Workspace Setup',
      'Cloud Infrastructure Management',
      'Backup & Disaster Recovery',
      'Cloud Security Services',
    ],
  },
  {
    icon: ShieldCheck,
    title: 'Cybersecurity Services',
    color: 'text-rose-600', bg: 'bg-rose-50', border: 'border-rose-100',
    items: [
      'Security Assessments',
      'Vulnerability Testing',
      'Endpoint Protection',
      'Firewall Configuration',
      'Data Protection Solutions',
      'Security Awareness Training',
      'Incident Response Support',
    ],
  },
  {
    icon: Headphones,
    title: 'IT Support & Managed Services',
    color: 'text-teal-600', bg: 'bg-teal-50', border: 'border-teal-100',
    items: [
      'Help Desk Support',
      'Remote & On-Site Support',
      'Server Administration',
      'System Monitoring',
      'IT Infrastructure Management',
      'Hardware & Software Support',
      'Managed IT Services',
    ],
  },
  {
    icon: BarChart2,
    title: 'Digital Marketing',
    color: 'text-orange-600', bg: 'bg-orange-50', border: 'border-orange-100',
    items: [
      'Search Engine Optimization (SEO)',
      'Social Media Marketing',
      'Pay-Per-Click Advertising (PPC)',
      'Content Marketing',
      'Email Marketing',
      'Online Reputation Management',
    ],
  },
  {
    icon: Lightbulb,
    title: 'IT Consulting',
    color: 'text-yellow-600', bg: 'bg-yellow-50', border: 'border-yellow-100',
    items: [
      'Technology Strategy & Planning',
      'Digital Transformation',
      'IT Project Management',
      'Business Process Automation',
      'Infrastructure Assessment',
      'Technology Procurement Advice',
    ],
  },
];

const WHY_US = [
  { icon: Users, title: 'Experienced Technology Professionals', desc: 'Certified experts with deep hands-on knowledge across all major IT disciplines.' },
  { icon: Zap, title: 'Customised Solutions for Every Business', desc: 'We design solutions around your specific goals, not templates.' },
  { icon: Globe, title: 'End-to-End IT Services', desc: 'From strategy through deployment and ongoing support — one partner for everything.' },
  { icon: ShieldCheck, title: 'Reliable Support & Maintenance', desc: 'Proactive monitoring, fast response times, and dedicated account management.' },
  { icon: TrendingUp, title: 'Scalable and Future-Ready Solutions', desc: 'Built to grow with your business and adapt to new technology landscapes.' },
  { icon: Award, title: 'Competitive Pricing & Transparency', desc: 'Honest communication, clear scopes, and no hidden fees — ever.' },
];

export default function About() {
  return (
    <div className="bg-white min-h-screen">
      <PublicHeader />
      <div className="pt-20 lg:pt-24">

        {/* Hero */}
        <section className="premium-page-hero py-28 sm:py-36">
          <div className="absolute inset-0 corporate-grid opacity-30" />
          <div className="absolute top-[-6rem] right-[-4rem] w-[30rem] h-[30rem] bg-sky-400/20 rounded-full blur-3xl animate-blob" />
          <div className="absolute bottom-[-8rem] left-[-4rem] w-[26rem] h-[26rem] bg-amber-300/20 rounded-full blur-3xl animate-blob" style={{ animationDelay: '5s' }} />
          <div className="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p className="text-sky-800 font-bold text-xs uppercase tracking-[0.2em] mb-5">SynapVex Technologies</p>
            <h1 className="font-display text-5xl sm:text-7xl font-semibold text-[#102d48] mb-7 leading-[1.02] tracking-[-0.05em]">
              Expertise with <span className="bg-gradient-to-r from-sky-700 to-amber-500 bg-clip-text text-transparent">executive-level polish.</span>
            </h1>
            <p className="text-slate-600 text-lg sm:text-xl leading-relaxed max-w-3xl mx-auto">
              Full-spectrum technology solutions for businesses of every size — from custom software and cybersecurity to cloud infrastructure, digital marketing, and our own LMS platform.
            </p>
            <div className="flex flex-wrap justify-center gap-4 mt-8">
              <Link to="/contact" className="luxury-button-primary gap-2">
                Get a Free Consultation <ArrowRight className="w-4 h-4" />
              </Link>
              <Link to="/products" className="luxury-button-light gap-2">
                <GraduationCap className="w-4 h-4" /> Explore Our Products
              </Link>
            </div>
          </div>
        </section>

        <section className="bg-white py-24 sm:py-32">
          <div className="mx-auto grid max-w-7xl items-center gap-14 px-4 sm:px-6 lg:grid-cols-[1.12fr_0.88fr] lg:px-8">
            <div className="relative">
              <div className="absolute -inset-6 rounded-[2.5rem] bg-gradient-to-tr from-sky-300/35 to-amber-200/30 blur-3xl" />
              <img src="/images/luxury/connected-capabilities.webp" alt="Connected cloud, software and security architecture" width="1536" height="1024" loading="eager" fetchPriority="high" decoding="async" className="luxury-surface relative aspect-[3/2] w-full rounded-[2rem] border border-white object-cover" />
            </div>
            <div>
              <p className="corporate-eyebrow">Connected by design</p>
              <h2 className="corporate-heading mt-4">Serious technical depth without fragmented delivery.</h2>
              <p className="mt-6 text-base leading-8 text-slate-600">Software, infrastructure, security and support are treated as one connected operating system. That reduces handoffs, makes ownership clearer and produces technology built to last.</p>
            </div>
          </div>
        </section>

        {/* All Services Grid */}
        <section className="py-24 bg-gradient-to-b from-slate-950 via-[#071327] to-slate-950 text-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-14">
              <p className="text-sky-300 font-semibold text-sm uppercase tracking-[0.22em] mb-3">What We Offer</p>
              <h2 className="font-sans text-4xl sm:text-5xl font-bold text-white mb-4 tracking-[-0.04em]">One partner. Serious technical depth.</h2>
              <p className="text-slate-300 max-w-2xl mx-auto leading-relaxed">
                Every service is delivered by specialists with deep domain expertise, focused on solving your real business challenges.
              </p>
            </div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {SERVICES.map((svc, idx) => (
                <div
                  key={svc.title}
                  className="group relative overflow-hidden rounded-3xl border border-white/10 bg-white/[0.06] p-7 shadow-2xl shadow-black/10 backdrop-blur-sm transition-all duration-300 hover:-translate-y-1.5 hover:border-sky-400/40 hover:bg-white/[0.09]"
                >
                  <div className="absolute -right-16 -top-16 h-36 w-36 rounded-full bg-sky-500/10 blur-3xl transition-colors group-hover:bg-cyan-400/20" />
                  <div className="flex items-center gap-3 mb-4">
                    <div className="w-12 h-12 bg-white/10 border border-white/10 rounded-2xl flex items-center justify-center shadow-sm shrink-0">
                      <svc.icon className={`w-5 h-5 ${svc.color}`} />
                    </div>
                    <span className={`text-xs font-bold uppercase tracking-wider ${svc.color}`}>0{idx + 1}</span>
                  </div>
                  <h3 className="font-bold text-white text-lg mb-4">{svc.title}</h3>
                  <ul className="space-y-2">
                    {svc.items.map(item => (
                      <li key={item} className="flex items-start gap-2 text-sm text-slate-300">
                        <CheckCircle className={`w-4 h-4 shrink-0 mt-0.5 ${svc.color}`} />
                        {item}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}

              {/* LMS Platform — Featured */}
              <div className="rounded-2xl border-2 border-sky-400 p-6 bg-white shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 relative overflow-hidden sm:col-span-2 lg:col-span-1">
                <div className="absolute top-4 right-4 bg-sky-600 text-white text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wider">
                  Our Product
                </div>
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-11 h-11 bg-sky-600 rounded-xl flex items-center justify-center shadow-sm shrink-0">
                    <GraduationCap className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-xs font-bold uppercase tracking-wider text-sky-600">11</span>
                </div>
                <h3 className="font-bold text-slate-900 text-lg mb-1">LMS Platform</h3>
                <p className="text-sm text-slate-500 mb-3 leading-relaxed">
                  SynapVex Learn is our own SaaS-based Learning Management System. Create courses, enrol students, run quizzes, issue certificates — and use AI to generate entire curricula in minutes.
                </p>
                <ul className="space-y-2 mb-5">
                  {[
                    'Create & publish online courses',
                    'AI-powered course & quiz builder',
                    'Student portal with progress tracking',
                    'Quizzes, exams & auto-grading',
                    'Automated certificate issuance',
                    'Secure enrolment & access control',
                    'Multi-role: Admin, Teacher, Student',
                    'Organisation & team management',
                  ].map(item => (
                    <li key={item} className="flex items-start gap-2 text-sm text-slate-600">
                      <CheckCircle className="w-4 h-4 shrink-0 mt-0.5 text-sky-600" />
                      {item}
                    </li>
                  ))}
                </ul>
                <Link
                  to="/products/learn"
                  className="luxury-button-primary w-full gap-2 !px-5 !py-3"
                >
                  <GraduationCap className="w-4 h-4" /> Discover SynapVex Learn <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            </div>
          </div>
        </section>

        {/* Why Choose SynapVex */}
        <section className="py-20 bg-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-14">
              <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Why SynapVex</p>
              <h2 className="font-sans text-4xl font-bold text-slate-900 mb-4">Why Choose SynapVex Technologies?</h2>
            </div>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {WHY_US.map((item) => (
                <div key={item.title} className="flex gap-4 p-5 rounded-2xl border border-slate-100 hover:border-sky-200 hover:shadow-md transition-all">
                  <div className="w-10 h-10 bg-sky-50 rounded-xl flex items-center justify-center shrink-0 mt-0.5">
                    <item.icon className="w-5 h-5 text-sky-600" />
                  </div>
                  <div>
                    <h3 className="font-bold text-slate-900 mb-1">{item.title}</h3>
                    <p className="text-sm text-slate-500 leading-relaxed">{item.desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="py-20 bg-slate-900 relative overflow-hidden">
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,rgba(14,165,233,0.12),transparent_60%)]" />
          <div className="relative max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 className="font-sans text-4xl font-bold text-white mb-5">
              Ready to Partner with SynapVex?
            </h2>
            <p className="text-slate-300 text-lg mb-8 leading-relaxed">
              Whether you need custom software, IT support, or want to launch your own online learning platform — we are here to help.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                to="/contact"
                className="luxury-button-primary gap-2 !px-8 !py-3.5"
              >
                Get a Free Consultation <ArrowRight className="w-4 h-4" />
              </Link>
              <Link
                to="/products"
                className="px-8 py-3.5 border-2 border-white/30 text-white font-bold rounded-xl hover:border-white/60 hover:bg-white/10 transition-colors flex items-center justify-center gap-2"
              >
                <GraduationCap className="w-4 h-4" /> Explore Our Products
              </Link>
            </div>
          </div>
        </section>

      </div>
      <PublicFooter />
    </div>
  );
}
