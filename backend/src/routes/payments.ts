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

const router = Router();
const paymentService = new PaymentService(); 

router.get(
  '/methods',
  isAuthenticated,
  validateGetPaymentMethods, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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
  validateAddPaymentMethod, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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
  validateRemovePaymentMethod, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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
  validateSetDefaultPaymentMethod, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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
  validateProcessPayment, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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
  validateProcessRefund, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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
  validateGetPaymentHistory, // Apply validation directly
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
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

export { router as paymentRoutes };
