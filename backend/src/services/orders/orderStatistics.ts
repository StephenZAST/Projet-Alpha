import { Timestamp } from 'firebase-admin/firestore';
import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { Query } from 'firebase-admin/firestore';
import { db } from '../firebase';

interface OrderStatistics {
  total: number;
  byStatus: Record<OrderStatus, number>;
  averageDeliveryTime: number;
  totalRevenue: number;
  averageOrderValue: number;
  period: {
    start: Timestamp;
    end: Timestamp;
  };
}

export async function getOrderStatistics(
  options: {
    zoneId?: string;
    startDate?: Timestamp;
    endDate?: Timestamp;
  } = {}
): Promise<OrderStatistics> {
  try {
    let query: Query = db.collection('orders');

    if (options.zoneId) {
      query = query.where('zoneId', '==', options.zoneId);
    }

    if (options.startDate) {
      query = query.where('creationDate', '>=', options.startDate);
    }

    if (options.endDate) {
      query = query.where('creationDate', '<=', options.endDate);
    }

    const ordersSnapshot = await query.get();
    const orders = ordersSnapshot.docs.map(doc => ({
      ...doc.data(),
      id: doc.id
    }) as Order);

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
        start: options.startDate || Timestamp.fromDate(new Date(0)),
        end: options.endDate || Timestamp.now()
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
    order.completionDate &&
    order.creationDate
  );

  if (completedOrders.length === 0) return 0;

  const totalTime = completedOrders.reduce((sum, order) => {
    const completionTime = order.completionDate!.toMillis() - order.creationDate!.toMillis();
    return sum + completionTime;
  }, 0);

  return Math.round((totalTime / completedOrders.length / (1000 * 60)) * 10) / 10; // Minutes avec 1 décimale
}
