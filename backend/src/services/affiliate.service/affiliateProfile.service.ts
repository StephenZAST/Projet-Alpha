import supabase from '../../config/database';
import { COMMISSION_LEVELS } from './constants';

export class AffiliateProfileService {
  static async getProfile(userId: string) {
    try {
      console.log('[AffiliateProfileService] Getting profile for user:', userId);

      // First check if user exists and is an affiliate
      const { data: profile, error } = await supabase
        .from('affiliate_profiles')
        .select(`
          id,
          user_id,
          affiliate_code,
          parent_affiliate_id,
          commission_balance,
          total_earned,
          created_at,
          updated_at,
          commission_rate,
          is_active,
          total_referrals,
          monthly_earnings,
          level_id,
          status,
          user_details:users!inner(
            id,
            email,
            first_name,
            last_name,
            phone,
            notification_preferences(
              id,
              email,
              sms,
              push,
              promotions,
              order_updates,
              payments,
              loyalty
            )
          ),
          level:affiliate_levels(
            id,
            name,
            "commissionRate"
          )
        `)
        .eq('user_id', userId)
        .single();

      if (error) {
        console.error('[AffiliateProfileService] Error fetching profile:', error);
        throw error;
      }

      if (!profile) {
        console.error('[AffiliateProfileService] Profile not found for user:', userId);
        throw new Error('Affiliate profile not found');
      }

      // Fetch recent transactions separately
      const { data: transactions, error: transactionError } = await supabase
        .from('commissionTransactions')
        .select('id, amount, status, created_at')
        .eq('affiliate_id', profile.id)
        .order('created_at', { ascending: false })
        .limit(10);

      if (transactionError) {
        console.error('[AffiliateProfileService] Error fetching transactions:', transactionError);
        // Don't throw here, just log the error and continue
      }

      return {
        ...profile,
        recentTransactions: transactions || []
      };

    } catch (error: any) {
      console.error('[AffiliateProfileService] GetProfile error:', error);
      throw error;
    }
  }

  static async updateProfile(userId: string, updates: {
    phone?: string;
    notificationPreferences?: {
      email?: boolean;
      sms?: boolean;
      push?: boolean;
      promotions?: boolean;
      order_updates?: boolean;
      payments?: boolean;
      loyalty?: boolean;
    }
  }) {
    try {
      // 1. Update phone in users table if provided
      if (updates.phone) {
        const { error: userError } = await supabase
          .from('users')
          .update({ phone: updates.phone })
          .eq('id', userId);

        if (userError) throw userError;
      }

      // 2. Update notification preferences if provided
      if (updates.notificationPreferences) {
        // Validate preference fields
        const validPrefs = {
          user_id: userId,
          email: !!updates.notificationPreferences.email,
          sms: !!updates.notificationPreferences.sms,
          push: !!updates.notificationPreferences.push,
          promotions: !!updates.notificationPreferences.promotions,
          order_updates: !!updates.notificationPreferences.order_updates,
          payments: !!updates.notificationPreferences.payments,
          loyalty: !!updates.notificationPreferences.loyalty,
          updated_at: new Date().toISOString()
        };

        // Check if preferences already exist
        const { data: existingPrefs } = await supabase
          .from('notification_preferences')
          .select('id, created_at')
          .eq('user_id', userId)
          .single();

        const prefsData = {
          ...validPrefs,
          created_at: existingPrefs?.created_at || new Date().toISOString()
        };

        const { error: prefsError } = await supabase
          .from('notification_preferences')
          .upsert([prefsData], {
            onConflict: 'user_id'
          });

        if (prefsError) {
          console.error('[AffiliateProfileService] Error updating preferences:', prefsError);
          throw new Error('Failed to update notification preferences');
        }
      }

      // 3. Get updated profile data using the same structure as getProfile
      const { data: profile, error: profileError } = await supabase
        .from('affiliate_profiles')
        .select(`
          id,
          user_id,
          affiliate_code,
          parent_affiliate_id,
          commission_balance,
          total_earned,
          created_at,
          updated_at,
          commission_rate,
          is_active,
          total_referrals,
          monthly_earnings,
          level_id,
          status,
          user_details:users!inner(
            id,
            email,
            first_name,
            last_name,
            phone,
            notification_preferences(
              id,
              email,
              sms,
              push,
              promotions,
              order_updates,
              payments,
              loyalty
            )
          ),
          level:affiliate_levels(
            id,
            name,
            "commissionRate"
          )
        `)
        .eq('user_id', userId)
        .single();

      if (profileError) throw profileError;
      return profile;

    } catch (error) {
      console.error('[AffiliateProfileService] UpdateProfile error:', error);
      throw error;
    }
  }

  static async getReferrals(userId: string) {
    const { data, error } = await supabase
      .from('affiliate_profiles')
      .select(`
        id,
        user_details:users(
          id,
          email,
          first_name,
          last_name,
          phone,
          notification_preferences(
            id,
            email,
            sms,
            push,
            promotions,
            order_updates,
            payments,
            loyalty
          )
        ),
        total_earned,
        total_referrals,
        monthly_earnings,
        created_at,
        status
      `)
      .eq('parent_affiliate_id', userId);

    if (error) throw error;
    return data;
  }

  static async getCurrentLevel(userId: string) {
    const { data: profile, error: profileError } = await supabase
      .from('affiliate_profiles')
      .select(`
        id,
        total_referrals,
        total_earned,
        level_id,
        level:affiliate_levels(
          id,
          name,
          commission_rate
        )
      `)
      .eq('user_id', userId)
      .single();

    if (profileError) throw profileError;
    if (!profile) throw new Error('Affiliate profile not found');

    let currentLevel;
    if (profile.total_referrals < 10) {
      currentLevel = COMMISSION_LEVELS.LEVEL1;
    } else if (profile.total_referrals < 20) {
      currentLevel = COMMISSION_LEVELS.LEVEL2;
    } else {
      currentLevel = COMMISSION_LEVELS.LEVEL3;
    }

    return {
      currentLevel: {
        ...currentLevel,
        current: {
          referrals: profile.total_referrals,
          earnings: profile.total_earned
        }
      },
      nextLevel: this.getNextLevel(profile.total_referrals)
    };
  }

  static async generateAffiliateCode(userId: string) {
    const { data: affiliate } = await supabase
      .from('affiliate_profiles')
      .select('id, affiliate_code')
      .eq('user_id', userId)
      .single();

    if (!affiliate) {
      throw new Error('Affiliate not found');
    }

    if (affiliate.affiliate_code) {
      throw new Error('Affiliate already has a code');
    }

    const newCode = Math.random().toString(36).substring(2, 10).toUpperCase();

    const { data, error } = await supabase
      .from('affiliate_profiles')
      .update({ affiliate_code: newCode })
      .eq('id', affiliate.id)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async createAffiliate(userId: string, parentAffiliateCode?: string) {
    let parentId: string | null = null;
    let level_id: string | null = null;

    try {
      // 1. Vérifier si l'utilisateur existe et n'est pas déjà affilié
      const { data: existingProfile } = await supabase
        .from('affiliate_profiles')
        .select('id')
        .eq('user_id', userId)
        .single();

      if (existingProfile) {
        throw new Error('User is already an affiliate');
      }

      // 2. Si un code parent est fourni, valider et récupérer le parent
      if (parentAffiliateCode) {
        const { data: parent } = await supabase
          .from('affiliate_profiles')
          .select('id, user_id')
          .eq('affiliate_code', parentAffiliateCode)
          .eq('is_active', true)
          .single();

        if (!parent) {
          throw new Error('Parent affiliate code not found or inactive');
        }

        if (parent.user_id === userId) {
          throw new Error('Cannot use your own affiliate code');
        }

        parentId = parent.id;
      }

      // 3. Récupérer le niveau de départ
      const { data: startingLevel } = await supabase
        .from('affiliate_levels')
        .select('id')
        .order('min_earnings', { ascending: true })
        .limit(1)
        .single();

      if (startingLevel) {
        level_id = startingLevel.id;
      }

      // 4. Créer le profil d'affilié
      const newCode = Math.random().toString(36).substring(2, 10).toUpperCase();

      const { data, error } = await supabase
        .from('affiliate_profiles')
        .insert([{
          user_id: userId,
          affiliate_code: newCode,
          parent_affiliate_id: parentId,
          commission_balance: 0,
          total_earned: 0,
          level_id: level_id,
          status: 'PENDING',
          is_active: true,
          total_referrals: 0,
          monthly_earnings: 0,
          commission_rate: 10.00,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select()
        .single();

      if (error) throw error;

      // 5. Incrémenter le compteur de filleuls du parent
      if (parentId) {
        const { error: updateError } = await supabase.rpc(
          'increment_referral_count',
          { p_affiliate_id: parentId }
        );

        if (updateError) throw updateError;
      }

      return data;
    } catch (error) {
      console.error('[AffiliateProfileService] Create affiliate error:', error);
      throw error;
    }
  }

  private static getNextLevel(currentReferrals: number) {
    if (currentReferrals < 10) {
      return {
        ...COMMISSION_LEVELS.LEVEL2,
        requiredReferrals: 10,
        remaining: 10 - currentReferrals
      };
    } else if (currentReferrals < 20) {
      return {
        ...COMMISSION_LEVELS.LEVEL3,
        requiredReferrals: 20,
        remaining: 20 - currentReferrals
      };
    }
    return null; // Maximum level reached
  }
}