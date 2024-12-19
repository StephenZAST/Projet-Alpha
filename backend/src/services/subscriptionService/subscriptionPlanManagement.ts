import { createClient } from '@supabase/supabase-js';
import { SubscriptionPlan, SubscriptionType } from '../../models/subscription';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const subscriptionPlansTable = 'subscriptionPlans';

export async function getSubscriptionPlan(id: string): Promise<SubscriptionPlan | null> {
  try {
    const { data, error } = await supabase.from(subscriptionPlansTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch subscription plan', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionPlan;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch subscription plan', errorCodes.DATABASE_ERROR);
  }
}

export async function createSubscriptionPlan(planData: SubscriptionPlan): Promise<SubscriptionPlan> {
  try {
    const { data, error } = await supabase.from(subscriptionPlansTable).insert([planData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create subscription plan', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionPlan;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create subscription plan', errorCodes.DATABASE_ERROR);
  }
}

export async function updateSubscriptionPlan(id: string, planData: Partial<SubscriptionPlan>): Promise<SubscriptionPlan> {
  try {
    const currentPlan = await getSubscriptionPlan(id);

    if (!currentPlan) {
      throw new AppError(404, 'Subscription plan not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(subscriptionPlansTable).update(planData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update subscription plan', errorCodes.DATABASE_ERROR);
    }

    return data as SubscriptionPlan;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update subscription plan', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteSubscriptionPlan(id: string): Promise<void> {
  try {
    const plan = await getSubscriptionPlan(id);

    if (!plan) {
      throw new AppError(404, 'Subscription plan not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(subscriptionPlansTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete subscription plan', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete subscription plan', errorCodes.DATABASE_ERROR);
  }
}
