import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import  supabase  from '../../config/supabase';

export async function updateOrderStatus(
  orderId: string,
  status: OrderStatus,
  deliveryPersonId?: string
): Promise<Order> {
  try {
    const { data, error } = await supabase
      .from('orders')
      .update({ status, deliveryPersonId, updatedAt: new Date().toISOString() })
      .eq('id', orderId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update order status', errorCodes.ORDER_UPDATE_FAILED);
    }

    return data;
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error updating order status:', error);
    throw new AppError(500, 'Failed to update order status', errorCodes.ORDER_UPDATE_FAILED);
  }
}

export async function updateOrder(
  orderId: string,
  updates: Partial<Order>
): Promise<Order> {
  try {
    const { data, error } = await supabase
      .from('orders')
      .update(updates)
      .eq('id', orderId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update order', errorCodes.ORDER_UPDATE_FAILED);
    }

    return data;
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error updating order:', error);
    throw new AppError(500, 'Failed to update order', errorCodes.ORDER_UPDATE_FAILED);
  }
}

export async function cancelOrder(orderId: string): Promise<Order> {
  try {
    return await updateOrderStatus(orderId, OrderStatus.CANCELLED);
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error cancelling order:', error);
    throw new AppError(500, 'Failed to cancel order', errorCodes.ORDER_CANCELLATION_FAILED);
  }
}
