interface ConnectorProps {
  from?: 'light' | 'dark';
  to?: 'light' | 'dark';
  className?: string;
}

/**
 * Animated SVG connector that visually bridges two sections.
 * A gradient line draws in on scroll, with a glowing dot traveling along the path.
 */
export default function Connector({ className = '' }: ConnectorProps) {
  return (
    <div className={`relative h-20 overflow-hidden ${className}`} aria-hidden="true">
      <svg
        viewBox="0 0 1200 80"
        preserveAspectRatio="none"
        className="absolute inset-0 w-full h-full"
      >
        <defs>
          <linearGradient id="connector-grad" x1="0" y1="0" x2="1200" y2="0" gradientUnits="userSpaceOnUse">
            <stop stopColor="#0EA5E9" stopOpacity="0" />
            <stop offset="0.15" stopColor="#0EA5E9" stopOpacity="0.5" />
            <stop offset="0.5" stopColor="#3B82F6" stopOpacity="0.7" />
            <stop offset="0.85" stopColor="#0EA5E9" stopOpacity="0.5" />
            <stop offset="1" stopColor="#0EA5E9" stopOpacity="0" />
          </linearGradient>
        </defs>
        <path
          d="M0,40 C150,40 150,0 300,0 C450,0 450,40 600,40 C750,40 750,0 900,0 C1050,0 1050,40 1200,40"
          fill="none"
          stroke="url(#connector-grad)"
          strokeWidth="2"
          className="animate-line-draw"
        />
        <circle r="4" fill="#38BDF8" className="connector-dot">
          <animate attributeName="opacity" values="0;1;1;0" dur="4s" repeatCount="indefinite" />
        </circle>
      </svg>
    </div>
  );
}
