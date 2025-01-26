import { Request, Response } from 'express';
import supabase from '../../config/database';
import { OrderStatus } from '../../models/types';
import { RewardsService, NotificationService } from '../../services';
import { OrderSharedMethods } from './shared';

export class OrderStatusController {
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

      // 2. Récupérer la commande complète avec les items
      const completeOrder = {
        ...order,
        items: await OrderSharedMethods.getOrderItems(orderId)
      };

      // 3. Si la commande est livrée, traiter les points et commissions
      if (status === 'DELIVERED') {
        // Confirmer les points de fidélité
        await RewardsService.processOrderPoints(order.userId, completeOrder, 'ORDER');
        
        // Confirmer la commission d'affilié si présente
        if (order.affiliateCode) {
          await RewardsService.processAffiliateCommission(completeOrder);
        }
      }

      // 4. Envoyer les notifications appropriées
      await NotificationService.createOrderNotification(
        order.userId,
        orderId,
        'ORDER_STATUS_UPDATED',
        { newStatus: status }
      );

      res.json({ data: completeOrder });

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
  ): Promise<any> {
    // Vérifier les autorisations
    const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
    if (!allowedRoles.includes(userRole)) {
      throw new Error('Unauthorized to update order status');
    }

    // Vérifier si la commande existe et obtenir son statut actuel
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      throw new Error('Order not found');
    }

    // Valider la transition de statut
    if (!this.isValidStatusTransition(order.status, newStatus)) {
      throw new Error(`Invalid status transition from ${order.status} to ${newStatus}`);
    }

    // Mettre à jour le statut
    const { data: updatedOrder, error } = await supabase
      .from('orders')
      .update({ 
        status: newStatus,
        updatedAt: new Date()
      })
      .eq('id', orderId)
      .select()
      .single();

    if (error) throw error;
    return updatedOrder;
  }

  private static isValidStatusTransition(currentStatus: OrderStatus, newStatus: OrderStatus): boolean {
    const validTransitions: Record<OrderStatus, OrderStatus[]> = {
      'PENDING': ['COLLECTING'],
      'COLLECTING': ['COLLECTED'],
      'COLLECTED': ['PROCESSING'],
      'PROCESSING': ['READY'],
      'READY': ['DELIVERING'],
      'DELIVERING': ['DELIVERED'],
      'DELIVERED': [], // Statut final
      'CANCELLED': []  // Statut final
    };

    return validTransitions[currentStatus]?.includes(newStatus) || false;
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