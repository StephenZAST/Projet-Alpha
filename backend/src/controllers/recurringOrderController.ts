import { Request, Response, NextFunction } from 'express';
import { RecurringOrderService } from '../services/recurringOrders';
import { RecurringOrder } from '../types/recurring';
import { User } from '../models/user';

interface AuthenticatedRequest extends Request {
  user?: User;
}

class RecurringOrderController {
  private recurringOrderService: RecurringOrderService;

  constructor() {
    this.recurringOrderService = new RecurringOrderService();
  }

  createRecurringOrder = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const orderData = req.body;

      const recurringOrder = await this.recurringOrderService.createRecurringOrder(
        userId,
        orderData
      );

      res.status(201).json({
        message: 'Commande récurrente créée avec succès',
        recurringOrder
      });
    } catch (error) {
      next(error);
    }
  };

  updateRecurringOrder = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const updates = req.body;

      const updatedOrder = await this.recurringOrderService.updateRecurringOrder(
        id,
        userId,
        updates
      );

      res.json({
        message: 'Commande récurrente mise à jour avec succès',
        recurringOrder: updatedOrder
      });
    } catch (error) {
      next(error);
    }
  };

  cancelRecurringOrder = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;

      await this.recurringOrderService.cancelRecurringOrder(id, userId);

      res.json({
        message: 'Commande récurrente annulée avec succès'
      });
    } catch (error) {
      next(error);
    }
  };

  getRecurringOrders = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const orders = await this.recurringOrderService.getRecurringOrders(userId);

      res.json({
        recurringOrders: orders
      });
    } catch (error) {
      next(error);
    }
  };

  processRecurringOrders = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      await this.recurringOrderService.processRecurringOrders();
      res.json({
        message: 'Traitement des commandes récurrentes effectué avec succès'
      });
    } catch (error) {
      next(error);
    }
  };
}

export const recurringOrderController = new RecurringOrderController();
