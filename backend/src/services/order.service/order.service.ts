import { PrismaClient } from '@prisma/client';
import { 
  CreateOrderDTO, 
  CreateOrderResponse, 
  Order, 
  OrderStatus
} from '../../models/types';
import { OrderCreateService } from './orderCreate.service';
import { OrderQueryService } from './orderQuery.service';
import { OrderStatusService } from './orderStatus.service';
import { OrderPaymentService } from './orderPayment.service';

const prisma = new PrismaClient();

export class OrderService {
  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    return OrderCreateService.createOrder(orderData);
  }

  static async getUserOrders(userId: string): Promise<Order[]> {
    return OrderQueryService.getUserOrders(userId);
  }

  static async getOrderDetails(orderId: string): Promise<Order> {
    return OrderQueryService.getOrderDetails(orderId);
  }

  static async getRecentOrders(limit: number = 5): Promise<Order[]> {
    return OrderQueryService.getRecentOrders(limit);
  }

  static async getOrdersByStatus(status?: OrderStatus): Promise<Record<string, number>> {
    const orders = await prisma.orders.groupBy({
      by: ['status'],
      _count: {
        status: true
      },
      where: status ? { status } : undefined
    });

    return orders.reduce((acc, curr) => {
      if (curr.status) {
        acc[curr.status] = curr._count.status;
      }
      return acc;
    }, {} as Record<string, number>);
  }

  static async updateOrderStatus(
    orderId: string,
    newStatus: OrderStatus,
    userId: string,
    userRole: string
  ): Promise<Order> {
    return OrderStatusService.updateOrderStatus(orderId, newStatus, userId, userRole);
  }

  static async deleteOrder(orderId: string, userId: string, userRole: string): Promise<void> {
    await prisma.orders.deleteMany({
      where: {
        id: orderId,
        OR: [
          { userId }, // Vérification directe de l'utilisateur
          ...(userRole === 'ADMIN' || userRole === 'SUPER_ADMIN' ? [{}] : []) // Autorisation basée sur le rôle passé
        ]
      }
    });
  }

  static async calculateTotal(
    items: { articleId: string; quantity: number }[]
  ): Promise<number> {
    const itemIds = items.map(item => item.articleId);
    const articles = await prisma.articles.findMany({
      where: {
        id: { in: itemIds }
      },
      select: {
        id: true,
        basePrice: true
      }
    });

    const articlePrices = new Map(
      articles.map(article => [article.id, article.basePrice])
    );

    return items.reduce((total, item) => {
      const price = articlePrices.get(item.articleId);
      if (!price) throw new Error(`Article not found: ${item.articleId}`);
      return total + (Number(price) * item.quantity);
    }, 0);
  }
}
