import supabase from '../../config/database';
import { Order } from '../../models/types';

export class OrderQueryService {
  static async getUserOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        service:services(*),
        address:addresses(*),
        items:order_items(
          *,
          article:articles(
            *,
            category:article_categories(name)
          )
        )
      `)
      .eq('userId', userId)
      .order('createdAt', { ascending: false });

    if (error) {
      console.error('Error fetching user orders:', error);
      throw error;
    }

    return (data || []).map(order => ({
      id: order.id,
      userId: order.userId,
      service_id: order.service_id,
      address_id: order.address_id,
      affiliateCode: order.affiliateCode,
      status: order.status,
      isRecurring: order.isRecurring,
      recurrenceType: order.recurrenceType,
      nextRecurrenceDate: order.nextRecurrenceDate,
      totalAmount: order.totalAmount,
      collectionDate: order.collectionDate ? new Date(order.collectionDate) : null,
      deliveryDate: order.deliveryDate ? new Date(order.deliveryDate) : null,
      createdAt: order.createdAt ? new Date(order.createdAt) : new Date(),
      updatedAt: order.updatedAt ? new Date(order.updatedAt) : new Date(),
      service: order.service,
      address: order.address,
      items: order.items?.map((item: any) => ({
        ...item,
        article: {
          ...item.article,
          categoryName: item.article.category?.name
        }
      })) || [],
      paymentStatus: order.paymentStatus,
      paymentMethod: order.paymentMethod
    }));
  }

  static async getOrderDetails(orderId: string): Promise<Order> {
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        *,
        service:services(*),
        address:addresses(*)
      `)
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      console.error('Error fetching order:', orderError);
      throw orderError || new Error('Order not found');
    }

    const { data: items, error: itemsError } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles(
          *,
          category:article_categories(*)
        )
      `)
      .eq('orderId', orderId);

    if (itemsError) {
      console.error('Error fetching order items:', itemsError);
      throw itemsError;
    }

    return {
      ...order,
      items: items?.map((item: {
        id: string;
        orderId: string;
        articleId: string;
        serviceId: string;
        quantity: number;
        unitPrice: number;
        article: {
          id: string;
          name: string;
          basePrice: number;
          premiumPrice: number;
          description: string;
          category: {
            id: string;
            name: string;
          } | null;
        } | null;
        createdAt: string;
        updatedAt: string;
      }) => ({
        id: item.id,
        orderId: item.orderId,
        articleId: item.articleId,
        serviceId: item.serviceId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        article: item.article ? {
          id: item.article.id,
          name: item.article.name,
          basePrice: item.article.basePrice,
          premiumPrice: item.article.premiumPrice,
          description: item.article.description,
          category: item.article.category ? {
            id: item.article.category.id,
            name: item.article.category.name
          } : null
        } : null,
        service: order.service ? {
          id: order.service.id,
          name: order.service.name
        } : null,
        createdAt: new Date(item.createdAt),
        updatedAt: new Date(item.updatedAt)
      })) || [],
      service: order.service,
      address: order.address,
      collectionDate: order.collectionDate ? new Date(order.collectionDate) : null,
      deliveryDate: order.deliveryDate ? new Date(order.deliveryDate) : null,
      createdAt: new Date(order.createdAt),
      updatedAt: new Date(order.updatedAt)
    };
  }

  static async getRecentOrders(limit: number = 5): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        service:services(*),
        user:users(
          id,
          email,
          first_name,
          last_name,
          phone,
          role,
          referral_code
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
        items:order_items(
          id,
          quantity,
          unitPrice,
          article:articles(
            id,
            name,
            basePrice,
            premiumPrice,
            description,
            category:article_categories(
              id,
              name
            )
          )
        )
      `)
      .order('createdAt', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('Error fetching recent orders:', error);
      throw error;
    }

    return data?.map(order => ({
      ...order,
      user: order.user ? {
        id: order.user.id,
        email: order.user.email,
        firstName: order.user.first_name,
        lastName: order.user.last_name,
        phone: order.user.phone,
        role: order.user.role,
        referralCode: order.user.referral_code
      } : null,
      service: order.service,
      address: order.address ? {
        id: order.address.id,
        name: order.address.name,
        street: order.address.street,
        city: order.address.city,
        postalCode: order.address.postal_code,
        gpsLatitude: order.address.gps_latitude,
        gpsLongitude: order.address.gps_longitude,
        isDefault: order.address.is_default
      } : null,
      items: order.items?.map((item: {
        id: string;
        quantity: number;
        unitPrice: number;
        article: {
          id: string;
          name: string;
          basePrice: number;
          premiumPrice: number;
          description: string;
          category: {
            id: string;
            name: string;
          } | null;
        };
      }) => ({
        id: item.id,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        article: {
          ...item.article,
          category: item.article.category
        }
      })) || [],
      createdAt: new Date(order.createdAt),
      updatedAt: new Date(order.updatedAt)
    })) || [];
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
}