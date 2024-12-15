export enum LoyaltyTier {
  BRONZE = 'BRONZE',    // 0-1000 points
  SILVER = 'SILVER',     // 1001-5000 points
  GOLD = 'GOLD',
  PLATINUM = 'PLATINUM'
}

export interface LoyaltyAccount {
  userId: string;
  points: number;
  lifetimePoints: number;
  tier: LoyaltyTier;
  lastUpdated: string;
}

function calculateLoyaltyTier(points: number): LoyaltyTier {
  if (points <= 1000) {
    return LoyaltyTier.BRONZE;
  } else if (points <= 5000) {
    return LoyaltyTier.SILVER;
  }
  // Expand with more tiers if needed
  throw new Error("Points exceed defined tiers");
}
