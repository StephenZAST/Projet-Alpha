import { Request, Response } from 'express';
import supabase from '../../config/database';
import { NotificationType, OrderStatus } from '../../models/types';
import { RewardsService, NotificationService } from '../../services';
import { OrderSharedMethods } from './shared';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();  

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
        NotificationType.ORDER_STATUS_UPDATED,
        { newStatus: status }
      );

      // 🔔 Notifier le client que le statut de sa commande a changé
      try {
        const oldStatus = order.status || 'UNKNOWN';
        await NotificationService.notifyOrderStatusChanged(
          order.userId,
          orderId,
          oldStatus,
          status,
          Number(order.totalAmount || 0)
        );
      } catch (notificationError: any) {
        console.error('[OrderStatusController] Error sending status changed notification:', notificationError);
      }

      // 🔔 Si la commande est prête, notifier le client
      if (status === 'READY') {
        try {
          const pickupDeadline = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
          await NotificationService.notifyOrderReadyPickup(
            order.userId,
            orderId,
            pickupDeadline,
            Number(order.totalAmount || 0)
          );
        } catch (notificationError: any) {
          console.error('[OrderStatusController] Error sending ready pickup notification:', notificationError);
        }
      }

      // 🔔 Si la commande est livrée, notifier le client
      if (status === 'DELIVERED') {
        try {
          const deliveryPersonName = req.body.deliveryPersonName || 'Livreur';
          await NotificationService.notifyDeliveryCompleted(
            order.userId,
            orderId,
            deliveryPersonName,
            Number(order.totalAmount || 0)
          );
        } catch (notificationError: any) {
          console.error('[OrderStatusController] Error sending delivery completed notification:', notificationError);
        }
      }

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
    const order = await supabase.orders.findUnique({
      where: {
        id: orderId
      }
    });

    if (!order) {
      throw new Error('Order not found');
    }

    // Valider la transition de statut
    const currentStatus = order.status ?? 'DRAFT';
    if (!this.isValidStatusTransition(currentStatus, newStatus)) {
      throw new Error(`Invalid status transition from ${currentStatus} to ${newStatus}`);
    }

    // Mettre à jour le statut
    const updatedOrder = await supabase.orders.update({
      where: {
        id: orderId
      },
      data: {
        status: newStatus,
        updatedAt: new Date()
      }
    });
    return updatedOrder;
  }

  private static isValidStatusTransition(currentStatus: OrderStatus, newStatus: OrderStatus): boolean {
    const validTransitions: Record<OrderStatus, OrderStatus[]> = {
      'DRAFT': ['PENDING'],
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

      // Récupérer la commande avant suppression pour les notifications
      const order = await prisma.orders.findUnique({
        where: { id: orderId }
      });

      // 🔔 Notifier le client que sa commande a été annulée
      if (order) {
        try {
          const cancellationReason = req.body.reason || 'Annulation administrative';
          const refundAmount = Number(order.totalAmount || 0);
          
          await NotificationService.notifyOrderCancelled(
            order.userId,
            orderId,
            cancellationReason,
            refundAmount
          );
        } catch (notificationError: any) {
          console.error('[OrderStatusController] Error sending order cancelled notification:', notificationError);
        }
      }

      await supabase.orders.delete({
        where: {
          id: orderId
        }
      });
      
      res.json({ message: 'Order deleted successfully' });
    } catch (error: any) {
      console.error('[OrderController] Error deleting order:', error);
      res.status(500).json({ error: error.message });
    }
  }
}