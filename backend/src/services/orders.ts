import { Timestamp, GeoPoint } from 'firebase-admin/firestore';
import { db } from './firebase';
import { Order, OrderStatus, OrderType, Location, OrderItem, MainService, PriceType, ItemType } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
import { getUserProfile } from './users';
import { optimizeRoute, RouteStop } from '../utils/routeOptimization';
import { validateOrderData } from '../validation/orders';
import { checkDeliverySlotAvailability } from './delivery';
import { Query, CollectionReference } from 'firebase-admin/firestore';
import { Address } from '../models/user';

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


export class OrderService {
  private ordersRef: CollectionReference;

  constructor() {
    this.ordersRef = db.collection('orders');
  }

  async createOrder(orderData: Partial<Order>): Promise<Order> {
    try {
      // Valider les données d'entrée
      const validationResult = validateOrderData(orderData);
      if (!validationResult.isValid) {
        throw new AppError(400, validationResult.errors.join(', '), errorCodes.INVALID_ORDER_DATA);
      }

      // Vérifier la disponibilité du créneau
      const isSlotAvailable = await checkDeliverySlotAvailability(
        orderData.zoneId!,
        orderData.scheduledPickupTime!,
        orderData.scheduledDeliveryTime!
      );
      if (!isSlotAvailable) {
        throw new AppError(400, 'Selected delivery slot is not available', errorCodes.SLOT_NOT_AVAILABLE);
      }

      // S'assurer que tous les champs requis sont présents
      if (!orderData.userId || !orderData.type || !orderData.items || !orderData.zoneId) {
        throw new AppError(400, 'Missing required fields', errorCodes.INVALID_ORDER_DATA);
      }

      const order: Order = {
        userId: orderData.userId,
        type: orderData.type,
        items: orderData.items,
        status: OrderStatus.PENDING,
        pickupAddress: orderData.pickupAddress!,
        pickupLocation: orderData.pickupLocation!,
        deliveryAddress: orderData.deliveryAddress!,
        deliveryLocation: orderData.deliveryLocation!,
        scheduledPickupTime: orderData.scheduledPickupTime!,
        scheduledDeliveryTime: orderData.scheduledDeliveryTime!,
        creationDate: Timestamp.now(),
        updatedAt: Timestamp.now(),
        totalAmount: orderData.totalAmount!,
        zoneId: orderData.zoneId,
        serviceType: orderData.serviceType!
      };

      const orderRef = await this.ordersRef.add(order);
      return { ...order, id: orderRef.id };
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error('Error creating order:', error);
      throw new AppError(500, 'Failed to create order', errorCodes.ORDER_CREATION_FAILED);
    }
  }

  async createOneClickOrder(
    userId: string,
    zoneId: string
  ): Promise<Order> {
    try {
      const userProfile = await getUserProfile(userId);
      if (!userProfile || !userProfile.defaultAddress) {
        throw new AppError(404, 'User profile or default address not found', errorCodes.INVALID_USER_PROFILE);
      }

      const defaultAddress = userProfile.defaultAddress as Address;
      if (!defaultAddress.coordinates) {
        throw new AppError(400, 'Default address coordinates not found', errorCodes.INVALID_ADDRESS_DATA);
      }
      const order: Partial<Order> = {
        userId,
        type: OrderType.ONE_CLICK,
        zoneId,
        status: OrderStatus.PENDING,
        pickupAddress: defaultAddress.street, // Use defaultAddress.street
        pickupLocation: {
          latitude: defaultAddress.coordinates.latitude,
          longitude: defaultAddress.coordinates.longitude
        },
        scheduledPickupTime: Timestamp.fromDate(new Date(Date.now() + 3600000)), // +1h
        scheduledDeliveryTime: Timestamp.fromDate(new Date(Date.now() + 7200000)), // +2h
        items: (userProfile.defaultItems || []).map(item => ({
          id: item.id,
          quantity: item.quantity,
          itemType: ItemType.PRODUCT, // Use ItemType enum
          mainService: MainService.PRESSING, // Provide a default MainService value
          price: 0, // Provide a default value or handle this based on your logic
          priceType: PriceType.FIXED // Provide a default PriceType value
        })),
        specialInstructions: userProfile.defaultInstructions
      };

      return await this.createOrder(order);
    } catch (error) {
      console.error('Error creating one-click order:', error);
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to create one-click order', errorCodes.ONE_CLICK_ORDER_FAILED);
    }
  }

  async getOrdersByUser(
    userId: string,
    options: { status?: OrderStatus; limit?: number; startAfter?: Timestamp, page?: number } = {} // Add page parameter
  ): Promise<Order[]> {
    try {
      let query = this.ordersRef.where('userId', '==', userId);

      if (options.status) {
        query = query.where('status', '==', options.status);
      }

      query = query.orderBy('creationDate', 'desc');

      if (options.startAfter) {
        query = query.startAfter(options.startAfter);
      }

      if (options.limit) {
        query = query.limit(options.limit);
      }

      // Apply pagination
      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.offset(offset);
      }

      const ordersSnapshot = await query.get();
      return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
    } catch (error) {
      console.error('Error fetching orders:', error);
      throw new AppError(500, 'Failed to fetch orders', errorCodes.ORDERS_FETCH_FAILED);
    }
  }

  async getOrdersByZone(
    zoneId: string,
    status?: OrderStatus[]
  ): Promise<Order[]> {
    try {
      let query = this.ordersRef.where('zoneId', '==', zoneId);

      if (status && status.length > 0) {
        query = query.where('status', 'in', status);
      }

      const ordersSnapshot = await query.orderBy('creationDate', 'desc').get();
      return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
    } catch (error) {
      console.error('Error fetching zone orders:', error);
      throw new AppError(500, 'Failed to fetch zone orders', errorCodes.ZONE_ORDERS_FETCH_FAILED);
    }
  }

  async updateOrderStatus(
    orderId: string,
    status: OrderStatus,
    deliveryPersonId?: string
  ): Promise<Order> {
    try {
      const orderRef = this.ordersRef.doc(orderId);
      const orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        throw new AppError(404, 'Order not found', errorCodes.ORDER_NOT_FOUND);
      }

      const order = orderDoc.data() as Order;
      const updateData: Partial<Order> = {
        status,
        updatedAt: Timestamp.now()
      };

      if (deliveryPersonId) {
        updateData.deliveryPersonId = deliveryPersonId;
      }

      await orderRef.update(updateData);
      return { ...order, ...updateData };
    } catch (error) {
      if (error instanceof AppError) throw error;
      console.error('Error updating order status:', error);
      throw new AppError(500, 'Failed to update order status', errorCodes.ORDER_UPDATE_FAILED);
    }
  }

  async getDeliveryRoute(deliveryPersonId: string): Promise<RouteStop[]> {
    try {
      const ordersSnapshot = await this.ordersRef
        .where('deliveryPersonId', '==', deliveryPersonId)
        .where('status', 'in', [OrderStatus.ACCEPTED, OrderStatus.PICKED_UP])
        .get();

      const stops: RouteStop[] = [];
      ordersSnapshot.forEach(doc => {
        const order = doc.data() as Order;
        stops.push(
          {
            type: 'pickup',
            location: order.pickupLocation,
            orderId: doc.id,
            scheduledTime: order.scheduledPickupTime,
            address: order.pickupAddress
          },
          {
            type: 'delivery',
            location: order.deliveryLocation,
            orderId: doc.id,
            scheduledTime: order.scheduledDeliveryTime,
            address: order.deliveryAddress
          }
        );
      });

      // Optimiser la route
      const optimizedStops = await optimizeRoute(stops);
      return optimizedStops;
    } catch (error) {
      console.error('Error getting delivery route:', error);
      throw new AppError(500, 'Failed to get delivery route', errorCodes.ROUTE_GENERATION_FAILED);
    }
  }

  async getOrderStatistics(
    options: {
      zoneId?: string;
      startDate?: Timestamp;
      endDate?: Timestamp;
    } = {}
  ): Promise<OrderStatistics> {
    try {
      let query: Query = this.ordersRef;

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
        averageDeliveryTime: this.calculateAverageDeliveryTime(orders),
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

  private calculateAverageDeliveryTime(orders: Order[]): number {
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
}
