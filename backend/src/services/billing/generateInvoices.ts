import { createClient } from '@supabase/supabase-js';
import { AppError, errorCodes } from '../../utils/errors';
import { Bill, BillStatus, PaymentStatus } from '../../models/bill';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

export async function generateInvoices(userId: string, startDate: Date, endDate: Date): Promise<Bill[]> {
  try {
    // Fetch orders for the user within the given time range
    const { data: orders, error: ordersError } = await supabase
      .from('orders')
      .select('*')
      .eq('userId', userId)
      .gte('createdAt', startDate.toISOString())
      .lte('createdAt', endDate.toISOString());

    if (ordersError) {
      throw new AppError(500, 'Failed to fetch orders', errorCodes.DATABASE_ERROR);
    }

    if (!orders) {
      return [];
    }

    // Create a bill for each order
    const bills: Bill[] = orders.map(order => ({
      id: '', // Let Supabase generate the ID
      userId: userId,
      orderId: order.id,
      items: order.items,
      subtotal: order.totalAmount,
      tax: 0,
      totalAmount: order.totalAmount,
      total: order.totalAmount,
      loyaltyPointsEarned: 0,
      discount: 0,
      status: BillStatus.PENDING, // Assuming you want to start with a PENDING status
      paymentStatus: PaymentStatus.PENDING,
      currency: 'USD',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // Due date 30 days from now
    }));

    // Insert the new bills into the database
    const { data: insertedBills, error: insertError } = await supabase
      .from('bills')
      .insert(bills)
      .select();

    if (insertError) {
      throw new AppError(500, 'Failed to create bills', errorCodes.DATABASE_ERROR);
    }

    return insertedBills || [];
  } catch (error) {
    console.error('Error generating invoices:', error);
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to generate invoices', errorCodes.INTERNAL_SERVER_ERROR);
  }
}
