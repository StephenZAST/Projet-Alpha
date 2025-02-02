import supabase from '../../config/database';
import { PaginationParams } from '../../utils/pagination';

export class AffiliateWithdrawalService {
  static async requestWithdrawal(affiliateId: string, amount: number) {
    try {
      // Vérifier le solde disponible
      const { data: profile, error: profileError } = await supabase
        .from('affiliate_profiles')
        .select('commission_balance')
        .eq('id', affiliateId)
        .single();

      if (profileError) throw profileError;
      if (!profile || profile.commission_balance < amount) {
        throw new Error('Insufficient balance');
      }

      // Create withdrawal transaction
      const { data: transaction, error: createError } = await supabase
        .from('commissionTransactions')
        .insert([{
          affiliate_id: affiliateId,
          amount: -amount, // Negative amount for withdrawals
          status: 'PENDING',
          created_at: new Date().toISOString()
        }])
        .select()
        .single();

      if (createError) throw createError;

      // Update affiliate balance
      const { error: updateError } = await supabase
        .from('affiliate_profiles')
        .update({
          commission_balance: profile.commission_balance - amount,
          updated_at: new Date().toISOString()
        })
        .eq('id', affiliateId);

      if (updateError) {
        // Rollback the transaction creation if balance update fails
        await supabase
          .from('commissionTransactions')
          .delete()
          .eq('id', transaction.id);
        throw updateError;
      }

      return transaction;
    } catch (error: any) {
      throw new Error(error.message);
    }
  }

  static async getWithdrawals(pagination: PaginationParams, status?: string) {
    const { page = 1, limit = 10 } = pagination;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data, error, count } = await supabase
        .from('commissionTransactions')
        .select(`
          *,
          affiliate:affiliate_profiles(
            id,
            user:users(
              id,
              email,
              first_name,
              last_name,
              phone
            )
          )
        `, { count: 'exact' })
        .is('order_id', null) // Les retraits n'ont pas d'order_id
        .eq('status', status || 'PENDING')
      .range(from, to);

    if (error) throw error;

    // Transform response to match API format
    const transformedData = data?.map(item => ({
      ...item,
      affiliate: item.affiliate ? {
        ...item.affiliate,
        user: item.affiliate.user ? {
          ...item.affiliate.user,
          firstName: item.affiliate.user.first_name,
          lastName: item.affiliate.user.last_name
        } : null
      } : null
    }));

    return {
      data: transformedData,
      pagination: {
        total: count || 0,
        currentPage: page,
        limit,
        totalPages: Math.ceil((count || 0) / limit)
      }
    };
  }

  static async rejectWithdrawal(withdrawalId: string, reason: string) {
    const { data: withdrawal, error: findError } = await supabase
      .from('commissionTransactions')
      .select('*, affiliate:affiliate_profiles(commission_balance)')
      .eq('id', withdrawalId)
      .is('order_id', null)
      .eq('status', 'PENDING')
      .single();

    if (findError) throw findError;
    if (!withdrawal) {
      throw new Error('Withdrawal not found or not in pending status');
    }

    const refundAmount = Math.abs(withdrawal.amount);
    const newBalance = Number(withdrawal.affiliate.commission_balance) + refundAmount;

    // Start transaction
    const { error: updateError } = await supabase
      .from('commissionTransactions')
      .update({
        status: 'REJECTED',
        updated_at: new Date().toISOString()
      })
      .eq('id', withdrawalId);

    if (updateError) throw updateError;

    // Refund the amount
    const { error: refundError } = await supabase
      .from('affiliate_profiles')
      .update({
        commission_balance: newBalance,
        updated_at: new Date().toISOString()
      })
      .eq('id', withdrawal.affiliate_id);

    if (refundError) throw refundError;

    return { message: 'Withdrawal rejected successfully' };
  }

  static async approveWithdrawal(withdrawalId: string) {
    const { data: withdrawal, error: findError } = await supabase
      .from('commissionTransactions')
      .select('*')
      .eq('id', withdrawalId)
      .is('order_id', null)
      .eq('status', 'PENDING')
      .single();

    if (findError || !withdrawal) {
      throw new Error('Withdrawal not found or not in pending status');
    }

    const { error: updateError } = await supabase
      .from('commissionTransactions')
      .update({
        status: 'APPROVED',
        updated_at: new Date().toISOString()
      })
      .eq('id', withdrawalId);

    if (updateError) throw updateError;

    return { message: 'Withdrawal approved successfully' };
  }

  static async getPendingWithdrawals(pagination: PaginationParams) {
    const { page = 1, limit = 10 } = pagination;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data, error, count } = await supabase
      .from('commissionTransactions')
      .select(`
        *,
        affiliate:affiliate_profiles(
          id,
          commission_balance,
          user:users(
            id,
            email,
            first_name,
            last_name,
            phone
          )
        )
      `, { count: 'exact' })
      .is('order_id', null)
      .eq('status', 'PENDING')
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) throw error;

    const transformedData = data?.map(item => ({
      id: item.id,
      amount: Math.abs(item.amount),
      status: item.status,
      createdAt: item.created_at,
      affiliate: item.affiliate ? {
        id: item.affiliate.id,
        currentBalance: item.affiliate.commission_balance,
        user: item.affiliate.user ? {
          id: item.affiliate.user.id,
          email: item.affiliate.user.email,
          firstName: item.affiliate.user.first_name,
          lastName: item.affiliate.user.last_name,
          phone: item.affiliate.user.phone
        } : null
      } : null
    }));

    return {
      data: transformedData,
      pagination: {
        total: count || 0,
        currentPage: page,
        limit,
        totalPages: Math.ceil((count || 0) / limit)
      }
    };
  }
}