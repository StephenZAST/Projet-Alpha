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
    // Notifier les admins de la demande de retrait
    // Notifier les admins de la demande de retrait
    const { data: admins } = await supabase
      .from('users')
      .select('id')
      .in('role', ['ADMIN', 'SUPER_ADMIN']);

    if (admins) {
      for (const admin of admins) {
        await NotificationService.sendNotification(
          admin.id,
          'WITHDRAWAL_REQUESTED',
          {
            affiliateId: affiliateId,
            amount: amount,
            transactionId: transaction.id,
            userName: `${affiliateProfile.user_id}`,
            status: 'PENDING',
            message: `Nouvelle demande de retrait de ${amount}€`
          }
        );
      }
    }
    // Notifier l'affilié de sa demande
    await NotificationService.sendNotification(
      affiliateProfile.user_id,
      'WITHDRAWAL_REQUESTED',
      {
        amount: amount,
        transactionId: transaction.id,
        status: 'PENDING',
        message: `Votre demande de retrait de ${amount}€ a été enregistrée et est en attente de validation.`
      }
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

  static async getWithdrawals(
    pagination: PaginationParams,
    status?: string
  ) {
    const { page = 1, limit = 10 } = pagination;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let query = supabase
      .from('commission_transactions')
      .select(`
        *,
        affiliate:affiliate_profiles(
          id,
          user:users(
            id,
            email,
            firstName,
            lastName
          )
        )
      `, { count: 'exact' })
      .eq('type', 'WITHDRAWAL')
      .order('created_at', { ascending: false })
      .range(from, to);

    if (status) {
      query = query.eq('status', status);
    }

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

  static async rejectWithdrawal(withdrawalId: string, reason: string) {
    const { data: withdrawal, error: getError } = await supabase
      .from('commission_transactions')
      .select('*, affiliate:affiliate_profiles(user_id, commission_balance)')
      .eq('id', withdrawalId)
      .eq('type', 'WITHDRAWAL')
      .single();

    if (getError || !withdrawal) {
      throw new Error('Withdrawal not found');
    }

    if (withdrawal.status !== 'PENDING') {
      throw new Error('Withdrawal cannot be rejected - invalid status');
    }

    // Recréditer le montant sur le compte de l'affilié
    const { error: updateError } = await supabase
      .from('affiliate_profiles')
      .update({
        commission_balance: withdrawal.affiliate.commission_balance - withdrawal.amount // Le montant est négatif dans la transaction
      })
      .eq('id', withdrawal.affiliate_id);

    if (updateError) throw updateError;

    // Mettre à jour le statut de la transaction
    const { data: updatedWithdrawal, error: txError } = await supabase
      .from('commission_transactions')
      .update({
        status: 'REJECTED',
        notes: reason
      })
      .eq('id', withdrawalId)
      .select()
      .single();

    if (txError) throw txError;

    // Notifier l'affilié
    await NotificationService.sendNotification(
      withdrawal.affiliate.user_id,
      'WITHDRAWAL_REJECTED',
      {
        amount: withdrawal.amount,
        transactionId: withdrawalId,
        reason: reason,
        status: 'REJECTED'
      }
    );

    return {
      ...updatedWithdrawal,
      userId: withdrawal.affiliate.user_id
    };
  }

  static async getAllAffiliates(
    pagination: PaginationParams,
    filters: { status?: string; query?: string; }
  ) {
    const { page = 1, limit = 10 } = pagination;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let query = supabase
      .from('affiliate_profiles')
      .select(`
        *,
        user:users(
          id,
          email,
          firstName,
          lastName,
          phone
        )
      `, { count: 'exact' });

    if (filters.status) {
      query = query.eq('status', filters.status);
    }

    if (filters.query) {
      query = query.or(`
        user.email.ilike.%${filters.query}%,
        user.firstName.ilike.%${filters.query}%,
        user.lastName.ilike.%${filters.query}%,
        affiliateCode.ilike.%${filters.query}%
      `);
    }

    const { data, error, count } = await query
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

  static async updateAffiliateStatus(
    affiliateId: string,
    status: string,
    isActive: boolean
  ) {
    // Vérifier si l'affilié existe
    const { data: affiliate, error: checkError } = await supabase
      .from('affiliate_profiles')
      .select('id, status')
      .eq('id', affiliateId)
      .single();

    if (checkError || !affiliate) {
      throw new Error('Affiliate not found');
    }

    // Mettre à jour le statut
    const { data: updatedAffiliate, error } = await supabase
      .from('affiliate_profiles')
      .update({
        status,
        is_active: isActive,
        updated_at: new Date().toISOString()
      })
      .eq('id', affiliateId)
      .select(`
        *,
        user:users(id)
      `)
      .single();

    if (error) throw error;

    // Notifier l'affilié du changement de statut
    await NotificationService.sendNotification(
      updatedAffiliate.user.id,
      'AFFILIATE_STATUS_UPDATED',
      {
        status,
        isActive,
        previousStatus: affiliate.status,
        message: `Votre compte affilié est maintenant ${status.toLowerCase()}${isActive ? '' : ' et inactif'}`
      }
    );

    return updatedAffiliate;
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
