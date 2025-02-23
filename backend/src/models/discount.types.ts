export enum DiscountType {
  FIRST_ORDER = 'FIRST_ORDER',
  LOYALTY = 'LOYALTY',
  ADMIN_OFFER = 'ADMIN_OFFER'
}

export interface DiscountRule {
  id: string;
  name: string;
  type: DiscountType;
  value: number;
  maxValue?: number;
  priority: number;
  isCumulative: boolean;
  startDate?: Date;
  endDate?: Date;
  isActive: boolean;
  conditions?: {
    minOrderAmount?: number;
    isFirstOrder?: boolean;
    isLoyaltyMember?: boolean;
  };
}

export interface Discount {
  type: DiscountType;
  amount: number;
  description: string;
}

export interface DiscountResult {
  subtotal: number;
  discounts: Discount[];
  total: number;
}
