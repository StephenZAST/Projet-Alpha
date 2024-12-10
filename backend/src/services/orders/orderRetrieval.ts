import { Timestamp } from 'firebase-admin/firestore';
import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { Query } from 'firebase-admin/firestore';
import { db } from '../firebase';

interface GetOrdersOptions {
  status?: OrderStatus;
  limit?: number;
  startAfter?: Timestamp;
  page?: number;
  userId?: string;
  startDate?: Date;
  endDate?: Date;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export async function getOrdersByUser(
  userId: string,
  options: GetOrdersOptions = {}
): Promise<Order[]> {
  try {
    let queryBuilder: Query = db.collection('orders');

    // Chain the where clauses
    if (options.status) {
      queryBuilder = queryBuilder.where('status', '==', options.status);
    }
    if (options.userId) {
      queryBuilder = queryBuilder.where('userId', '==', options.userId);
    }
    if (options.startDate) {
      queryBuilder = queryBuilder.where('creationDate', '>=', options.startDate);
    }
    if (options.endDate) {
      queryBuilder = queryBuilder.where('creationDate', '<=', options.endDate);
    }

    // Apply ordering
    if (options.sortBy) {
      queryBuilder = queryBuilder.orderBy(options.sortBy, options.sortOrder || 'desc');
    }

    // Apply startAfter if provided
    if (options.startAfter) {
      queryBuilder = queryBuilder.startAfter(options.startAfter);
    }

    // Apply limit if provided
    if (options.limit) {
      queryBuilder = queryBuilder.limit(options.limit);
    }

    // Apply pagination offset
    if (options.page && options.limit) {
      const offsetValue = (options.page - 1) * options.limit;
      queryBuilder = queryBuilder.offset(offsetValue);
    }

    const ordersSnapshot = await queryBuilder.get();
    return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
  } catch (error) {
    console.error('Error fetching orders:', error);
    throw new AppError(500, 'Failed to fetch orders', errorCodes.ORDER_FETCH_FAILED);
  }
}

export async function getOrdersByZone(
  zoneId: string,
  status?: OrderStatus[]
): Promise<Order[]> {
  try {
    let queryBuilder: Query = db.collection('orders');

    // Chain the where clauses
    queryBuilder = queryBuilder.where('zoneId', '==', zoneId);
    if (status && status.length > 0) {
      queryBuilder = queryBuilder.where('status', 'in', status);
    }

    // Apply ordering
    queryBuilder = queryBuilder.orderBy('creationDate', 'desc');

    const ordersSnapshot = await queryBuilder.get();
    return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
  } catch (error) {
    console.error('Error fetching zone orders:', error);
    throw new AppError(500, 'Failed to fetch zone orders', errorCodes.ZONES_FETCH_FAILED);
  }
}

export async function getOrderById(orderId: string, userId: string): Promise<Order> {
  try {
    const orderDoc = await db.collection('orders').doc(orderId).get();

    if (!orderDoc.exists) {
      throw new AppError(404, 'Order not found', errorCodes.ORDER_NOT_FOUND);
    }

    const order = orderDoc.data() as Order;

    if (order.userId !== userId) {
      throw new AppError(403, 'Unauthorized to access this order', errorCodes.UNAUTHORIZED);
    }

    return { ...order, id: orderDoc.id };
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error fetching order:', error);
    throw new AppError(500, 'Failed to fetch order', errorCodes.ORDER_FETCH_FAILED);
  }
}

export async function getAllOrders(options: GetOrdersOptions = {}): Promise<Order[]> {
  try {
    let queryBuilder: Query = db.collection('orders');

    // Chain the where clauses
    if (options.status) {
      queryBuilder = queryBuilder.where('status', '==', options.status);
    }
    if (options.userId) {
      queryBuilder = queryBuilder.where('userId', '==', options.userId);
    }
    if (options.startDate) {
      queryBuilder = queryBuilder.where('creationDate', '>=', options.startDate);
    }
    if (options.endDate) {
      queryBuilder = queryBuilder.where('creationDate', '<=', options.endDate);
    }

    // Apply ordering
    if (options.sortBy) {
      queryBuilder = queryBuilder.orderBy(options.sortBy, options.sortOrder || 'desc');
    }

    // Apply limit if provided
    if (options.limit) {
      queryBuilder = queryBuilder.limit(options.limit);
    }

    // Apply pagination offset
    if (options.page && options.limit) {
      const offsetValue = (options.page - 1) * options.limit;
      queryBuilder = queryBuilder.offset(offsetValue);
    }

    const ordersSnapshot = await queryBuilder.get();
    return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
  } catch (error) {
    console.error('Error fetching all orders:', error);
    throw new AppError(500, 'Failed to fetch all orders', errorCodes.ORDER_FETCH_FAILED);
  }
}
