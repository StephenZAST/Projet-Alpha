import { Order, OrderStatus, RouteStop } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { optimizeRoute } from '../../utils/routeOptimization';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

export async function getDeliveryRoute(deliveryPersonId: string): Promise<RouteStop[]> {
  try {
    const { data: orders, error } = await supabase
      .from('orders')
      .select('*')
      .eq('deliveryPersonId', deliveryPersonId)
      .in('status', [OrderStatus.ACCEPTED, OrderStatus.PICKED_UP]);

    if (error) {
      console.error('Error fetching orders:', error);
      throw new AppError(500, 'Failed to get delivery route', errorCodes.DATABASE_ERROR);
    }

    const stops: RouteStop[] = [];
    if (orders) {
      orders.forEach(order => {
        stops.push(
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
        );
      });
    }

    // Optimiser la route
    const optimizedStops = await optimizeRoute(stops);
    return optimizedStops;
  } catch (error) {
    console.error('Error getting delivery route:', error);
    throw new AppError(500, 'Failed to get delivery route', errorCodes.ROUTE_GENERATION_FAILED);
  }
}
