export const COMMISSION_LEVELS = {
  LEVEL1: { min: 0, max: 9, rate: 0.10 },    // 10% pour 0-9 clients
  LEVEL2: { min: 10, max: 19, rate: 0.15 },  // 15% pour 10-19 clients
  LEVEL3: { min: 20, max: Infinity, rate: 0.20 }  // 20% pour 20+ clients
} as const;

export const INDIRECT_COMMISSION_RATE = 0.10; // 10% sur les filleuls
export const PROFIT_MARGIN_RATE = 0.40; // 40% du prix total pour le bénéfice net