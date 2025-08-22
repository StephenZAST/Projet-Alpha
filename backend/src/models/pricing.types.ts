export type PricingType = 'PER_ITEM' | 'PER_WEIGHT' | 'SUBSCRIPTION' | 'FIXED';

export interface PriceCalculationParams {
  articleId: string;
  serviceTypeId: string;
  serviceId: string;
  quantity?: number;
  weight?: number;
  isPremium?: boolean;
}

export interface PriceDetails {
  unitPrice: number; // prix unitaire
  lineTotal: number; // prix total pour la ligne (unitPrice * quantity ou * weight)
  pricingType: PricingType;
  isPremium: boolean;
}
   