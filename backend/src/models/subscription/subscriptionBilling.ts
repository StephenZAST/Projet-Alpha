import { SubscriptionType } from './subscriptionPlan';

export interface SubscriptionBillingInfo {
  type: SubscriptionType;
  collectionsRemaining: number;
  nextCollectionDate?: string;
  weightLimit: number;
  currentWeight: number;
  periodStart: string;
  periodEnd: string;
}

export { SubscriptionType } from './subscriptionPlan';
