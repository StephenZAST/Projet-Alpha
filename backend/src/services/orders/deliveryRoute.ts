import { Order, OrderStatus, RouteStop } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { optimizeRoute } from '../../utils/routeOptimization';
import { db } from '../firebase';

export async function getDeliveryRoute(deliveryPersonId: string): Promise<RouteStop[]> {
  try {
    const ordersSnapshot = await db.collection('orders')
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
