import { PrismaClient, order_status, payment_method_enum, orders } from '@prisma/client';
import { 
  CreateOrderDTO, 
  CreateOrderResponse, 
  AppliedDiscount, 
  NotificationType, 
  Order,
  PaymentMethod,
  PaymentStatus,
  OrderItem
} from '../../models/types';
import { NotificationService } from '../notification.service';
import { LoyaltyService } from '../loyalty.service';
import { OrderPaymentService } from './orderPayment.service';

const prisma = new PrismaClient();

export class OrderCreateService {
  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    try {
      const service_type_id = orderData.service_type_id || orderData.serviceTypeId;
      if (!service_type_id) {
        throw new Error('service_type_id is required');
      }

      // Vérification des articles
      const articles = await prisma.articles.findMany({
        where: {
          id: { in: orderData.items.map(item => item.articleId) },
          isDeleted: false
        }
      });

      if (articles.length !== orderData.items.length) {
        throw new Error('One or more articles are not available');
      }

      // Création de la commande
      const createdOrder = await prisma.orders.create({
        data: {
          userId: orderData.userId,
          serviceId: orderData.serviceId,
          addressId: orderData.addressId,
          status: 'PENDING',
          isRecurring: orderData.isRecurring || false,
          recurrenceType: orderData.recurrenceType,
          collectionDate: orderData.collectionDate,
          deliveryDate: orderData.deliveryDate,
          affiliateCode: orderData.affiliateCode,
          service_type_id: service_type_id,
          paymentMethod: orderData.paymentMethod as payment_method_enum,
          order_items: {
            create: orderData.items.map(item => ({
              articleId: item.articleId,
              serviceId: orderData.serviceId,
              quantity: item.quantity,
              isPremium: item.premiumPrice || false,
              unitPrice: 0
            }))
          }
        },
        include: {
          order_items: {
            include: {
              article: {
                include: {
                  article_categories: true
                }
              }
            }
          },
          service_types: true
        }
      });

      // Calcul du montant total
      const totalAmount = await OrderPaymentService.calculateTotal(orderData.items);
      let finalAmount = totalAmount;
      let appliedDiscounts: AppliedDiscount[] = [];

      if (orderData.offerIds?.length) {
        const discountResult = await OrderPaymentService.calculateDiscounts(
          orderData.userId,
          finalAmount,
          orderData.items.map(item => item.articleId),
          orderData.offerIds
        );
        
        finalAmount = discountResult.finalAmount;
        appliedDiscounts = discountResult.appliedDiscounts;

        await prisma.orders.update({
          where: { id: createdOrder.id },
          data: { totalAmount: finalAmount }
        });
      }

      // Traitement affilié et points
      if (orderData.affiliateCode) {
        await OrderPaymentService.processAffiliateCommission(
          createdOrder.id,
          orderData.affiliateCode,
          finalAmount
        );
      }

      const earnedPoints = Math.floor(finalAmount);
      await LoyaltyService.earnPoints(
        orderData.userId,
        earnedPoints,
        'ORDER',
        createdOrder.id
      );

      // Notification
      const orderItems = await prisma.order_items.findMany({
        where: { orderId: createdOrder.id },
        include: { article: true }
      });

      await NotificationService.createOrderNotification(
        orderData.userId,
        createdOrder.id,
        NotificationType.ORDER_CREATED,
        {
          totalAmount: finalAmount,
          items: orderItems.map(item => ({
            name: item.article?.name || 'Unknown Article',
            quantity: item.quantity
          }))
        }
      );

      // Construction de la réponse
      const orderResponse: Order = {
        id: createdOrder.id,
        userId: createdOrder.userId,
        service_id: createdOrder.serviceId || '',
        address_id: createdOrder.addressId || '',
        status: createdOrder.status || 'PENDING',
        isRecurring: createdOrder.isRecurring || false,
        recurrenceType: createdOrder.recurrenceType || 'NONE',
        totalAmount: Number(finalAmount),
        createdAt: createdOrder.createdAt || new Date(),
        updatedAt: createdOrder.updatedAt || new Date(),
        service_type_id: service_type_id,
        paymentStatus: PaymentStatus.PENDING,
        paymentMethod: orderData.paymentMethod,
        affiliateCode: createdOrder.affiliateCode || undefined,
        items: orderItems.map(item => ({
          id: item.id,
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: Number(item.unitPrice),
          isPremium: item.isPremium || false,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        }))
      };

      const currentPoints = await OrderPaymentService.getCurrentLoyaltyPoints(orderData.userId);

      return {
        order: orderResponse,
        pricing: {
          subtotal: totalAmount,
          discounts: appliedDiscounts,
          total: finalAmount
        },
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: currentPoints
        }
      };

    } catch (error) {
      console.error('[OrderService] Error creating order:', error);
      throw error;
    }
  }
}