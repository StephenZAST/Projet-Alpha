import supabase from '../config/database';
import { SubscriptionPlan, UserSubscription } from '../models/types';
import { NotificationService } from './notification.service';

export class SubscriptionService {
  static async createPlan(planData: Partial<SubscriptionPlan>): Promise<SubscriptionPlan> {
    try {
      const { data, error } = await supabase
        .from('subscription_plans')
        .insert([{
          ...planData,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('[SubscriptionService] Error creating plan:', error);
      throw error;
    }
  }

  static async subscribeToPlan(
    userId: string, 
    planId: string
  ): Promise<UserSubscription> {
    try {
      // 1. Vérifier s'il existe déjà un abonnement actif
      const existingSubscription = await this.getUserActiveSubscription(userId);
      if (existingSubscription) {
        throw new Error('User already has an active subscription');
      }

      // 2. Récupérer les détails du plan
      const { data: plan, error: planError } = await supabase
        .from('subscription_plans')
        .select('*')
        .eq('id', planId)
        .single();

      if (planError || !plan) throw new Error('Plan not found');

      // 3. Créer l'abonnement
      const startDate = new Date();
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + plan.duration_days);

      const subscription = {
        user_id: userId,
        plan_id: planId,
        start_date: startDate,
        end_date: endDate,
        status: 'ACTIVE',
        auto_renew: true,
        remaining_weight_kg: plan.max_weight_kg,
        remaining_orders: plan.max_orders
      };

      const { data, error } = await supabase
        .from('user_subscriptions')
        .insert([subscription])
        .select(`
          *,
          plan:subscription_plans(*)
        `)
        .single();

      if (error) throw error;

      // 4. Notifier l'utilisateur
      await NotificationService.sendNotification(
        userId,
        'SUBSCRIPTION_CREATED',
        {
          title: 'Nouvel abonnement',
          message: `Votre abonnement ${plan.name} est maintenant actif`
        }
      );

      return data;
    } catch (error) {
      console.error('[SubscriptionService] Error subscribing to plan:', error);
      throw error;
    }
  }

  static async getUserActiveSubscription(userId: string): Promise<UserSubscription | null> {
    const { data, error } = await supabase
      .from('user_subscriptions')
      .select(`
        *,
        plan:subscription_plans(*)
      `)
      .eq('user_id', userId)
      .eq('status', 'ACTIVE')
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  static async cancelSubscription(
    userId: string, 
    subscriptionId: string
  ): Promise<void> {
    try {
      const { error } = await supabase
        .from('user_subscriptions')
        .update({
          status: 'CANCELLED',
          auto_renew: false,
          updated_at: new Date()
        })
        .eq('id', subscriptionId)
        .eq('user_id', userId);

      if (error) throw error;

      await NotificationService.sendNotification(
        userId,
        'SUBSCRIPTION_CANCELLED',
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

  static async checkSubscriptionUsage(
    subscriptionId: string,
    weightKg?: number
  ): Promise<boolean> {
    try {
      const { data: subscription, error } = await supabase
        .from('user_subscriptions')
        .select('*')
        .eq('id', subscriptionId)
        .single();

      if (error) throw error;
      if (!subscription) throw new Error('Subscription not found');

      // Vérifier le poids si spécifié
      if (weightKg && subscription.remaining_weight_kg != null) {
        if (subscription.remaining_weight_kg < weightKg) {
          return false;
        }
      }

      // Vérifier le nombre de commandes
      if (subscription.remaining_orders != null && subscription.remaining_orders <= 0) {
        return false;
      }

      return true;
    } catch (error) {
      console.error('[SubscriptionService] Error checking subscription usage:', error);
      throw error;
    }
  }
}
