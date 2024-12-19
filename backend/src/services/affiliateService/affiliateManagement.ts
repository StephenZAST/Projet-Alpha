import { createClient } from '@supabase/supabase-js';
import { Affiliate, AffiliateStatus, PaymentMethod } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Supabase environment variables not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

export async function createAffiliate(
  firstName: string,
  lastName: string,
  email: string,
  phoneNumber: string,
  address: string,
  orderPreferences: Affiliate['orderPreferences'],
  paymentInfo: Affiliate['paymentInfo']
): Promise<Affiliate> {
  try {
    const { data, error } = await supabase
      .from('affiliates')
      .insert([
        {
          firstName,
          lastName,
          email,
          phoneNumber,
          address,
          orderPreferences,
          paymentInfo,
          status: 'pending' as AffiliateStatus,
          commissionRate: 0.05, // Default commission rate
          referralCode: Math.random().toString(36).substring(2, 8).toUpperCase(), // Generate a random 6-character code
        },
      ])
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to create affiliate', errorCodes.DATABASE_ERROR);
    }

    return data as Affiliate;
  } catch (error) {
    console.error('Error creating affiliate:', error);
    throw new AppError(500, 'Failed to create affiliate', errorCodes.DATABASE_ERROR);
  }
}

export async function approveAffiliate(affiliateId: string): Promise<void> {
  try {
    const { error } = await supabase
      .from('affiliates')
      .update({ status: 'approved' })
      .eq('id', affiliateId);

    if (error) {
      throw new AppError(500, 'Failed to approve affiliate', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error approving affiliate:', error);
    throw new AppError(500, 'Failed to approve affiliate', errorCodes.DATABASE_ERROR);
  }
}

export async function getAffiliateProfile(affiliateId: string): Promise<Affiliate> {
  try {
    const { data, error } = await supabase
      .from('affiliates')
      .select('*')
      .eq('id', affiliateId)
      .single();

    if (error) {
      throw new AppError(500, 'Failed to fetch affiliate profile', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(404, 'Affiliate not found', errorCodes.NOT_FOUND);
    }

    return data as Affiliate;
  } catch (error) {
    console.error('Error fetching affiliate profile:', error);
    throw error;
  }
}

export async function updateProfile(
  affiliateId: string,
  updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>
): Promise<void> {
  try {
    const { error } = await supabase
      .from('affiliates')
      .update(updates)
      .eq('id', affiliateId);

    if (error) {
      throw new AppError(500, 'Failed to update affiliate profile', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error updating affiliate profile:', error);
    throw new AppError(500, 'Failed to update affiliate profile', errorCodes.DATABASE_ERROR);
  }
}

export async function getPendingAffiliates(): Promise<Affiliate[]> {
  try {
    const { data, error } = await supabase
      .from('affiliates')
      .select('*')
      .eq('status', 'pending');

    if (error) {
      throw new AppError(500, 'Failed to fetch pending affiliates', errorCodes.DATABASE_ERROR);
    }

    return (data || []) as Affiliate[];
  } catch (error) {
    console.error('Error fetching pending affiliates:', error);
    throw new AppError(500, 'Failed to fetch pending affiliates', errorCodes.DATABASE_ERROR);
  }
}

export async function getAllAffiliates(): Promise<Affiliate[]> {
  try {
    const { data, error } = await supabase
      .from('affiliates')
      .select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch all affiliates', errorCodes.DATABASE_ERROR);
    }

    return (data || []) as Affiliate[];
  } catch (error) {
    console.error('Error fetching all affiliates:', error);
    throw new AppError(500, 'Failed to fetch all affiliates', errorCodes.DATABASE_ERROR);
  }
}

export async function getAffiliateById(affiliateId: string): Promise<Affiliate | null> {
  try {
    const { data, error } = await supabase
      .from('affiliates')
      .select('*')
      .eq('id', affiliateId)
      .single();

    if (error) {
      throw new AppError(500, 'Failed to fetch affiliate', errorCodes.DATABASE_ERROR);
    }

    return data as Affiliate || null;
  } catch (error) {
    console.error('Error fetching affiliate:', error);
    throw new AppError(500, 'Failed to fetch affiliate', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteAffiliate(affiliateId: string): Promise<void> {
  try {
    const { error } = await supabase
      .from('affiliates')
      .delete()
      .eq('id', affiliateId);

    if (error) {
      throw new AppError(500, 'Failed to delete affiliate', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting affiliate:', error);
    throw new AppError(500, 'Failed to delete affiliate', errorCodes.DATABASE_ERROR);
  }
}

export async function updateAffiliate(affiliateId: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
  try {
    const { data, error } = await supabase
      .from('affiliates')
      .update(affiliateData)
      .eq('id', affiliateId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update affiliate', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(404, 'Affiliate not found', errorCodes.NOT_FOUND);
    }

    return data as Affiliate;
  } catch (error) {
    console.error('Error updating affiliate:', error);
    throw new AppError(500, 'Failed to update affiliate', errorCodes.DATABASE_ERROR);
  }
}
