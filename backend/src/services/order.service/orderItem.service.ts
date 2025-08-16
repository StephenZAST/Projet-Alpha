import { PrismaClient, Prisma } from '@prisma/client';
import { OrderItem, CreateOrderItemDTO } from '../../models/types';

const prisma = new PrismaClient();

export class OrderItemService {
  // Définition de l'include avec les bonnes relations
  private static readonly itemInclude = {
    article: {
      include: {
        article_categories: true
      }
    }
  };

  static async createOrderItem(orderItemData: CreateOrderItemDTO): Promise<OrderItem> {
  const { orderId, articleId, serviceId, quantity, unitPrice, serviceTypeId, isPremium, weight } = orderItemData as any;

    // Vérification de l'article
    const article = await prisma.articles.findFirst({
      where: {
        id: articleId,
        isDeleted: false
      }
    });
    if (!article) {
      throw new Error(`Article not found or inactive: ${articleId}`);
    }

    // Récupération du prix via la table centralisée
    const priceEntry = await prisma.article_service_prices.findFirst({
      where: {
        article_id: articleId,
        service_type_id: serviceTypeId
      },
      include: {
        service_types: true
      }
    });
    if (!priceEntry || !priceEntry.is_available) {
      throw new Error('No price available for this article/service type');
    }

    let calculatedUnitPrice = 0;
    if (priceEntry.service_types?.pricing_type === 'PER_WEIGHT' || priceEntry.price_per_kg) {
      // Cas prix au poids
      if (!weight) throw new Error('Weight required for PER_WEIGHT service');
      calculatedUnitPrice = Number(priceEntry.price_per_kg) * Number(weight);
    } else {
      // Cas prix fixe
      calculatedUnitPrice = isPremium ? Number(priceEntry.premium_price) : Number(priceEntry.base_price);
    }

    const orderItem = await prisma.order_items.create({
      data: {
        orderId,
        articleId,
        serviceId,
        quantity,
        unitPrice: new Prisma.Decimal(calculatedUnitPrice),
        isPremium: !!isPremium,
        weight: weight !== undefined ? weight : null,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      include: this.itemInclude
    });

    return {
      id: orderItem.id,
      orderId: orderItem.orderId,
      articleId: orderItem.articleId,
      serviceId: orderItem.serviceId,
      quantity: orderItem.quantity,
      unitPrice: Number(orderItem.unitPrice),
      isPremium: orderItem.isPremium || false,
      createdAt: orderItem.createdAt,
      updatedAt: orderItem.updatedAt,
      article: orderItem.article ? {
        id: orderItem.article.id,
        categoryId: orderItem.article.categoryId || '',
        name: orderItem.article.name,
        description: orderItem.article.description || undefined,
        basePrice: Number(orderItem.article.basePrice),
        premiumPrice: Number(orderItem.article.premiumPrice || 0),
        createdAt: orderItem.article.createdAt || new Date(),
        updatedAt: orderItem.article.updatedAt || new Date()
      } : undefined
    };
  }

  static async getOrderItemById(orderItemId: string): Promise<OrderItem> {
    const orderItem = await prisma.order_items.findUnique({
      where: { id: orderItemId },
      include: this.itemInclude
    });

    if (!orderItem) throw new Error('Order item not found');

    return {
      id: orderItem.id,
      orderId: orderItem.orderId,
      articleId: orderItem.articleId,
      serviceId: orderItem.serviceId,
      quantity: orderItem.quantity,
      unitPrice: Number(orderItem.unitPrice),
      isPremium: orderItem.isPremium || false,
      createdAt: orderItem.createdAt,
      updatedAt: orderItem.updatedAt,
      article: orderItem.article ? {
        id: orderItem.article.id,
        categoryId: orderItem.article.categoryId || '',
        name: orderItem.article.name,
        description: orderItem.article.description || undefined,
        basePrice: Number(orderItem.article.basePrice),
        premiumPrice: Number(orderItem.article.premiumPrice || 0),
        createdAt: orderItem.article.createdAt || new Date(),
        updatedAt: orderItem.article.updatedAt || new Date()
      } : undefined
    };
  }

  static async getAllOrderItems(): Promise<OrderItem[]> {
    const items = await prisma.order_items.findMany({
      include: this.itemInclude
    });

    return items.map(item => ({
      id: item.id,
      orderId: item.orderId,
      articleId: item.articleId,
      serviceId: item.serviceId,
      quantity: item.quantity,
      unitPrice: Number(item.unitPrice),
      isPremium: item.isPremium || false,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      article: item.article ? {
        id: item.article.id,
        categoryId: item.article.categoryId || '',
        name: item.article.name,
        description: item.article.description || undefined,
        basePrice: Number(item.article.basePrice),
        premiumPrice: Number(item.article.premiumPrice || 0),
        createdAt: item.article.createdAt || new Date(),
        updatedAt: item.article.updatedAt || new Date()
      } : undefined
    }));
  }

  static async updateOrderItem(
    orderItemId: string,
    orderItemData: Partial<OrderItem>
  ): Promise<OrderItem> {
    const orderItem = await prisma.order_items.update({
      where: { id: orderItemId },
      data: {
        quantity: orderItemData.quantity,
        unitPrice: orderItemData.unitPrice ? new Prisma.Decimal(orderItemData.unitPrice) : undefined,
        isPremium: orderItemData.isPremium,
        updatedAt: new Date()
      },
      include: this.itemInclude
    });

    return {
      id: orderItem.id,
      orderId: orderItem.orderId,
      articleId: orderItem.articleId,
      serviceId: orderItem.serviceId,
      quantity: orderItem.quantity,
      unitPrice: Number(orderItem.unitPrice),
      isPremium: orderItem.isPremium || false,
      createdAt: orderItem.createdAt,
      updatedAt: orderItem.updatedAt,
      article: orderItem.article ? {
        id: orderItem.article.id,
        categoryId: orderItem.article.categoryId || '',
        name: orderItem.article.name,
        description: orderItem.article.description || undefined,
        basePrice: Number(orderItem.article.basePrice),
        premiumPrice: Number(orderItem.article.premiumPrice || 0),
        createdAt: orderItem.article.createdAt || new Date(),
        updatedAt: orderItem.article.updatedAt || new Date()
      } : undefined
    };
  }

  static async deleteOrderItem(orderItemId: string): Promise<void> {
    await prisma.order_items.delete({
      where: { id: orderItemId }
    });
  }

  static async calculateTotal(orderItems: Array<{ articleId: string; serviceTypeId: string; quantity?: number; weight?: number; isPremium?: boolean }>): Promise<number> {
    let total = 0;
    for (const item of orderItems) {
      const priceEntry = await prisma.article_service_prices.findFirst({
        where: {
          article_id: item.articleId,
          service_type_id: item.serviceTypeId
        },
        include: {
          service_types: true
        }
      });
      if (!priceEntry || !priceEntry.is_available) {
        throw new Error('No price available for this article/service type');
      }
      let itemTotal = 0;
      if (priceEntry.service_types?.pricing_type === 'PER_WEIGHT' || priceEntry.price_per_kg) {
        if (!item.weight) throw new Error('Weight required for PER_WEIGHT service');
        itemTotal = Number(priceEntry.price_per_kg) * Number(item.weight);
      } else {
        itemTotal = (item.isPremium ? Number(priceEntry.premium_price) : Number(priceEntry.base_price)) * (item.quantity || 1);
      }
      total += itemTotal;
    }
    return total;
  }

  static async getOrderItemsByOrderId(orderId: string) {
    try {
      const orderItems = await prisma.order_items.findMany({
        where: {
          orderId: orderId
        },
        include: {
          article: true,
          order: true
        }
      });

      if (!orderItems.length) {
        throw new Error('No order items found for this order');
      }

      return orderItems;
    } catch (error) {
      console.error('Error getting order items:', error);
      throw error;
    }
  }
}