import { createClient } from '@supabase/supabase-js';
import { ReferralProgram } from '../../models/referral';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const programsTable = 'referral-programs';

/**
 * Get referral program by id
 */
export async function getReferralProgram(id: string): Promise<ReferralProgram | null> {
  try {
    const { data, error } = await supabase.from(programsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch referral program', errorCodes.DATABASE_ERROR);
    }

    return data as ReferralProgram;
  } catch (error) {
    console.error('Error getting referral program:', error);
    throw error;
  }
}

/**
 * Get active referral program
 */
export async function getActiveReferralProgram(): Promise<ReferralProgram | null> {
  try {
    const { data, error } = await supabase.from(programsTable).select('*').eq('isActive', true).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch active referral program', errorCodes.DATABASE_ERROR);
    }

    return data as ReferralProgram;
  } catch (error) {
    console.error('Error getting active referral program:', error);
    throw error;
  }
}

/**
 * Create a new referral program
 */
export async function createReferralProgram(programData: Omit<ReferralProgram, 'id'>): Promise<ReferralProgram> {
  try {
    const { data, error } = await supabase.from(programsTable).insert([programData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create referral program', errorCodes.DATABASE_ERROR);
    }

    return { ...programData, id: data.id } as ReferralProgram;
  } catch (error) {
    console.error('Error creating referral program:', error);
    throw error;
  }
}

/**
 * Update a referral program
 */
export async function updateReferralProgram(id: string, programData: Partial<ReferralProgram>): Promise<ReferralProgram> {
  try {
    const currentProgram = await getReferralProgram(id);

    if (!currentProgram) {
      throw new AppError(404, 'Referral program not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(programsTable).update(programData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update referral program', errorCodes.DATABASE_ERROR);
    }

    return { ...currentProgram, ...programData } as ReferralProgram;
  } catch (error) {
    console.error('Error updating referral program:', error);
    throw error;
  }
}

/**
 * Delete a referral program
 */
export async function deleteReferralProgram(id: string): Promise<void> {
  try {
    const program = await getReferralProgram(id);

    if (!program) {
      throw new AppError(404, 'Referral program not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(programsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete referral program', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting referral program:', error);
    throw error;
  }
}
