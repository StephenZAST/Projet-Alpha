import { Request, Response } from 'express';
import supabase from '../../config/database';
import { 
  PricingService, 
  RewardsService, 
  NotificationService,
  SYSTEM_CONSTANTS
} from '../../services';
import { OrderStatus } from '../../models/types';
import { OrderSharedMethods } from './shared';

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
        serviceTypeId
      } = req.body;
      
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      // 1. Calculer le prix total avec les réductions
      console.log('[OrderController] Calculating total price for items:', items);
      const pricing = await PricingService.calculateOrderTotal({
        items,
        userId,
        appliedOfferIds
      });
      console.log('[OrderController] Price calculation result:', pricing);

      // 2. Créer la commande avec le montant total
      const orderData = {
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
      };

      const { data: order, error } = await supabase
        .from('orders')
        .insert([orderData])
        .select()
        .single();

      if (error) throw error;
      console.log('[OrderController] Order created:', order.id);

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

      // 7. Envoyer les notifications
      await NotificationService.createOrderNotification(
        userId,
        order.id,
        'ORDER_CREATED',
        {
          pricing,
          earnedPoints,
          affiliateCommission
        }
      );
      console.log('[OrderController] Notifications sent');

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