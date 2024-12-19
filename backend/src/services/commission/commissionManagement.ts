import { createClient } from '@supabase/supabase-js';
import { Commission } from '../../models/commission';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const commissionsTable = 'commissions';

export async function getCommission(id: string): Promise<Commission | null> {
  try {
    const { data, error } = await supabase.from(commissionsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch commission', errorCodes.DATABASE_ERROR);
    }

    return data as Commission;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch commission', errorCodes.DATABASE_ERROR);
  }
}

export async function createCommission(commissionData: Commission): Promise<Commission> {
  try {
    const { data, error } = await supabase.from(commissionsTable).insert([commissionData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create commission', errorCodes.DATABASE_ERROR);
    }

    return data as Commission;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create commission', errorCodes.DATABASE_ERROR);
  }
}

export async function updateCommission(id: string, commissionData: Partial<Commission>): Promise<Commission> {
  try {
    const currentCommission = await getCommission(id);

    if (!currentCommission) {
      throw new AppError(404, 'Commission not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(commissionsTable).update(commissionData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update commission', errorCodes.DATABASE_ERROR);
    }

    return data as Commission;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update commission', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteCommission(id: string): Promise<void> {
  try {
    const commission = await getCommission(id);

    if (!commission) {
      throw new AppError(404, 'Commission not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(commissionsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete commission', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete commission', errorCodes.DATABASE_ERROR);
  }
}
