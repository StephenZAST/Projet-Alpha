import { createClient } from '@supabase/supabase-js';
import { Referral } from '../../models/referral';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const referralsTable = 'referrals';

/**
 * Get referral by id
 */
export async function getReferral(id: string): Promise<Referral | null> {
  try {
    const { data, error } = await supabase.from(referralsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch referral', errorCodes.DATABASE_ERROR);
    }

    return data as Referral;
  } catch (error) {
    console.error('Error getting referral:', error);
    throw error;
  }
}

/**
 * Create a new referral
 */
export async function createReferral(referralData: Omit<Referral, 'id'>): Promise<Referral> {
  try {
    const { data, error } = await supabase.from(referralsTable).insert([referralData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create referral', errorCodes.DATABASE_ERROR);
    }

    return { ...referralData, id: data.id } as Referral;
  } catch (error) {
    console.error('Error creating referral:', error);
    throw error;
  }
}

/**
 * Update a referral
 */
export async function updateReferral(id: string, referralData: Partial<Referral>): Promise<Referral> {
  try {
    const currentReferral = await getReferral(id);

    if (!currentReferral) {
      throw new AppError(404, 'Referral not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(referralsTable).update(referralData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update referral', errorCodes.DATABASE_ERROR);
    }

    return { ...currentReferral, ...referralData } as Referral;
  } catch (error) {
    console.error('Error updating referral:', error);
    throw error;
  }
}

/**
 * Delete a referral
 */
export async function deleteReferral(id: string): Promise<void> {
  try {
    const referral = await getReferral(id);

    if (!referral) {
      throw new AppError(404, 'Referral not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(referralsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete referral', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting referral:', error);
    throw error;
  }
}
