import supabase from '../../config/database';
import { Order } from '../../models/types';

export class OrderQueryService {
  private static readonly baseOrderSelect = `
    *,
    user:users(
      id,
      email,
      first_name,
      last_name,
      phone,
      role,
      referral_code
    ),
    service:services(
      id,
      name,
      price,
      description
    ),
    address:addresses(
      id,
      name,
      street, 
      city,
      postal_code,
      gps_latitude,
      gps_longitude,
      is_default
    ),
    items:order_items!inner(
      id,
      quantity,
      unit_price,
      created_at,
      updated_at,
      article:articles!inner(
        id,
        name,
        description,
        base_price,
        premium_price,
        category:article_categories!inner(
          id,
          name,
          description
        )
      )
    )
  `;

  static async getUserOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select(this.baseOrderSelect)
      .eq('userId', userId)
      .order('createdAt', { ascending: false });

    if (error) {
      console.error('Error fetching user orders:', error);
      throw error;
    } 

    return this.formatOrders(data || []);
  }

  static async getOrderDetails(orderId: string): Promise<Order> {
    const { data, error } = await supabase
      .from('orders')
      .select(this.baseOrderSelect)
      .eq('id', orderId)
      .single();

    if (error) {
      console.error('Error fetching order details:', error);
      throw error;
    }

    if (!data) {
      throw new Error('Order not found');
    }

    return this.formatOrder(data);
  }

  static async getRecentOrders(limit: number = 5): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select(this.baseOrderSelect)
      .order('createdAt', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('Error fetching recent orders:', error);
      throw error;
    }

    return this.formatOrders(data || []);
  }

  static async getOrdersByStatus(): Promise<Record<string, number>> {
    const { data, error } = await supabase
      .from('orders')
      .select('status');

    if (error) throw error;

    const statusCount: Record<string, number> = {};
    data.forEach((order) => {
      statusCount[order.status] = (statusCount[order.status] || 0) + 1;
    });

    return statusCount;
  }

  private static formatOrder(order: any): Order {
    return {
      ...order,
      items: order.items?.map((item: any) => ({
        id: item.id,
        orderId: item.orderId,
        articleId: item.article.id,
        serviceId: item.serviceId,
        quantity: item.quantity,
        unitPrice: item.unit_price,
        article: {
          id: item.article.id,
          name: item.article.name,
          description: item.article.description,
          basePrice: item.article.base_price,
          premiumPrice: item.article.premium_price,
          category: item.article.category ? {
            id: item.article.category.id,
            name: item.article.category.name,
            description: item.article.category.description
          } : null
        },
        createdAt: new Date(item.created_at),
        updatedAt: new Date(item.updated_at)
      })) || [],
      service: order.service,
      address: order.address ? {
        ...order.address,
        postalCode: order.address.postal_code,
        gpsLatitude: order.address.gps_latitude,
        gpsLongitude: order.address.gps_longitude,
        isDefault: order.address.is_default
      } : null,
      user: order.user ? {
        ...order.user,
        firstName: order.user.first_name,
        lastName: order.user.last_name,
        referralCode: order.user.referral_code
      } : null,
      collectionDate: order.collectionDate ? new Date(order.collectionDate) : null,
      deliveryDate: order.deliveryDate ? new Date(order.deliveryDate) : null,
      createdAt: new Date(order.createdAt),
      updatedAt: new Date(order.updatedAt)
    };
  }

  private static formatOrders(orders: any[]): Order[] {
    return orders.map(order => this.formatOrder(order));
  }
}