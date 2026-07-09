import { useEffect, useRef, useState, type ReactNode, type ElementType } from 'react';

type Direction = 'up' | 'down' | 'left' | 'right' | 'none';

interface RevealProps {
  children: ReactNode;
  /** Entrance direction. Default 'up'. */
  direction?: Direction;
  /** Stagger delay in ms (multiply by index for lists). */
  delay?: number;
  className?: string;
  as?: ElementType;
  /** Only animate the first time it enters. Default true. */
  once?: boolean;
  /** Any extra props (onClick, id, …) are forwarded to the element. */
  [key: string]: unknown;
}

const OFFSET: Record<Direction, string> = {
  up: 'translateY(28px)',
  down: 'translateY(-28px)',
  left: 'translateX(28px)',
  right: 'translateX(-28px)',
  none: 'translateY(0)',
};

/**
 * Scroll-triggered entrance animation. Reveals its children with a soft
 * fade + slide the first time they scroll into view. Respects
 * prefers-reduced-motion (renders instantly, no transform).
 */
export default function Reveal({
  children,
  direction = 'up',
  delay = 0,
  className = '',
  as: Tag = 'div',
  once = true,
  ...rest
}: RevealProps) {
  const ref = useRef<HTMLElement | null>(null);
  const [shown, setShown] = useState(false);
  const reduced = typeof window !== 'undefined'
    && window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;

  useEffect(() => {
    if (reduced) { setShown(true); return; }
    const el = ref.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setShown(true);
          if (once) observer.disconnect();
        } else if (!once) {
          setShown(false);
        }
      },
      { threshold: 0.12, rootMargin: '0px 0px -8% 0px' },
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [once, reduced]);

  return (
    <Tag
      ref={ref}
      className={className}
      style={{
        opacity: shown ? 1 : 0,
        transform: shown ? 'none' : OFFSET[direction],
        transitionProperty: 'opacity, transform',
        transitionDuration: '700ms',
        transitionTimingFunction: 'cubic-bezier(0.22, 1, 0.36, 1)',
        transitionDelay: `${delay}ms`,
        willChange: 'opacity, transform',
      }}
      {...rest}
    >
      {children}
    </Tag>
  );
}
