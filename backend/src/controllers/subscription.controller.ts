import { Request, Response } from 'express';
import { SubscriptionService } from '../services/subscription.service';
import { asyncHandler } from '../utils/asyncHandler';
import { NotificationService } from '../services';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient(); 

export class SubscriptionController {
  static async getAllPlans(req: Request, res: Response) {
    try {
      const plans = await SubscriptionService.getAllPlans();
      res.json({ success: true, data: plans });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message ?? 'Erreur lors de la récupération des plans.' });
    }
  }
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
        error: error.message ?? 'Erreur lors de la création du plan.'
      });
    }
  }

  static async subscribeToPlan(req: Request, res: Response) {
    try {
      const { planId } = req.body;
      const userId = req.user?.id;
      if (!userId) throw new Error('User not authenticated');
      
      // Récupérer le plan pour les détails
      const plan = await prisma.subscription_plans.findUnique({
        where: { id: planId }
      });

      const subscription = await SubscriptionService.subscribeToPlan(userId, planId);

      // 🔔 Notifier l'utilisateur que son abonnement a été activé
      if (plan) {
        try {
          const startDate = new Date().toISOString();
          const endDate = new Date(Date.now() + plan.duration_days * 24 * 60 * 60 * 1000).toISOString();
          
          await NotificationService.notifySubscriptionActivated(
            userId,
            plan.name,
            plan.id,
            startDate,
            endDate,
            Number(plan.price)
          );
        } catch (notificationError: any) {
          console.error('[SubscriptionController] Error sending subscription activated notification:', notificationError);
        }
      }

      res.json({
        success: true,
        data: subscription
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message ?? 'Erreur lors de la souscription au plan.'
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
        error: error.message ?? 'Erreur lors de la recuperation de l\'abonnement.'
      });
    }
  }

  static async cancelSubscription(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const { subscriptionId } = req.params;
      if (!userId) throw new Error('User not authenticated');

      // Récupérer l'abonnement avant annulation
      const subscription = await prisma.user_subscriptions.findUnique({
        where: { id: subscriptionId },
        include: { subscription_plans: true }
      });

      await SubscriptionService.cancelSubscription(userId, subscriptionId);

      // 🔔 Notifier l'utilisateur que son abonnement a été annulé
      if (subscription && subscription.subscription_plans) {
        try {
          await NotificationService.notifySubscriptionCancelled(
            userId,
            subscription.subscription_plans.name,
            subscription.subscription_plans.id,
            new Date().toISOString(),
            undefined
          );
        } catch (notificationError: any) {
          console.error('[SubscriptionController] Error sending subscription cancelled notification:', notificationError);
        }
      }

      res.json({
        success: true,
        message: 'Subscription cancelled successfully'
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        error: error.message ?? 'Erreur lors de l\'annulation de l\'abonnement.'
      });
    }
  }

  static async getPlanSubscribersWithNames(req: Request, res: Response) {
    try {
      const { planId } = req.params;
      const subscribers = await SubscriptionService.getPlanSubscribersWithNames(planId);
      res.json({ success: true, data: subscribers });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message ?? 'Erreur lors de la récupération des abonnés.' });
    }
  }
}
