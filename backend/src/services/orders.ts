import { Order, OrderStatus, OrderType, Location, OrderItem, MainService, PriceType, ItemType } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
import { getUserProfile } from './users';
import { optimizeRoute, RouteStop } from '../utils/routeOptimization';
import { validateOrderData } from '../validation/orders';
import { checkDeliverySlotAvailability } from './delivery';
import { Query, CollectionReference, Timestamp } from 'firebase-admin/firestore';
import { Address, User } from '../models/user';
import { db } from './firebase'; // Import db
import { createOrder, createOneClickOrder } from './orders/orderCreation';
import { getOrdersByUser, getOrdersByZone, getOrderById, getAllOrders } from './orders/orderRetrieval';
import { updateOrderStatus, updateOrder, cancelOrder } from './orders/orderUpdate';
import { getDeliveryRoute } from './orders/deliveryRoute';
import { getOrderStatistics } from './orders/orderStatistics';

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

export class OrderService {
  private ordersRef: CollectionReference;

  constructor() {
    this.ordersRef = db.collection('orders');
  }

  async createOrder(orderData: Partial<Order>): Promise<Order> {
    return createOrder(orderData);
  }

  async createOneClickOrder(
    userId: string,
    zoneId: string
  ): Promise<Order> {
    return createOneClickOrder(userId, zoneId);
  }

  async getOrdersByUser(
    userId: string,
    options: GetOrdersOptions = {}
  ): Promise<Order[]> {
    return getOrdersByUser(userId, options);
  }

  async getOrdersByZone(
    zoneId: string,
    status?: OrderStatus[]
  ): Promise<Order[]> {
    return getOrdersByZone(zoneId, status);
  }

  async updateOrderStatus(
    orderId: string,
    status: OrderStatus,
    deliveryPersonId?: string
  ): Promise<Order> {
    return updateOrderStatus(orderId, status, deliveryPersonId);
  }

  async getDeliveryRoute(deliveryPersonId: string): Promise<RouteStop[]> {
    return getDeliveryRoute(deliveryPersonId);
  }

  async getOrderStatistics(
    options: {
      zoneId?: string;
      startDate?: Timestamp;
      endDate?: Timestamp;
    } = {}
  ): Promise<OrderStatistics> {
    return getOrderStatistics(options);
  }

  async getOrderById(orderId: string, userId: string): Promise<Order> {
    return getOrderById(orderId, userId);
  }

  async updateOrder(orderId: string, userId: string, updates: Partial<Order>): Promise<Order> {
    return updateOrder(orderId, userId, updates);
  }

  async cancelOrder(orderId: string, userId: string): Promise<Order> {
    return cancelOrder(orderId, userId);
  }

  async getAllOrders(options: GetOrdersOptions = {}): Promise<Order[]> {
    return getAllOrders(options);
  }
}
