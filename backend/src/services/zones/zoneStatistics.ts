import { createClient } from '@supabase/supabase-js';
import { Zone } from '../../models/zone';
import { Order } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const zonesTable = 'zones';
const ordersTable = 'orders';

/**
 * Get zone statistics
 */
export async function getZoneStatistics(zoneId: string, startDate?: Date, endDate?: Date): Promise<{
  totalOrders: number;
  averageDeliveryTime: number;
  totalRevenue: number;
  busyHours: { hour: number; count: number }[];
  deliveryPersonsStats: any[];
  period: { start: string | null; end: string | null };
}> {
  try {
    const zone = await getZone(zoneId);

    if (!zone) {
      throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
    }

    let query = supabase.from(ordersTable).select('*').eq('zoneId', zoneId);

    if (startDate) {
      query = query.gte('createdAt', startDate.toISOString());
    }

    if (endDate) {
      query = query.lte('createdAt', endDate.toISOString());
    }

    const { data: orders, error: ordersError } = await query;

    if (ordersError) {
      throw new AppError(500, 'Failed to fetch orders', errorCodes.DATABASE_ERROR);
    }

    const averageDeliveryTime = calculateAverageDeliveryTime(orders);
    const totalRevenue = calculateTotalRevenue(orders);
    const busyHours = calculateBusyHours(orders);
    const deliveryPersonsStats = await getDeliveryPersonsStats(zoneId);

    return {
      totalOrders: orders.length,
      averageDeliveryTime,
      totalRevenue,
      busyHours,
      deliveryPersonsStats,
      period: {
        start: startDate ? startDate.toISOString() : null,
        end: endDate ? endDate.toISOString() : null
      }
    };
  } catch (error) {
    console.error('Error fetching zone statistics:', error);
    throw new AppError(500, 'Failed to fetch zone statistics', errorCodes.DATABASE_ERROR);
  }
}

/**
 * Calculate average delivery time
 */
function calculateAverageDeliveryTime(orders: Order[]): number {
  if (orders.length === 0) return 0;

  const totalTime = orders.reduce((sum, order) => {
    if (order.deliveredAt && order.pickedUpAt) {
      return sum + (new Date(order.deliveredAt).getTime() - new Date(order.pickedUpAt).getTime());
    }
    return sum;
  }, 0);

  return totalTime / orders.length / (1000 * 60); // Convert to minutes
}

/**
 * Calculate total revenue
 */
function calculateTotalRevenue(orders: Order[]): number {
  return orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
}

/**
 * Calculate busy hours
 */
function calculateBusyHours(orders: Order[]): { hour: number; count: number }[] {
  const hourCounts = new Array(24).fill(0);

  orders.forEach(order => {
    if (order.pickedUpAt) {
      const hour = new Date(order.pickedUpAt).getHours();
      hourCounts[hour]++;
    }
  });

  return hourCounts.map((count, hour) => ({ hour, count }));
}

/**
 * Get delivery persons stats
 */
async function getDeliveryPersonsStats(zoneId: string): Promise<any[]> {
  const { data: deliveryPersons, error: deliveryPersonsError } = await supabase
    .from('deliveryPersons')
    .select('*')
    .eq('zoneId', zoneId);

  if (deliveryPersonsError) {
    throw new AppError(500, 'Failed to fetch delivery persons', errorCodes.DATABASE_ERROR);
  }

  if (!deliveryPersons) {
    return [];
  }

  return deliveryPersons.map(doc => ({ id: doc.id, ...doc }));
}

/**
 * Get zone by id
 */
async function getZone(id: string): Promise<Zone | null> {
  try {
    const { data, error } = await supabase.from(zonesTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch zone', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      return null;
    }

    return data as Zone;
  } catch (error) {
    console.error('Error fetching zone:', error);
    throw error;
  }
}
