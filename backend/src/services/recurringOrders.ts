import { db } from '../config/firebase';
import { RecurringOrder, RecurringFrequency } from '../types/recurring';
import { OrderService } from './orders';
import { NotificationService } from './notifications';
import { addDays, addWeeks, addMonths } from 'date-fns';
import { Timestamp } from 'firebase-admin/firestore';
import { OrderItem, ItemType, PriceType } from '../models/order'; // Import necessary types

export class RecurringOrderService {
  private recurringOrdersRef = db.collection('recurringOrders');
  private orderService = new OrderService();
  private notificationService = new NotificationService();

  async createRecurringOrder(userId: string, orderData: Partial<RecurringOrder>): Promise<RecurringOrder> {
    const now = new Date();

    const recurringOrder: RecurringOrder = {
      id: '', // Will be set after creation
      userId,
      frequency: orderData.frequency || RecurringFrequency.ONCE,
      baseOrder: orderData.baseOrder!,
      nextScheduledDate: this.calculateNextDate(now, orderData.frequency || RecurringFrequency.ONCE),
      isActive: true,
      createdAt: now,
      updatedAt: now
    };

    // Create the recurring order
    const docRef = await this.recurringOrdersRef.add(recurringOrder);
    recurringOrder.id = docRef.id;

    // Create the first order immediately
    const firstOrder = await this.orderService.createOrder({
      ...recurringOrder.baseOrder,
      userId,
      recurringOrderId: recurringOrder.id,
      scheduledPickupTime: Timestamp.fromDate(now),
      scheduledDeliveryTime: Timestamp.fromDate(new Date(now.getTime() + 24 * 60 * 60 * 1000)), // Next day delivery
      items: recurringOrder.baseOrder.items.map(item => ({
        ...item,
        productId: item.id || '', // Provide a default value if id is missing
        productName: item.name || '', // Provide a default value if name is missing
        itemType: ItemType.PRODUCT, // Set default item type
        priceType: PriceType.FIXED // Set default price type
      }))
    });

    // Update the recurring order with the first order reference
    await docRef.update({
      lastOrderId: firstOrder.id,
      lastProcessedDate: now,
      updatedAt: now
    });

    recurringOrder.lastOrderId = firstOrder.id;
    recurringOrder.lastProcessedDate = now;

    return recurringOrder;
  }

  async updateRecurringOrder(orderId: string, userId: string, updates: Partial<RecurringOrder>): Promise<RecurringOrder> {
    const docRef = this.recurringOrdersRef.doc(orderId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error('Recurring order not found');
    }

    const recurringOrder = doc.data() as RecurringOrder;
    if (recurringOrder.userId !== userId) {
      throw new Error('Unauthorized');
    }

    const updatedOrder = {
      ...recurringOrder,
      ...updates,
      updatedAt: new Date()
    };

    await docRef.update(updatedOrder);
    return updatedOrder;
  }

  async cancelRecurringOrder(orderId: string, userId: string): Promise<void> {
    const docRef = this.recurringOrdersRef.doc(orderId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error('Recurring order not found');
    }

    const recurringOrder = doc.data() as RecurringOrder;
    if (recurringOrder.userId !== userId) {
      throw new Error('Unauthorized');
    }

    await docRef.update({
      isActive: false,
      updatedAt: new Date()
    });
  }

  async getRecurringOrders(userId: string): Promise<RecurringOrder[]> {
    const snapshot = await this.recurringOrdersRef
      .where('userId', '==', userId)
      .where('isActive', '==', true)
      .get();

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as RecurringOrder));
  }

  async processRecurringOrders(): Promise<void> {
    const now = new Date();
    const snapshot = await this.recurringOrdersRef
      .where('isActive', '==', true)
      .where('nextScheduledDate', '<=', now)
      .get();

    const batch = db.batch();

    for (const doc of snapshot.docs) {
      const recurringOrder = doc.data() as RecurringOrder;

      try {
        // Create new order from the base order
        const newOrder = await this.orderService.createOrder({
          ...recurringOrder.baseOrder,
          userId: recurringOrder.userId,
          recurringOrderId: recurringOrder.id,
          scheduledPickupTime: Timestamp.fromDate(now),
          scheduledDeliveryTime: Timestamp.fromDate(new Date(now.getTime() + 24 * 60 * 60 * 1000)), // Next day delivery
          items: recurringOrder.baseOrder.items.map(item => ({
            ...item,
            productId: item.id || '', // Provide a default value if id is missing
            productName: item.name || '', // Provide a default value if name is missing
            itemType: ItemType.PRODUCT, // Set default item type
            priceType: PriceType.FIXED // Set default price type
          }))
        });

        // Calculate next scheduled date
        const nextDate = this.calculateNextDate(now, recurringOrder.frequency);

        // Update recurring order
        batch.update(doc.ref, {
          lastOrderId: newOrder.id,
          lastProcessedDate: now,
          nextScheduledDate: nextDate,
          updatedAt: now
        });

        // Notify user
        await this.notificationService.sendNotification(recurringOrder.userId, {
          type: 'RECURRING_ORDER_CREATED',
          title: 'Nouvelle commande récurrente créée',
          message: `Votre commande récurrente a été automatiquement renouvelée. ID de commande: ${newOrder.id}`,
          data: {
            orderId: newOrder.id,
            recurringOrderId: recurringOrder.id
          }
        });
      } catch (error) {
        console.error(`Failed to process recurring order ${recurringOrder.id}:`, error);
        // Continue with other orders even if one fails
      }
    }

    await batch.commit();
  }

  private calculateNextDate(fromDate: Date, frequency: RecurringFrequency): Date {
    switch (frequency) {
      case RecurringFrequency.WEEKLY:
        return addWeeks(fromDate, 1);
      case RecurringFrequency.BIWEEKLY:
        return addWeeks(fromDate, 2);
      case RecurringFrequency.MONTHLY:
        return addMonths(fromDate, 1);
      case RecurringFrequency.ONCE:
      default:
        return addDays(fromDate, 365); // Set far future date for one-time orders
    }
  }
}
