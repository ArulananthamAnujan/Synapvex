import { Link } from 'react-router-dom';
import { Compass, ArrowLeft } from 'lucide-react';
import PublicHeader from '../../components/layout/PublicHeader';
import PublicFooter from '../../components/layout/PublicFooter';

export default function NotFound() {
  return (
    <div className="bg-white min-h-screen flex flex-col">
      <PublicHeader />
      <div className="flex-1 flex items-center justify-center pt-20 pb-16 px-4">
        <div className="text-center max-w-md">
          <div className="w-16 h-16 bg-slate-100 rounded-2xl flex items-center justify-center mx-auto mb-6">
            <Compass className="w-8 h-8 text-slate-400" />
          </div>
          <p className="font-sans text-6xl font-bold text-slate-200 mb-2">404</p>
          <h1 className="text-2xl font-bold text-slate-900 mb-3">Page not found</h1>
          <p className="text-slate-500 mb-8">
            The page you're looking for doesn't exist or has moved. Check the address, or head back to the homepage.
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <Link to="/" className="px-6 py-3 bg-sky-600 hover:bg-sky-700 text-white font-bold rounded-xl transition-colors flex items-center gap-2">
              <ArrowLeft className="w-4 h-4" /> Back to Home
            </Link>
            <Link to="/contact" className="px-6 py-3 border-2 border-slate-200 text-slate-700 font-bold rounded-xl hover:border-sky-400 hover:text-sky-600 transition-colors">
              Contact Us
            </Link>
          </div>
        </div>
      </div>
      <PublicFooter />
    </div>
  );
}
