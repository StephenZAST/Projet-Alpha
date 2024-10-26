import { db } from './firebase';
import { Order, OrderStatus } from '../models/order';

export async function createOrder(order: Order): Promise<Order | null> {
  try {
    const orderRef = await db.collection('orders').add({
      ...order,
      creationDate: new Date(),
      status: OrderStatus.PENDING,
    });
    
    return { ...order, orderId: orderRef.id };
  } catch (error) {
    console.error('Error creating order:', error);
    return null;
  }
}

export async function getOrdersByUser(userId: string): Promise<Order[]> {
  try {
    const ordersSnapshot = await db.collection('orders')
      .where('userId', '==', userId)
      .orderBy('creationDate', 'desc')
      .get();

    return ordersSnapshot.docs.map(doc => ({
      orderId: doc.id,
      ...doc.data()
    } as Order));
  } catch (error) {
    console.error('Error fetching orders:', error);
    return [];
  }
}

export async function updateOrderStatus(
  orderId: string, 
  status: OrderStatus
): Promise<boolean> {
  try {
    await db.collection('orders').doc(orderId).update({ status });
    return true;
  } catch (error) {
    console.error('Error updating order status:', error);
    return false;
  }
}
