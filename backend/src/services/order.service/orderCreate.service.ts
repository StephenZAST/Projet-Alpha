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
    // Vérification d’abonnement actif
    const subscription = await import('../subscription.service').then(m => m.SubscriptionService.getUserActiveSubscription(orderData.userId));
    const isSubscriptionOrder = !!subscription;
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

      // Calculer le prix de chaque item via PricingService
      const PricingService = require('../pricing.service').PricingService;
      const orderItemsWithPrice = [];
      for (const item of orderData.items) {
        const priceDetails = await PricingService.calculatePrice({
          articleId: item.articleId,
          serviceTypeId: service_type_id,
          quantity: item.quantity,
          isPremium: item.premiumPrice || false,
          weight: item.weight
        });
        orderItemsWithPrice.push({
          articleId: item.articleId,
          serviceId: orderData.serviceId,
          quantity: item.quantity,
          isPremium: item.premiumPrice || false,
          unitPrice: priceDetails.basePrice,
          weight: item.weight
        });
      }

      // Création de la commande avec les bons prix
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
            create: orderItemsWithPrice
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
      }

      // Toujours mettre à jour le totalAmount de la commande avec le vrai total calculé
      await prisma.orders.update({
        where: { id: createdOrder.id },
        data: { totalAmount: finalAmount }
      });

      // Rafraîchir la commande pour avoir le totalAmount à jour
      const refreshedOrder = await prisma.orders.findUnique({
        where: { id: createdOrder.id },
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

      // Construction de la réponse avec la commande rafraîchie
      if (!refreshedOrder) {
        throw new Error('Order not found after update');
      }
      const orderResponse: Order = {
        id: refreshedOrder.id,
        userId: refreshedOrder.userId,
        service_id: refreshedOrder.serviceId || '',
        address_id: refreshedOrder.addressId || '',
        status: refreshedOrder.status || 'PENDING',
        isRecurring: refreshedOrder.isRecurring || false,
        recurrenceType: refreshedOrder.recurrenceType || 'NONE',
        totalAmount: Number(refreshedOrder.totalAmount),
        createdAt: refreshedOrder.createdAt || new Date(),
        updatedAt: refreshedOrder.updatedAt || new Date(),
        service_type_id: service_type_id,
        paymentStatus: PaymentStatus.PENDING,
        paymentMethod: orderData.paymentMethod,
        affiliateCode: refreshedOrder.affiliateCode || undefined,
        items: refreshedOrder.order_items.map(item => ({
          id: item.id,
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: Number(item.unitPrice),
          isPremium: item.isPremium || false,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          article: item.article
            ? {
                ...item.article,
                categoryId: item.article.categoryId ?? '', // force string, jamais null
                description: item.article.description ?? '', // force string, jamais null
                basePrice: item.article.basePrice ? Number(item.article.basePrice) : 0,
                premiumPrice: item.article.premiumPrice ? Number(item.article.premiumPrice) : 0,
                createdAt: item.article.createdAt ? new Date(item.article.createdAt) : new Date(),
                updatedAt: item.article.updatedAt ? new Date(item.article.updatedAt) : new Date(),
                // ignore article_categories, deletedAt, etc. qui ne sont pas dans le type Article
              }
            : undefined
        }))
      };

      const currentPoints = await OrderPaymentService.getCurrentLoyaltyPoints(orderData.userId);

      return {
        order: orderResponse,
        pricing: {
          subtotal: finalAmount, // synchronisé avec le vrai total
          discounts: appliedDiscounts,
          total: finalAmount
        },
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: currentPoints
        },
        isSubscriptionOrder
      };

    } catch (error) {
      console.error('[OrderService] Error creating order:', error);
      throw error;
    }
  }
}