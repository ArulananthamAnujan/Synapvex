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

export const learnPlanFeatures = (slug: string, features: string[]) => {
  const pricing = learnPlanPricing(slug);
  if (!pricing) return features;
  const creditLabel = `${pricing.credits.toLocaleString()} AI credits for 3 months`;
  let replaced = false;
  const consistent = features.map((feature) => {
    if (!/AI\s+(tokens?|credits?)/i.test(feature)) return feature;
    replaced = true;
    return creditLabel;
  });
  return replaced ? consistent : [...consistent, creditLabel];
};

export const aud = (cents: number) => `$${(cents / 100).toFixed(2)}`;
