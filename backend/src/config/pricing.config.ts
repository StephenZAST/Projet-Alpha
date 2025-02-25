export const pricingConfig = {
  allowPricePerKg: process.env.ALLOW_PRICE_PER_KG === 'true',
  allowPremiumPrices: process.env.ALLOW_PREMIUM_PRICES === 'true',
  minBasePrice: Number(process.env.MIN_BASE_PRICE) || 100,
  maxPremiumMultiplier: Number(process.env.MAX_PREMIUM_MULTIPLIER) || 3,
  priceRoundingDecimal: Number(process.env.PRICE_ROUNDING_DECIMAL) || 2,
  cacheDuration: Number(process.env.PRICE_CACHE_DURATION) || 3600 // 1 heure
};
   