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
    const { orderId, articleId, serviceId, quantity, unitPrice } = orderItemData;

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

    // Création de l'item avec le bon nom de table
    const orderItem = await prisma.order_items.create({
      data: {
        orderId,
        articleId,
        serviceId,
        quantity,
        unitPrice: new Prisma.Decimal(unitPrice),
        createdAt: new Date(),
        updatedAt: new Date()
      },
      include: this.itemInclude
    });

    // Conversion en OrderItem
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

  static async calculateTotal(orderItems: Array<{ articleId: string; quantity: number }>): Promise<number> {
    const articleIds = orderItems.map(item => item.articleId);
    
    const articles = await prisma.articles.findMany({
      where: {
        id: { in: articleIds }
      },
      select: {
        id: true,
        basePrice: true
      }
    });

    const priceMap = new Map(
      articles.map(article => [article.id, Number(article.basePrice)])
    );

    return orderItems.reduce((total, item) => {
      const price = priceMap.get(item.articleId);
      if (!price) throw new Error(`Article not found: ${item.articleId}`);
      return total + (price * item.quantity);
    }, 0);
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