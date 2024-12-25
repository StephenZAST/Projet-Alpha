import supabase from '../config/database';
import { NotificationService } from './notification.service';
import { PaginationParams } from '../utils/pagination';
import { AffiliateProfile, CommissionTransaction } from '../models/types';

export class AffiliateService {
  static getProfile(userId: string) {
    throw new Error('Method not implemented.');
  }
  static updateProfile(userId: string, arg1: { phone: any; notificationPreferences: any; }) {
    throw new Error('Method not implemented.');
  }
  static getReferrals(userId: string) {
    throw new Error('Method not implemented.');
  }
  static getLevels() {
    throw new Error('Method not implemented.');
  }
  static getCurrentLevel(userId: string) {
    throw new Error('Method not implemented.');
  }
  static async getDashboard(affiliateId: string) {
    const { data, error } = await supabase
      .from('affiliate_profiles')
      .select(`*,
        commission_transactions(*),
        referred_users:users(count),
        referred_affiliates:affiliate_profiles(count)
      `)
      .eq('id', affiliateId)
      .single();

    if (error) throw error;
    return data;
  }

  static async getCommissions(
    affiliateId: string, 
    { page = 1, limit = 10 }: PaginationParams
  ) {
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data, error, count } = await supabase
      .from('commission_transactions')
      .select('*', { count: 'exact' })
      .eq('affiliate_id', affiliateId)
      .order('created_at', { ascending: false })
      .range(from, to);

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

  static async requestWithdrawal(affiliateId: string, amount: number) {
    // Récupérer le profil affilié avec toutes les informations nécessaires
    const { data: affiliateProfile, error: profileError } = await supabase
      .from('affiliate_profiles')
      .select('*')
      .eq('id', affiliateId)
      .single();

    if (profileError || !affiliateProfile) {
      throw new Error('Affiliate not found');
    }

    // Vérifier le statut et le solde
    if (!affiliateProfile.is_active || affiliateProfile.status !== 'ACTIVE') {
      throw new Error('Affiliate account is not active');
    }

    if (affiliateProfile.commission_balance < amount) {
      throw new Error('Insufficient balance');
    }

    // Créer la transaction de retrait
    const { data: transaction, error: transactionError } = await supabase
      .from('commission_transactions')
      .insert([{
        affiliate_id: affiliateId,
        amount: -amount,
        type: 'WITHDRAWAL',
        status: 'PENDING'
      }])
      .select()
      .single();

    if (transactionError) throw transactionError;

    // Mettre à jour le solde de l'affilié
    const { error: updateError } = await supabase
      .from('affiliate_profiles')
      .update({
        commission_balance: affiliateProfile.commission_balance - amount
      })
      .eq('id', affiliateId);

    if (updateError) throw updateError;

    // Notifier l'admin
    await NotificationService.create(
      affiliateProfile.user_id,
      'PROMOTIONS',
      "Demande de retrait",
      `L'affilié ${affiliateId} a demandé un retrait de ${amount} €.`,
      { amount, transactionId: transaction.id }
    );

    return transaction;
  }

  static async generateAffiliateCode(affiliateId: string) {
    const { data: affiliate } = await supabase
      .from('affiliate_profiles')
      .select('id, affiliateCode')
      .eq('id', affiliateId)
      .single();

    if (!affiliate) {
      throw new Error('Affiliate not found');
    }

    if (affiliate.affiliateCode) {
      throw new Error('Affiliate already has a code');
    }

    const newCode = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

    const { data, error } = await supabase
      .from('affiliate_profiles')
      .update({ affiliateCode: newCode })
      .eq('id', affiliateId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async createAffiliate(userId: string, parentAffiliateCode?: string) {
    const { data: parentAffiliate } = await supabase
      .from('affiliate_profiles')
      .select('id')
      .eq('affiliateCode', parentAffiliateCode)
      .single();

    if (parentAffiliateCode && !parentAffiliate) {
      throw new Error('Parent affiliate code not found');
    }

    const newAffiliate: AffiliateProfile = {
      id: userId,
      userId,
      affiliateCode: Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15),
      parentAffiliateId: parentAffiliate?.id,
      commissionBalance: 0,
      totalEarned: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
      commissionRate: 0,
      status: 'ACTIVE',
      isActive: false,
      totalReferrals: 0,
      monthlyEarnings: 0
    };

    const { data, error } = await supabase
      .from('affiliate_profiles')
      .insert([newAffiliate])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async createCustomerWithAffiliateCode(email: string, password: string, firstName: string, lastName: string, affiliateCode: string, phone?: string) {
    const { data: affiliate } = await supabase
      .from('affiliate_profiles')
      .select('id')
      .eq('affiliateCode', affiliateCode)
      .single();

    if (!affiliate) {
      throw new Error('Affiliate code not found');
    }

    const { data: user, error: userError } = await supabase
      .from('users')
      .insert([{
        email,
        password,
        firstName,
        lastName,
        phone,
        role: 'CLIENT',
        referralCode: affiliateCode
      }])
      .select()
      .single();

    if (userError) throw userError;

    return user;
  }

  static async getAffiliateDashboard(userId: string) {
    const { data: profile, error } = await supabase
      .from('affiliate_profiles')
      .select(`
        *,
        level:affiliate_levels(*),
        referrals:affiliate_profiles(count)
      `)
      .eq('user_id', userId)
      .single();

    if (error) throw error;

    // Calculer les statistiques mensuelles
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);

    const { data: monthlyStats } = await supabase
      .from('commission_transactions')
      .select('amount')
      .eq('affiliate_id', profile.id)
      .gte('created_at', startOfMonth.toISOString());

    const monthlyEarnings = monthlyStats?.reduce((sum, tx) => sum + tx.amount, 0) || 0;

    // Mettre à jour le profil avec les nouvelles statistiques
    await supabase
      .from('affiliate_profiles')
      .update({
        monthly_earnings: monthlyEarnings,
        total_referrals: profile.referrals?.count || 0
      })
      .eq('id', profile.id);

    return {
      ...profile,
      monthlyEarnings,
      nextLevel: await this.getNextLevel(profile.total_earned)
    };
  }

  static async getNextLevel(currentEarnings: number) {
    const { data: nextLevel } = await supabase
      .from('affiliate_levels')
      .select('*')
      .gt('min_earnings', currentEarnings)
      .order('min_earnings', { ascending: true })
      .limit(1)
      .single();

    return nextLevel;
  }

  static async updateAffiliateLevel(affiliateId: string) {
    const { data: affiliate, error: affiliateError } = await supabase
      .from('affiliate_profiles')
      .select('total_earned')
      .eq('id', affiliateId)
      .single();

    if (affiliateError || !affiliate) {
      throw new Error('Affiliate not found');
    }

    const { data: newLevel } = await supabase
      .from('affiliate_levels')
      .select('*')
      .lte('min_earnings', affiliate.total_earned)
      .order('min_earnings', { ascending: false })
      .limit(1)
      .single();

    if (newLevel) {
      const { error: updateError } = await supabase
        .from('affiliate_profiles')
        .update({
          level_id: newLevel.id,
          commission_rate: newLevel.commission_rate
        })
        .eq('id', affiliateId);

      if (updateError) {
        throw new Error('Failed to update affiliate level');
      }
    }

    return { affiliate, newLevel };
  }
}
