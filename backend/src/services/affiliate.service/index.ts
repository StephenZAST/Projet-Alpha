import { AffiliateProfileService } from './affiliateProfile.service';
import { AffiliateCommissionService } from './affiliateCommission.service';
import { PaginationParams } from '../../utils/pagination';
import supabase from '../../config/database';

export class AffiliateService {
  // Profile Management
  static getProfile = AffiliateProfileService.getProfile;
  static updateProfile = AffiliateProfileService.updateProfile;
  static getReferrals = AffiliateProfileService.getReferrals;
  static getCurrentLevel = AffiliateProfileService.getCurrentLevel;
  static generateAffiliateCode = AffiliateProfileService.generateAffiliateCode;
  static createAffiliate = AffiliateProfileService.createAffiliate;

  // Commission Management
  static getCommissions = AffiliateCommissionService.getCommissions;
  static calculateCommission = AffiliateCommissionService.calculateCommission;
  static calculateIndirectCommission = AffiliateCommissionService.calculateIndirectCommission;
  static processNewCommission = AffiliateCommissionService.processNewCommission;
  static updateAffiliateLevels = AffiliateCommissionService.updateAffiliateLevels;
  static resetMonthlyEarnings = AffiliateCommissionService.resetMonthlyEarnings;

  // Withdrawal Management
  static async requestWithdrawal(affiliateId: string, amount: number) {
    try {
      const { error } = await supabase.rpc(
        'process_withdrawal_request',
        {
          p_affiliate_id: affiliateId,
          p_amount: amount
        }
      );

      if (error) throw error;

      // Récupérer la transaction créée
      const { data: transaction } = await supabase
        .from('commissionTransactions')
        .select('*')
        .eq('affiliate_id', affiliateId)
        .eq('type', 'WITHDRAWAL')
        .eq('status', 'PENDING')
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      return transaction;
    } catch (error: any) {
      throw new Error(error.message);
    }
  }

  static async getWithdrawals(pagination: PaginationParams, status?: string) {
    const { page = 1, limit = 10 } = pagination;
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let query = supabase
      .from('commissionTransactions')
      .select(`
        *,
        affiliate:affiliate_profiles(
          id,
          user:users(
            email,
            firstName,
            lastName
          )
        )
      `, { count: 'exact' })
      .eq('type', 'WITHDRAWAL');

    if (status) {
      query = query.eq('status', status);
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

  static async rejectWithdrawal(withdrawalId: string, reason: string) {
    try {
      const { error } = await supabase.rpc(
        'reject_withdrawal',
        {
          p_withdrawal_id: withdrawalId,
          p_reason: reason
        }
      );

      if (error) throw error;

      return { message: 'Withdrawal rejected successfully' };
    } catch (error: any) {
      throw new Error(error.message);
    }
  }

  static async approveWithdrawal(withdrawalId: string) {
    try {
      const { error } = await supabase.rpc(
        'approve_withdrawal',
        {
          p_withdrawal_id: withdrawalId
        }
      );

      if (error) throw error;

      return { message: 'Withdrawal approved successfully' };
    } catch (error: any) {
      throw new Error(error.message);
    }
  }

  // Administrative Functions
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
    const { data: affiliate, error: checkError } = await supabase
      .from('affiliate_profiles')
      .select('id, status')
      .eq('id', affiliateId)
      .single();

    if (checkError || !affiliate) {
      throw new Error('Affiliate not found');
    }

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

    return updatedAffiliate;
  }

  static async createCustomerWithAffiliateCode(
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    affiliateCode: string,
    phone?: string
  ) {
    const { data: affiliate } = await supabase
      .from('affiliate_profiles')
      .select('id')
      .eq('affiliate_code', affiliateCode)
      .single();

    if (!affiliate) {
      throw new Error('Affiliate code not found');
    }

    const { data: user, error: userError } = await supabase
      .from('users')
      .insert([{
        email,
        password,
        first_name: firstName,
        last_name: lastName,
        phone,
        role: 'CLIENT',
        referral_code: affiliateCode
      }])
      .select()
      .single();

    if (userError) throw userError;

    return user;
  }
}

export { AffiliateProfileService, AffiliateCommissionService };