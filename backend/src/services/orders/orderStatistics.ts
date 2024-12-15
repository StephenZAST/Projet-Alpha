import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import supabase from '../../config/supabase';

interface OrderStatistics {
  total: number;
  byStatus: Record<OrderStatus, number>;
  averageDeliveryTime: number;
  totalRevenue: number;
  averageOrderValue: number;
  period: {
    start: Date;
    end: Date;
  };
}

export async function getOrderStatistics(
  options: {
    zoneId?: string;
    startDate?: Date;
    endDate?: Date;
  } = {}
): Promise<OrderStatistics> {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', OrderStatus.COMPLETED);

    if (error) {
      throw new AppError(500, 'Failed to fetch order statistics', errorCodes.STATS_FETCH_FAILED);
    }

    const orders = data;

    const byStatus = Object.values(OrderStatus).reduce((acc, status) => {
      acc[status] = orders.filter(o => o.status === status).length;
      return acc;
    }, {} as Record<OrderStatus, number>);

    const totalRevenue = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);

    return {
      total: orders.length,
      byStatus,
      averageDeliveryTime: calculateAverageDeliveryTime(orders),
      totalRevenue,
      averageOrderValue: orders.length > 0 ? totalRevenue / orders.length : 0,
      period: {
        start: options.startDate || new Date(),
        end: options.endDate || new Date()
      }
    };
  } catch (error) {
    console.error('Error fetching order statistics:', error);
    throw new AppError(500, 'Failed to fetch order statistics', errorCodes.STATS_FETCH_FAILED);
  }
}

function calculateAverageDeliveryTime(orders: Order[]): number {
  const completedOrders = orders.filter(
    order => order.status === OrderStatus.COMPLETED &&
    order.completionDate !== null &&
    order.creationDate !== null
  );

  if (completedOrders.length === 0) return 0;

  const totalTime = completedOrders.reduce((sum, order) => {
    const completionTime = new Date(order.completionDate as string).getTime() - new Date(order.creationDate as string).getTime();
    return sum + completionTime;
  }, 0);

  return Math.round((totalTime / completedOrders.length / (1000 * 60)) * 10) / 10; // Minutes avec 1 décimale
}
