import supabase from '../config/database';
import { Order, PointSource, PointTransactionType } from '../models/types';

export class RewardsService {
  // Configuration par défaut
  private static readonly DEFAULT_POINTS_PER_AMOUNT = 1; // 1 point par unité monétaire
  private static readonly DEFAULT_COMMISSION_RATE = 0.1; // 10% de commission
  private static readonly PARENT_COMMISSION_RATE = 0.1; // 10% de la commission du filleul pour chaque niveau

  /**
   * Gère les points gagnés pour une commande
   */
  static async processOrderPoints(
    userId: string,
    order: Order,
    source: PointSource = 'ORDER'
  ): Promise<void> {
    try {
      // 1. Calculer les points à attribuer
      const pointsToAward = Math.floor(order.totalAmount * this.DEFAULT_POINTS_PER_AMOUNT);

      // 2. Mettre à jour le solde de points
      console.log('[RewardsService] Processing points for user:', userId, 'Amount:', pointsToAward);

      // 2.1 Vérifier si le profil existe
      const { data: loyalty, error: loyaltyError } = await supabase
        .from('loyalty_points')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle(); // Utiliser maybeSingle au lieu de single pour éviter l'erreur

      console.log('[RewardsService] Existing loyalty profile:', loyalty);

      if (loyaltyError) {
        console.error('[RewardsService] Error checking loyalty profile:', loyaltyError);
        throw loyaltyError;
      }

      let result;
      if (loyalty) {
        // 2.2 Mettre à jour le profil existant
        console.log('[RewardsService] Updating existing profile');
        const { data: updatedLoyalty, error: updateError } = await supabase
          .from('loyalty_points')
          .update({
            "pointsBalance": loyalty.pointsBalance + pointsToAward,
            "totalEarned": loyalty.totalEarned + pointsToAward
          })
          .eq('user_id', userId)
          .select()
          .single();

        if (updateError) {
          console.error('[RewardsService] Error updating loyalty points:', updateError);
          throw updateError;
        }
        result = updatedLoyalty;
      } else {
        // 2.3 Créer un nouveau profil
        console.log('[RewardsService] Creating new loyalty profile');
        const { data: newLoyalty, error: insertError } = await supabase
          .from('loyalty_points')
          .insert([{
            user_id: userId,
            "pointsBalance": pointsToAward,
            "totalEarned": pointsToAward
          }])
          .select()
          .single();

        if (insertError) {
          console.error('[RewardsService] Error creating loyalty profile:', insertError);
          throw insertError;
        }
        result = newLoyalty;
      }

      console.log('[RewardsService] Points processing successful:', result);

      // 3. Enregistrer la transaction
      await this.createPointTransaction(userId, pointsToAward, 'EARNED', source, order.id);

    } catch (error) {
      console.error('[RewardsService] Error processing order points:', error);
      throw new Error('Failed to process order points');
    }
  }

  /**
   * Gère les points gagnés par parrainage
   */
  static async processReferralPoints(
    referrerId: string,
    referredUserId: string,
    pointsAmount: number
  ): Promise<void> {
    try {
      // 1. Mettre à jour les points du parrain
      const { data: loyalty, error: loyaltyError } = await supabase
        .from('loyalty_points')
        .select('*')
        .eq('user_id', referrerId)
        .single();

      if (loyaltyError) throw loyaltyError;

      await supabase
        .from('loyalty_points')
        .update({
          pointsBalance: loyalty.pointsBalance + pointsAmount,
          totalEarned: loyalty.totalEarned + pointsAmount
        })
        .eq('user_id', referrerId);

      // 2. Enregistrer la transaction
      await this.createPointTransaction(
        referrerId,
        pointsAmount,
        'EARNED',
        'REFERRAL',
        referredUserId
      );

    } catch (error) {
      console.error('[RewardsService] Error processing referral points:', error);
      throw new Error('Failed to process referral points');
    }
  }

  /**
   * Traite les commissions d'affiliation
   */
  static async processAffiliateCommission(order: Order): Promise<void> {
    try {
      if (!order.affiliateCode) return;

      // 1. Trouver le profil d'affilié avec son niveau
      const { data: affiliate, error: affiliateError } = await supabase
        .from('affiliate_profiles')
        .select(`
          *,
          level:affiliate_levels(*)
        `)
        .eq('affiliateCode', order.affiliateCode)
        .eq('isActive', true)
        .single();

      if (affiliateError) throw affiliateError;

      // 2. Calculer la commission basée sur le niveau
      const commissionRate = affiliate.level?.commissionRate || this.DEFAULT_COMMISSION_RATE;
      const commissionAmount = order.totalAmount * commissionRate;

      // 3. Mettre à jour le solde de commission
      await supabase
        .from('affiliate_profiles')
        .update({
          commissionBalance: affiliate.commissionBalance + commissionAmount,
          totalEarned: affiliate.totalEarned + commissionAmount,
          monthlyEarnings: affiliate.monthlyEarnings + commissionAmount,
          totalReferrals: affiliate.totalReferrals + 1
        })
        .eq('id', affiliate.id);

      // 4. Créer une transaction de commission
      await supabase
        .from('commission_transactions')
        .insert([{
          affiliateId: affiliate.id,
          orderId: order.id,
          amount: commissionAmount,
          status: 'PENDING'
        }]);

      // 5. Processus récursif pour les commissions des parents
      await this.processParentCommissions(affiliate.parentAffiliateId, order.id, commissionAmount, 1);

    } catch (error) {
      console.error('[RewardsService] Error processing affiliate commission:', error);
      throw new Error('Failed to process affiliate commission');
    }
  }

  /**
   * Convertit des points en réduction
   */
  static async convertPointsToDiscount(
    userId: string,
    points: number,
    orderId: string
  ): Promise<number> {
    try {
      // 1. Vérifier le solde de points
      const { data: loyalty, error: loyaltyError } = await supabase
        .from('loyalty_points')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (loyaltyError) throw loyaltyError;
      if (loyalty.pointsBalance < points) {
        throw new Error('Insufficient points balance');
      }

      // 2. Calculer la valeur de la réduction (1 point = 1 unité monétaire)
      const discountAmount = points;

      // 3. Déduire les points
      await supabase
        .from('loyalty_points')
        .update({
          pointsBalance: loyalty.pointsBalance - points
        })
        .eq('user_id', userId);

      // 4. Enregistrer la transaction
      await this.createPointTransaction(
        userId,
        points,
        'SPENT',
        'ORDER',
        orderId
      );

      return discountAmount;
    } catch (error) {
      console.error('[RewardsService] Error converting points to discount:', error);
      throw new Error('Failed to convert points to discount');
    }
  }

  /**
   * Crée une transaction de points
   */
  private static async createPointTransaction(
    userId: string,
    points: number,
    type: PointTransactionType,
    source: PointSource,
    referenceId: string
  ): Promise<void> {
    try {
      const { error } = await supabase
        .from('point_transactions')
        .insert([{
          userId,
          points,
          type,
          source,
          referenceId
        }]);

      if (error) throw error;
    } catch (error) {
      console.error('[RewardsService] Error creating point transaction:', error);
      throw new Error('Failed to create point transaction');
    }
  }

  /**
   * Traite une commission secondaire (pour les affiliés parents)
   */
  private static async processSecondaryCommission(
    affiliateId: string,
    orderId: string,
    amount: number
  ): Promise<void> {
    try {
      const { data: affiliate } = await supabase
        .from('affiliate_profiles')
        .select('*')
        .eq('id', affiliateId)
        .single();

      if (!affiliate) return;

      // Mettre à jour le solde
      await supabase
        .from('affiliate_profiles')
        .update({
          commission_balance: affiliate.commission_balance + amount,
          total_earned: affiliate.total_earned + amount,
          monthly_earnings: affiliate.monthly_earnings + amount
        })
        .eq('id', affiliateId);

      // Créer la transaction
      await supabase
        .from('commission_transactions')
        .insert([{
          affiliate_id: affiliateId,
          order_id: orderId,
          amount: amount,
          status: 'PENDING'
        }]);

    } catch (error) {
      console.error('[RewardsService] Error processing secondary commission:', error);
      throw new Error('Failed to process secondary commission');
    }
  }
}