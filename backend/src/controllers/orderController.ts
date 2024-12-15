import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import  supabase  from '../config/supabase';
import { Order, OrderStatus } from '../models/order';

export class OrderController {
  async createOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;
      const userId = (req as any).user!.uid;

      const { data, error } = await supabase.from('orders').insert({
        userId,
        items,
        totalAmount,
        shippingAddress,
        billingAddress,
        paymentMethod,
        status: OrderStatus.PENDING,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

      if (error) {
        throw new AppError(500, 'Échec de la création de la commande', errorCodes.ORDER_CREATION_FAILED);
      }

      if (data && data[0]) {
        res.status(201).json({
          id: (data[0] as any).id,
          message: 'Commande créée avec succès'
        });
      } else {
        throw new AppError(500, 'Échec de la création de la commande', errorCodes.ORDER_CREATION_FAILED);
      }
    } catch (error) {
      next(new AppError(500, 'Échec de la création de la commande', errorCodes.ORDER_CREATION_FAILED));
    }
  }

  async getOrders(req: Request, res: Response, next: NextFunction) {
    try {
      const { page = 1, limit = 10, status, userId, startDate, endDate } = req.query;

      let query = supabase.from('orders').select('*').order('createdAt', { ascending: false });

      if (status) {
        query = query.eq('status', status);
      }

      if (userId) {
        query = query.eq('userId', userId);
      }

      if (startDate) {
        query = query.gte('createdAt', startDate);
      }

      if (endDate) {
        query = query.lte('createdAt', endDate);
      }

      const { data, error } = await query.range((Number(page) - 1) * Number(limit), Number(page) * Number(limit));

      if (error) {
        throw new AppError(500, 'Échec de la récupération des commandes', errorCodes.ORDER_FETCH_FAILED);
      }

      if (data) {
        res.json(data);
      } else {
        res.json([]);
      }
    } catch (error) {
      next(new AppError(500, 'Échec de la récupération des commandes', errorCodes.ORDER_FETCH_FAILED));
    }
  }

  async getOrderById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const { data, error } = await supabase.from('orders').select('*').eq('id', id).single();

      if (error) {
        throw new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND);
      }

      res.json(data);
    } catch (error) {
      next(new AppError(500, 'Échec de la récupération de la commande', errorCodes.ORDER_FETCH_FAILED));
    }
  }

  async updateOrderStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const { data, error } = await supabase.from('orders').update({ status, updatedAt: new Date().toISOString() }).eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Échec de la mise à jour du statut de la commande', errorCodes.ORDER_UPDATE_FAILED);
      }

      res.json({
        message: 'Statut de la commande mis à jour avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la mise à jour du statut de la commande', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async assignDeliveryPerson(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { deliveryPersonId } = req.body;

      const { data, error } = await supabase.from('orders').update({ deliveryPersonId, updatedAt: new Date().toISOString() }).eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Échec de l\'assignation du livreur à la commande', errorCodes.ORDER_UPDATE_FAILED);
      }

      res.json({
        message: 'Livreur assigné à la commande avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de l\'assignation du livreur à la commande', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async updateOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;

      const { data, error } = await supabase.from('orders').update({ items, totalAmount, shippingAddress, billingAddress, paymentMethod, updatedAt: new Date().toISOString() }).eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Échec de la mise à jour de la commande', errorCodes.ORDER_UPDATE_FAILED);
      }

      res.json({
        message: 'Commande mise à jour avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la mise à jour de la commande', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async cancelOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const { data, error } = await supabase.from('orders').update({ status: OrderStatus.CANCELLED, updatedAt: new Date().toISOString() }).eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Échec de l\'annulation de la commande', errorCodes.ORDER_CANCELLATION_FAILED);
      }

      res.json({
        message: 'Commande annulée avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de l\'annulation de la commande', errorCodes.ORDER_CANCELLATION_FAILED));
    }
  }

  async getOrderHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user!.uid;
      const { page = 1, limit = 10 } = req.query;

      const { data, error } = await supabase.from('orders').select('*').eq('userId', userId).order('createdAt', { ascending: false }).range((Number(page) - 1) * Number(limit), Number(page) * Number(limit));

      if (error) {
        throw new AppError(500, 'Échec de la récupération de l\'historique des commandes', errorCodes.ORDER_HISTORY_FETCH_FAILED);
      }

      if (data) {
        res.json(data);
      } else {
        res.json([]);
      }
    } catch (error) {
      next(new AppError(500, 'Échec de la récupération de l\'historique des commandes', errorCodes.ORDER_HISTORY_FETCH_FAILED));
    }
  }

  async rateOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { rating, comment } = req.body;

      const { data, error } = await supabase.from('orders').update({ rating, comment, updatedAt: new Date().toISOString() }).eq('id', id).select().single();

      if (error) {
        throw new AppError(500, 'Échec de la notation de la commande', errorCodes.ORDER_RATING_FAILED);
      }

      res.json({
        message: 'Commande notée avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la notation de la commande', errorCodes.ORDER_RATING_FAILED));
    }
  }
}
