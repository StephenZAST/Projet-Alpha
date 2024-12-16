import { Request, Response } from 'express';
import { RecurringOrderService } from '../services/recurringOrders';

class RecurringOrderController {
  private recurringOrderService: RecurringOrderService;

  constructor() {
    this.recurringOrderService = new RecurringOrderService();
  }

  createRecurringOrder = async (req: Request, res: Response) => {
    try {
      const userId = req.body.userId;
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
      console.error('Error creating recurring order:', error);
      res.status(500).json({ 
        error: 'Échec de la création de la commande récurrente',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  };

  updateRecurringOrder = async (req: Request, res: Response) => {
    try {
      const userId = req.body.userId;
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
      console.error('Error updating recurring order:', error);
      if (error instanceof Error && error.message === 'Unauthorized') {
        res.status(403).json({ error: 'Non autorisé' });
      } else if (error instanceof Error && error.message === 'Recurring order not found') {
        res.status(404).json({ error: 'Commande récurrente non trouvée' });
      } else {
        res.status(500).json({ 
          error: 'Échec de la mise à jour de la commande récurrente',
          details: error instanceof Error ? error.message : 'Unknown error'
        });
      }
    }
  };

  cancelRecurringOrder = async (req: Request, res: Response) => {
    try {
      const userId = req.body.userId;
      const { id } = req.params;

      await this.recurringOrderService.cancelRecurringOrder(id, userId);

      res.json({
        message: 'Commande récurrente annulée avec succès'
      });
    } catch (error) {
      console.error('Error canceling recurring order:', error);
      if (error instanceof Error && error.message === 'Unauthorized') {
        res.status(403).json({ error: 'Non autorisé' });
      } else if (error instanceof Error && error.message === 'Recurring order not found') {
        res.status(404).json({ error: 'Commande récurrente non trouvée' });
      } else {
        res.status(500).json({ 
          error: 'Échec de l\'annulation de la commande récurrente',
          details: error instanceof Error ? error.message : 'Unknown error'
        });
      }
    }
  };

  getRecurringOrders = async (req: Request, res: Response) => {
    try {
      const userId = req.body.userId;
      const orders = await this.recurringOrderService.getRecurringOrders(userId);

      res.json({
        recurringOrders: orders
      });
    } catch (error) {
      console.error('Error fetching recurring orders:', error);
      res.status(500).json({ 
        error: 'Échec de la récupération des commandes récurrentes',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  };

  // Cette méthode serait appelée par un job planifié
  processRecurringOrders = async (_req: Request, res: Response) => {
    try {
      await this.recurringOrderService.processRecurringOrders();
      res.json({
        message: 'Traitement des commandes récurrentes effectué avec succès'
      });
    } catch (error) {
      console.error('Error processing recurring orders:', error);
      res.status(500).json({ 
        error: 'Échec du traitement des commandes récurrentes',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  };
}

export const recurringOrderController = new RecurringOrderController();
