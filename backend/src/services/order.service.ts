import supabase from '../config/database';
import { AppliedDiscount, CreateOrderDTO, CreateOrderResponse, Order, OrderStatus, PaymentStatus, RecurrenceType } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import { NotificationService } from './notification.service';
import { LoyaltyService } from './loyalty.service';
import { error } from 'console';

export class OrderService {
  
  private static async getCurrentLoyaltyPoints(userId: string): Promise<number> {
    const { data: loyalty } = await supabase
      .from('loyalty_points')
      .select('points_balance')
      .eq('user_id', userId)
      .single();

    return loyalty?.points_balance || 0;
  }

  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    const { userId, serviceId, addressId, isRecurring, recurrenceType, collectionDate, deliveryDate, affiliateCode, serviceTypeId, paymentMethod } = orderData;

    console.log('Creating order:', {
      userId,
      serviceId,
      itemsCount: orderData.items.length,
      items: orderData.items.map(item => ({
        articleId: item.articleId,
        quantity: item.quantity,
        isPremium: item.premiumPrice
      }))
    });

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
    
    const items = orderData.items;
    console.log('Fetching articles for items:', items.map(item => item.articleId));
    const { data: articles, error: articlesQueryError } = await supabase
      .from('articles')
      .select(`
        *,
        category:article_categories(
          id,
          name
        )
      `)
      .in('id', items.map(item => item.articleId));

    if (articlesQueryError) {
      console.error('Error fetching articles:', articlesQueryError);
      throw articlesQueryError;
    }

    if (!articles || articles.length !== items.length) {
      console.error('Articles mismatch:', {
        requestedIds: items.map(item => item.articleId),
        foundArticles: articles?.map(a => ({ id: a.id, name: a.name })) || []
      });
      throw new Error('One or more articles not found');
    }

    console.log('Found articles:', articles.map(a => ({
      id: a.id,
      name: a.name,
      category: a.category?.name,
      basePrice: a.basePrice,
      premiumPrice: a.premiumPrice
    })));

    // Variables for tracking discounts and total amount
    let appliedDiscounts: AppliedDiscount[] = [];
    let subtotalAmount = service.price;

    // Calculate total amount with premium prices if applicable
    items.forEach(item => {
      const article = articles.find(a => a.id === item.articleId);
      if (article) {
        const price = item.premiumPrice ? article.premiumPrice : article.basePrice;
        subtotalAmount += price * item.quantity;
      }
    });

    totalAmount = subtotalAmount;
    console.log('Calculated initial total amount:', totalAmount);

    // Calculer le montant total initial avant de créer la commande
    console.log('Initial amounts:', {
      servicePrice: service.price,
      subtotalAmount,
      itemsCount: items.length
    });
    
    // Mapper les noms de colonnes pour correspondre à la base de données
    const orderToInsert = {
      id: uuidv4(),
      userId,
      service_id: serviceId,
      service_type_id: serviceTypeId,
      address_id: addressId,
      affiliateCode,
      status: 'PENDING',
      isRecurring,
      recurrenceType,
      nextRecurrenceDate: isRecurring ? collectionDate : null,
      totalAmount: subtotalAmount, // Utiliser le montant calculé
      collectionDate: collectionDate || null,
      deliveryDate: deliveryDate || null,
      createdAt: new Date(),
      updatedAt: new Date(),
      paymentStatus: 'PENDING',
      paymentMethod
    };

    console.log('Creating order with total amount:', subtotalAmount);

    // Start a transaction
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert([orderToInsert])
      .select()
      .single();

    if (orderError) throw orderError;

    console.log('Order created successfully:', order);

    // Création des items de commande
    console.log('Creating order items...');
    console.log('Processing items:', items.map(item => ({
      articleId: item.articleId,
      quantity: item.quantity,
      isPremium: item.premiumPrice
    })));
    
    // Créer les items un par un pour éviter les problèmes de transaction
    const itemPromises = items.map(async (item: { articleId: string; quantity: number; premiumPrice?: boolean }) => {
      // 1. Récupérer l'article et son prix
      const { data: article, error: articleError } = await supabase
        .from('articles')
        .select('*, category:article_categories(*)')
        .eq('id', item.articleId)
        .single();

      if (articleError || !article) {
        console.error('Error fetching article:', articleError);
        throw new Error(`Article not found: ${item.articleId}`);
      }

      console.log('Found article:', {
        id: article.id,
        name: article.name,
        category: article.category?.name
      });

      // 2. Calculer le prix unitaire
      const unitPrice = item.premiumPrice ? article.premiumPrice : article.basePrice;

      // 3. Créer l'item de commande
      const orderItem = {
        id: uuidv4(),
        orderId: order.id,
        articleId: item.articleId,
        serviceId: serviceId,
        quantity: item.quantity,
        unitPrice: unitPrice,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      // 4. Insérer l'item
      const { error: insertError } = await supabase
        .from('order_items')
        .insert([orderItem]);

      if (insertError) {
        console.error('Error inserting order item:', insertError);
        throw insertError;
      }

      return orderItem;
    });

    // Attendre que tous les items soient créés
    console.log('Waiting for all items to be created...');
    const createdItems = await Promise.all(itemPromises);
    console.log(`Successfully created ${createdItems.length} order items`);

    // Récupérer les items avec leurs relations complètes
    const { data: insertedItems, error: fetchError } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles!inner(
          *,
          category:article_categories!inner(*)
        )
      `)
      .eq('orderId', order.id)
      .order('created_at', { ascending: true });

    console.log('Fetching complete order items:', {
      orderId: order.id,
      success: !fetchError,
      itemsFound: insertedItems?.length || 0
    });

    if (fetchError) {
      console.error('Error fetching inserted items:', fetchError);
      throw fetchError;
    }

    console.log('Retrieved complete order items:', {
      count: insertedItems?.length || 0,
      items: insertedItems?.map(item => ({
        id: item.id,
        articleName: item.article?.name,
        quantity: item.quantity,
        unitPrice: item.unitPrice
      }))
    });


    console.log('Order items created successfully:', {
      count: insertedItems.length,
      items: insertedItems.map(item => ({
        id: item.id,
        articleName: item.article?.name,
        quantity: item.quantity,
        unitPrice: item.unitPrice
      }))
    });

    // Mettre à jour l'ordre avec les items
    order.items = insertedItems;

    // Update order with initial total amount
    const { error: updateError } = await supabase
      .from('orders')
      .update({ totalAmount: subtotalAmount })
      .eq('id', order.id);

    if (updateError) {
      console.error('Error updating order total amount:', updateError);
      throw updateError;
    }

    // 1. D'abord calculer et appliquer les réductions
    if (orderData.offerIds?.length) {
      const articleIds = items.map(item => item.articleId);
      const { finalAmount, appliedDiscounts } = await this.calculateDiscounts(
        userId,
        totalAmount,
        articleIds,
        orderData.offerIds
      );

      console.log('Calculating discounts:', {
        originalAmount: totalAmount,
        finalAmount,
        appliedDiscounts
      });

      // Mettre à jour le montant total après réductions
      totalAmount = finalAmount;

      // Enregistrer les offres utilisées
      const userOffers = appliedDiscounts.map(discount => ({
        user_id: userId,
        offer_id: discount.offerId,
        order_id: order.id,
        discount_amount: discount.discountAmount,
        used_at: new Date()
      }));

      const { error: offersError } = await supabase.from('user_offers').insert(userOffers);
      if (offersError) {
        console.error('Error applying discounts:', offersError);
        throw offersError;
      }

      console.log('Discounts applied successfully:', {
        newTotalAmount: totalAmount,
        appliedDiscounts: appliedDiscounts
      });

      // Mettre à jour le montant total de la commande
      const { error: updateError } = await supabase
        .from('orders')
        .update({ totalAmount })
        .eq('id', order.id);

      if (updateError) {
        console.error('Error updating order total amount:', updateError);
        throw updateError;
      }
    }

    // 2. Ensuite traiter la commission d'affilié sur le montant final
    let affiliate = null;
    let commissionAmount = 0;

    if (affiliateCode) {
      console.log('[OrderService] Processing affiliate code:', orderData.affiliateCode);
      
      const { data: affiliateData } = await supabase
        .from('affiliate_profiles')
        .select('*')
        .eq('affiliateCode', orderData.affiliateCode)
        .eq('is_active', true)
        .eq('status', 'ACTIVE')
        .single();

      if (affiliateData) {
        affiliate = affiliateData;
        console.log('[OrderService] Found active affiliate:', affiliate.id);
        
        // Utiliser le taux de commission de l'affilié ou le taux par défaut
        const commissionRate = affiliate.commission_rate || 10;
        commissionAmount = totalAmount * (commissionRate / 100);
        
        console.log('[OrderService] Calculating commission:', {
          totalAmount,
          commissionRate,
          commissionAmount
        });

        const { error: updateError } = await supabase
          .from('affiliate_profiles')
          .update({
            commission_balance: affiliate.commission_balance + commissionAmount,
            total_earned: affiliate.total_earned + commissionAmount,
            total_referrals: affiliate.total_referrals + 1
          })
          .eq('id', affiliate.id);

        if (updateError) {
          console.error('[OrderService] Error updating affiliate balance:', updateError);
          throw updateError;
        }

        // Créer une transaction de commission
        const { error: transactionError } = await supabase
          .from('commission_transactions')
          .insert([{
            affiliate_id: affiliate.id,
            order_id: order.id,
            amount: commissionAmount,
            status: 'PENDING',
            created_at: new Date()
          }]);

        if (transactionError) {
          console.error('[OrderService] Error creating commission transaction:', transactionError);
          throw transactionError;
        }

        console.log('[OrderService] Affiliate commission processed successfully');
      } else {
        console.warn('[OrderService] No active affiliate found for code:', orderData.affiliateCode);
      }
    }
    console.log('Processing complete:', {
      orderId: order.id,
      totalAmount,
      affiliate: affiliate ? affiliate.id : null,
      commissionAmount
    });

    // 3. Envoyer les notifications
    await NotificationService.sendNotification(
      userId,
      'ORDER_CREATED',
      {
        orderId: order.id,
        totalAmount: totalAmount,
        items: items.map(item => ({
          name: articles.find(a => a.id === item.articleId)?.name,
          quantity: item.quantity
        }))
      }
    );

    // Si code affilié, notifier l'affilié
    if (orderData.affiliateCode && affiliate) {
      await NotificationService.sendAffiliateNotification(
        affiliate.user_id,
        order.id,
        totalAmount
      );
    }
    
    // 4. Attribuer les points de fidélité sur le montant final (après réductions)
    try {
      console.log('Attributing loyalty points for amount:', totalAmount);
      await LoyaltyService.earnPoints(userId, Math.floor(totalAmount), 'ORDER', order.id);
      console.log('Loyalty points attributed successfully');
    } catch (error) {
      console.error('Error attributing loyalty points:', error);
      // Ne pas bloquer la création de la commande si l'attribution des points échoue
    }

    // 5. Mettre à jour le montant total final de la commande
    const { error: updateTotalError } = await supabase
      .from('orders')
      .update({ totalAmount })
      .eq('id', order.id);

    if (updateTotalError) {
      console.error('Error updating final total amount:', updateTotalError);
      throw updateTotalError;
    }

    console.log('Final total amount updated:', totalAmount);

    // 6. Préparer la réponse finale
    console.log('Preparing final order response');

    // Construire l'objet order complet avec les items
    const completeOrder = {
      ...order,
      items: insertedItems || [],
      service,
      address,
      serviceId,
      addressId,
      totalAmount: subtotalAmount,
      createdAt: new Date(order.createdAt),
      updatedAt: new Date(order.updatedAt)
    };

    // Log des détails finaux
    // Log des détails finaux
    console.log('Order details:', {
      id: completeOrder.id,
      itemsCount: completeOrder.items.length,
      total: subtotalAmount,
      items: completeOrder.items.map((item: {
        id: string;
        articleId: string;
        quantity: number;
        unitPrice: number;
        article?: {
          name: string;
        };
      }) => ({
        id: item.id,
        articleId: item.articleId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        articleName: item.article?.name
      }))
    });

    // Construire et retourner la réponse finale
    const finalResponse: CreateOrderResponse = {
      order: completeOrder,
      pricing: {
        subtotal: subtotalAmount,
        discounts: appliedDiscounts,
        total: subtotalAmount
      },
      rewards: {
        pointsEarned: Math.floor(subtotalAmount),
        currentBalance: await this.getCurrentLoyaltyPoints(userId)
      }
    };

    return finalResponse;
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
      .eq('userId', userId)
      .order('createdAt', { ascending: false });

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
      userId: order.userId,  // Garder en camelCase car c'est pour l'API
      service_id: order.service_id,  // Garder en snake_case car c'est pour la BD
      address_id: order.address_id,  // Garder en snake_case car c'est pour la BD
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
    console.log('Fetching order details with items for:', orderId);
    
    // 1. Récupérer la commande avec ses relations
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        *,
        service:services!inner(*),
        address:addresses!inner(*),
        items:order_items!inner(
          id,
          quantity,
          unitPrice,
          article:articles!inner(
            id,
            name,
            basePrice,
            premiumPrice,
            description,
            category:article_categories!inner(name)
          )
        )
      `)
      .eq('id', orderId)
      .single();

    if (orderError) {
      console.error('Error fetching order:', orderError);
      throw orderError;
    }

    if (!order) {
      console.error('No order found with ID:', orderId);
      throw new Error('Order not found');
    }

    // La commande contient déjà les items grâce à la requête précédente
    console.log('Processing order data with items:', {
      orderId: order.id,
      itemsCount: order.items?.length || 0,
      totalAmount: order.totalAmount
    });

    return {
      ...order,
      serviceId: order.service_id,
      addressId: order.address_id,
      userId: order.user_id,
      service: order.service,
      address: order.address,
      createdAt: new Date(order.created_at),
      updatedAt: new Date(order.updated_at),
      items: order.items?.map((item: {
        id: string;
        orderId: string;
        articleId: string;
        quantity: number;
        unitPrice: number;
        article: {
          id: string;
          name: string;
          basePrice: number;
          premiumPrice: number;
          description?: string;
          category?: {
            name: string;
          };
        };
      }) => ({
        id: item.id,
        orderId: item.orderId,
        articleId: item.articleId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        article: {
          ...item.article,
          categoryName: item.article.category?.name
        }
      })) || []
    } as Order;
  }

  // Définir les transitions de statut valides
  private static readonly validStatusTransitions: Record<OrderStatus, OrderStatus[]> = {
    'PENDING': ['COLLECTING'],
    'COLLECTING': ['COLLECTED'],
    'COLLECTED': ['PROCESSING'],
    'PROCESSING': ['READY'],
    'READY': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': [],  // Statut final
    'CANCELLED': []   // Statut final
  };

  // Valider la transition de statut
  private static validateStatusTransition(currentStatus: OrderStatus, newStatus: OrderStatus): boolean {
    const validNextStatuses = this.validStatusTransitions[currentStatus];
    return validNextStatuses.includes(newStatus);
  }

  static async updateOrderStatus(orderId: string, newStatus: OrderStatus, userId: string, userRole: string): Promise<Order> {
    try {
      console.log(`Attempting to update order ${orderId} to status ${newStatus}`);
      
      console.log(`Starting status update process for order ${orderId}`);

      // 1. Vérifier si la commande existe et obtenir son statut actuel
      const { data: order, error: orderError } = await supabase
        .from('orders')
        .select('*')
        .eq('id', orderId)
        .single();

      if (orderError || !order) {
        console.error('Order not found:', orderError);
        throw new Error('Order not found');
      }

      // 2. Vérifier les autorisations
      const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
      if (!allowedRoles.includes(userRole)) {
        console.error(`Unauthorized role ${userRole} attempting to update order status`);
        throw new Error('Unauthorized to update order status');
      }

      // 3. Valider la transition de statut
      if (!this.validateStatusTransition(order.status, newStatus)) {
        console.error(`Invalid status transition from ${order.status} to ${newStatus}`);
        throw new Error(`Invalid status transition from ${order.status} to ${newStatus}`);
      }

      console.log(`Updating order ${orderId} from ${order.status} to ${newStatus}`);

      // 4. Mettre à jour le statut
      const { data: updatedOrder, error: updateError } = await supabase
        .from('orders')
        .update({
          status: newStatus,
          updatedAt: new Date()
        })
        .eq('id', orderId)
        .select()
        .single();

      if (updateError) {
        console.error('Error updating order status:', updateError);
        throw updateError;
      }

      // 4. Si le statut est "DELIVERED", mettre à jour les statistiques
      // Vérifier si la commande est déjà DELIVERED
      if (order.status === 'DELIVERED') {
        console.error(`Order ${orderId} is already in DELIVERED status`);
        throw new Error('Cannot update order that is already delivered');
      }

      // Si la nouvelle mise à jour est DELIVERED
      if (newStatus === 'DELIVERED') {
        try {
          console.log(`Processing DELIVERED status for order ${orderId}`);
          
          // Récupérer les détails de la commande pour les statistiques
          const orderDetails = await this.getOrderDetails(orderId, order.userId);
          
          // Ajouter à l'historique des commandes livrées
          const { error: historyError } = await supabase
            .from('delivery_history')
            .insert([{
              order_id: orderId,
              user_id: order.userId,
              delivery_date: new Date(),
              total_amount: orderDetails.totalAmount,
              created_at: new Date()
            }]);

          if (historyError) {
            console.error('Error adding to delivery history:', historyError);
          }

          // Log de la mise à jour dans les statistiques
          const { error: logError } = await supabase
            .from('order_status_logs')
            .insert([{
              order_id: orderId,
              previous_status: order.status,
              new_status: newStatus,
              updated_by: userId,
              created_at: new Date()
            }]);

          if (logError) {
            console.error('Error adding status log:', logError);
          }

        } catch (statsError) {
          console.error('Error updating delivery statistics:', statsError);
          // Ne pas bloquer la mise à jour du statut si les stats échouent
        }
      }

      // 5. Notifier le client du changement de statut
      console.log(`Sending notification for order ${orderId} status update`);
      try {
        await NotificationService.sendNotification(
          order.userId,
          'ORDER_STATUS_UPDATED',
          {
            orderId: orderId,
            newStatus: newStatus,
            message: `Votre commande est maintenant ${newStatus.toLowerCase()}`
          }
        );
        console.log('Notification sent successfully');
      } catch (notifError) {
        console.error('Error sending notification:', notifError);
        // Ne pas bloquer la mise à jour du statut si la notification échoue
      }

      return updatedOrder;
    } catch (error) {
      console.error('Error updating order status:', error);
      throw error;
    }
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
