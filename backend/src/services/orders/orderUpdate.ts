import { Timestamp } from 'firebase-admin/firestore';
import { Order, OrderStatus } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import { db } from '../firebase';

export async function updateOrderStatus(
  orderId: string,
  status: OrderStatus,
  deliveryPersonId?: string
): Promise<Order> {
  try {
    const orderRef = db.collection('orders').doc(orderId);
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

export async function updateOrder(orderId: string, userId: string, updates: Partial<Order>): Promise<Order> {
  try {
    const orderRef = db.collection('orders').doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw new AppError(404, 'Order not found', errorCodes.ORDER_NOT_FOUND);
    }

    const order = orderDoc.data() as Order;

    if (order.userId !== userId) {
      throw new AppError(403, 'Unauthorized to update this order', errorCodes.UNAUTHORIZED);
    }

    // Validate updates using validateOrderData if needed

    const updatedOrder = {
      ...order,
      ...updates,
      updatedAt: Timestamp.now()
    };

    await orderRef.update(updatedOrder);
    return updatedOrder;
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error updating order:', error);
    throw new AppError(500, 'Failed to update order', errorCodes.ORDER_UPDATE_FAILED);
  }
}

export async function cancelOrder(orderId: string, userId: string): Promise<Order> {
  try {
    return await updateOrderStatus(orderId, OrderStatus.CANCELLED, userId);
  } catch (error) {
    if (error instanceof AppError) throw error;
    console.error('Error cancelling order:', error);
    throw new AppError(500, 'Failed to cancel order', errorCodes.ORDER_CANCELLATION_FAILED);
  }
}
