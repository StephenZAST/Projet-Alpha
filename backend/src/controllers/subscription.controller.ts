import { Request, Response } from 'express';
import { SubscriptionService } from '../services/subscription.service';
import { asyncHandler } from '../utils/asyncHandler';

export class SubscriptionController {
  static async createPlan(req: Request, res: Response) {
    try {
      const plan = await SubscriptionService.createPlan(req.body);
      res.status(201).json({
        success: true,
        data: plan
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  static async subscribeToPlan(req: Request, res: Response) {
    try {
      const { planId } = req.body;
      const userId = req.user?.id;
      if (!userId) throw new Error('User not authenticated');

      const subscription = await SubscriptionService.subscribeToPlan(userId, planId);
      res.json({
        success: true,
        data: subscription
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  static async getActiveSubscription(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) throw new Error('User not authenticated');

      const subscription = await SubscriptionService.getUserActiveSubscription(userId);
      res.json({
        success: true,
        data: subscription
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  static async cancelSubscription(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const { subscriptionId } = req.params;
      if (!userId) throw new Error('User not authenticated');

      await SubscriptionService.cancelSubscription(userId, subscriptionId);
      res.json({
        success: true,
        message: 'Subscription cancelled successfully'
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }
}
