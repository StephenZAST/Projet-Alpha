export interface TierBenefit {
  type: 'discount' | 'freeShipping' | 'pointsMultiplier' | 'exclusiveAccess';
  value: number | boolean;
  description: string;
}

export interface LoyaltyTierConfig {
  id: string;
  name: string;
  description: string;
  pointsThreshold: number;
  benefits: TierBenefit[];
  icon?: string;
  color?: string;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}
