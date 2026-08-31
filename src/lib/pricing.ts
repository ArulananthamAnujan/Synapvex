/** Current Australian domestic-card processing cost used by Stripe Checkout. */
export const processingTotalCents = (baseAmountCents: number) =>
  Math.ceil((baseAmountCents + 30) / 0.983);

export const processingCostCents = (baseAmountCents: number) =>
  Math.max(0, processingTotalCents(baseAmountCents) - baseAmountCents);

export type LearnPlanSlug = 'starter' | 'professional' | 'business';

export const LEARN_PLAN_CATALOGUE = {
  starter: {
    name: 'Starter',
    listPriceCents: 7499,
    priceCents: 4999,
    credits: 500,
  },
  professional: {
    name: 'Professional',
    listPriceCents: 10000,
    priceCents: 8900,
    credits: 900,
  },
  business: {
    name: 'Business',
    listPriceCents: 20000,
    priceCents: 17500,
    credits: 1800,
  },
} as const;

export const learnPlanPricing = (slug: string) =>
  LEARN_PLAN_CATALOGUE[slug as LearnPlanSlug] ?? null;

export const aud = (cents: number) => `$${(cents / 100).toFixed(2)}`;
