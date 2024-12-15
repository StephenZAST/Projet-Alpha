import { createClient } from '@supabase/supabase-js';
import { LoyaltyProgram, LoyaltyTier } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const loyaltyProgramsTable = 'loyaltyPrograms';

export async function getLoyaltyProgram(id: string): Promise<LoyaltyProgram | null> {
  try {
    const { data, error } = await supabase.from(loyaltyProgramsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch loyalty program', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyProgram;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch loyalty program', errorCodes.DATABASE_ERROR);
  }
}

export async function createLoyaltyProgram(programData: LoyaltyProgram): Promise<LoyaltyProgram> {
  try {
    const { data, error } = await supabase.from(loyaltyProgramsTable).insert([programData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create loyalty program', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyProgram;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create loyalty program', errorCodes.DATABASE_ERROR);
  }
}

export async function updateLoyaltyProgram(id: string, programData: Partial<LoyaltyProgram>): Promise<LoyaltyProgram> {
  try {
    const currentProgram = await getLoyaltyProgram(id);

    if (!currentProgram) {
      throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(loyaltyProgramsTable).update(programData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update loyalty program', errorCodes.DATABASE_ERROR);
    }

    return data as LoyaltyProgram;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update loyalty program', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteLoyaltyProgram(id: string): Promise<void> {
  try {
    const program = await getLoyaltyProgram(id);

    if (!program) {
      throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(loyaltyProgramsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete loyalty program', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete loyalty program', errorCodes.DATABASE_ERROR);
  }
}
