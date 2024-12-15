export interface LoyaltyTierDefinition {
  name: string;
  minimumPoints: number;
  benefits: {
    pointsMultiplier: number;
    additionalPerks: string[];
  };
}
