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
        paymentMethod,
        totalAmount: pricing.total,
        status: 'PENDING' as OrderStatus
      }; // Retirer items car ce n'est pas une colonne de la table orders

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

      // 4. Récupérer la commande complète avec les items
      console.log('[OrderController] Getting complete order details');
      const completeOrder = {
        ...order,
        totalAmount: pricing.total,
        items: await this.getOrderItems(order.id)
      };
      console.log('[OrderController] Complete order:', {
        id: completeOrder.id,
        userId: completeOrder.userId,
        totalAmount: completeOrder.totalAmount,
        itemsCount: completeOrder.items.length
      });

      // 5. Traiter les points de fidélité
      console.log('[OrderController] Calculating loyalty points');
      const earnedPoints = Math.floor(pricing.total * SYSTEM_CONSTANTS.POINTS.ORDER_MULTIPLIER);
      console.log('[OrderController] Points to award:', earnedPoints);
      
      try {
        await RewardsService.processOrderPoints(userId, completeOrder, 'ORDER');
        console.log('[OrderController] Points processing successful');
      } catch (error) {
        console.error('[OrderController] Error in points processing:', error);
        throw error;
      }

      // 6. Si code affilié, traiter la commission
      if (affiliateCode) {
        await RewardsService.processAffiliateCommission(completeOrder);
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

  static async getRecentOrders(req: Request, res: Response) {
    try {
      const { limit = 5 } = req.query;
      const { data: orders, error } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name),
          service:services(name),
          items:order_items(
            quantity,
            article:articles(name)
          )
        `)
        .order('createdAt', { ascending: false })
        .limit(Number(limit));

      if (error) throw error;
      res.json({ data: orders });
    } catch (error: any) {
      console.error('[OrderController] Error getting recent orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getOrdersByStatus(req: Request, res: Response) {
    try {
      const { data: ordersByStatus, error } = await supabase
        .from('orders')
        .select('status, count')
        .select('*')
        .then((result) => {
          const orders = result.data || [];
          return orders.reduce((acc: Record<string, number>, order) => {
            acc[order.status] = (acc[order.status] || 0) + 1;
            return acc;
          }, {});
        });

      if (error) throw error;
      res.json({ data: ordersByStatus });
    } catch (error: any) {
      console.error('[OrderController] Error getting orders by status:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getUserOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const { data: orders, error } = await supabase
        .from('orders')
        .select('*, service:services(name)')
        .eq('userId', userId)
        .order('createdAt', { ascending: false });

      if (error) throw error;
      res.json({ data: orders });
    } catch (error: any) {
      console.error('[OrderController] Error getting user orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getOrderDetails(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      const { data: order, error } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name, email, phone),
          service:services(name),
          address:addresses(*),
          items:order_items(
            quantity,
            unit_price,
            article:articles(*)
          )
        `)
        .eq('id', orderId)
        .single();

      if (error) throw error;
      if (!order) return res.status(404).json({ error: 'Order not found' });

      res.json({ data: order });
    } catch (error: any) {
      console.error('[OrderController] Error getting order details:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async generateInvoice(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      
      // Récupérer les détails de la commande directement depuis Supabase
      const { data: order, error } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name, email, phone),
          service:services(name),
          address:addresses(*),
          items:order_items(
            quantity,
            unit_price,
            article:articles(*)
          )
        `)
        .eq('id', orderId)
        .single();

      if (error) throw error;
      if (!order) return res.status(404).json({ error: 'Order not found' });

      const doc = new PDFDocument();
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename=invoice-${orderId}.pdf`);
      
      doc.pipe(res);
      // Générer le contenu de la facture
      doc.fontSize(25).text('Facture', 100, 50);
      doc.fontSize(12).text(`Commande: ${orderId}`, 100, 100);
      // ... Ajouter plus de contenu
      doc.end();
    } catch (error: any) {
      console.error('[OrderController] Error generating invoice:', error);
      res.status(500).json({ error: error.message });
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

  static async getAllOrders(req: Request, res: Response) {
    try {
      const { page = 1, limit = 20, status, startDate, endDate } = req.query;

      let query = supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name),
          service:services(name)
        `);

      if (status) {
        query = query.eq('status', status);
      }

      if (startDate && endDate) {
        query = query
          .gte('createdAt', startDate as string)
          .lte('createdAt', endDate as string);  
      }

      const offset = (Number(page) - 1) * Number(limit);
      const { data: orders, error, count } = await query
        .range(offset, offset + Number(limit) - 1)
        .order('createdAt', { ascending: false });

      if (error) throw error;

      res.json({
        data: orders,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total: count || 0,
          totalPages: Math.ceil((count || 0) / Number(limit))
        }
      });
    } catch (error: any) {
      console.error('[OrderController] Error getting all orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteOrder(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      const userRole = req.user?.role;

      if (userRole !== 'ADMIN' && userRole !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Unauthorized' });
      }

      const { error } = await supabase
        .from('orders')
        .delete()
        .eq('id', orderId);

      if (error) throw error;
      res.json({ message: 'Order deleted successfully' });
    } catch (error: any) {
      console.error('[OrderController] Error deleting order:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
