import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { paymentValidation } from '../validations/paymentValidation';
import { billingService } from '../services/billing'; // Correct import
import { billingStatsSchema } from '../validation/billing'; // Import billingStatsSchema

const router = express.Router();

router.get('/methods', isAuthenticated, async (req, res, next) => {
  try {
    const userId = req.user!.uid; // Extract userId from req.user
    const paymentMethods = await billingService.getPaymentMethods(userId);
    res.json(paymentMethods);
  } catch (error) {
    next(error);
  }
});

router.post('/methods', 
  isAuthenticated, 
  validateRequest(paymentValidation.addPaymentMethod),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid; // Extract userId from req.user
      const paymentMethod = await billingService.addPaymentMethod(userId, req.body);
      res.status(201).json(paymentMethod);
    } catch (error) {
      next(error);
    }
  }
);

router.delete('/methods/:id', 
  isAuthenticated, 
  validateRequest(paymentValidation.removePaymentMethod),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid; // Extract userId from req.user
      const paymentMethodId = req.params.id; // Extract paymentMethodId from req.params
      await billingService.removePaymentMethod(userId, paymentMethodId);
      res.json({ message: 'Payment method removed successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.put('/methods/:id/default', 
  isAuthenticated, 
  validateRequest(paymentValidation.setDefaultPaymentMethod),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid; // Extract userId from req.user
      const paymentMethodId = req.params.id; // Extract paymentMethodId from req.params
      await billingService.setDefaultPaymentMethod(userId, paymentMethodId);
      res.json({ message: 'Default payment method updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.post('/process', 
  isAuthenticated, 
  validateRequest(paymentValidation.processPayment),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid; // Extract userId from req.user
      const payment = await billingService.processPayment({ ...req.body, userId });
      res.json(payment);
    } catch (error) {
      next(error);
    }
  }
);

router.post('/refund', 
  isAuthenticated, 
  validateRequest(paymentValidation.processRefund),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid; // Extract userId from req.user
      const refund = await billingService.processRefund({ ...req.body, userId });
      res.json(refund);
    } catch (error) {
      next(error);
    }
  }
);

router.get('/history', 
  isAuthenticated, 
  validateRequest(paymentValidation.getPaymentHistory),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid; // Extract userId from req.user
      const paymentHistory = await billingService.getPaymentHistory(userId, req.query);
      res.json(paymentHistory);
    } catch (error) {
      next(error);
    }
  }
);

router.get('/stats', 
  isAuthenticated, 
  requireAdminRole, 
  validateRequest(billingStatsSchema), // Use imported billingStatsSchema
  async (req, res, next) => {
    try {
      const { startDate, endDate } = req.query;
      const billingStats = await billingService.getBillingStats(
        startDate ? new Date(startDate as string) : undefined, 
        endDate ? new Date(endDate as string) : undefined
      );
      res.json(billingStats);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
