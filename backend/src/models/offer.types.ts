export enum OfferDiscountType {
  PERCENTAGE = 'PERCENTAGE',
  FIXED_AMOUNT = 'FIXED_AMOUNT',
  POINTS_EXCHANGE = 'POINTS_EXCHANGE'
} 

export interface CreateOfferDTO {
  name: string;
  description?: string;
  discountType: OfferDiscountType;
  discountValue: number;
  minPurchaseAmount?: number;
  maxDiscountAmount?: number;
  isCumulative: boolean;
  startDate: Date;
  endDate: Date;
  pointsRequired?: number;
  articleIds?: string[]; // Added missing property
}

export interface Offer {
  id: string;
  name: string;
  description?: string | null;
  discountType: string;
  discountValue: number;
  minPurchaseAmount?: number;
  maxDiscountAmount?: number;
  isCumulative: boolean;
  startDate: Date;
  endDate: Date;
  isActive: boolean;
  pointsRequired?: number;
  createdAt: Date;
  updatedAt: Date;
  articles?: Array<{
    id: string;
    name: string;
    description?: string;
  }>;
}

export interface OfferSubscription {
  id: string;
  userId: string;
  offerId: string;
  status: 'ACTIVE' | 'INACTIVE';
  subscribedAt: Date;
  updatedAt: Date;
  offer?: Offer;
}

export interface OfferUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
}

export interface OfferSubscriptionResponse extends OfferSubscription {
  user?: OfferUser;
}
