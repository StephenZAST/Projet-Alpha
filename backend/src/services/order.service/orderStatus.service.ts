import { PrismaClient, payment_method_enum } from '@prisma/client';
import { Order, OrderStatus, NotificationType, PaymentMethod } from '../../models/types';
import { NotificationService } from '../notification.service';

const prisma = new PrismaClient();

export class OrderStatusService {
  private static readonly validStatusTransitions: Record<OrderStatus, OrderStatus[]> = {
    'DRAFT': ['PENDING'],
    'PENDING': ['COLLECTING'],
    'COLLECTING': ['COLLECTED'],
    'COLLECTED': ['PROCESSING'],
    'PROCESSING': ['READY'],
    'READY': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': [],
    'CANCELLED': []
  };

  private static validateStatusTransition(currentStatus: OrderStatus, newStatus: OrderStatus): boolean {
    const validNextStatuses = this.validStatusTransitions[currentStatus];
    return validNextStatuses.includes(newStatus);
  }

  static async updateOrderStatus(
    orderId: string, 
    newStatus: OrderStatus, 
    userId: string, 
    userRole: string 
  ): Promise<Order> {
    console.log(`Attempting to update order ${orderId} to status ${newStatus}`);

    try {
      // 1. Vérifier si la commande existe
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        include: {
          order_items: {
            include: {
              article: true
            }
          }
        }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      // 2. Vérifier les autorisations
      const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
      if (!allowedRoles.includes(userRole)) {
        throw new Error('Unauthorized to update order status');
      }

      // 3. Valider la transition de statut
      if (!this.validateStatusTransition(order.status as OrderStatus, newStatus)) {
        throw new Error(`Invalid status transition from ${order.status} to ${newStatus}`);
      }

      // Conversion du type payment_method_enum vers PaymentMethod
      const convertPaymentMethod = (method: payment_method_enum | null): PaymentMethod => {
        switch (method) {
          case 'CASH':
            return PaymentMethod.CASH;
          case 'ORANGE_MONEY':
            return PaymentMethod.ORANGE_MONEY;
          default:
            return PaymentMethod.CASH;
        }
      };

      // 4. Mettre à jour le statut
      const updatedOrder = await prisma.orders.update({
        where: { id: orderId },
        data: {
          status: newStatus,
          updatedAt: new Date()
        },
        include: {
          order_items: {
            include: {
              article: true
            }
          },
          service_types: true
        }
      });

      // 5. Si le statut est "DELIVERED", mettre à jour les statistiques
      if (newStatus === 'DELIVERED' && order.status !== 'DELIVERED') {
        await this.handleDeliveredStatus(orderId, order.userId);
      }

      // 6. Notifier le client
      await NotificationService.createOrderNotification(
        order.userId,
        orderId,
        NotificationType.ORDER_STATUS_UPDATED,
        { newStatus }
      );

      // 7. Formater la réponse selon l'interface Order
      return {
        id: updatedOrder.id,
        userId: updatedOrder.userId,
        service_id: updatedOrder.serviceId || '',
        address_id: updatedOrder.addressId || '',
        status: updatedOrder.status as OrderStatus,
        isRecurring: updatedOrder.isRecurring || false,
        recurrenceType: updatedOrder.recurrenceType || 'NONE',
        totalAmount: Number(updatedOrder.totalAmount || 0),
        collectionDate: updatedOrder.collectionDate || undefined,
        deliveryDate: updatedOrder.deliveryDate || undefined,
        createdAt: updatedOrder.createdAt || new Date(),
        updatedAt: updatedOrder.updatedAt || new Date(),
        service_type_id: updatedOrder.service_type_id,
        paymentStatus: updatedOrder.status as any,
        paymentMethod: convertPaymentMethod(updatedOrder.paymentMethod),
        affiliateCode: updatedOrder.affiliateCode || undefined,
        items: updatedOrder.order_items.map(item => ({
          id: item.id,
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: Number(item.unitPrice),
          isPremium: item.isPremium || false,
          article: item.article ? {
            id: item.article.id,
            categoryId: item.article.categoryId || '',
            name: item.article.name,
            description: item.article.description || undefined,
            basePrice: Number(item.article.basePrice),
            premiumPrice: Number(item.article.premiumPrice || 0),
            createdAt: item.article.createdAt || new Date(),
            updatedAt: item.article.updatedAt || new Date()
          } : undefined,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        }))
      };

    } catch (error) {
      console.error('Error updating order status:', error);
      throw error;
    }
  }

  private static async handleDeliveredStatus(orderId: string, userId: string): Promise<void> {
    try {
      await prisma.orders.update({
        where: { id: orderId },
        data: {
          updatedAt: new Date()
        }
      });

    } catch (error) {
      console.error('Error updating delivery statistics:', error);
    }
  }

  static async deleteOrder(orderId: string, userId: string, userRole: string): Promise<void> {
    const order = await prisma.orders.findUnique({
      where: { id: orderId }
    });

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.userId !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
      throw new Error('Unauthorized to delete order');
    }

    await prisma.orders.delete({
      where: { id: orderId }
    });
  }
}