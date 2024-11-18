import { Request, Response } from 'express';
import { PaymentService } from '../services/payment';

class PaymentController {
  private paymentService: PaymentService;

  constructor() {
    this.paymentService = new PaymentService();
  }

  getPaymentMethods = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const paymentMethods = await this.paymentService.getPaymentMethods(userId);
      res.json(paymentMethods);
    } catch (error) {
      console.error('Error fetching payment methods:', error);
      res.status(500).json({ error: 'Failed to fetch payment methods' });
    }
  };

  addPaymentMethod = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const { type, token, isDefault } = req.body;
      
      const paymentMethod = await this.paymentService.addPaymentMethod(userId, {
        type,
        token,
        isDefault,
      });

      res.status(201).json({
        id: paymentMethod.id,
        message: 'Payment method added successfully',
      });
    } catch (error) {
      console.error('Error adding payment method:', error);
      res.status(500).json({ error: 'Failed to add payment method' });
    }
  };

  removePaymentMethod = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;

      await this.paymentService.removePaymentMethod(userId, id);
      res.json({ message: 'Payment method removed successfully' });
    } catch (error) {
      console.error('Error removing payment method:', error);
      res.status(500).json({ error: 'Failed to remove payment method' });
    }
  };

  setDefaultPaymentMethod = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;

      await this.paymentService.setDefaultPaymentMethod(userId, id);
      res.json({ message: 'Default payment method updated successfully' });
    } catch (error) {
      console.error('Error setting default payment method:', error);
      res.status(500).json({ error: 'Failed to set default payment method' });
    }
  };

  processPayment = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const { orderId, amount, currency, paymentMethodId, description } = req.body;

      const payment = await this.paymentService.processPayment({
        userId,
        orderId,
        amount,
        currency,
        paymentMethodId,
        description,
      });

      res.json({
        id: payment.id,
        status: payment.status,
        message: 'Payment processed successfully',
      });
    } catch (error) {
      console.error('Error processing payment:', error);
      res.status(500).json({ error: 'Failed to process payment' });
    }
  };

  getPaymentHistory = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const { page, limit, status } = req.query;

      const history = await this.paymentService.getPaymentHistory(userId, {
        page: Number(page) || 1,
        limit: Number(limit) || 10,
        status: status as string,
      });

      res.json(history);
    } catch (error) {
      console.error('Error fetching payment history:', error);
      res.status(500).json({ error: 'Failed to fetch payment history' });
    }
  };

  processRefund = async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      const { paymentId, amount, reason } = req.body;

      const refund = await this.paymentService.processRefund({
        userId,
        paymentId,
        amount,
        reason,
      });

      res.json({
        id: refund.id,
        status: refund.status,
        amount: refund.amount,
        message: 'Refund processed successfully',
      });
    } catch (error) {
      console.error('Error processing refund:', error);
      res.status(500).json({ error: 'Failed to process refund' });
    }
  };
}

export const paymentController = new PaymentController();
