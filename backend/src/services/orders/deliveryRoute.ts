import { Order, OrderStatus, RouteStop as RouteStopModel } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { optimizeRoute, RouteStop as RouteStopUtils } from '../../utils/routeOptimization';
import supabase from '../../config/supabase';
import { Timestamp } from 'firebase-admin/firestore';

export async function getDeliveryRoute(deliveryPersonId: string): Promise<RouteStopUtils[]> {
  try {
    const { data: orders, error } = await supabase
      .from('orders')
      .select('*')
      .eq('deliveryPersonId', deliveryPersonId)
      .in('status', [OrderStatus.ACCEPTED, OrderStatus.PICKED_UP, OrderStatus.DELIVERING]);

    if (error) {
      console.error('Error fetching orders:', error);
      throw new AppError(500, 'Failed to get delivery route', errorCodes.DATABASE_ERROR);
    }

    const stops: RouteStopModel[] = [];
    if (orders) {
      orders.forEach(order => {
        stops.push(
          {
            type: 'pickup',
            location: order.pickupLocation,
            orderId: order.id,
            scheduledTime: new Date(order.scheduledPickupTime),
            address: order.pickupAddress
          },
          {
            type: 'delivery',
            location: order.deliveryLocation,
            orderId: order.id,
            scheduledTime: new Date(order.scheduledDeliveryTime),
            address: order.deliveryAddress
          }
        );
      });
    }

    // Convert RouteStopModel to RouteStopUtils
    const routeStopsUtils: RouteStopUtils[] = stops.map((routeStop) => ({
      ...routeStop,
      scheduledTime: new Timestamp(
        routeStop.scheduledTime.getTime() / 1000,
        (routeStop.scheduledTime.getTime() % 1000) * 1e6
      )
    }));

    // Optimiser la route
    const optimizedStops = await optimizeRoute(routeStopsUtils);
    return optimizedStops;
  } catch (error) {
    console.error('Error getting delivery route:', error);
    throw new AppError(500, 'Failed to get delivery route', errorCodes.ROUTE_GENERATION_FAILED);
  }
}
