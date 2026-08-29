import { useSiteSettings } from '../../hooks/useSiteSettings';

interface MaximusLogoProps {
  height?: number;
  variant?: 'light' | 'dark';
  compact?: boolean;
}

const DARK_LOGO = '/synapvex-logo.png';        // navy wordmark — for light backgrounds
const LIGHT_LOGO = '/synapvex-logo-light.png'; // light wordmark — for dark backgrounds

/**
 * SynapVex brand logo. Uses the transparent brand PNG so it sits cleanly on
 * any background. By default it auto-adapts to the app's light/dark theme
 * (navy logo on light surfaces, light logo on dark ones). Pass
 * `variant="light"` to force the light logo on an always-dark surface. An
 * admin-configured `logo_url` from site settings always takes precedence.
 */
export default function MaximusLogo({ height = 64, variant = 'dark', compact = false }: MaximusLogoProps) {
  const { logo_url, platform_name } = useSiteSettings();
  const alt = platform_name || 'SynapVex';
  const style = { height, width: 'auto', maxWidth: '100%', objectFit: 'contain' as const };

  if (compact && !logo_url) {
    return (
      <span className="inline-flex min-w-0 items-center gap-2.5" aria-label={alt}>
        <img src="/favicon.svg" alt="" aria-hidden="true" style={{ width: height, height }} className="shrink-0 rounded-xl" />
        <span className="min-w-0 leading-none">
          <span className={`block truncate text-[1.35rem] font-bold tracking-[-0.045em] ${variant === 'light' ? 'text-white' : 'text-navy-900 dark:text-white'}`}>
            Synap<span className="text-blue-600 dark:text-blue-400">Vex</span>
          </span>
          <span className={`mt-1 block text-[0.57rem] font-bold uppercase tracking-[0.28em] ${variant === 'light' ? 'text-slate-300' : 'text-slate-500 dark:text-slate-400'}`}>
            Learn
          </span>
        </span>
      </span>
    );
  }

  // Admin override wins — show exactly what they configured.
  if (logo_url) {
    return <img src={logo_url} alt={alt} style={style} />;
  }

  // Forced light logo for permanently-dark surfaces.
  if (variant === 'light') {
    return <img src={LIGHT_LOGO} alt={alt} style={style} className="brightness-0 invert" />;
  }

  // Default: follow the app theme (dark logo in light mode, light logo in dark mode).
  return (
    <>
      <img src={DARK_LOGO} alt={alt} style={style} className="block dark:hidden" />
      <img src={LIGHT_LOGO} alt={alt} style={style} className="hidden brightness-0 invert dark:block" />
    </>
  );
}
