import { Request, Response } from 'express';
import { OrderCreateController } from './orderCreate.controller';
import { OrderQueryController } from './orderQuery.controller';
import { OrderStatusController } from './orderStatus.controller';
import { OrderSharedMethods } from './shared';

export class OrderController {
  // Méthodes de création
  static async createOrder(req: Request, res: Response): Promise<void> {
    await OrderCreateController.createOrder(req, res);
  }

  static async calculateTotal(req: Request, res: Response): Promise<void> {
    await OrderCreateController.calculateTotal(req, res);
  }

  // Méthodes de lecture
  static async getOrderDetails(req: Request, res: Response): Promise<void> {
    await OrderQueryController.getOrderDetails(req, res);
  }

  static async getUserOrders(req: Request, res: Response): Promise<void> {
    await OrderQueryController.getUserOrders(req, res);
  }

  static async getRecentOrders(req: Request, res: Response): Promise<void> {
    await OrderQueryController.getRecentOrders(req, res);
  }

  static async getAllOrders(req: Request, res: Response): Promise<void> {
    await OrderQueryController.getAllOrders(req, res);
  }

  static async getOrdersByStatus(req: Request, res: Response): Promise<void> {
    await OrderQueryController.getOrdersByStatus(req, res);
  }

  static async generateInvoice(req: Request, res: Response): Promise<void> {
    await OrderQueryController.generateInvoice(req, res);
  }

  // Méthodes de gestion des statuts
  static async updateOrderStatus(req: Request, res: Response): Promise<void> {
    await OrderStatusController.updateOrderStatus(req, res);
  }

  static async deleteOrder(req: Request, res: Response): Promise<void> {
    await OrderStatusController.deleteOrder(req, res);
  }

  // Méthodes partagées
  static getOrderItems = OrderSharedMethods.getOrderItems;
  static getUserPoints = OrderSharedMethods.getUserPoints;
}

// Exporter les sous-contrôleurs pour un accès direct si nécessaire
export {
  OrderCreateController,
  OrderQueryController,
  OrderStatusController,
  OrderSharedMethods
};