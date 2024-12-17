import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import  supabase  from '../config/supabase';
import { Order, OrderStatus, GetOrdersOptions } from '../models/order';
import { User } from '../models/user';

interface CustomRequest extends Request {
  user?: User;
}

export class OrderController {
  async createOrder(req: CustomRequest, res: Response, next: NextFunction) {
    try {
      const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;
      const userId = req.user!.uid;

      const { data, error } = await supabase
        .from('orders')
        .insert({
          userId,
          items,
          totalAmount,
          shippingAddress,
          billingAddress,
          paymentMethod,
          status: OrderStatus.PENDING,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        })
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to create order', errorCodes.ORDER_CREATION_FAILED);
      }

      res.status(201).json({
        id: data.id,
        message: 'Order created successfully',
      });
    } catch (error) {
      next(new AppError(500, 'Failed to create order', errorCodes.ORDER_CREATION_FAILED));
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
        throw new AppError(500, 'Failed to fetch orders', errorCodes.ORDER_FETCH_FAILED);
      }

      res.json(data);
    } catch (error) {
      next(new AppError(500, 'Failed to fetch orders', errorCodes.ORDER_FETCH_FAILED));
    }
  }

  async getOrderById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const { data, error } = await supabase.from('orders').select('*').eq('id', id).single();

      if (error) {
        throw new AppError(404, 'Order not found', errorCodes.ORDER_NOT_FOUND);
      }

      res.json(data);
    } catch (error) {
      next(new AppError(500, 'Failed to fetch order', errorCodes.ORDER_FETCH_FAILED));
    }
  }

  async updateOrderStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const { data, error } = await supabase
        .from('orders')
        .update({ status, updatedAt: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to update order status', errorCodes.ORDER_UPDATE_FAILED);
      }

      res.json({
        message: 'Order status updated successfully',
      });
    } catch (error) {
      next(new AppError(500, 'Failed to update order status', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async assignDeliveryPerson(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { deliveryPersonId } = req.body;

      const { data, error } = await supabase
        .from('orders')
        .update({ deliveryPersonId, updatedAt: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to assign delivery person to order', errorCodes.ORDER_UPDATE_FAILED);
      }

      res.json({
        message: 'Delivery person assigned to order successfully',
      });
    } catch (error) {
      next(new AppError(500, 'Failed to assign delivery person to order', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async updateOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;

      const { data, error } = await supabase
        .from('orders')
        .update({ items, totalAmount, shippingAddress, billingAddress, paymentMethod, updatedAt: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to update order', errorCodes.ORDER_UPDATE_FAILED);
      }

      res.json({
        message: 'Order updated successfully',
      });
    } catch (error) {
      next(new AppError(500, 'Failed to update order', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async cancelOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const { data, error } = await supabase
        .from('orders')
        .update({ status: OrderStatus.CANCELLED, updatedAt: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to cancel order', errorCodes.ORDER_CANCELLATION_FAILED);
      }

      res.json({
        message: 'Order cancelled successfully',
      });
    } catch (error) {
      next(new AppError(500, 'Failed to cancel order', errorCodes.ORDER_CANCELLATION_FAILED));
    }
  }

  async getOrderHistory(req: CustomRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.uid;
      const { page = 1, limit = 10 } = req.query;

      const { data, error } = await supabase
        .from('orders')
        .select('*')
        .eq('userId', userId)
        .order('createdAt', { ascending: false })
        .range((Number(page) - 1) * Number(limit), Number(page) * Number(limit));

      if (error) {
        throw new AppError(500, 'Failed to fetch order history', errorCodes.ORDER_HISTORY_FETCH_FAILED);
      }

      res.json(data);
    } catch (error) {
      next(new AppError(500, 'Failed to fetch order history', errorCodes.ORDER_HISTORY_FETCH_FAILED));
    }
  }

  async rateOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { rating, comment } = req.body;

      const { data, error } = await supabase
        .from('orders')
        .update({ rating, comment, updatedAt: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw new AppError(500, 'Failed to rate order', errorCodes.ORDER_RATING_FAILED);
      }

      res.json({
        message: 'Order rated successfully',
      });
    } catch (error) {
      next(new AppError(500, 'Failed to rate order', errorCodes.ORDER_RATING_FAILED));
    }
  }
}
