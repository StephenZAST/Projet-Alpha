import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import supabase from '../../config/supabase';

interface GetOrdersOptions {
  status?: OrderStatus;
  limit?: number;
  startAfter?: any;
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
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('userId', userId);

    if (error) {
      throw new AppError(500, 'Failed to fetch orders', errorCodes.ORDER_FETCH_FAILED);
    }

    return data;
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
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('zoneId', zoneId);

    if (error) {
      throw new AppError(500, 'Failed to fetch zone orders', errorCodes.ZONES_FETCH_FAILED);
    }

    return data;
  } catch (error) {
    console.error('Error fetching zone orders:', error);
    throw new AppError(500, 'Failed to fetch zone orders', errorCodes.ZONES_FETCH_FAILED);
  }
}

export async function getOrderById(orderId: string, userId: string): Promise<Order> {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId);

    if (error) {
      throw new AppError(404, 'Order not found', errorCodes.ORDER_NOT_FOUND);
    }

    const order = data[0];

    if (order.userId !== userId) {
      throw new AppError(403, 'Unauthorized to access this order', errorCodes.UNAUTHORIZED);
    }

    return order;
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error fetching order:', error);
    throw new AppError(500, 'Failed to fetch order', errorCodes.ORDER_FETCH_FAILED);
  }
}

export async function getAllOrders(options: GetOrdersOptions = {}): Promise<Order[]> {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch all orders', errorCodes.ORDER_FETCH_FAILED);
    }

    return data;
  } catch (error) {
    console.error('Error fetching all orders:', error);
    throw new AppError(500, 'Failed to fetch all orders', errorCodes.ORDER_FETCH_FAILED);
  }
}
