import { Request, Response } from 'express';
import supabase from '../../config/database';
import { 
  PricingService, 
  RewardsService, 
  NotificationService,
  LoyaltyService,  // Ajout de l'import
  SYSTEM_CONSTANTS
} from '../../services';
import { NotificationType, OrderStatus } from '../../models/types';
import { OrderSharedMethods } from './shared';
import { orderNotificationTemplates, getCustomerName } from '../../utils/notificationTemplates';

interface CreateOrderItemData {
  articleId: string;
  quantity: number;
  isPremium?: boolean;
}

interface OrderItem {
  orderId: string;
  articleId: string;
  serviceId: string;
  quantity: number; 
  unitPrice: number;
  createdAt: Date;
  updatedAt: Date;
}

interface Article {
  id: string;
  basePrice: number;
  premiumPrice: number;
}

export class OrderCreateController {
  static async createOrder(req: Request, res: Response) {
    console.log('[OrderController] Starting order creation');
    try {
      const { 
        serviceId, 
        addressId, 
        isRecurring, 
        recurrenceType, 
        collectionDate, 
        deliveryDate, 
        affiliateCode,
        items,
        paymentMethod,
        appliedOfferIds,
        serviceTypeId,
        usePoints  // Add this new field
      } = req.body;
      
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      // 1. Calculer le prix total avec les réductions
      console.log('[OrderController] Calculating total price for items:', items);
      const pricing = await PricingService.calculateOrderTotal({
        items,
        userId,
        appliedOfferIds,
        usePoints: usePoints || 0
      });
      console.log('[OrderController] Price calculation result:', pricing);

      // 2. Créer la commande avec le montant total
      const { data: order, error } = await supabase
        .from('orders')
        .insert([{
          userId,
          serviceId,
          addressId,
          isRecurring,
          recurrenceType,
          nextRecurrenceDate: null,
          totalAmount: pricing.total,
          collectionDate,
          deliveryDate,
          affiliateCode,
          paymentMethod,
          status: 'PENDING' as OrderStatus,
          createdAt: new Date(),
          updatedAt: new Date(),
          service_type_id: serviceTypeId  // Garde le snake_case car c'est le nom exact dans la DB
        }])
        .select()
        .single();

      if (error) throw error;
      console.log('[OrderController] Order created:', order.id);

      // 3. Si des points sont utilisés, les déduire maintenant qu'on a l'ID de commande
      if (usePoints > 0) {
        try {
          await LoyaltyService.deductPoints(userId, usePoints, order.id);
        } catch (error) {
          // Si la déduction échoue, annuler la commande
          await supabase
            .from('orders')
            .delete()
            .eq('id', order.id);
          throw error;
        }
      }

      // 3. Créer les items de commande
      const orderItems: OrderItem[] = items.map((item: CreateOrderItemData) => ({
        orderId: order.id,
        articleId: item.articleId,
        serviceId,
        quantity: item.quantity,
        unitPrice: 0, // Sera mis à jour après la récupération des articles
        createdAt: new Date(),
        updatedAt: new Date()
      }));

      // Récupérer les articles pour obtenir les prix
      const { data: articles, error: articlesError } = await supabase
        .from('articles')
        .select('id, basePrice, premiumPrice')
        .in('id', items.map((item: CreateOrderItemData) => item.articleId));

      if (articlesError || !articles) {
        throw new Error('Failed to fetch articles');
      }

      const articleMap = new Map<string, Article>(
        articles.map(article => [article.id, article])
      );

      // Mettre à jour les prix des items
      orderItems.forEach((item: OrderItem, index: number) => {
        const article = articleMap.get(item.articleId);
        if (article) {
          item.unitPrice = items[index].isPremium ? article.premiumPrice : article.basePrice;
        } else {
          throw new Error(`Article not found: ${item.articleId}`);
        }
      });

      // Insérer les items
      const { error: itemsError } = await supabase
        .from('order_items')
        .insert(orderItems.map(item => ({
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        })));

      if (itemsError) {
        console.error('Error creating order items:', itemsError);
        throw itemsError;
      }
      console.log('[OrderController] Order items created');

      // 4. Récupérer la commande complète avec les items
      const completeOrder = {
        ...order,
        totalAmount: pricing.total,
        items: await OrderSharedMethods.getOrderItems(order.id)
      };

      // 5. Traiter les points de fidélité
      const earnedPoints = Math.floor(pricing.total * SYSTEM_CONSTANTS.POINTS.ORDER_MULTIPLIER);
      await RewardsService.processOrderPoints(userId, completeOrder, 'ORDER');
      console.log('[OrderController] Loyalty points processed:', earnedPoints);

      // 6. Traiter la commission d'affilié
      let affiliateCommission = null;
      if (affiliateCode) {
        await RewardsService.processAffiliateCommission(completeOrder);
        console.log('[OrderController] Affiliate commission processed');

        // Récupérer les détails de la commission pour la réponse
        const { data: commissionTx } = await supabase
          .from('commissionTransactions')
          .select('amount, affiliate_id')
          .eq('order_id', order.id)
          .single();

        if (commissionTx) {
          affiliateCommission = {
            amount: commissionTx.amount,
            affiliate_id: commissionTx.affiliate_id
          };
        }
      }

      // 7. Get user data and send notifications with proper type checking
      const { data: userData } = await supabase
        .from('users')
        .select('id, email, firstName, lastName')  // Changed first_name to firstName to match User type
        .eq('id', userId)
        .single();

      // Convert supabase user data to User type
      const userForNotification = userData ? {
        id: userData.id,
        email: userData.email,
        firstName: userData.firstName,
        lastName: userData.lastName,
        role: req.user?.role || 'CLIENT',  // Provide default role
        createdAt: new Date(),
        updatedAt: new Date(),
        password: ''  // This field is required by User type but not needed for notification
      } : undefined;

      const notificationTemplate = orderNotificationTemplates.orderCreated(
        completeOrder,
        userForNotification
      );

      // Ensure userId is available for notification creation
      await NotificationService.createNotification(
        userId,  // Use validated userId instead of req.user?.id
        NotificationType.ORDER_CREATED,
        notificationTemplate.message,
        notificationTemplate.data
      );

      // Envoyer les notifications en arrière-plan
      NotificationService.sendOrderNotification(order)
        .catch((error: Error) => console.error('[OrderController] Notification error:', error));

      // Récupérer les données utilisateur avec la commande
      const { data: orderWithUser } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name),
          address:addresses(city)
        `)
        .eq('id', order.id)
        .single();

      if (!orderWithUser) {
        throw new Error('Order data not found');
      }

      // Préparer les données pour les notifications avec vérification null
      const notificationData = {
        orderId: orderWithUser.id,
        clientName: orderWithUser.user 
          ? `${orderWithUser.user.first_name || ''} ${orderWithUser.user.last_name || ''}`.trim() || 'Client'
          : 'Client',
        amount: orderWithUser.totalAmount,
        deliveryZone: orderWithUser.address?.city || 'Zone non spécifiée',
        itemCount: completeOrder.items?.length || 0
      };

      // Envoyer les notifications en arrière-plan
      await NotificationService.sendRoleBasedNotifications(orderWithUser, notificationData)
        .catch((error: Error) => console.error('[OrderController] Notification error:', error));

      // 8. Préparer la réponse
      const response = {
        order: completeOrder,
        pricing,
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: await OrderSharedMethods.getUserPoints(userId)
        },
        affiliateCommission
      };

      res.json({ data: response });

    } catch (error: any) {
      console.error('[OrderController] Error creating order:', error);
      res.status(500).json({ 
        error: error.message || 'Error creating order',
        details: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }
  }

  static async calculateTotal(req: Request, res: Response) {
    try {
      const { items, appliedOfferIds } = req.body;
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const pricing = await PricingService.calculateOrderTotal({
        items,
        userId,
        appliedOfferIds
      });

      res.json({ data: pricing });
    } catch (error: any) {
      console.error('[OrderController] Error calculating total:', error);
      res.status(500).json({ error: error.message });
    }
  }
}