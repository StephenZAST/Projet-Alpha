import { OrderItem } from '../../models/types';
import supabase from '../../config/database';

export interface OrderItemWithArticle extends OrderItem {
  article: {
    id: string;
    name: string;
    basePrice: number;
    premiumPrice: number;
    categoryId: string;
    category?: {
      id: string;
      name: string;
      description?: string;
    };
    createdAt: Date;
    updatedAt: Date;
    [key: string]: any;
  };
}

export class OrderSharedMethods {
  static async getOrderItems(orderId: string): Promise<OrderItemWithArticle[]> {
    const { data: items, error } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles(
          *,
          category:article_categories(
            id,
            name,
            description
          )
        )
      `)
      .eq('order_id', orderId);  // Correction : orderId -> order_id

    if (error) {
      console.error('Error fetching order items:', error);
      throw error;
    }

    if (!items) return [];

    return items.map(item => ({
      id: item.id,
      orderId: item.order_id,       // Conversion snake_case -> camelCase
      articleId: item.article_id,    // pour la réponse API
      serviceId: item.service_id,
      quantity: item.quantity,
      unitPrice: item.unit_price,
      createdAt: item.created_at,
      updatedAt: item.updated_at,
      article: {
        ...item.article,
        categoryId: item.article?.category_id,  // Conversion pour la réponse
        createdAt: item.article?.created_at,
        updatedAt: item.article?.updated_at,
        category: item.article?.category ? {
          ...item.article.category,
          createdAt: item.article.category.created_at
        } : null
      }
    }));
  }

  static async getUserPoints(userId: string): Promise<number> {
    const { data, error } = await supabase
      .from('loyalty_points')
      .select('points_balance')  // Correction : pointsBalance -> points_balance
      .eq('user_id', userId)
      .single();

    if (error) {
      console.error('Error fetching user points:', error);
      // En cas d'erreur, retourner 0 points au lieu de faire échouer la requête
      return 0;
    }
    
    return data?.points_balance || 0;  // Utilisation du nom exact de la colonne
  }

  static async getOrderWithDetails(orderId: string) {
    const { data: order, error } = await supabase
      .from('orders')
      .select(`
        *,
        user:users(
          id,
          email,
          first_name,
          last_name,
          phone
        ),
        service:services(*),
        address:addresses(*),
        items:order_items(
          *,
          article:articles(
            *,
            category:article_categories(*)
          )
        )
      `)
      .eq('id', orderId)
      .single();

    if (error) {
      console.error('Error fetching order details:', error);
      throw error;
    }

    // Conversion snake_case -> camelCase pour la réponse API
    const formattedOrder = {
      ...order,
      userId: order.user_id,
      serviceId: order.service_id,
      addressId: order.address_id,
      serviceTypeId: order.service_type_id,
      totalAmount: order.total_amount,
      isRecurring: order.is_recurring,
      recurrenceType: order.recurrence_type,
      nextRecurrenceDate: order.next_recurrence_date,
      collectionDate: order.collection_date,
      deliveryDate: order.delivery_date,
      affiliateCode: order.affiliate_code,
      paymentMethod: order.payment_method,
      createdAt: order.created_at,
      updatedAt: order.updated_at,
      items: order.items?.map((item: any) => ({
        ...item,
        orderId: item.order_id,
        articleId: item.article_id,
        serviceId: item.service_id,
        unitPrice: item.unit_price,
        createdAt: item.created_at,
        updatedAt: item.updated_at
      }))
    };

    return formattedOrder;
  }
}