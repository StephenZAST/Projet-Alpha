import { db } from './firebase';
import { Order, OrderStatus, OrderType } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
import { getUserProfile } from './users';
import { calculateDeliveryRoute } from '../utils/routeOptimization';
import { GeoPoint } from 'firebase-admin/firestore';

export async function createOrder(order: Order): Promise<Order | null> {
  try {
    const orderRef = await db.collection('orders').add({
      ...order,
      creationDate: new Date(),
      status: OrderStatus.PENDING,
      lastUpdated: new Date()
    });
    return { ...order, orderId: orderRef.id };
  } catch (error) {
    console.error('Error creating order:', error);
    throw new AppError(errorCodes.ORDER_CREATION_FAILED, 'Failed to create order');
  }
}

export async function createOneClickOrder(userId: string, zoneId: string): Promise<Order | null> {
  try {
    // Récupérer le profil utilisateur pour les préférences
    const userProfile = await getUserProfile(userId);
    if (!userProfile) {
      throw new AppError(errorCodes.USER_NOT_FOUND, 'User profile not found');
    }

    // Créer la commande avec les préférences par défaut
    const order: Order = {
      userId,
      type: OrderType.ONE_CLICK,
      zoneId,
      status: OrderStatus.PENDING,
      serviceType: userProfile.defaultServiceType,
      pickupAddress: userProfile.defaultAddress,
      pickupLocation: userProfile.defaultLocation,
      creationDate: new Date(),
      lastUpdated: new Date()
    };

    return await createOrder(order);
  } catch (error) {
    console.error('Error creating one-click order:', error);
    throw new AppError(errorCodes.ONE_CLICK_ORDER_FAILED, 'Failed to create one-click order');
  }
}

export async function getOrdersByUser(userId: string): Promise<Order[]> {
  try {
    const ordersSnapshot = await db.collection('orders')
      .where('userId', '==', userId)
      .orderBy('creationDate', 'desc')
      .get();

    return ordersSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Order));
  } catch (error) {
    console.error('Error fetching orders:', error);
    throw new AppError(errorCodes.ORDERS_FETCH_FAILED, 'Failed to fetch orders');
  }
}

export async function getOrdersByZone(zoneId: string): Promise<Order[]> {
  try {
    const ordersSnapshot = await db.collection('orders')
      .where('zoneId', '==', zoneId)
      .where('status', 'in', [OrderStatus.PENDING, OrderStatus.ACCEPTED])
      .orderBy('creationDate', 'desc')
      .get();

    return ordersSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Order));
  } catch (error) {
    console.error('Error fetching zone orders:', error);
    throw new AppError(errorCodes.ZONE_ORDERS_FETCH_FAILED, 'Failed to fetch zone orders');
  }
}

export async function updateOrderStatus(
  orderId: string,
  status: OrderStatus,
  deliveryPersonId?: string
): Promise<boolean> {
  try {
    await db.collection('orders').doc(orderId).update({
      status,
      deliveryPersonId,
      lastUpdated: new Date()
    });
    return true;
  } catch (error) {
    console.error('Error updating order status:', error);
    throw new AppError(errorCodes.ORDER_UPDATE_FAILED, 'Failed to update order status');
  }
}

export async function getDeliveryRoute(deliveryPersonId: string): Promise<any[]> {
  try {
    // Récupérer toutes les commandes assignées au livreur
    const ordersSnapshot = await db.collection('orders')
      .where('deliveryPersonId', '==', deliveryPersonId)
      .where('status', 'in', [OrderStatus.ACCEPTED, OrderStatus.IN_PROGRESS])
      .get();

    const orders = ordersSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Order));

    // Extraire les points de collecte et de livraison
    const locations = orders.flatMap(order => [
      { type: 'pickup', location: order.pickupLocation, orderId: order.id },
      { type: 'delivery', location: order.deliveryLocation, orderId: order.id }
    ]);

    // Calculer l'itinéraire optimisé
    return calculateDeliveryRoute(locations);
  } catch (error) {
    console.error('Error calculating delivery route:', error);
    throw new AppError(errorCodes.ROUTE_CALCULATION_FAILED, 'Failed to calculate delivery route');
  }
}

export async function getOrderStatistics(zoneId?: string, startDate?: Date, endDate?: Date) {
  try {
    let query = db.collection('orders');

    if (zoneId) {
      query = query.where('zoneId', '==', zoneId);
    }

    if (startDate) {
      query = query.where('creationDate', '>=', startDate);
    }

    if (endDate) {
      query = query.where('creationDate', '<=', endDate);
    }

    const ordersSnapshot = await query.get();
    const orders = ordersSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Order));

    return {
      total: orders.length,
      completed: orders.filter(o => o.status === OrderStatus.COMPLETED).length,
      pending: orders.filter(o => o.status === OrderStatus.PENDING).length,
      inProgress: orders.filter(o => o.status === OrderStatus.IN_PROGRESS).length,
      cancelled: orders.filter(o => o.status === OrderStatus.CANCELLED).length,
      averageDeliveryTime: calculateAverageDeliveryTime(orders)
    };
  } catch (error) {
    console.error('Error fetching order statistics:', error);
    throw new AppError(errorCodes.STATS_FETCH_FAILED, 'Failed to fetch order statistics');
  }
}

function calculateAverageDeliveryTime(orders: Order[]): number {
  const completedOrders = orders.filter(o => 
    o.status === OrderStatus.COMPLETED && o.completionDate && o.creationDate
  );

  if (completedOrders.length === 0) return 0;

  const totalTime = completedOrders.reduce((sum, order) => {
    const completionTime = order.completionDate!.getTime() - order.creationDate!.getTime();
    return sum + completionTime;
  }, 0);

  return totalTime / completedOrders.length / (1000 * 60 * 60); // Convertir en heures
}
