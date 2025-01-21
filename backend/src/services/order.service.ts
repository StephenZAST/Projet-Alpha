import supabase from '../config/database';
import { AppliedDiscount, CreateOrderDTO, Order, OrderStatus, PaymentStatus, RecurrenceType } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import { NotificationService } from './notification.service';
import { LoyaltyService } from './loyalty.service';

export class OrderService {
  
  static async createOrder(orderData: CreateOrderDTO): Promise<Order> {
    const { userId, serviceId, addressId, items, isRecurring, recurrenceType, collectionDate, deliveryDate, affiliateCode, serviceTypeId, paymentMethod } = orderData;

    console.log('Creating order with data:', orderData);

    const { data: service } = await supabase
      .from('services')
      .select('*')
      .eq('id', serviceId)
      .single();

    if (!service) {
      throw new Error('Service not found');
    }

    const { data: address } = await supabase
      .from('addresses')
      .select('*')
      .eq('id', addressId)
      .single();

    if (!address) {
      throw new Error('Address not found');
    }

    // Calculate total amount including articles
    let totalAmount = service.price;
    
    // Fetch all articles prices
    const { data: articles } = await supabase
      .from('articles')
      .select('*')
      .in('id', items.map(item => item.articleId));

    if (!articles || articles.length !== items.length) {
      throw new Error('One or more articles not found');
    }

    // Add articles prices to total
    items.forEach(item => {
      const article = articles.find(a => a.id === item.articleId);
      if (article) {
        totalAmount += article.basePrice * item.quantity;
      }
    });

    const newOrder: Order = {
      id: uuidv4(),
      userId: userId,
      service_id: serviceId,
      service_type_id: serviceTypeId,
      address_id: addressId,
      affiliateCode: affiliateCode,
      status: 'PENDING',
      isRecurring: isRecurring,
      recurrenceType: recurrenceType,
      nextRecurrenceDate: isRecurring ? collectionDate : null,
      totalAmount: totalAmount,
      collectionDate: collectionDate,
      deliveryDate: deliveryDate,
      createdAt: new Date(),
      updatedAt: new Date(),
      paymentStatus: 'PENDING', // Add this line
      paymentMethod: paymentMethod // Add this line
    };

    // Start a transaction
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert([newOrder])
      .select()
      .single();

    if (orderError) throw orderError;

    console.log('Order created successfully:', order);

    // Create order items
    const orderItems = items.map((item: { articleId: string; quantity: number; premiumPrice?: boolean }) => {
      const article = articles.find(a => a.id === item.articleId);
      const unitPrice = item.premiumPrice ? article?.premiumPrice : article?.basePrice;
      return {
        id: uuidv4(),
        orderId: order.id,
        articleId: item.articleId,
        serviceId: serviceId,
        quantity: item.quantity,
        unitPrice: unitPrice || 0,
        createdAt: new Date(),
        updatedAt: new Date()
      };
    });

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems);

    if (itemsError) throw itemsError;

    console.log('Order items created successfully:', orderItems);

    let affiliate;
    let commissionAmount = 0;

    // Si un code affilié est fourni, calculer et attribuer la commission
    if (orderData.affiliateCode) {
      const { data: affiliateData } = await supabase
        .from('affiliate_profiles')
        .select('*')
        .eq('affiliate_code', orderData.affiliateCode)
        .single();

      if (affiliateData) {
        affiliate = affiliateData;
        commissionAmount = totalAmount * 0.1; // 10% de commission
        
        await supabase
          .from('affiliate_profiles')
          .update({ 
            commission_balance: affiliate.commission_balance + commissionAmount,
            total_earned: affiliate.total_earned + commissionAmount
          })
          .eq('id', affiliate.id);

        // Créer une transaction de commission
        await supabase
          .from('commission_transactions')
          .insert([{
            affiliate_id: affiliate.id,
            order_id: order.id,
            amount: commissionAmount,
            status: 'PENDING'
          }]);
      }
    }

    console.log('Affiliate commission processed:', { affiliate, commissionAmount });

    // Calculer les réductions si des offres sont appliquées
    if (orderData.offerIds?.length) {
      const articleIds = orderItems.map(item => item.articleId);
      const { finalAmount, appliedDiscounts } = await this.calculateDiscounts(
        userId,
        totalAmount,
        articleIds,
        orderData.offerIds
      );

      // Mettre à jour le montant total
      totalAmount = finalAmount;

      // Enregistrer les offres utilisées
      const userOffers = appliedDiscounts.map(discount => ({
        user_id: userId,
        offer_id: discount.offerId,
        order_id: order.id,
        discount_amount: discount.discountAmount,
        used_at: new Date()
      }));

      await supabase.from('user_offers').insert(userOffers);
    
      console.log('Discounts applied:', { totalAmount: totalAmount, appliedDiscounts: appliedDiscounts });
    }

    // Créer notification pour le client
    await NotificationService.createOrderNotification(
      userId,
      order.id,
      'ORDER_CREATED'
    );

    // Si code affilié, notifier l'affilié
    if (orderData.affiliateCode && affiliate) {
      await NotificationService.createAffiliateNotification(
        affiliate.user_id,
        userId,
        order.id,
        commissionAmount
      );
    }
    
    console.log('Returning order details');
    const orderDetails = await this.getOrderDetails(order.id, userId);
    const finalTotalAmount = orderDetails.items?.reduce((acc, item) => acc + (item.unitPrice * item.quantity), 0) || 0;

    // Attribuer des points de fidélité au client
    await LoyaltyService.earnPoints(userId, finalTotalAmount, 'ORDER', order.id);

    return {
      ...orderDetails,
      totalAmount: finalTotalAmount
    }
  }

  static async getUserOrders(userId: string): Promise<Order[]> {
    console.log('Getting orders for user:', userId);

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
      .eq('userId', userId);

    console.log('Raw query result:', data);

    if (error) {
      console.error('Error fetching user orders:', error);
      throw error;
    }

    // Filter valid orders
    const userOrders = data || [];

    console.log('Filtered orders:', userOrders);

    // Transform data
    return userOrders.map(order => ({
      id: order.id,
      userId: order.user_id,
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
      paymentStatus: order.paymentStatus, // Add this line
      paymentMethod: order.paymentMethod // Add this line
    }));  }

  static async getOrderDetails(orderId: string, userId: string): Promise<Order> {
    console.log('Fetching order details:', { orderId, userId }); // Debug log

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
      .eq('id', orderId)
      .single(); // Changed from array to single result

    if (error) {
      console.error('Error fetching order:', error);
      throw error;
    }

    if (!data) {
      console.error('No order found with ID:', orderId);
      throw new Error('Order not found');
    }

    // Map snake_case to camelCase
    return {
      ...data,
      serviceId: data.service_id,
      addressId: data.address_id,
      userId: data.user_id,
      service: data.service,
      address: data.address,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
      items: data.items?.map((item: any) => ({
        ...item,
        article: {
          ...item.article,
          categoryName: item.article.category?.name
        }
      })) || []
    } as Order;
  }

  static async updateOrderStatus(orderId: string, status: OrderStatus, userId: string, userRole: string): Promise<Order> {
    const { data: order } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (!order) {
      throw new Error('Order not found');
    }

    // Vérifier les autorisations
    const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
    if (!allowedRoles.includes(userRole)) {
      throw new Error('Unauthorized to update order status');
    }

    const { data, error } = await supabase
      .from('orders')
      .update({ status, updatedAt: new Date() })
      .eq('id', orderId)
      .select()
      .single();

    if (error) throw error;

    // Notifier le client du changement de statut
    await NotificationService.createOrderNotification(
      order.userId,
      orderId,
      'ORDER_STATUS_UPDATED',
      { newStatus: status }
    );

    return data;
  }

  static async getAllOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }

  static async deleteOrder(orderId: string, userId: string): Promise<void> {
    const { data: order } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.user_id !== userId && !['ADMIN'].includes(order.user.role)) {
      throw new Error('Unauthorized to delete order');
    }

    const { error } = await supabase
      .from('orders')
      .delete()
      .eq('id', orderId);

    if (error) throw error;
  }

  private static async calculateDiscounts(
    userId: string,
    totalAmount: number,
    articleIds: string[],
    appliedOfferIds: string[]
  ): Promise<{ 
    finalAmount: number; 
    appliedDiscounts: AppliedDiscount[]
  }> {
    let finalAmount = totalAmount;
    const appliedDiscounts: AppliedDiscount[] = [];

    // Récupérer les offres disponibles
    const { data: availableOffers } = await supabase
      .from('offers')
      .select('*, articles:offer_articles(article_id)')
      .eq('is_active', true)
      .lte('start_date', new Date().toISOString())
      .gte('end_date', new Date().toISOString())
      .in('id', appliedOfferIds);

    if (!availableOffers) return { finalAmount, appliedDiscounts };

    // Trier les offres : non cumulables d'abord
    const sortedOffers = availableOffers.sort((a, b) => 
      (a.isCumulative === b.isCumulative) ? 0 : a.isCumulative ? 1 : -1
    );

    for (const offer of sortedOffers) {
      // Vérifier si l'offre s'applique aux articles
      const offerArticleIds = offer.articles.map((a: any) => a.article_id);
      const hasValidArticles = articleIds.some(id => offerArticleIds.includes(id));
      
      if (!hasValidArticles) continue;

      // Vérifier le montant minimum si défini
      if (offer.minPurchaseAmount && totalAmount < offer.minPurchaseAmount) continue;

      let discountAmount = 0;

      switch (offer.discountType) {
        case 'PERCENTAGE':
          discountAmount = (totalAmount * offer.discountValue) / 100;
          break;
        case 'FIXED_AMOUNT':
          discountAmount = offer.discountValue;
          break;
        case 'POINTS_EXCHANGE':
          // Vérifier les points du client
          const { data: loyalty } = await supabase
            .from('loyalty_points')
            .select('points_balance')
            .eq('user_id', userId)
            .single();

          if (!loyalty || loyalty.points_balance < offer.pointsRequired!) continue;
          
          discountAmount = offer.discountValue;
          
          // Déduire les points
          await supabase
            .from('loyalty_points')
            .update({ 
              points_balance: loyalty.points_balance - offer.pointsRequired!
            })
            .eq('user_id', userId);
          break;
      }

      // Appliquer le plafond si défini
      if (offer.maxDiscountAmount) {
        discountAmount = Math.min(discountAmount, offer.maxDiscountAmount);
      }

      finalAmount -= discountAmount;
      appliedDiscounts.push({ offerId: offer.id, discountAmount });

      // Si l'offre n'est pas cumulative, arrêter ici
      if (!offer.isCumulative) break;
    }

    return { 
      finalAmount: Math.max(finalAmount, 0),
      appliedDiscounts: appliedDiscounts
    };
  }

  static async calculateTotal(items: { articleId: string; quantity: number }[]): Promise<number> {
    let totalAmount = 0;

    // Fetch all articles prices
    const { data: articles } = await supabase
      .from('articles')
      .select('*')
      .in('id', items.map(item => item.articleId));

    if (!articles || articles.length !== items.length) {
      throw new Error('One or more articles not found');
    }

    // Add articles prices to total
    items.forEach(item => {
      const article = articles.find(a => a.id === item.articleId);
      if (article) {
        totalAmount += article.basePrice * item.quantity;
      }
    });

    return totalAmount;
  }

  static async updatePaymentStatus(
    orderId: string, 
    paymentStatus: PaymentStatus,
    userId: string
  ): Promise<Order> {
    const { data: order } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (!order) {
      throw new Error('Order not found');
    }

    const { data, error } = await supabase
      .from('orders')
      .update({ 
        paymentStatus,
        updatedAt: new Date()
      })
      .eq('id', orderId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getRecentOrders(limit: number = 5): Promise<Order[]> {
    try {
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

      // Transform the response to match our frontend model
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
        items: order.items?.map((item: { id: string; quantity: number; unitPrice: number; article: any }) => ({
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
    } catch (error) {
      console.error('Error in getRecentOrders:', error);
      throw error;
    }
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
