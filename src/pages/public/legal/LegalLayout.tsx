import PublicHeader from '../../../components/layout/PublicHeader';
import PublicFooter from '../../../components/layout/PublicFooter';

interface Props {
  title: string;
  lastUpdated: string;
  children: React.ReactNode;
}

/** Shared shell for Privacy / Terms / Refund pages. */
export default function LegalLayout({ title, lastUpdated, children }: Props) {
  return (
    <div className="bg-white min-h-screen">
      <PublicHeader />
      <div className="pt-20 lg:pt-24">
        <section className="bg-slate-900 py-14">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
            <h1 className="font-playfair text-4xl font-bold text-white mb-2">{title}</h1>
            <p className="text-slate-400 text-sm">Last updated: {lastUpdated}</p>
          </div>
        </section>
        <section className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="prose-slate space-y-8 text-slate-600 leading-relaxed [&_h2]:font-bold [&_h2]:text-slate-900 [&_h2]:text-xl [&_h2]:mb-3 [&_ul]:list-disc [&_ul]:pl-6 [&_ul]:space-y-1.5 [&_p]:mb-3">
            {children}
          </div>
        </section>
      </div>
      <PublicFooter />
    </div>
  );
}
