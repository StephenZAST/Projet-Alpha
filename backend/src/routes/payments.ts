import { Router } from 'express';
import { isAuthenticated } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { paymentValidation } from '../validations/paymentValidation';
import { PaymentService } from '../services/payment'; // Import PaymentService

const router = Router();
const paymentService = new PaymentService(); // Create instance

router.get(
  '/methods',
  isAuthenticated,
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
  validateRequest(paymentValidation.addPaymentMethod),
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
  validateRequest(paymentValidation.removePaymentMethod),
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
  validateRequest(paymentValidation.setDefaultPaymentMethod),
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
  validateRequest(paymentValidation.processPayment),
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
  validateRequest(paymentValidation.processRefund),
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
  validateRequest(paymentValidation.getPaymentHistory),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
      const { page, limit, status } = req.query; // Extract properties from req.query
      const paymentHistory = await paymentService.getPaymentHistory(userId, {
        page: Number(page),
        limit: Number(limit),
        status: status as string
      }); // Pass an object with the correct type
      res.json(paymentHistory);
    } catch (error) {
      next(error);
    }
  }
);

export { router as paymentRoutes };
