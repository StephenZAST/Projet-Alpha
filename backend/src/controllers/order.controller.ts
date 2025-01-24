import { Request, Response } from 'express';
import supabase from '../config/database';
import { 
  PricingService, 
  RewardsService, 
  NotificationService,
  OrderCalculationResult,
  SYSTEM_CONSTANTS
} from '../services';
import { Order, OrderStatus, OrderItem } from '../models/types';
import PDFDocument from 'pdfkit';

interface CreateOrderItemData {
  articleId: string;
  quantity: number;
  isPremium?: boolean;
}

interface OrderItemWithArticle extends OrderItem {
  article: {
    id: string;
    name: string;
    basePrice: number;
    premiumPrice: number;
    categoryId: string;
    createdAt: Date;
    updatedAt: Date;
    [key: string]: any;
  };
}

export class OrderController {
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
        items,
        paymentMethod,
        totalAmount: pricing.total,
        status: 'PENDING' as OrderStatus
      };

      const { data: order, error } = await supabase
        .from('orders')
        .insert([orderData])
        .select()
        .single();

      if (error) throw error;

      // 3. Créer les items de la commande
      const itemPromises = items.map(async (item: CreateOrderItemData) => {
        const unitPrice = await PricingService.getArticlePrice(
          item.articleId, 
          item.isPremium || false
        );

        return supabase.from('order_items').insert({
          orderId: order.id,
          articleId: item.articleId,
          serviceId,
          quantity: item.quantity,
          unitPrice
        });
      });

      await Promise.all(itemPromises);

      // 4. Traiter les points de fidélité
      const earnedPoints = Math.floor(pricing.total * SYSTEM_CONSTANTS.POINTS.ORDER_MULTIPLIER);
      await RewardsService.processOrderPoints(userId, order, 'ORDER');

      // 5. Si code affilié, traiter la commission
      if (affiliateCode) {
        await RewardsService.processAffiliateCommission(order);
      }

      // 6. Envoyer les notifications
      await NotificationService.createOrderNotification(
        userId,
        order.id,
        'ORDER_CREATED',
        {
          pricing,
          earnedPoints
        }
      );

      // 7. Préparer la réponse
      const response = {
        order: {
          ...order,
          items: await this.getOrderItems(order.id)
        },
        pricing,
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: (await this.getUserPoints(userId)).pointsBalance
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

  static async updateOrderStatus(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });
      if (!userRole) return res.status(401).json({ error: 'User role not found' });

      const orderId = req.params.orderId;
      const { status } = req.body;

      // 1. Mettre à jour le statut
      const order = await this.updateStatus(orderId, status, userId, userRole);

      // 2. Si la commande est livrée, traiter les points et commissions
      if (status === 'DELIVERED') {
        // Confirmer les points de fidélité
        await RewardsService.processOrderPoints(order.userId, order, 'ORDER');
        
        // Confirmer la commission d'affilié si présente
        if (order.affiliateCode) {
          await RewardsService.processAffiliateCommission(order);
        }
      }

      // 3. Envoyer les notifications appropriées
      await NotificationService.createOrderNotification(
        order.userId,
        orderId,
        'ORDER_STATUS_UPDATED',
        { newStatus: status }
      );

      res.json({ data: order });

    } catch (error: any) {
      console.error('[OrderController] Error updating order status:', error);
      res.status(500).json({ error: error.message });
    }
  }

  private static async updateStatus(
    orderId: string,
    newStatus: OrderStatus,
    userId: string,
    userRole: string
  ): Promise<Order> {
    const { data: order, error } = await supabase
      .from('orders')
      .update({ 
        status: newStatus,
        updatedAt: new Date()
      })
      .eq('id', orderId)
      .select()
      .single();

    if (error) throw error;
    if (!order) throw new Error('Order not found');
    
    return order;
  }

  private static async getOrderItems(orderId: string): Promise<OrderItemWithArticle[]> {
    const { data: items, error } = await supabase
      .from('order_items')
      .select(`
        *,
        article:articles(*)
      `)
      .eq('orderId', orderId);

    if (error) throw error;
    return items || [];
  }

  private static async getUserPoints(userId: string): Promise<{ pointsBalance: number }> {
    const { data, error } = await supabase
      .from('loyalty_points')
      .select('pointsBalance')
      .eq('user_id', userId)
      .single();

    if (error) throw error;
    return data || { pointsBalance: 0 };
  }

  // Autres méthodes du contrôleur...
}
