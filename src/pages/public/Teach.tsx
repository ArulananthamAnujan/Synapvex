import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  BookOpen, CheckCircle, ChevronRight, ArrowRight, Users,
  GraduationCap, Globe, Award, BarChart2, ShieldCheck,
  Video, Clock, DollarSign, Sparkles,
} from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import { supabase } from '../../lib/supabase';

interface Plan {
  id: string;
  name: string;
  slug: string;
  price_monthly_cents: number;
  max_courses: number;
  max_students: number;
  ai_tokens_monthly: number;
  features: string[];
  sort_order: number;
}

const HOW_IT_WORKS = [
  {
    step: '01',
    icon: GraduationCap,
    title: 'Choose a Plan',
    desc: 'Pick the subscription plan that matches your teaching goals. Start with Starter and upgrade anytime.',
    color: 'text-sky-600', bg: 'bg-sky-50',
  },
  {
    step: '02',
    icon: BookOpen,
    title: 'Create Your Courses',
    desc: 'Use our AI-powered course builder to create structured lessons, quizzes, exams, and assignments in minutes.',
    color: 'text-emerald-600', bg: 'bg-emerald-50',
  },
  {
    step: '03',
    icon: Globe,
    title: 'Share Your Link',
    desc: 'Every course gets a unique shareable link. Share it anywhere — social media, email, your website — and students enrol directly.',
    color: 'text-violet-600', bg: 'bg-violet-50',
  },
  {
    step: '04',
    icon: DollarSign,
    title: 'Earn & Grow',
    desc: 'Set your course price, earn from every enrolment, and track student progress and earnings from your dashboard.',
    color: 'text-amber-600', bg: 'bg-amber-50',
  },
];

const PLATFORM_FEATURES = [
  { icon: Sparkles, title: 'AI Course Builder', desc: 'Generate entire curriculums, quizzes, and lesson content with AI in minutes.' },
  { icon: Video, title: 'Video & Document Lessons', desc: 'Upload videos, PDFs, and rich text lessons with a clean student player.' },
  { icon: BarChart2, title: 'Progress & Analytics', desc: 'Real-time student progress tracking, quiz scores, and completion reports.' },
  { icon: Award, title: 'Certificates', desc: 'Automatically issue branded certificates when students complete your courses.' },
  { icon: Clock, title: 'Flexible Scheduling', desc: 'Book live face-to-face sessions, manage schedules, and send announcements.' },
  { icon: ShieldCheck, title: 'Secure Payments', desc: 'Collect course fees securely online. Earnings paid directly to you.' },
];

function PlanCard({ plan, isPopular }: { plan: Plan; isPopular: boolean }) {
  const navigate = useNavigate();

  const handleGetStarted = () => {
    // /teach/register handles every account state: new visitors sign up,
    // signed-in teachers subscribe with their existing account, teachers
    // with an active plan and non-teacher accounts get guidance.
    navigate(`/teach/register?plan=${plan.slug}`);
  };

  const price = (plan.price_monthly_cents / 100).toFixed(0);
  const coursesLabel = plan.max_courses === -1 ? 'Unlimited' : `Up to ${plan.max_courses}`;
  const studentsLabel = plan.max_students === -1 ? 'Unlimited' : `Up to ${plan.max_students}`;
  const tokensLabel = plan.ai_tokens_monthly.toLocaleString();

  return (
    <div className={`relative rounded-2xl border-2 p-8 flex flex-col ${isPopular ? 'border-sky-500 shadow-2xl shadow-sky-100 bg-white scale-105' : 'border-slate-200 bg-white hover:border-sky-200 hover:shadow-lg'} transition-all duration-300`}>
      {isPopular && (
        <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-sky-600 text-white text-xs font-bold px-5 py-1.5 rounded-full uppercase tracking-wider shadow-lg">
          Most Popular
        </div>
      )}
      <div className="mb-6">
        <h3 className="font-bold text-slate-900 text-xl mb-2">{plan.name}</h3>
        <div className="flex items-end gap-1">
          <span className="font-black text-4xl text-slate-900">${price}</span>
          <span className="text-slate-500 mb-1">/month</span>
        </div>
        <div className="mt-3 space-y-1">
          <div className="text-sm text-slate-500"><span className="font-semibold text-slate-700">{coursesLabel}</span> courses</div>
          <div className="text-sm text-slate-500"><span className="font-semibold text-slate-700">{studentsLabel}</span> students</div>
          <div className="text-sm text-slate-500"><span className="font-semibold text-slate-700">{tokensLabel}</span> AI tokens/month</div>
        </div>
      </div>
      <ul className="space-y-2.5 mb-8 flex-1">
        {(plan.features as string[]).map((f) => (
          <li key={f} className="flex items-start gap-2.5 text-sm text-slate-600">
            <CheckCircle className={`w-4 h-4 shrink-0 mt-0.5 ${isPopular ? 'text-sky-600' : 'text-emerald-500'}`} />
            {f}
          </li>
        ))}
      </ul>
      <button
        onClick={handleGetStarted}
        className={`w-full py-3.5 rounded-xl font-bold text-sm transition-all flex items-center justify-center gap-2 ${
          isPopular
            ? 'bg-sky-600 hover:bg-sky-700 text-white shadow-lg shadow-sky-200'
            : 'bg-slate-900 hover:bg-slate-800 text-white'
        }`}
      >
        Get Started <ArrowRight className="w-4 h-4" />
      </button>
    </div>
  );
}

export default function Teach() {
  const [plans, setPlans] = useState<Plan[]>([]);

  useEffect(() => {
    supabase
      .from('teacher_subscription_plans')
      .select('*')
      .eq('is_active', true)
      .order('sort_order')
      .then(({ data }) => {
        if (data) setPlans(data as Plan[]);
      });
  }, []);

  return (
    <div className="min-h-screen bg-white">
      <PublicHeader />

      {/* Hero */}
      <section className="relative min-h-[90vh] flex items-center overflow-hidden bg-slate-900">
        <div className="absolute inset-0">
          <img
            src="https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg"
            alt="Teacher"
            className="w-full h-full object-cover opacity-15"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-slate-900 via-slate-900/95 to-slate-900/60" />
        </div>
        <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-sky-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-sky-400/10 rounded-full blur-3xl" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-36">
          <div className="max-w-3xl">
            <div className="inline-flex items-center gap-2 bg-sky-500/20 border border-sky-500/30 rounded-full px-4 py-1.5 mb-6">
              <span className="w-2 h-2 bg-sky-400 rounded-full animate-pulse" />
              <span className="text-sky-300 text-sm font-semibold">Synapvex Learn — Teacher Platform</span>
            </div>
            <h1 className="font-playfair text-5xl sm:text-6xl lg:text-7xl font-bold text-white leading-tight mb-5">
              Teach the World.<br />
              <span className="text-sky-400">On Your Terms.</span>
            </h1>
            <p className="text-xl text-slate-300 leading-relaxed mb-8 max-w-2xl">
              Create online courses, share your unique course link, and let students enrol directly. Build your teaching business on Synapvex Learn.
            </p>
            {/* Free-trial highlight */}
            <div className="inline-flex items-center gap-2.5 rounded-xl bg-sky-500/15 border border-sky-400/30 px-4 py-2.5 mb-8">
              <Sparkles className="w-4 h-4 text-sky-300 shrink-0" />
              <span className="text-sky-100 text-sm font-semibold">Start free with AI credits — no credit card required</span>
            </div>
            <div className="flex flex-wrap gap-4">
              <Link to="/teach/register?free=1" className="flex items-center gap-2 px-8 py-4 rounded-xl bg-sky-500 hover:bg-sky-400 text-white font-bold transition-all text-base shadow-lg shadow-sky-500/30 hover:-translate-y-0.5">
                Start Free <ArrowRight className="w-5 h-5" />
              </Link>
              <a href="#pricing" className="flex items-center gap-2 px-8 py-4 rounded-xl border-2 border-white/30 text-white font-bold hover:border-white/60 hover:bg-white/10 transition-all text-base">
                View Pricing <ChevronRight className="w-5 h-5" />
              </a>
            </div>
            <div className="flex flex-wrap gap-10 mt-14">
              {[
                { value: 'Free', label: 'To Get Started' },
                { value: '$29', label: 'Plans From /Month' },
                { value: '70%', label: 'You Keep Per Sale' },
              ].map(stat => (
                <div key={stat.label}>
                  <p className="text-3xl font-bold text-white font-playfair">{stat.value}</p>
                  <p className="text-slate-400 text-sm mt-0.5">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Simple Process</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-4">How It Works</h2>
            <p className="text-slate-500 max-w-xl mx-auto">From sign-up to your first enrolled student in under an hour.</p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {HOW_IT_WORKS.map((step, i) => (
              <div key={step.step} className="relative">
                {i < HOW_IT_WORKS.length - 1 && (
                  <div className="hidden lg:block absolute top-8 left-[calc(100%-12px)] w-full h-0.5 bg-slate-200 z-0" />
                )}
                <div className={`relative z-10 rounded-2xl p-6 border border-slate-100 bg-white hover:shadow-lg transition-all`}>
                  <div className="flex items-center justify-between mb-4">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${step.bg}`}>
                      <step.icon className={`w-6 h-6 ${step.color}`} />
                    </div>
                    <span className="text-2xl font-black text-slate-200">{step.step}</span>
                  </div>
                  <h3 className="font-bold text-slate-900 text-lg mb-2">{step.title}</h3>
                  <p className="text-sm text-slate-500 leading-relaxed">{step.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Platform Features */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <div>
              <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">What You Get</p>
              <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-5">Everything You Need to Teach Online</h2>
              <p className="text-slate-500 mb-8 leading-relaxed">
                Synapvex Learn gives you a complete teaching toolkit — from course creation and student management to payments and certificates — all in one place.
              </p>
              <div className="grid sm:grid-cols-2 gap-4">
                {PLATFORM_FEATURES.map(f => (
                  <div key={f.title} className="flex gap-3 p-4 rounded-xl border border-slate-100 hover:border-sky-200 hover:bg-sky-50/50 transition-all">
                    <div className="w-9 h-9 bg-sky-100 rounded-lg flex items-center justify-center shrink-0">
                      <f.icon className="w-4 h-4 text-sky-600" />
                    </div>
                    <div>
                      <p className="font-semibold text-slate-900 text-sm">{f.title}</p>
                      <p className="text-xs text-slate-500 mt-0.5 leading-relaxed">{f.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="relative">
              <div className="absolute -inset-5 bg-gradient-to-tr from-sky-400/15 to-indigo-400/15 blur-3xl rounded-[2.5rem]" />
              <div className="relative rounded-3xl bg-slate-900 p-7 shadow-2xl overflow-hidden">
                <div className="absolute inset-0 bg-grid opacity-50" />
                <div className="relative">
                  <div className="flex items-center gap-2.5 mb-5">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-sky-400 to-blue-600 flex items-center justify-center">
                      <Sparkles className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="text-white font-bold text-sm">AI Course Builder</p>
                      <p className="text-slate-400 text-xs">Draft a full course in minutes</p>
                    </div>
                  </div>
                  <div className="space-y-2.5">
                    {['Course outline & lessons', 'Quizzes & exams', 'Flashcards & summaries'].map((t, i) => (
                      <div key={t} className="glass-card rounded-xl px-4 py-3 flex items-center justify-between">
                        <span className="text-sm text-white font-medium">{t}</span>
                        <CheckCircle className={`w-4 h-4 ${i === 0 ? 'text-sky-300' : 'text-slate-500'}`} />
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section id="pricing" className="py-24 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <p className="text-sky-600 font-semibold text-sm uppercase tracking-wider mb-2">Simple Pricing</p>
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-4">Choose Your Plan</h2>
            <p className="text-slate-500 max-w-xl mx-auto">Simple per-period pricing — monthly or annual. No hidden fees. Cancel anytime.</p>
          </div>

          {plans.length === 0 ? (
            <div className="grid md:grid-cols-3 gap-6 max-w-5xl mx-auto">
              {[1, 2, 3].map(i => (
                <div key={i} className="h-96 rounded-2xl bg-slate-200 animate-pulse" />
              ))}
            </div>
          ) : (
            <div className="grid md:grid-cols-3 gap-6 max-w-5xl mx-auto items-start">
              {plans.map(plan => (
                <PlanCard key={plan.id} plan={plan} isPopular={plan.slug === 'professional'} />
              ))}
            </div>
          )}

          <p className="text-center text-sm text-slate-400 mt-8">
            All prices in AUD. Billed monthly. Cancel anytime from your dashboard.
          </p>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-20 bg-slate-50">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="font-playfair text-4xl font-bold text-slate-900 mb-3">Frequently Asked Questions</h2>
          </div>
          <div className="space-y-4">
            {[
              { q: 'Can I share my course links externally?', a: 'Yes. Every course gets a unique public link you can share on social media, email, your website, or anywhere. Students click the link, land on the course preview page, and enrol directly.' },
              { q: 'Who keeps the course earnings?', a: 'You set your own course price and keep 100% of what students pay. SynapVex charges only the monthly subscription fee — no per-sale commission.' },
              { q: 'Can I use the AI course builder on all plans?', a: 'AI tools are available on all plans. Starter includes 500 tokens/month; Professional includes 2,000; Business includes 10,000. Tokens reset each billing cycle.' },
              { q: 'How does billing work?', a: 'Plans are paid per period — monthly, or annually with two months free. You can cancel at any time from Plan & Billing in your dashboard, and your account stays active until the end of the period you paid for.' },
              { q: 'Can I upgrade or downgrade my plan?', a: 'Yes. You can change your plan at any time. Upgrades take effect immediately; downgrades apply at the next billing cycle.' },
            ].map(({ q, a }) => (
              <details key={q} className="group bg-white rounded-xl border border-slate-200 p-5 cursor-pointer hover:border-sky-200 transition-colors">
                <summary className="flex items-center justify-between font-semibold text-slate-900 list-none">
                  {q}
                  <ChevronRight className="w-5 h-5 text-slate-400 group-open:rotate-90 transition-transform shrink-0 ml-3" />
                </summary>
                <p className="mt-3 text-sm text-slate-600 leading-relaxed">{a}</p>
              </details>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 bg-sky-600">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <Users className="w-12 h-12 text-white/70 mx-auto mb-5" />
          <h2 className="font-playfair text-4xl font-bold text-white mb-4">Ready to Start Teaching?</h2>
          <p className="text-sky-100 text-lg mb-8 leading-relaxed">
            Create your account, pick a plan, and publish your first course under your own brand. Cancel anytime.
          </p>
          <div className="flex flex-wrap gap-4 justify-center">
            <Link to="/teach/register" className="px-8 py-4 bg-white text-sky-700 font-bold rounded-xl hover:bg-sky-50 transition-colors flex items-center gap-2">
              <GraduationCap className="w-5 h-5" /> Start Free Trial
            </Link>
            <Link to="/contact" className="px-8 py-4 border-2 border-white/40 text-white font-bold rounded-xl hover:border-white hover:bg-white/10 transition-colors">
              Talk to Sales
            </Link>
          </div>
        </div>
      </section>

      <PublicFooter />
    </div>
  );
}
