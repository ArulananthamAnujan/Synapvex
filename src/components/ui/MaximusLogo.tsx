import { useSiteSettings } from '../../hooks/useSiteSettings';

interface MaximusLogoProps {
  height?: number;
  variant?: 'light' | 'dark';
}

export default function MaximusLogo({ height = 64, variant = 'dark' }: MaximusLogoProps) {
  const { logo_url, platform_name } = useSiteSettings();

  const textColor = variant === 'light' ? 'text-white' : 'text-slate-900';
  const accentColor = variant === 'light' ? 'text-sky-300' : 'text-sky-600';

  if (logo_url) {
    return (
      <img
        src={logo_url}
        alt={platform_name || 'Logo'}
        style={{ height, width: 'auto', objectFit: 'contain' }}
      />
    );
  }

  return (
    <div className="flex items-center gap-2.5" style={{ height }}>
      <div
        className="rounded-xl bg-sky-600 flex items-center justify-center font-black text-white shrink-0"
        style={{ width: height * 0.6, height: height * 0.6, fontSize: height * 0.3 }}
      >
        S
      </div>
      <div className="flex flex-col leading-none">
        <span className={`font-black tracking-tight ${textColor}`} style={{ fontSize: height * 0.28 }}>
          Synap<span className={accentColor}>Vex</span>
        </span>
        <span
          className={`font-medium tracking-widest uppercase ${variant === 'light' ? 'text-sky-200' : 'text-slate-400'}`}
          style={{ fontSize: height * 0.14 }}
        >
          Technologies
        </span>
      </div>
    </div>
  );
}
