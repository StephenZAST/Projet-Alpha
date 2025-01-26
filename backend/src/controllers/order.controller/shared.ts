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
      .eq('orderId', orderId);

    if (error) {
      console.error('Error fetching order items:', error);
      throw error;
    }

    if (!items) return [];

    return items.map(item => ({
      ...item,
      article: {
        ...item.article,
        category: item.article?.category || null
      }
    }));
  }

  static async getUserPoints(userId: string): Promise<number> {
    const { data, error } = await supabase
      .from('loyalty_points')
      .select('pointsBalance')
      .eq('user_id', userId)
      .single();

    if (error) {
      console.error('Error fetching user points:', error);
      // En cas d'erreur, retourner 0 points au lieu de faire échouer la requête
      return 0;
    }
    
    return data?.pointsBalance || 0;
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

    return order;
  }
}