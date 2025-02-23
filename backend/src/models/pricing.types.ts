export type PricingType = 'PER_ITEM' | 'PER_WEIGHT' | 'SUBSCRIPTION';

export interface PriceCalculationParams {
  articleId: string;
  serviceTypeId: string;
  quantity?: number;
  weight?: number;
  isPremium?: boolean;
}

export interface PriceDetails {
  basePrice: number;
  total: number;
  pricingType: PricingType;
  isPremium: boolean;
}
  