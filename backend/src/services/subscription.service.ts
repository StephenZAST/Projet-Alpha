import { PrismaClient } from '@prisma/client';
import { SubscriptionPlan, UserSubscription, NotificationType } from '../models/types';
import { NotificationService } from './notification.service';

const prisma = new PrismaClient();

export class SubscriptionService {
  static async getAllPlans() {
    // Récupère tous les plans d'abonnement
    const plans = await prisma.subscription_plans.findMany();
    return plans.map(plan => ({
      id: plan.id,
      name: plan.name,
      description: plan.description ?? undefined,
      price: Number(plan.price),
      duration_days: plan.duration_days,
      max_orders_per_month: plan.max_orders_per_month,
      max_weight_per_order: plan.max_weight_per_order ? Number(plan.max_weight_per_order) : undefined,
      is_premium: plan.is_premium,
      created_at: plan.created_at,
      updated_at: plan.updated_at
    }));
  }
  // Vérifie et met à jour l’expiration des abonnements (à appeler périodiquement ou lors de chaque accès)
  static async expireSubscriptions(): Promise<void> {
    const now = new Date();
  // Table user_subscriptions n'existe pas, on retire cette logique ou l'adapte si besoin
  // TODO: Adapter la logique d'expiration si une table d'abonnement utilisateur existe
  }
  // Helper pour récupérer le prix d’un article/service via la logique centralisée
  static async getCentralizedServicePrice(articleId: string, serviceTypeId: string, weight?: number): Promise<number | null> {
    try {
      // Appel direct à la fonction stockée pour obtenir le prix
      const result = await prisma.$queryRaw`SELECT public.calculate_service_price(${articleId}, ${serviceTypeId}, ${weight ?? null}) AS price`;
      if (Array.isArray(result) && result.length > 0 && result[0].price !== null) {
        return Number(result[0].price);
      }
      return null;
    } catch (error) {
      console.error('[SubscriptionService] Centralized price error:', error);
      throw error;
    }
  }
  static async createPlan(planData: Partial<SubscriptionPlan>): Promise<SubscriptionPlan> {
    try {
      const data = await prisma.subscription_plans.create({
        data: {
          id: planData.id,
          name: planData.name!,
        description: planData.description ?? undefined,
          price: planData.price!,
          duration_days: planData.duration_days ?? 30,
          max_orders_per_month: planData.max_orders_per_month ?? 10,
          max_weight_per_order: planData.max_weight_per_order,
          is_premium: planData.is_premium ?? false,
        }
      });
      return {
        id: data.id,
        name: data.name,
        description: data.description ?? undefined,
        price: Number(data.price),
        duration_days: data.duration_days,
        max_orders_per_month: data.max_orders_per_month,
        max_weight_per_order: data.max_weight_per_order ? Number(data.max_weight_per_order) : undefined,
        is_premium: data.is_premium,
        created_at: data.created_at,
        updated_at: data.updated_at
      };
    } catch (error) {
      console.error('[SubscriptionService] Error creating plan:', error);
      throw error;
    }
  }

  static async subscribeToPlan(userId: string, planId: string): Promise<UserSubscription> {
    try {
      const now = new Date();
      const plan = await prisma.subscription_plans.findUnique({ where: { id: planId } });
      if (!plan) throw new Error('Plan not found');
      const endDate = new Date(now.getTime() + plan.duration_days * 24 * 60 * 60 * 1000);
      const userSub = await prisma.user_subscriptions.create({
        data: {
          userId: userId,
          plan_id: planId,
          start_date: now,
          end_date: endDate,
          status: 'ACTIVE',
          remaining_orders: plan.max_orders_per_month,
          expired: false,
        }
      });
      return {
        id: userSub.id,
        userId: userSub.userId,
        planId: userSub.plan_id,
        startDate: userSub.start_date,
        endDate: userSub.end_date,
        status: userSub.status as 'ACTIVE' | 'CANCELLED' | 'EXPIRED',
        remainingWeight: plan.max_weight_per_order ? Number(plan.max_weight_per_order) : 0,
        remainingOrders: userSub.remaining_orders ?? 0,
        expired: userSub.expired,
        createdAt: userSub.created_at,
        updatedAt: userSub.updated_at
      };
    } catch (error) {
      console.error('[SubscriptionService] Error subscribing to plan:', error);
      throw error;
    }
  }

  static async getUserActiveSubscription(userId: string): Promise<UserSubscription | null> {
      // Met à jour l’expiration avant de chercher l’abonnement actif
      await SubscriptionService.expireSubscriptions();
    try {
      const subscription = await prisma.user_subscriptions.findFirst({
        where: {
          userId: userId,
          status: 'ACTIVE',
          end_date: { gte: new Date() },
          expired: false,
        },
        orderBy: { start_date: 'desc' }
      });
      if (!subscription) return null;
      const plan = await prisma.subscription_plans.findUnique({ where: { id: subscription.plan_id } });
      return {
        id: subscription.id,
        userId: subscription.userId,
        planId: subscription.plan_id,
        startDate: subscription.start_date,
        endDate: subscription.end_date,
        status: subscription.status as 'ACTIVE' | 'CANCELLED' | 'EXPIRED',
        remainingWeight: plan?.max_weight_per_order ? Number(plan.max_weight_per_order) : 0,
        remainingOrders: subscription.remaining_orders ?? 0,
        expired: subscription.expired,
        createdAt: subscription.created_at,
        updatedAt: subscription.updated_at
      };
    } catch (error) {
      console.error('[SubscriptionService] Error getting active subscription:', error);
      throw error;
    }
  }

  static async cancelSubscription(userId: string, subscriptionId: string): Promise<void> {
    try {
      await prisma.user_subscriptions.update({
        where: { id: subscriptionId },
        data: { status: 'CANCELLED', expired: true, updated_at: new Date() }
      });
      await NotificationService.sendNotification(
        userId,
        NotificationType.SUBSCRIPTION_CANCELLED,
        {
          title: 'Abonnement annulé',
          message: 'Votre abonnement a été annulé avec succès'
        }
      );
    } catch (error) {
      console.error('[SubscriptionService] Error cancelling subscription:', error);
      throw error;
    }
  }

  static async checkSubscriptionUsage(subscriptionId: string, weightKg?: number): Promise<boolean> {
    try {
      const subscription = await prisma.user_subscriptions.findUnique({ where: { id: subscriptionId } });
      if (!subscription) throw new Error('Subscription not found');
      if (subscription.expired || subscription.status !== 'ACTIVE') return false;
      if (typeof subscription.remaining_orders === 'number' && subscription.remaining_orders <= 0) return false;
      if (subscription.end_date < new Date()) return false;
      if (weightKg !== undefined) {
        const plan = await prisma.subscription_plans.findUnique({ where: { id: subscription.plan_id } });
        if (plan?.max_weight_per_order !== undefined && weightKg > Number(plan.max_weight_per_order)) return false;
      }
      return true;
    } catch (error) {
      console.error('[SubscriptionService] Error checking subscription usage:', error);
      throw error;
    }
  }

  static async getPlanSubscribersWithNames(planId: string) {
    // Récupère tous les abonnements pour un plan donné, avec le nom de l'utilisateur
    const subs = await prisma.user_subscriptions.findMany({
      where: { plan_id: planId },
      include: { users: true }, // Correction : la relation s'appelle 'users' dans Prisma
    });
    return subs.map(sub => ({
      id: sub.id,
      userId: sub.userId,
      userName: sub.users?.first_name ? `${sub.users.first_name} ${sub.users.last_name ?? ''}`.trim() : sub.users?.email ?? '',
      planId: sub.plan_id,
      startDate: sub.start_date,
      endDate: sub.end_date,
      status: sub.status,
      remainingOrders: sub.remaining_orders,
      expired: sub.expired,
      createdAt: sub.created_at,
      updatedAt: sub.updated_at
    }));
  }
}
