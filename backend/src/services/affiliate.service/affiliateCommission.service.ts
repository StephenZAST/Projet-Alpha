import supabase from '../../config/database';
import { NotificationService } from '../notification.service';
import { COMMISSION_LEVELS, INDIRECT_COMMISSION_RATE, PROFIT_MARGIN_RATE } from './constants';
import { PaginationParams } from '../../utils/pagination';

export class AffiliateCommissionService {

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

  static async requestWithdrawal(affiliateId: string, amount: number) {
    const { data: affiliateProfile, error: profileError } = await supabase
      .from('affiliate_profiles')
      .select('*')
      .eq('id', affiliateId)
      .single();

    if (profileError || !affiliateProfile) {
      throw new Error('Affiliate not found');
    }

    if (!affiliateProfile.is_active || affiliateProfile.status !== 'ACTIVE') {
      throw new Error('Affiliate account is not active');
    }

    if (affiliateProfile.commission_balance < amount) {
      throw new Error('Insufficient balance');
    }

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

    const { error: updateError } = await supabase
      .from('affiliate_profiles')
      .update({
        commission_balance: affiliateProfile.commission_balance - amount
      })
      .eq('id', affiliateId);

    if (updateError) throw updateError;

    await this.notifyWithdrawalRequest(affiliateProfile, transaction, amount);

    return transaction;
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

    const { error: updateError } = await supabase
      .from('affiliate_profiles')
      .update({
        commission_balance: withdrawal.affiliate.commission_balance - withdrawal.amount
      })
      .eq('id', withdrawal.affiliate_id);

    if (updateError) throw updateError;

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

  static async calculateCommission(orderTotal: number, affiliateId: string): Promise<number> {
    const benefitNet = orderTotal * PROFIT_MARGIN_RATE;
    
    const { data: profile, error } = await supabase
      .from('affiliate_profiles')
      .select('total_referrals')
      .eq('id', affiliateId)
      .single();

    if (error) throw error;

    const referralCount = profile.total_referrals;
    let commissionRate;

    if (referralCount < 10) {
      commissionRate = COMMISSION_LEVELS.LEVEL1.rate;
    } else if (referralCount < 20) {
      commissionRate = COMMISSION_LEVELS.LEVEL2.rate;
    } else {
      commissionRate = COMMISSION_LEVELS.LEVEL3.rate;
    }

    return benefitNet * commissionRate;
  }

  static async calculateIndirectCommission(directCommission: number): Promise<number> {
    return directCommission * INDIRECT_COMMISSION_RATE;
  }

  private static async notifyWithdrawalRequest(affiliate: any, transaction: any, amount: number) {
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
            affiliateId: affiliate.id,
            amount: amount,
            transactionId: transaction.id,
            userName: `${affiliate.user_id}`,
            status: 'PENDING',
            message: `Nouvelle demande de retrait de ${amount}€`
          }
        );
      }
    }

    await NotificationService.sendNotification(
      affiliate.user_id,
      'WITHDRAWAL_REQUESTED',
      {
        amount: amount,
        transactionId: transaction.id,
        status: 'PENDING',
        message: `Votre demande de retrait de ${amount}€ a été enregistrée et est en attente de validation.`
      }
    );
  }
}