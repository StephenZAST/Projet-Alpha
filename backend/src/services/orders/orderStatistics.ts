import { createClient } from '@supabase/supabase-js';
import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

export async function getOrderStatistics(options: {
  zoneId?: string;
  startDate?: Date;
  endDate?: Date;
}): Promise<{
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  totalOrdersDelivered: number;
}> {
  try {
    let query = supabase.from('orders').select('*', { count: 'exact' });

    if (options.zoneId) {
      query = query.eq('zoneId', options.zoneId);
    }

    if (options.startDate) {
      query = query.gte('createdAt', options.startDate.toISOString());
    }

    if (options.endDate) {
      query = query.lte('createdAt', options.endDate.toISOString());
    }

    const { data, error, count } = await query;

    if (error) {
      throw new AppError(500, 'Failed to fetch orders', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      return {
        totalOrders: 0,
        totalRevenue: 0,
        averageOrderValue: 0,
        totalOrdersDelivered: 0,
      };
    }

    const totalOrders = count || 0;
    const totalRevenue = data.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
    const totalOrdersDelivered = data.filter(
      (order) => order.status === OrderStatus.DELIVERED
    ).length;

    return {
      totalOrders,
      totalRevenue,
      averageOrderValue,
      totalOrdersDelivered,
    };
  } catch (error) {
    console.error('Error fetching order statistics:', error);
    throw new AppError(500, 'Failed to fetch order statistics', errorCodes.DATABASE_ERROR);
  }
}
