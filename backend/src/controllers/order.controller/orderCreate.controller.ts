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
        appliedOfferIds
      } = req.body;
      
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      // 1. Calculer le prix total avec les réductions
      const pricing = await PricingService.calculateOrderTotal({
        items,
        userId,
        appliedOfferIds
      });

      // 2. Créer la commande
      const orderData = {
        userId,
        serviceId,
        addressId,
        isRecurring,
        recurrenceType,
        collectionDate,
        deliveryDate,
        affiliateCode,
        paymentMethod,
        totalAmount: pricing.total,
        status: 'PENDING' as OrderStatus,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      const { data: order, error } = await supabase
        .from('orders')
        .insert([orderData])
        .select()
        .single();

      if (error) throw error;

      // 3. Créer les items
      const articlesData = await Promise.all(items.map(async (item: CreateOrderItemData) => {
        const { data: article, error: articleError } = await supabase
          .from('articles')
          .select('*, category:article_categories(*)')
          .eq('id', item.articleId)
          .single();

        if (articleError || !article) {
          throw new Error(`Article not found: ${item.articleId}`);
        }

        return {
          article,
          quantity: item.quantity,
          isPremium: item.isPremium || false
        };
      }));

      // 4. Créer les items de commande
      const orderItems = articlesData.map(({ article, quantity, isPremium }) => ({
        orderId: order.id,
        articleId: article.id,
        serviceId,
        quantity,
        unitPrice: isPremium ? article.premiumPrice : article.basePrice,
        createdAt: new Date(),
        updatedAt: new Date()
      }));

      const { error: itemsError } = await supabase
        .from('order_items')
        .insert(orderItems);

      if (itemsError) {
        console.error('Error creating order items:', itemsError);
        throw itemsError;
      }

      // 5. Récupérer la commande complète
      const completeOrder = {
        ...order,
        totalAmount: pricing.total,
        items: await OrderSharedMethods.getOrderItems(order.id)
      };

      // 6. Traiter les points de fidélité
      const earnedPoints = Math.floor(pricing.total * SYSTEM_CONSTANTS.POINTS.ORDER_MULTIPLIER);
      await RewardsService.processOrderPoints(userId, completeOrder, 'ORDER');

      // 7. Traiter la commission d'affilié
      if (affiliateCode) {
        await RewardsService.processAffiliateCommission(completeOrder);
      }

      // 8. Envoyer les notifications
      await NotificationService.createOrderNotification(
        userId,
        order.id,
        'ORDER_CREATED',
        {
          pricing,
          earnedPoints
        }
      );

      // 9. Préparer la réponse
      const response = {
        order: completeOrder,
        pricing,
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: await OrderSharedMethods.getUserPoints(userId)
        }
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