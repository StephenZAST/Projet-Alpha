import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { db } from '../config/firebase';
import { Order, OrderStatus } from '../models/order';
import { Timestamp } from 'firebase-admin/firestore';

export class OrderController {
  async createOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { items, totalAmount, shippingAddress, billingAddress, paymentMethod } = req.body;
      const userId = req.user!.uid;

      const orderRef = await db.collection('orders').add({
        userId,
        items,
        totalAmount,
        shippingAddress,
        billingAddress,
        paymentMethod,
        status: OrderStatus.PENDING,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now()
      });

      res.status(201).json({
        id: orderRef.id,
        message: 'Commande créée avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la création de la commande', errorCodes.ORDER_CREATION_FAILED));
    }
  }

  async getOrders(req: Request, res: Response, next: NextFunction) {
    try {
      const { page = 1, limit = 10, status, userId, startDate, endDate } = req.query;

      let query = db.collection('orders').orderBy('createdAt', 'desc');

      if (status) {
        query = query.where('status', '==', status);
      }

      if (userId) {
        query = query.where('userId', '==', userId);
      }

      if (startDate) {
        query = query.where('createdAt', '>=', new Date(startDate as string));
      }

      if (endDate) {
        query = query.where('createdAt', '<=', new Date(endDate as string));
      }

      const snapshot = await query
        .offset((Number(page) - 1) * Number(limit))
        .limit(Number(limit))
        .get();

      const orders = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(orders);
    } catch (error) {
      next(new AppError(500, 'Échec de la récupération des commandes', errorCodes.ORDER_FETCH_FAILED));
    }
  }

  async getOrderById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const orderDoc = await db.collection('orders').doc(id).get();
      if (!orderDoc.exists) {
        return next(new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND));
      }

      res.json({
        id: orderDoc.id,
        ...orderDoc.data()
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la récupération de la commande', errorCodes.ORDER_FETCH_FAILED));
    }
  }

  async updateOrderStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const orderRef = db.collection('orders').doc(id);

      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        return next(new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND));
      }

      await orderRef.update({
        status,
        updatedAt: Timestamp.now()
      });

      res.json({
        id,
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

      const orderRef = db.collection('orders').doc(id);

      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        return next(new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND));
      }

      await orderRef.update({
        deliveryPersonId,
        updatedAt: Timestamp.now()
      });

      res.json({
        id,
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

      const orderRef = db.collection('orders').doc(id);

      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        return next(new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND));
      }

      await orderRef.update({
        items,
        totalAmount,
        shippingAddress,
        billingAddress,
        paymentMethod,
        updatedAt: Timestamp.now()
      });

      res.json({
        id,
        message: 'Commande mise à jour avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la mise à jour de la commande', errorCodes.ORDER_UPDATE_FAILED));
    }
  }

  async cancelOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const orderRef = db.collection('orders').doc(id);

      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        return next(new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND));
      }

      // Check if the order can be cancelled (e.g., not already delivered)
      const orderData = orderDoc.data() as Order;
      if (orderData.status === OrderStatus.DELIVERED) {
        return next(new AppError(400, 'Impossible d\'annuler une commande déjà livrée', errorCodes.ORDER_CANCELLATION_FAILED));
      }

      await orderRef.update({
        status: OrderStatus.CANCELLED,
        updatedAt: Timestamp.now()
      });

      res.json({
        message: 'Commande annulée avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de l\'annulation de la commande', errorCodes.ORDER_CANCELLATION_FAILED));
    }
  }

  async getOrderHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.uid;
      const { page = 1, limit = 10 } = req.query;

      const ordersSnapshot = await db.collection('orders')
        .where('userId', '==', userId)
        .orderBy('createdAt', 'desc')
        .offset((Number(page) - 1) * Number(limit))
        .limit(Number(limit))
        .get();

      const orders = ordersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      res.json(orders);
    } catch (error) {
      next(new AppError(500, 'Échec de la récupération de l\'historique des commandes', errorCodes.ORDER_HISTORY_FETCH_FAILED));
    }
  }

  async rateOrder(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { rating, comment } = req.body;

      const orderRef = db.collection('orders').doc(id);

      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        return next(new AppError(404, 'Commande non trouvée', errorCodes.ORDER_NOT_FOUND));
      }

      // Check if the order has already been rated by the user
      const orderData = orderDoc.data() as Order;
      if (orderData.rating) {
        return next(new AppError(400, 'Cette commande a déjà été notée', errorCodes.ORDER_ALREADY_RATED));
      }

      await orderRef.update({
        rating,
        comment,
        updatedAt: Timestamp.now()
      });

      res.json({
        message: 'Commande notée avec succès'
      });
    } catch (error) {
      next(new AppError(500, 'Échec de la notation de la commande', errorCodes.ORDER_RATING_FAILED));
    }
  }
}
