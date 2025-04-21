import { OrderItem } from '../../models/types';
import prisma from '../../config/prisma';
import { order_status, payment_method_enum } from '@prisma/client';

// Mise à jour de l'interface pour gérer les valeurs nullables
export interface OrderItemWithArticle extends Omit<OrderItem, 'article'> {
  article: {
    id: string;
    name: string;
    basePrice: number;
    premiumPrice: number | null;
    categoryId: string | null;  // Permettre null pour categoryId
    category?: {
      id: string;
      name: string;
      description?: string | null;
    } | null;
    createdAt: Date | null;
    updatedAt: Date | null;
  };
}

interface OrderWithDetails {
  id: string;
  userId: string;
  serviceId: string | null;
  addressId: string | null;
  affiliateCode?: string | null;
  status: order_status | null;
  isRecurring: boolean | null;
  recurrenceType: string | null;
  nextRecurrenceDate: Date | null;
  totalAmount: number | null;
  collectionDate: Date | null;
  deliveryDate: Date | null;
  createdAt: Date | null;
  updatedAt: Date | null;
  paymentMethod: payment_method_enum | null;
  service_type_id: string;
  order_items: Array<{
    id: string;
    orderId: string;
    articleId: string;
    serviceId: string;
    quantity: number;
    unitPrice: number;
    createdAt: Date;
    updatedAt: Date;
  }>;
}

export class OrderSharedMethods {
  static async getOrderItems(orderId: string): Promise<OrderItemWithArticle[]> {
    const items = await prisma.order_items.findMany({
      where: {
        orderId: orderId
      },
      include: {
        article: {
          include: {
            article_categories: true
          }
        }
      }
    });

    return items.map(item => ({
      id: item.id,
      orderId: item.orderId,
      articleId: item.articleId,
      serviceId: item.serviceId,
      quantity: item.quantity,
      unitPrice: Number(item.unitPrice),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      article: {
        id: item.article.id,
        name: item.article.name,
        basePrice: Number(item.article.basePrice),
        premiumPrice: item.article.premiumPrice ? Number(item.article.premiumPrice) : null,
        categoryId: item.article.categoryId || null,
        createdAt: item.article.createdAt,
        updatedAt: item.article.updatedAt,
        category: item.article.article_categories ? {
          id: item.article.article_categories.id,
          name: item.article.article_categories.name,
          description: item.article.article_categories.description || null
        } : null
      }
    }));
  }

  static async getUserPoints(userId: string): Promise<number> {
    const points = await prisma.loyalty_points.findUnique({
      where: {
        user_id: userId
      },
      select: {
        pointsBalance: true
      }
    });

    return points?.pointsBalance || 0;
  }

  static async getOrderWithDetails(orderId: string): Promise<OrderWithDetails> {
    const order = await prisma.orders.findUnique({
      where: {
        id: orderId
      },
      include: {
        user: true,
        service_types: true,
        address: true,
        order_items: {
          include: {
            article: {
              include: {
                article_categories: true
              }
            }
          }
        }
      }
    });

    if (!order) {
      throw new Error('Order not found');
    }

    return {
      ...order,
      userId: order.userId,
      serviceId: order.serviceId,
      addressId: order.addressId,
      service_type_id: order.service_type_id,
      totalAmount: order.totalAmount ? Number(order.totalAmount) : null,
      isRecurring: order.isRecurring,
      recurrenceType: order.recurrenceType,
      nextRecurrenceDate: order.nextRecurrenceDate,
      collectionDate: order.collectionDate,
      deliveryDate: order.deliveryDate,
      affiliateCode: order.affiliateCode,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      order_items: order.order_items.map(item => ({
        id: item.id,
        orderId: item.orderId,
        articleId: item.articleId,
        serviceId: item.serviceId,
        quantity: item.quantity,
        unitPrice: Number(item.unitPrice),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt
      }))
    };
  }
}