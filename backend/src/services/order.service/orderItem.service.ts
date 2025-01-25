import supabase from '../../config/database';
import { OrderItem, CreateOrderItemDTO } from '../../models/types';
import { v4 as uuidv4 } from 'uuid';

export class OrderItemService {
  static async createOrderItem(orderItemData: CreateOrderItemDTO): Promise<OrderItem> {
    const { orderId, articleId, serviceId, quantity, unitPrice } = orderItemData;

    const newOrderItem: OrderItem = {
      id: uuidv4(),
      orderId,
      articleId,
      serviceId,
      quantity,
      unitPrice,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const { data, error } = await supabase
      .from('order_items')
      .insert([newOrderItem])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getOrderItemById(orderItemId: string): Promise<OrderItem> {
      const { data, error } = await supabase
          .from('order_items')
          .select('*')
          .eq('id', orderItemId)
          .single();

      if (error) throw error;
      if (!data) throw new Error('Order item not found');

      return data;
  }

  static async getAllOrderItems(): Promise<OrderItem[]> {
    const { data, error } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles(
          *,
          category:article_categories(*)
        ),
        service:services(*)
      `);

    if (error) throw error;

    return data;
  }

  static async getOrderItemsByOrderId(orderId: string): Promise<OrderItem[]> {
    const { data, error } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles(
          *,
          category:article_categories(*)
        ),
        service:services(*)
      `)
      .eq('orderId', orderId);

    if (error) throw error;
    if (!data) return [];

    return data;
  }

  static async updateOrderItem(orderItemId: string, orderItemData: Partial<OrderItem>): Promise<OrderItem> {
    const { data, error } = await supabase
      .from('order_items')
      .update(orderItemData)
      .eq('id', orderItemId)
      .select()
      .single();

    if (error) throw error;
      if (!data) throw new Error('Order item not found');

    return data;
  }

  static async deleteOrderItem(orderItemId: string): Promise<void> {
    const { error } = await supabase
      .from('order_items')
      .delete()
      .eq('id', orderItemId);

    if (error) throw error;
  }
}