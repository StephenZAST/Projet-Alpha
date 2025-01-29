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
  static getWithdrawals = AffiliateCommissionService.getWithdrawals;
  static getCommissions = async (affiliateId: string, pagination: PaginationParams) => {
    return AffiliateCommissionService.getWithdrawals(pagination);
  };
  static requestWithdrawal = AffiliateCommissionService.requestWithdrawal;
  static rejectWithdrawal = AffiliateCommissionService.rejectWithdrawal;
  static calculateCommission = AffiliateCommissionService.calculateCommission;
  static calculateIndirectCommission = AffiliateCommissionService.calculateIndirectCommission;

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