export enum SubscriptionType {
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
  QUARTERLY = 'QUARTERLY',
  YEARLY = 'YEARLY'
}

export interface SubscriptionPlan {
  id?: string;
  name: string;
  description: string;
  type: SubscriptionType;
  price: number;
  duration: number;
  benefits: string[];
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}
