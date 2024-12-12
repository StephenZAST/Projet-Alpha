import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Bill {
  id?: string;
  userId: string;
  amount: number;
  status: 'pending' | 'paid' | 'failed' | 'refunded';
  paymentMethod: string;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store bill data
const billsTable = 'bills';

// Function to get bill data
export async function getBill(id: string): Promise<Bill | null> {
  const { data, error } = await supabase.from(billsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch bill', 'INTERNAL_SERVER_ERROR');
  }

  return data as Bill;
}

// Function to create bill
export async function createBill(billData: Bill): Promise<Bill> {
  const { data, error } = await supabase.from(billsTable).insert([billData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create bill', 'INTERNAL_SERVER_ERROR');
  }

  return data as Bill;
}

// Function to update bill
export async function updateBill(id: string, billData: Partial<Bill>): Promise<Bill> {
  const currentBill = await getBill(id);

  if (!currentBill) {
    throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(billsTable).update(billData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update bill', 'INTERNAL_SERVER_ERROR');
  }

  return data as Bill;
}

// Function to delete bill
export async function deleteBill(id: string): Promise<void> {
  const bill = await getBill(id);

  if (!bill) {
    throw new AppError(404, 'Bill not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(billsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete bill', 'INTERNAL_SERVER_ERROR');
  }
}
