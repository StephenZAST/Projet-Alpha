import supabase from '../../config/database';
import { NotificationService } from '../notification.service';
import { COMMISSION_LEVELS, INDIRECT_COMMISSION_RATE, PROFIT_MARGIN_RATE, MIN_WITHDRAWAL_AMOUNT } from './constants';
import { PaginationParams } from '../../utils/pagination';
import { AffiliateLevel, NotificationType } from '../../models/types';

export class AffiliateCommissionService {

  static async getCommissions(affiliateId: string, pagination: PaginationParams) {
    const { page = 1, limit = 10 } = pagination;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let query = supabase
      .from('commissionTransactions')
      .select(`
        *,
        order:orders(
          id,
          totalAmount,
          createdAt
        )
      `, { count: 'exact' })
      .eq('affiliate_id', affiliateId)
      .order('created_at', { ascending: false })
      .range(from, to);

    const { data, error, count } = await query;

    if (error) throw error;

    return {
      data,
      pagination: {
        total: count || 0,
        currentPage: page,
        limit,
        totalPages: Math.ceil((count || 0) / limit)
      }
    };
  }

  static async calculateCommissionRate(totalReferrals: number): Promise<number> {
    if (totalReferrals >= 20) {
      return COMMISSION_LEVELS.LEVEL3.rate;
    } else if (totalReferrals >= 10) {
      return COMMISSION_LEVELS.LEVEL2.rate;
    }
    return COMMISSION_LEVELS.LEVEL1.rate;
  }

  static async calculateCommission(orderTotal: number, affiliateId: string): Promise<number> {
    const benefitNet = orderTotal * PROFIT_MARGIN_RATE;
    
    const { data: profile, error } = await supabase
      .from('affiliate_profiles')
      .select('total_referrals')
      .eq('id', affiliateId)
      .single();

    if (error) throw error;

    const commissionRate = await this.calculateCommissionRate(profile.total_referrals);
    return benefitNet * commissionRate;
  }

  static async calculateIndirectCommission(directCommission: number): Promise<number> {
    return directCommission * INDIRECT_COMMISSION_RATE;
  }

  static async requestWithdrawal(affiliateId: string, amount: number) {
    // Vérifier que le montant est supérieur au minimum en FCFA
    if (amount < MIN_WITHDRAWAL_AMOUNT) {
      throw new Error(`Le montant minimum de retrait est de ${MIN_WITHDRAWAL_AMOUNT} FCFA`);
    }

    const { data: affiliateProfile, error: profileError } = await supabase
      .from('affiliate_profiles')
      .select('*, user:users(email, firstName, lastName)')
      .eq('id', affiliateId)
      .single();

    if (profileError || !affiliateProfile) {
      throw new Error('Profil affilié non trouvé');
    }

    if (!affiliateProfile.is_active || affiliateProfile.status !== 'ACTIVE') {
      throw new Error('Le compte affilié n\'est pas actif');
    }

    if (affiliateProfile.commission_balance < amount) {
      throw new Error('Solde insuffisant');
    }

    const { data: transaction, error: transactionError } = await supabase
      .from('commissionTransactions')
      .insert([{
        affiliate_id: affiliateId,
        amount: -amount,
        type: 'WITHDRAWAL',
        status: 'PENDING'
      }])
      .select()
      .single();

    if (transactionError) throw transactionError;

    const { error: updateError } = await supabase
      .from('affiliate_profiles')
      .update({
        commission_balance: affiliateProfile.commission_balance - amount
      })
      .eq('id', affiliateId);

    if (updateError) throw updateError;

    await NotificationService.sendNotification(
      affiliateProfile.user_id,
      'WITHDRAWAL_REQUESTED' as NotificationType,
      {
        amount: amount,
        transactionId: transaction.id,
        status: 'PENDING',
        message: `Votre demande de retrait de ${amount} FCFA a été enregistrée et est en attente de validation.`
      }
    );

    return transaction;
  }

  static async processNewCommission(orderId: string, orderAmount: number, affiliateCode: string) {
    try {
      const { error } = await supabase.rpc('process_affiliate_commission', {
        p_order_id: orderId,
        p_order_amount: orderAmount,
        p_affiliate_code: affiliateCode
      });

      if (error) {
        console.error('[AffiliateCommissionService] Process commission error:', error);
        throw error;
      }

      return true;
    } catch (error) {
      console.error('[AffiliateCommissionService] Process commission error:', error);
      throw error;
    }
  }

  static async getDistinctionLevel(totalEarnings: number): Promise<Omit<AffiliateLevel, 'createdAt' | 'updatedAt'>> {
    const { data: levels, error } = await supabase
      .from('affiliate_levels')
      .select('id, name, min_earnings, commission_rate')
      .lte('min_earnings', totalEarnings)
      .order('min_earnings', { ascending: false })
      .limit(1);

    if (error) throw error;

    // Transformer les propriétés snake_case en camelCase
    const defaultLevel = {
      id: 'bronze',
      name: 'Bronze',
      minEarnings: 0,
      commissionRate: 0
    };

    if (!levels?.[0]) return defaultLevel;

    return {
      id: levels[0].id,
      name: levels[0].name,
      minEarnings: levels[0].min_earnings,
      commissionRate: levels[0].commission_rate
    };
  }

  static async updateAffiliateLevels() {
    try {
      const { data: affiliates, error } = await supabase
        .from('affiliate_profiles')
        .select('id, total_earned')
        .eq('is_active', true);

      if (error) throw error;

      for (const affiliate of affiliates) {
        const level = await this.getDistinctionLevel(affiliate.total_earned);
        await supabase
          .from('affiliate_profiles')
          .update({
            level_id: level.id,
            updated_at: new Date().toISOString()
          })
          .eq('id', affiliate.id);
      }

      return true;
    } catch (error) {
      console.error('[AffiliateCommissionService] Update levels error:', error);
      throw error;
    }
  }

  static async resetMonthlyEarnings() {
    try {
      // Call the reset_monthly_earnings function and get the number of updated affiliates
      const { data, error } = await supabase.rpc('reset_monthly_earnings', {});

      if (error) {
        console.error('[AffiliateCommissionService] Reset monthly earnings DB error:', error);
        throw new Error('Failed to reset monthly earnings: ' + error.message);
      }

      const updatedCount = data as number;
      console.log(`[AffiliateCommissionService] Reset monthly earnings for ${updatedCount} affiliates`);

      // Get all active affiliates for notifications
      const { data: activeAffiliates, error: queryError } = await supabase
        .from('affiliate_profiles')
        .select('user_id')
        .eq('is_active', true);

      if (queryError) {
        console.error('[AffiliateCommissionService] Error fetching active affiliates:', queryError);
        throw new Error('Failed to fetch active affiliates: ' + queryError.message);
      }

      // Send notifications to all active affiliates
      if (activeAffiliates && activeAffiliates.length > 0) {
        await Promise.all(activeAffiliates.map(affiliate =>
          NotificationService.sendNotification(
            affiliate.user_id,
            'COMMISSION_EARNED' as NotificationType,
            {
              title: 'Réinitialisation des gains mensuels',
              message: 'Vos gains mensuels ont été réinitialisés pour le nouveau mois',
              data: {
                action: 'RESET_MONTHLY_EARNINGS',
                timestamp: new Date().toISOString()
              }
            }
          ).catch(err => {
            console.error(`Failed to send notification to affiliate ${affiliate.user_id}:`, err);
            // Don't throw, continue with other notifications
          })
        ));
      }

      return {
        success: true,
        updatedCount,
        notificationsSent: activeAffiliates?.length || 0
      };
    } catch (error) {
      console.error('[AffiliateCommissionService] Reset monthly earnings error:', error);
      throw error;
    }
  }
}