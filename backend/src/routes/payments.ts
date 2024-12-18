import { Router } from 'express';
import { isAuthenticated } from '../middleware/auth';
import {
  validateGetPaymentMethods,
  validateAddPaymentMethod,
  validateRemovePaymentMethod,
  validateSetDefaultPaymentMethod,
  validateProcessPayment,
  validateProcessRefund,
  validateGetPaymentHistory
} from '../middleware/paymentValidation';
import { PaymentService } from '../services/payment';
import { User } from '../models/user';
import { Request, Response, NextFunction } from 'express';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = Router();
const paymentService = new PaymentService();

router.get(
  '/methods',
  isAuthenticated,
  validateGetPaymentMethods,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const paymentMethods = await paymentService.getPaymentMethods(userId);
      res.json(paymentMethods);
    } catch (error) {
      next(error);
    }
  }
);

router.post(
  '/methods',
  isAuthenticated,
  validateAddPaymentMethod,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const paymentMethod = await paymentService.addPaymentMethod(userId, req.body);
      res.status(201).json(paymentMethod);
    } catch (error) {
      next(error);
    }
  }
);

router.delete(
  '/methods/:id',
  isAuthenticated,
  validateRemovePaymentMethod,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const paymentMethodId = req.params.id;
      await paymentService.removePaymentMethod(userId, paymentMethodId);
      res.json({ message: 'Payment method removed successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.put(
  '/methods/:id/default',
  isAuthenticated,
  validateSetDefaultPaymentMethod,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const paymentMethodId = req.params.id;
      await paymentService.setDefaultPaymentMethod(userId, paymentMethodId);
      res.json({ message: 'Default payment method updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.post(
  '/process',
  isAuthenticated,
  validateProcessPayment,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const payment = await paymentService.processPayment({ ...req.body, userId });
      res.json(payment);
    } catch (error) {
      next(error);
    }
  }
);

router.post(
  '/refund',
  isAuthenticated,
  validateProcessRefund,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const refund = await paymentService.processRefund({ ...req.body, userId });
      res.json(refund);
    } catch (error) {
      next(error);
    }
  }
);

router.get(
  '/history',
  isAuthenticated,
  validateGetPaymentHistory,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }
      const userId = req.user.id;
      const { page, limit, status } = req.query;
      const paymentHistory = await paymentService.getPaymentHistory(userId, {
        page: Number(page),
        limit: Number(limit),
        status: status as string
      });
      res.json(paymentHistory);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
