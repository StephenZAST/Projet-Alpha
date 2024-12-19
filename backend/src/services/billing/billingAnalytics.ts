import { createClient } from '@supabase/supabase-js';
import { Bill, BillStatus } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const billsTable = 'bills';

export async function getBillingStats(startDate: Date, endDate: Date): Promise<{
  totalRevenue: number;
  totalBills: number;
  averageBillAmount: number;
  billsByStatus: { [status: string]: number };
}> {
  try {
    const { data, error } = await supabase
      .from(billsTable)
      .select('*')
      .gte('createdAt', startDate.toISOString())
      .lte('createdAt', endDate.toISOString());

    if (error) {
      throw new AppError(500, 'Failed to fetch bills', errorCodes.DATABASE_ERROR);
    }

    const bills = data as Bill[];

    const totalRevenue = bills.reduce((sum, bill) => sum + bill.total, 0);
    const totalBills = bills.length;
    const averageBillAmount = totalBills > 0 ? totalRevenue / totalBills : 0;
    const billsByStatus = bills.reduce((acc, bill) => {
      acc[bill.status] = (acc[bill.status] || 0) + 1;
      return acc;
    }, {} as { [status: string]: number });

    return {
      totalRevenue,
      totalBills,
      averageBillAmount,
      billsByStatus
    };
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch billing stats', errorCodes.DATABASE_ERROR);
  }
}
