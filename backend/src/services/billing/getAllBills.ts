import { createClient } from '@supabase/supabase-js';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Supabase environment variables not set.");
}

const supabase = createClient(supabaseUrl, supabaseKey);

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
