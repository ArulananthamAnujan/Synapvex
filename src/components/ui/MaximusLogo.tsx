import { useSiteSettings } from '../../hooks/useSiteSettings';

interface MaximusLogoProps {
  height?: number;
  variant?: 'light' | 'dark';
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
export default function MaximusLogo({ height = 64, variant = 'dark' }: MaximusLogoProps) {
  const { logo_url, platform_name } = useSiteSettings();
  const alt = platform_name || 'SynapVex';
  const style = { height, width: 'auto', objectFit: 'contain' as const };

  // Admin override wins — show exactly what they configured.
  if (logo_url) {
    return <img src={logo_url} alt={alt} style={style} />;
  }

  // Forced light logo for permanently-dark surfaces.
  if (variant === 'light') {
    return <img src={LIGHT_LOGO} alt={alt} style={style} />;
  }

  // Default: follow the app theme (dark logo in light mode, light logo in dark mode).
  return (
    <>
      <img src={DARK_LOGO} alt={alt} style={style} className="block dark:hidden" />
      <img src={LIGHT_LOGO} alt={alt} style={style} className="hidden dark:block" />
    </>
  );
}
