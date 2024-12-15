import { createClient } from '@supabase/supabase-js';
import { RecurringOrder, RecurringFrequency } from '../types/recurring';
import { OrderService } from './orders';
import { NotificationService } from './notifications';
import { addDays, addWeeks, addMonths } from 'date-fns';
import { OrderItem, PriceType, OrderStatus, OrderType } from '../models/order'; // Import necessary types
import { AppError, errorCodes } from '../utils/errors';
import { NotificationType } from '../models/notification';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const recurringOrdersTable = 'recurringOrders';

export class RecurringOrderService {
  private orderService = new OrderService();
  private notificationService = new NotificationService();

  /**
   * Create a new recurring order
   */
  async createRecurringOrder(userId: string, orderData: Partial<RecurringOrder>): Promise<RecurringOrder> {
    try {
      const now = new Date().toISOString();

      const recurringOrder: RecurringOrder = {
        id: '', // Will be set after creation
        userId,
        frequency: orderData.frequency || RecurringFrequency.ONCE,
        baseOrder: orderData.baseOrder!,
        nextScheduledDate: this.calculateNextDate(new Date(), orderData.frequency || RecurringFrequency.ONCE).toISOString(),
        isActive: true,
        createdAt: now,
        updatedAt: now
      };

      // Create the recurring order
      const { data, error } = await supabase.from(recurringOrdersTable).insert([recurringOrder]).select().single();

      if (error) {
        throw new AppError(500, 'Failed to create recurring order', errorCodes.DATABASE_ERROR);
      }

      recurringOrder.id = data.id;

      // Create the first order immediately
      const firstOrder = await this.orderService.createOrder({
        ...recurringOrder.baseOrder,
        userId,
        recurringOrderId: recurringOrder.id,
        scheduledPickupTime: now,
        scheduledDeliveryTime: new Date(now).toISOString(), // Next day delivery
        items: recurringOrder.baseOrder.items.map(item => ({
          ...item,
          productId: item.id || '', // Provide a default value if id is missing
          productName: item.name || '', // Provide a default value if name is missing
          priceType: PriceType.FIXED // Set default price type
        }))
      });

      // Update the recurring order with the first order reference
      await supabase.from(recurringOrdersTable).update({
        lastOrderId: firstOrder.id,
        lastProcessedDate: now,
        updatedAt: now
      }).eq('id', recurringOrder.id);

      recurringOrder.lastOrderId = firstOrder.id;
      recurringOrder.lastProcessedDate = new Date(now);

      return recurringOrder;
    } catch (error) {
      console.error('Error creating recurring order:', error);
      throw error;
    }
  }

  /**
   * Update a recurring order
   */
  async updateRecurringOrder(orderId: string, userId: string, updates: Partial<RecurringOrder>): Promise<RecurringOrder> {
    try {
      const { data, error } = await supabase.from(recurringOrdersTable).select('*').eq('id', orderId).single();

      if (error) {
        throw new AppError(404, 'Recurring order not found', errorCodes.NOT_FOUND);
      }

      const recurringOrder = data as RecurringOrder;
      if (recurringOrder.userId !== userId) {
        throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
      }

      const updatedOrder = {
        ...recurringOrder,
        ...updates,
        updatedAt: new Date().toISOString()
      };

      await supabase.from(recurringOrdersTable).update(updatedOrder).eq('id', orderId);

      return updatedOrder;
    } catch (error) {
      console.error('Error updating recurring order:', error);
      throw error;
    }
  }

  /**
   * Cancel a recurring order
   */
  async cancelRecurringOrder(orderId: string, userId: string): Promise<void> {
    try {
      const { data, error } = await supabase.from(recurringOrdersTable).select('*').eq('id', orderId).single();

      if (error) {
        throw new AppError(404, 'Recurring order not found', errorCodes.NOT_FOUND);
      }

      const recurringOrder = data as RecurringOrder;
      if (recurringOrder.userId !== userId) {
        throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
      }

      await supabase.from(recurringOrdersTable).update({
        isActive: false,
        updatedAt: new Date().toISOString()
      }).eq('id', orderId);
    } catch (error) {
      console.error('Error canceling recurring order:', error);
      throw error;
    }
  }

  /**
   * Get recurring orders for a user
   */
  async getRecurringOrders(userId: string): Promise<RecurringOrder[]> {
    try {
      const { data, error } = await supabase.from(recurringOrdersTable)
        .select('*')
        .eq('userId', userId)
        .eq('isActive', true);

      if (error) {
        throw new AppError(500, 'Failed to fetch recurring orders', errorCodes.DATABASE_ERROR);
      }

      return data as RecurringOrder[];
    } catch (error) {
      console.error('Error fetching recurring orders:', error);
      throw error;
    }
  }

  /**
   * Process recurring orders
   */
  async processRecurringOrders(): Promise<void> {
    try {
      const now = new Date().toISOString();
      const { data, error } = await supabase.from(recurringOrdersTable)
        .select('*')
        .eq('isActive', true)
        .lte('nextScheduledDate', now);

      if (error) {
        throw new AppError(500, 'Failed to fetch recurring orders', errorCodes.DATABASE_ERROR);
      }

      for (const recurringOrder of data as RecurringOrder[]) {
        try {
          // Create new order from the base order
          const newOrder = await this.orderService.createOrder({
            ...recurringOrder.baseOrder,
            userId: recurringOrder.userId,
            recurringOrderId: recurringOrder.id,
            scheduledPickupTime: now,
            scheduledDeliveryTime: new Date(now).toISOString(), // Next day delivery
            items: recurringOrder.baseOrder.items.map(item => ({
              ...item,
              productId: item.id || '', // Provide a default value if id is missing
              productName: item.name || '', // Provide a default value if name is missing
              priceType: PriceType.FIXED // Set default price type
            }))
          });

          // Calculate next scheduled date
          const nextDate = this.calculateNextDate(new Date(now), recurringOrder.frequency);

          // Update recurring order
          await supabase.from(recurringOrdersTable).update({
            lastOrderId: newOrder.id,
            lastProcessedDate: now,
            nextScheduledDate: nextDate.toISOString(),
            updatedAt: now
          }).eq('id', recurringOrder.id);

          // Notify user
          await this.notificationService.sendNotification(recurringOrder.userId, {
            type: NotificationType.RECURRING_ORDER_CREATED,
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
    } catch (error) {
      console.error('Error processing recurring orders:', error);
      throw error;
    }
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

export const recurringOrder
