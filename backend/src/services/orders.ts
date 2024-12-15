import { createClient } from '@supabase/supabase-js';
import { Order, OrderStatus, OrderType, MainService, PriceType, PaymentMethod, OrderItem, OrderInput, GetOrdersOptions, OrderStatistics } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
import { getUserProfile } from './users';
import { optimizeRoute, RouteStop } from '../utils/routeOptimization';
import { validateOrderData } from '../validation/orders';
import { checkDeliverySlotAvailability } from './delivery';
import { createOrder as createOrderService, createOneClickOrder as createOneClickOrderService } from './orders/orderCreation';
import { getOrdersByUser, getOrdersByZone, getOrderById, getAllOrders } from './orders/orderRetrieval';
import { updateOrderStatus, updateOrder, cancelOrder } from './orders/orderUpdate';
import { getDeliveryRoute } from './orders/deliveryRoute';
import { getOrderStatistics } from './orders/orderStatistics';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const ordersTable = 'orders';

export class OrderService {
  private ordersTable = 'orders';

  /**
   * Create a new order
   */
  async createOrder(orderData: Partial<Order>): Promise<Order> {
    return createOrderService(orderData);
  }

  /**
   * Create a one-click order
   */
  async createOneClickOrder(
    userId: string,
    zoneId: string
  ): Promise<Order> {
    return createOneClickOrderService({ userId, zoneId });
  }

  /**
   * Get orders by user
   */
  async getOrdersByUser(
    userId: string,
    options: GetOrdersOptions = {}
  ): Promise<Order[]> {
    return getOrdersByUser(userId, options);
  }

  /**
   * Get orders by zone
   */
  async getOrdersByZone(
    zoneId: string,
    status?: OrderStatus[]
  ): Promise<Order[]> {
    return getOrdersByZone(zoneId, status);
  }

  /**
   * Update order status
   */
  async updateOrderStatus(
    orderId: string,
    status: OrderStatus,
    deliveryPersonId?: string
  ): Promise<Order> {
    return updateOrderStatus(orderId, status, deliveryPersonId);
  }

  /**
   * Get delivery route
   */
  async getDeliveryRoute(deliveryPersonId: string): Promise<RouteStop[]> {
    return getDeliveryRoute(deliveryPersonId);
  }

  /**
   * Get order statistics
   */
  async getOrderStatistics(
    options: {
      zoneId?: string;
      startDate?: string;
      endDate?: string;
    } = {}
  ): Promise<OrderStatistics> {
    return getOrderStatistics(options);
  }

  /**
   * Get order by id
   */
  async getOrderById(orderId: string): Promise<Order | null> {
    return getOrderById(orderId);
  }

  /**
   * Update order
   */
  async updateOrder(orderId: string, updates: Partial<Order>): Promise<Order> {
    return updateOrder(orderId, updates);
  }

  /**
   * Cancel order
   */
  async cancelOrder(orderId: string): Promise<Order> {
    return cancelOrder(orderId);
  }

  /**
   * Get all orders
   */
  async getAllOrders(options: GetOrdersOptions = {}): Promise<Order[]> {
    return getAllOrders(options);
  }

  /**
   * Delete order
   */
  async deleteOrder(orderId: string): Promise<void> {
    return deleteOrder(orderId);
  }
}
