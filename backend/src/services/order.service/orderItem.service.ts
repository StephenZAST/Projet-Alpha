import supabase from '../../config/database';
import { OrderItem, CreateOrderItemDTO } from '../../models/types';

export class OrderItemService {
  private static readonly itemSelect = `
    *,
    article:articles!inner(
      *,
      category:article_categories!inner(
        id,
        name,
        description
      )
    ),
    service:services!inner(*)
  `;

  static async createOrderItem(orderItemData: CreateOrderItemDTO): Promise<OrderItem> {
    const { orderId, articleId, serviceId, quantity, unitPrice } = orderItemData;

    // 1. Vérifier que l'article existe
    const { data: article, error: articleError } = await supabase
      .from('articles')
      .select('*')
      .eq('id', articleId)
      .single();

    if (articleError || !article) {
      throw new Error(`Article not found: ${articleId}`);
    }

    // 2. Créer l'item de commande
    const { data, error } = await supabase
      .from('order_items')
      .insert({
        orderId,
        articleId,
        serviceId,
        quantity,
        unitPrice,
        createdAt: new Date(),
        updatedAt: new Date()
      })
      .select(this.itemSelect)
      .single();

    if (error) {
      console.error('Error creating order item:', error);
      throw error;
    }

    return data;
  }

  static async getOrderItemById(orderItemId: string): Promise<OrderItem> {
    const { data, error } = await supabase
      .from('order_items')
      .select(this.itemSelect)
      .eq('id', orderItemId)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Order item not found');

    return data;
  }

  static async getAllOrderItems(): Promise<OrderItem[]> {
    const { data, error } = await supabase
      .from('order_items')
      .select(this.itemSelect);

    if (error) throw error;

    return data || [];
  }

  static async getOrderItemsByOrderId(orderId: string): Promise<OrderItem[]> {
    const { data, error } = await supabase
      .from('order_items')
      .select(this.itemSelect)
      .eq('orderId', orderId);

    if (error) throw error;
    if (!data) return [];

    return data;
  }

  static async updateOrderItem(
    orderItemId: string, 
    orderItemData: Partial<OrderItem>
  ): Promise<OrderItem> {
    const { data, error } = await supabase
      .from('order_items')
      .update({
        ...orderItemData,
        updatedAt: new Date()
      })
      .eq('id', orderItemId)
      .select(this.itemSelect)
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

  static async calculateItemsTotal(items: OrderItem[]): Promise<number> {
    return items.reduce((total, item) => total + (item.unitPrice * item.quantity), 0);
  }
}