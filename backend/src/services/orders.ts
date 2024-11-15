import { Timestamp, GeoPoint } from 'firebase-admin/firestore';
import { db } from './firebase';
import { Order, OrderStatus, OrderType, Location } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
import { getUserProfile } from './users';
import { optimizeRoute, RouteStop } from '../utils/routeOptimization';
import { validateOrderData } from '../validation/orders';
import { checkDeliverySlotAvailability } from './delivery';
import { Address } from '../models/address';

export async function createOrder(orderData: Partial<Order>): Promise<Order> {
  try {
    // Valider les données d'entrée
    const validationResult = await validateOrderData(orderData);
    if (!validationResult.isValid) {
      throw new AppError(errorCodes.INVALID_ORDER_DATA, validationResult.errors.join(', '));
    }

    // Vérifier la disponibilité du créneau
    const isSlotAvailable = await checkDeliverySlotAvailability(
      orderData.zoneId!,
      orderData.scheduledPickupTime!,
      orderData.scheduledDeliveryTime!
    );
    if (!isSlotAvailable) {
      throw new AppError(errorCodes.SLOT_NOT_AVAILABLE, 'Selected delivery slot is not available');
    }

    const order: Order = {
      ...orderData,
      status: OrderStatus.PENDING,
      creationDate: Timestamp.now(),
      updatedAt: Timestamp.now()
    };

    const orderRef = await db.collection('orders').add(order);
    return { ...order, id: orderRef.id };
  } catch (error) {
    console.error('Error creating order:', error);
    throw new AppError(errorCodes.ORDER_CREATION_FAILED, 'Failed to create order');
  }
}

export async function createOneClickOrder(
  userId: string,
  zoneId: string
): Promise<Order> {
  try {
    const userProfile = await getUserProfile(userId);
    if (!userProfile || !userProfile.defaultAddress) {
      throw new AppError(
        errorCodes.INVALID_USER_PROFILE,
        'User profile or default address not found'
      );
    }

    const defaultAddress = userProfile.defaultAddress as Address;
    const order: Partial<Order> = {
      userId,
      type: OrderType.ONE_CLICK,
      zoneId,
      status: OrderStatus.PENDING,
      pickupAddress: defaultAddress.formattedAddress,
      pickupLocation: {
        latitude: defaultAddress.coordinates.latitude,
        longitude: defaultAddress.coordinates.longitude
      },
      scheduledPickupTime: Timestamp.fromDate(new Date(Date.now() + 3600000)), // +1h
      scheduledDeliveryTime: Timestamp.fromDate(new Date(Date.now() + 7200000)), // +2h
      items: userProfile.defaultItems || [],
      specialInstructions: userProfile.defaultInstructions
    };

    return await createOrder(order);
  } catch (error) {
    console.error('Error creating one-click order:', error);
    throw new AppError(errorCodes.ONE_CLICK_ORDER_FAILED, 'Failed to create one-click order');
  }
}

export async function getOrdersByUser(
  userId: string,
  options: { status?: OrderStatus; limit?: number; startAfter?: Timestamp } = {}
): Promise<Order[]> {
  try {
    let query = db.collection('orders').where('userId', '==', userId);

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

    const ordersSnapshot = await query.get();
    return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
  } catch (error) {
    console.error('Error fetching orders:', error);
    throw new AppError(errorCodes.ORDERS_FETCH_FAILED, 'Failed to fetch orders');
  }
}

export async function getOrdersByZone(
  zoneId: string,
  status?: OrderStatus[]
): Promise<Order[]> {
  try {
    let query = db.collection('orders').where('zoneId', '==', zoneId);

    if (status && status.length > 0) {
      query = query.where('status', 'in', status);
    }

    const ordersSnapshot = await query.orderBy('creationDate', 'desc').get();
    return ordersSnapshot.docs.map(doc => ({ ...doc.data(), id: doc.id } as Order));
  } catch (error) {
    console.error('Error fetching zone orders:', error);
    throw new AppError(errorCodes.ZONE_ORDERS_FETCH_FAILED, 'Failed to fetch zone orders');
  }
}

export async function updateOrderStatus(
  orderId: string,
  status: OrderStatus,
  deliveryPersonId?: string
): Promise<Order> {
  try {
    const orderRef = db.collection('orders').doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw new AppError(errorCodes.ORDER_NOT_FOUND, 'Order not found');
    }

    const updateData: Partial<Order> = {
      status,
      updatedAt: Timestamp.now()
    };

    if (deliveryPersonId) {
      updateData.deliveryPersonId = deliveryPersonId;
    }

    if (status === OrderStatus.COMPLETED) {
      updateData.completionDate = Timestamp.now();
    }

    await orderRef.update(updateData);
    return { ...orderDoc.data(), ...updateData, id: orderId } as Order;
  } catch (error) {
    console.error('Error updating order status:', error);
    throw new AppError(errorCodes.ORDER_UPDATE_FAILED, 'Failed to update order status');
  }
}

export async function getDeliveryRoute(deliveryPersonId: string): Promise<RouteStop[]> {
  try {
    const ordersSnapshot = await db.collection('orders')
      .where('deliveryPersonId', '==', deliveryPersonId)
      .where('status', 'in', [OrderStatus.ACCEPTED, OrderStatus.IN_PROGRESS])
      .get();

    const orders = ordersSnapshot.docs.map(doc => ({
      ...doc.data(),
      id: doc.id
    }) as Order);

    const stops: RouteStop[] = orders.flatMap(order => [
      {
        type: 'pickup',
        location: order.pickupLocation,
        orderId: order.id,
        scheduledTime: order.scheduledPickupTime,
        address: order.pickupAddress
      },
      {
        type: 'delivery',
        location: order.deliveryLocation,
        orderId: order.id,
        scheduledTime: order.scheduledDeliveryTime,
        address: order.deliveryAddress
      }
    ]);

    return optimizeRoute(stops);
  } catch (error) {
    console.error('Error calculating delivery route:', error);
    throw new AppError(errorCodes.ROUTE_CALCULATION_FAILED, 'Failed to calculate delivery route');
  }
}

export interface OrderStatistics {
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
    let query = db.collection('orders');

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
    throw new AppError(errorCodes.STATS_FETCH_FAILED, 'Failed to fetch order statistics');
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
