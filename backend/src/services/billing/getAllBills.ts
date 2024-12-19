import { createClient } from '@supabase/supabase-js';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Supabase environment variables not set.");
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

export async function getAllBills(): Promise<any[]> {
  try {
    const { data, error } = await supabase
      .from('bills')
      .select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch all bills', errorCodes.DATABASE_ERROR);
    }

    return data || [];
  } catch (error) {
    console.error('Error fetching all bills:', error);
    throw error;
  }
}
