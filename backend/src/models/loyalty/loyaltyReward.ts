export interface LoyaltyReward {
  id?: string;
  name: string;
  description: string;
  pointsCost: number;
  type: 'discount' | 'freeService' | 'gift';
  value: number; // Percentage discount or monetary value
  minOrderAmount?: number;
  maxDiscount?: number;
  validFrom: string;
  validUntil: string;
  isActive: boolean;
  termsAndConditions?: string;
  limitPerUser?: number;
  totalLimit?: number;
  redemptionCount: number;
}
