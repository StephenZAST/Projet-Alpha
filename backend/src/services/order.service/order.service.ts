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

export class OrderService {
  // Création de commande
  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    return OrderCreateService.createOrder(orderData);
  }

  // Requêtes de commandes
  static async getUserOrders(userId: string): Promise<Order[]> {
    return OrderQueryService.getUserOrders(userId);
  } 

  static async getOrderDetails(orderId: string): Promise<Order> {
    return OrderQueryService.getOrderDetails(orderId);
  }

  static async getRecentOrders(limit: number = 5): Promise<Order[]> {
    return OrderQueryService.getRecentOrders(limit);
  }

  static async getOrdersByStatus(): Promise<Record<string, number>> {
    return OrderQueryService.getOrdersByStatus();
  }

  // Gestion des statuts
  static async updateOrderStatus(
    orderId: string,
    newStatus: OrderStatus,
    userId: string,
    userRole: string
  ): Promise<Order> {
    return OrderStatusService.updateOrderStatus(orderId, newStatus, userId, userRole);
  }

  static async deleteOrder(orderId: string, userId: string, userRole: string): Promise<void> {
    return OrderStatusService.deleteOrder(orderId, userId, userRole);
  }

  // Paiements et calculs
  static async calculateTotal(
    items: { articleId: string; quantity: number }[]
  ): Promise<number> {
    return OrderPaymentService.calculateTotal(items);
  }

  static async updatePaymentStatus(
    orderId: string,
    paymentStatus: string,
    userId: string
  ): Promise<void> {
    return OrderPaymentService.updatePaymentStatus(orderId, paymentStatus, userId);
  }
}

// Exporter tous les services pour un accès direct si nécessaire
export {
  OrderCreateService,
  OrderQueryService,
  OrderStatusService,
  OrderPaymentService
};
