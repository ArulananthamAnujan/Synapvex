import { ArrowRight, CheckCircle2, ExternalLink, Languages } from 'lucide-react';
import { Link } from 'react-router-dom';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';
import ProductMotionVisual from '../../components/ui/ProductMotionVisual';
import Reveal from '../../components/ui/Reveal';

const PTE_APP_URL = 'https://synapvexpte.netlify.app';

export default function ProductPte() {
  return (
    <div className="min-h-screen bg-white text-slate-900">
      <PublicHeader />
      <main>
        <section className="relative overflow-hidden bg-gradient-to-br from-[#fffdf8] via-white to-sky-50 pb-24 pt-36 sm:pb-32 sm:pt-44">
          <div className="absolute -right-32 top-10 h-[32rem] w-[32rem] rounded-full bg-sky-300/20 blur-[110px]" />
          <div className="relative mx-auto grid max-w-7xl items-center gap-14 px-4 sm:px-6 lg:grid-cols-[0.95fr_1.05fr] lg:px-8">
            <div>
              <div className="inline-flex items-center gap-2 rounded-full border border-sky-200 bg-white px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-sky-800 shadow-sm"><Languages className="h-4 w-4" /> SynapVex PTE · Live platform</div>
              <h1 className="mt-8 max-w-3xl font-display text-5xl font-semibold leading-[1.02] tracking-[-0.045em] text-[#102d48] sm:text-7xl">Practise with purpose. Walk into test day prepared.</h1>
              <p className="mt-7 max-w-xl text-lg leading-8 text-slate-600">A focused preparation environment for speaking, writing, reading and listening—with feedback that shows learners what to improve next.</p>
              <div className="mt-10 flex flex-col gap-3 sm:flex-row">
                <a href={PTE_APP_URL} target="_blank" rel="noopener noreferrer" className="luxury-button-primary gap-2">Open SynapVex PTE <ExternalLink className="h-4 w-4" /></a>
                <Link to="/products" className="luxury-button-light gap-2">All products <ArrowRight className="h-4 w-4" /></Link>
              </div>
              <p className="mt-4 text-xs leading-5 text-slate-500">The live learning application opens in a new tab. You will remain within the SynapVex product family.</p>
            </div>
            <div className="overflow-hidden rounded-[28px] shadow-[0_35px_90px_-45px_rgba(3,105,161,.65)]"><ProductMotionVisual variant="pte" /></div>
          </div>
        </section>
        <section className="py-24 sm:py-32"><div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8"><Reveal className="grid gap-12 lg:grid-cols-[0.72fr_1.28fr]"><div><p className="corporate-eyebrow">One clear practice loop</p><h2 className="corporate-heading mt-3">Know what to work on next.</h2></div><div className="grid gap-4 sm:grid-cols-2">{['Practise all four PTE skills', 'Complete realistic timed activities', 'Receive AI feedback for speaking and writing', 'Track progress towards exam readiness'].map(item => <div key={item} className="flex gap-3 rounded-2xl border border-slate-200 bg-slate-50 p-5 text-sm font-semibold leading-6 text-slate-700"><CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-sky-600" />{item}</div>)}</div></Reveal></div></section>
      </main>
      <PublicFooter />
    </div>
  );
}
