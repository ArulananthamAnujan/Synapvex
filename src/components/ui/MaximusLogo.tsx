import { useSiteSettings } from '../../hooks/useSiteSettings';

interface MaximusLogoProps {
  height?: number;
  variant?: 'light' | 'dark';
}

export default function MaximusLogo({ height = 64, variant: _variant = 'dark' }: MaximusLogoProps) {
  const { logo_url, platform_name } = useSiteSettings();

  const src = logo_url || '/image copy copy copy copy copy copy copy copy copy.png';

  return (
    <img
      src={src}
      alt={platform_name || 'SynapVex'}
      style={{ height, width: 'auto', objectFit: 'contain' }}
    />
  );
}
