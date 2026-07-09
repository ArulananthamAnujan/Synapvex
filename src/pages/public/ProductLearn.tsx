import { Link } from 'react-router-dom';
import {
  GraduationCap, ArrowRight, CheckCircle, Store, Share2, Sparkles,
  CreditCard, Award, BarChart2, Users, BookOpen, Palette, Link2,
  Building2, Video, ClipboardList, Bot,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import Reveal from '../../components/ui/Reveal';

const STEPS = [
  {
    icon: GraduationCap,
    title: 'Sign up & pick a plan',
    desc: 'Create your teacher account and choose a plan that fits — from solo starter to full academy.',
  },
  {
    icon: Sparkles,
    title: 'Build your course',
    desc: 'Use the course builder — or let AI draft your outline, lessons, quizzes and exams in minutes.',
  },
  {
    icon: Palette,
    title: 'Brand your course page',
    desc: 'Add your logo, name and colors. You get your own page link — it looks like YOUR website, not ours.',
  },
  {
    icon: Share2,
    title: 'Share your link & earn',
    desc: 'Put the link on your website or socials. Students land on your branded page, enrol, pay and learn.',
  },
];

const TEACHER_FEATURES = [
  { icon: Store, title: 'Your Branded Course Page', desc: 'A white-label storefront with your logo, colors and only your courses — "Powered by" note optional.' },
  { icon: Bot, title: 'AI Course Builder', desc: 'Generate outlines, lesson content, quizzes, exams and flashcards with AI tokens.' },
  { icon: CreditCard, title: 'Sell Your Courses', desc: 'Set your price, accept secure card payments, offer promo codes — earnings tracked in your dashboard.' },
  { icon: ClipboardList, title: 'Quizzes, Exams & Assignments', desc: 'Auto-graded quizzes and exams with attempt limits, plus assignment submissions and grading.' },
  { icon: Video, title: 'Live Sessions & F2F', desc: 'Schedule live classes and manage face-to-face session requests from students.' },
  { icon: BarChart2, title: 'Student Analytics', desc: 'See enrolments, lesson-level progress and completion for every student.' },
];

const STUDENT_FEATURES = [
  { icon: BookOpen, title: 'Learn anywhere', desc: 'Video, PDF and article lessons with progress that syncs across devices.' },
  { icon: Award, title: 'Verified certificates', desc: 'Certificates are issued automatically on completion and publicly verifiable.' },
  { icon: Users, title: 'Discussions & support', desc: 'Course discussions, announcements and direct contact with the teacher.' },
];

const PLANS = [
  {
    name: 'Starter', price: 29,
    features: ['3 courses', '50 students', '500 AI tokens/month', 'Branded course page', 'Quizzes & assignments', 'Email support'],
    popular: false,
  },
  {
    name: 'Professional', price: 49,
    features: ['15 courses', '500 students', '2,000 AI tokens/month', 'AI course builder', 'Certificates & exams', 'Earnings dashboard', 'Priority support'],
    popular: true,
  },
  {
    name: 'Business', price: 99,
    features: ['Unlimited courses & students', '10,000 AI tokens/month', 'Organisation & team of teachers', 'Full AI curriculum builder', 'Advanced analytics', 'Dedicated account manager'],
    popular: false,
  },
];

export default function ProductLearn() {
  return (
    <div className="bg-white min-h-screen">
      <PublicHeader />
      <div className="pt-20 lg:pt-24">
        {/* Hero */}
        <section className="bg-mesh relative overflow-hidden">
          <div className="absolute inset-0 bg-grid" />
          <div className="absolute top-[-6rem] right-[-4rem] w-[32rem] h-[32rem] bg-sky-500/15 rounded-full blur-3xl animate-blob" />
          <div className="absolute bottom-0 left-0 w-96 h-96 bg-indigo-500/12 rounded-full blur-3xl animate-blob" style={{ animationDelay: '5s' }} />
          <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28 grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <div className="inline-flex items-center gap-2 bg-sky-500/20 border border-sky-500/30 rounded-full px-4 py-1.5 mb-6">
                <GraduationCap className="w-4 h-4 text-sky-300" />
                <span className="text-sky-300 text-sm font-semibold">Synapvex Learn · Live Product</span>
              </div>
              <h1 className="font-playfair text-4xl lg:text-6xl font-bold text-white leading-tight mb-6">
                Sell courses from<br /><span className="text-sky-400">your own website</span>
              </h1>
              <p className="text-slate-300 text-lg leading-relaxed mb-8 max-w-xl">
                Create courses here, get your own branded course page, and drop one link on your
                website. Your students see <em>your</em> brand — we quietly handle the video hosting,
                payments, quizzes, progress and certificates behind the scenes.
              </p>
              <div className="flex flex-wrap gap-4">
                <Link to="/teach/register" className="px-8 py-3.5 bg-sky-600 hover:bg-sky-500 text-white font-bold rounded-xl transition-colors flex items-center gap-2 shadow-lg shadow-sky-600/30">
                  Start Teaching <ArrowRight className="w-5 h-5" />
                </Link>
                <Link to="/teach/register" className="px-8 py-3.5 border-2 border-white/30 text-white font-bold rounded-xl hover:border-white/60 hover:bg-white/10 transition-colors">
                  View Pricing
                </Link>
              </div>
              <p className="text-slate-500 text-sm mt-5">
                Plans from $29/month · Students join free ·{' '}
                <Link to="/login" className="text-sky-400 hover:text-sky-300 font-semibold">Already teaching? Sign in</Link>
              </p>
            </div>

            {/* Mock storefront preview */}
            <div className="hidden lg:block relative">
              <div className="absolute -inset-6 bg-gradient-to-tr from-sky-400/20 to-indigo-400/20 blur-3xl rounded-[2.5rem]" />
              <div className="relative rounded-3xl bg-white shadow-2xl overflow-hidden border border-slate-200 animate-float-slow">
                <div className="flex items-center gap-2 px-4 py-2.5 bg-slate-100 border-b border-slate-200">
                  <span className="w-2.5 h-2.5 rounded-full bg-red-400" />
                  <span className="w-2.5 h-2.5 rounded-full bg-amber-400" />
                  <span className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
                  <div className="ml-3 flex items-center gap-1.5 bg-white rounded-md px-3 py-1 text-xs text-slate-400 flex-1">
                    <Link2 className="w-3 h-3" /> synapvex.com/school/<span className="text-slate-700 font-semibold">your-academy</span>
                  </div>
                </div>
                <div className="bg-violet-700 px-6 py-8 text-center">
                  <div className="w-12 h-12 bg-white rounded-2xl mx-auto mb-3 flex items-center justify-center font-black text-violet-700 text-xl">Y</div>
                  <p className="text-white font-bold text-lg">Your Academy</p>
                  <p className="text-white/70 text-xs">Your logo · Your colors · Your courses</p>
                </div>
                <div className="p-5 grid grid-cols-3 gap-3">
                  {['Course A', 'Course B', 'Course C'].map(c => (
                    <div key={c} className="rounded-xl border border-slate-100 overflow-hidden">
                      <div className="h-14 bg-gradient-to-br from-slate-200 to-slate-100" />
                      <div className="p-2">
                        <p className="text-[10px] font-bold text-slate-700">{c}</p>
                        <p className="text-[9px] text-violet-700 font-bold mt-1">Enrol →</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* How it works */}
        <section className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">How It Works</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-3">From your website to their certificate</h2>
            <p className="text-slate-500 max-w-2xl mx-auto">Four steps between you and a course business under your own brand.</p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {STEPS.map((step, i) => (
              <Reveal as="div" key={step.title} delay={i * 90} className="relative p-6 rounded-2xl border border-slate-100 bg-slate-50 hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all group">
                <span className="absolute top-4 right-5 text-4xl font-black text-slate-200/80 font-playfair">{i + 1}</span>
                <div className="w-11 h-11 bg-sky-600 rounded-xl flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                  <step.icon className="w-5 h-5 text-white" />
                </div>
                <h3 className="font-bold text-slate-900 mb-2">{step.title}</h3>
                <p className="text-sm text-slate-500 leading-relaxed">{step.desc}</p>
              </Reveal>
            ))}
          </div>
        </section>

        {/* White-label callout */}
        <section className="bg-slate-900 py-20 relative overflow-hidden">
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,rgba(124,58,237,0.15),transparent_60%)]" />
          <div className="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <Store className="w-10 h-10 text-sky-400 mx-auto mb-5" />
            <h2 className="font-playfair text-3xl lg:text-4xl font-bold text-white mb-5">
              Your students never feel like they left your website
            </h2>
            <p className="text-slate-300 text-lg max-w-3xl mx-auto mb-8">
              Every teacher and academy gets a branded course page at their own link — your logo in the
              header, your colors on every button, only your courses on the shelf. Share it from your
              website, Instagram or WhatsApp; students enrol and learn without ever seeing another brand.
            </p>
            <div className="flex flex-wrap justify-center gap-x-8 gap-y-3 text-sm text-slate-300 mb-9">
              {['Custom page link', 'Your logo & brand colors', 'Hide platform branding', 'Per-course share links'].map(f => (
                <span key={f} className="flex items-center gap-2"><CheckCircle className="w-4 h-4 text-sky-400" />{f}</span>
              ))}
            </div>
            <Link to="/teach/register" className="inline-flex items-center gap-2 px-8 py-3.5 bg-sky-600 hover:bg-sky-500 text-white font-bold rounded-xl transition-colors">
              Claim Your Page <ArrowRight className="w-5 h-5" />
            </Link>
          </div>
        </section>

        {/* Feature grids */}
        <section className="py-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Everything Included</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900">Built for teachers, loved by students</h2>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5 mb-10">
            {TEACHER_FEATURES.map(f => (
              <div key={f.title} className="p-6 rounded-2xl border border-slate-100 hover:shadow-lg hover:-translate-y-0.5 transition-all">
                <div className="w-10 h-10 bg-sky-50 rounded-xl flex items-center justify-center mb-3">
                  <f.icon className="w-5 h-5 text-sky-600" />
                </div>
                <h3 className="font-bold text-slate-900 text-sm mb-1.5">{f.title}</h3>
                <p className="text-xs text-slate-500 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
          <div className="grid sm:grid-cols-3 gap-5">
            {STUDENT_FEATURES.map(f => (
              <div key={f.title} className="p-6 rounded-2xl bg-slate-50 border border-slate-100">
                <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center mb-3 border border-slate-100">
                  <f.icon className="w-5 h-5 text-emerald-600" />
                </div>
                <h3 className="font-bold text-slate-900 text-sm mb-1.5">{f.title}</h3>
                <p className="text-xs text-slate-500 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Organisations */}
        <section className="bg-slate-50 border-y border-slate-100 py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 grid lg:grid-cols-2 gap-10 items-center">
            <div>
              <div className="inline-flex items-center gap-2 bg-white border border-slate-200 rounded-full px-4 py-1.5 mb-5">
                <Building2 className="w-4 h-4 text-slate-600" />
                <span className="text-slate-700 text-sm font-semibold">For Academies & Organisations</span>
              </div>
              <h2 className="font-playfair text-3xl font-bold text-slate-900 mb-4">Run a whole academy, not just a course</h2>
              <p className="text-slate-500 leading-relaxed mb-6">
                Organisations get a team of teachers, shared AI token pools, student roster management
                and an organisation-level branded course page — ideal for training companies, schools
                and corporate learning teams.
              </p>
              <Link to="/contact" className="inline-flex items-center gap-2 px-6 py-3 bg-slate-900 text-white font-bold rounded-xl hover:bg-slate-800 transition-colors">
                Talk to Sales <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                { icon: Users, label: 'Team of teachers' },
                { icon: Bot, label: 'Shared AI token pool' },
                { icon: Store, label: 'Org-branded course page' },
                { icon: BarChart2, label: 'Organisation analytics' },
              ].map(item => (
                <div key={item.label} className="bg-white rounded-2xl border border-slate-100 p-5 flex items-center gap-3">
                  <item.icon className="w-5 h-5 text-sky-600 shrink-0" />
                  <span className="text-sm font-semibold text-slate-700">{item.label}</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Pricing */}
        <section className="py-20 max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Simple Pricing</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-3">Start small, scale to an academy</h2>
            <p className="text-slate-500">Pay monthly, or pay annually upfront and get two months free. Students always join free. Cancel anytime.</p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            {PLANS.map(plan => (
              <div
                key={plan.name}
                className={`rounded-3xl border p-7 relative ${
                  plan.popular ? 'border-sky-400 shadow-xl shadow-sky-100 scale-[1.02]' : 'border-slate-200'
                }`}
              >
                {plan.popular && (
                  <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-sky-600 text-white text-xs font-bold px-4 py-1 rounded-full">
                    MOST POPULAR
                  </span>
                )}
                <h3 className="font-bold text-slate-900 text-lg mb-1">{plan.name}</h3>
                <p className="mb-5">
                  <span className="text-4xl font-bold text-slate-900 font-playfair">${plan.price}</span>
                  <span className="text-slate-400 text-sm">/month</span>
                </p>
                <ul className="space-y-2.5 mb-7">
                  {plan.features.map(f => (
                    <li key={f} className="flex items-start gap-2.5 text-sm text-slate-600">
                      <CheckCircle className="w-4 h-4 text-sky-500 shrink-0 mt-0.5" /> {f}
                    </li>
                  ))}
                </ul>
                <Link
                  to="/teach/register"
                  className={`block text-center px-6 py-3 font-bold rounded-xl transition-colors ${
                    plan.popular
                      ? 'bg-sky-600 hover:bg-sky-700 text-white'
                      : 'border-2 border-slate-200 text-slate-700 hover:border-sky-400 hover:text-sky-600'
                  }`}
                >
                  Choose {plan.name}
                </Link>
              </div>
            ))}
          </div>
        </section>

        {/* Final CTA */}
        <section className="bg-sky-600 py-16">
          <div className="max-w-3xl mx-auto px-4 text-center">
            <h2 className="font-playfair text-3xl lg:text-4xl font-bold text-white mb-4">Your courses. Your brand. Our engine.</h2>
            <p className="text-sky-100 mb-8">Join Synapvex Learn today and launch your branded course page this week.</p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Link to="/teach/register" className="px-8 py-3.5 bg-white text-sky-700 font-bold rounded-xl hover:bg-sky-50 transition-colors flex items-center gap-2">
                Start Teaching <ArrowRight className="w-5 h-5" />
              </Link>
              <Link to="/register" className="px-8 py-3.5 border-2 border-white/40 text-white font-bold rounded-xl hover:bg-white/10 transition-colors">
                Join as a Student
              </Link>
            </div>
          </div>
        </section>
      </div>
      <PublicFooter />
    </div>
  );
}
