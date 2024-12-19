import { createClient } from '@supabase/supabase-js';
import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = process.env.SUPABASE_URL as string;
const supabaseKey = process.env.SUPABASE_KEY as string;

const supabase = createClient(supabaseUrl, supabaseKey);

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
