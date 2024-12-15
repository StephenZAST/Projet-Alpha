import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { MainService, AdditionalService } from '../order';

export enum SubscriptionType {
  NONE = 'NONE',
  BASIC = 'BASIC',
  PREMIUM = 'PREMIUM',
  VIP = 'VIP'
}

export interface SubscriptionPlan {
  id?: string;
  name: string;
  description: string;
  type: SubscriptionType;
  price: number;
  duration: number; // in months
  servicesIncluded: MainService[];
  additionalServicesIncluded: AdditionalService[];
  itemsPerMonth: number;
  weightLimitPerWeek: number;
  benefits: string[];
  isActive: boolean;
  discountPercentage?: number;
  minimumCommitment?: number; // in months
  earlyTerminationFee?: number;
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store subscription plan data
const subscriptionPlansTable = 'subscriptionPlans';

// Function to get subscription plan data
export async function getSubscriptionPlan(id: string): Promise<SubscriptionPlan | null> {
  const { data, error } = await supabase.from(subscriptionPlansTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch subscription plan', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionPlan;
}

// Function to create subscription plan
export async function createSubscriptionPlan(planData: SubscriptionPlan): Promise<SubscriptionPlan> {
  const { data, error } = await supabase.from(subscriptionPlansTable).insert([planData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create subscription plan', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionPlan;
}

// Function to update subscription plan
export async function updateSubscriptionPlan(id: string, planData: Partial<SubscriptionPlan>): Promise<SubscriptionPlan> {
  const currentPlan = await getSubscriptionPlan(id);

  if (!currentPlan) {
    throw new AppError(404, 'Subscription plan not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(subscriptionPlansTable).update(planData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update subscription plan', 'INTERNAL_SERVER_ERROR');
  }

  return data as SubscriptionPlan;
}

// Function to delete subscription plan
export async function deleteSubscriptionPlan(id: string): Promise<void> {
  const plan = await getSubscriptionPlan(id);

  if (!plan) {
    throw new AppError(404, 'Subscription plan not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(subscriptionPlansTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete subscription plan', 'INTERNAL_SERVER_ERROR');
  }
}
