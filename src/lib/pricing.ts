/** Current Australian domestic-card processing cost used by Stripe Checkout. */
export const processingTotalCents = (baseAmountCents: number) =>
  Math.ceil((baseAmountCents + 30) / 0.983);

export const processingCostCents = (baseAmountCents: number) =>
  Math.max(0, processingTotalCents(baseAmountCents) - baseAmountCents);
