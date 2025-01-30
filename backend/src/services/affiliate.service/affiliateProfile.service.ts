import supabase from '../../config/database';
import { COMMISSION_LEVELS } from './constants';

export class AffiliateProfileService {
  static async getProfile(userId: string) {
    const { data: profile, error } = await supabase
      .from('affiliate_profiles')
      .select(`
        *,
        user:users(
          id,
          email,
          firstName,
          lastName,
          phone
        ),
        commissionTransactions(
          amount,
          status,
          created_at
        ),
        childAffiliates:affiliate_profiles(
          id,
          total_earned
        )
      `)
      .eq('user_id', userId)
      .single();

    if (error) throw error;
    if (profile) {
      return {
        ...profile,
        user: profile.user ? {
          ...profile.user,
          firstName: profile.user.first_name,
          lastName: profile.user.last_name
        } : null
      };
    }
    return profile;
  }

  static async updateProfile(userId: string, updates: { phone?: string; notificationPreferences?: any }) {
    const { data, error } = await supabase
      .from('affiliate_profiles')
      .update(updates)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getReferrals(userId: string) {
    const { data, error } = await supabase
      .from('affiliate_profiles')
      .select(`
        id,
        user:users(
          id,
          email,
          firstName,
          lastName
        ),
        total_earned,
        total_referrals,
        monthly_earnings,
        created_at
      `)
      .eq('parent_affiliate_id', userId);

    if (error) throw error;
    return data;
  }

  static async getCurrentLevel(userId: string) {
    const { data: profile, error } = await supabase
      .from('affiliate_profiles')
      .select('total_referrals')
      .eq('user_id', userId)
      .maybeSingle();

    if (error) throw error;
    if (!profile) throw new Error('Affiliate profile not found');

    const referralCount = profile.total_referrals;
    let currentLevel;

    if (referralCount < 10) {
      currentLevel = COMMISSION_LEVELS.LEVEL1;
    } else if (referralCount < 20) {
      currentLevel = COMMISSION_LEVELS.LEVEL2;
    } else {
      currentLevel = COMMISSION_LEVELS.LEVEL3;
    }

    return {
      currentLevel: {
        rate: currentLevel.rate,
        minReferrals: currentLevel.min,
        maxReferrals: currentLevel.max === Infinity ? null : currentLevel.max
      },
      nextLevel: this.getNextLevel(referralCount)
    };
  }

  static async generateAffiliateCode(affiliateId: string) {
    const { data: affiliate } = await supabase
      .from('affiliate_profiles')
      .select('id, affiliate_code')
      .eq('id', affiliateId)
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
      .eq('id', affiliateId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  /**
   * Crée un nouveau profil d'affilié
   * @param userId ID de l'utilisateur
   * @param parentAffiliateCode Code d'affiliation du parent (optionnel)
   */
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
          status: 'ACTIVE',
          is_active: true,
          total_referrals: 0,
          monthly_earnings: 0,
          commission_rate: 10.00, // Taux de départ
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select(`
          *,
          affiliateLevel (
            id,
            name,
            commission_rate
          ),
          parentAffiliate (
            id,
            affiliate_code
          )
        `)
        .single();

      if (error) throw error;

      // 5. Mettre à jour le compteur de filleuls du parent si nécessaire
      if (parentId) {
        await supabase
          .from('affiliate_profiles')
          .update({
            total_referrals: supabase.rpc('increment_referral_count', {
              p_affiliate_id: parentId
            })
          })
          .eq('id', parentId);
      }

      return data;
    } catch (error) {
      console.error('[AffiliateProfileService] Create affiliate error:', error);
      throw error;
    }
  }

  /**
   * Applique un code d'affiliation à un client
   */
  /**
   * Applique un code d'affiliation à un client existant
   * @param userId ID de l'utilisateur client
   * @param affiliateCode Code d'affiliation à appliquer
   */
  static async applyAffiliateCode(userId: string, affiliateCode: string) {
    try {
      // 1. Vérifier le statut de l'utilisateur
      const { data: user } = await supabase
        .from('users')
        .select('referral_code, role')
        .eq('id', userId)
        .single();

      if (!user) {
        throw new Error('User not found');
      }

      if (user.role !== 'CLIENT') {
        throw new Error('Only clients can use affiliate codes');
      }

      if (user.referral_code) {
        throw new Error('User already has an affiliate code');
      }

      // 2. Vérifier l'affilié et son statut
      const { data: affiliate } = await supabase
        .from('affiliate_profiles')
        .select('id, user_id, status, is_active')
        .eq('affiliate_code', affiliateCode)
        .single();

      if (!affiliate) {
        throw new Error('Invalid affiliate code');
      }

      if (!affiliate.is_active || affiliate.status !== 'ACTIVE') {
        throw new Error('This affiliate account is not active');
      }

      if (affiliate.user_id === userId) {
        throw new Error('Cannot use your own affiliate code');
      }

      // 3. Appliquer le code et mettre à jour la date
      const { error: updateError } = await supabase
        .from('users')
        .update({
          referral_code: affiliateCode,
          updated_at: new Date().toISOString()
        })
        .eq('id', userId);

      if (updateError) throw updateError;

      // 4. Incrémenter le compteur de filleuls de l'affilié
      await supabase
        .from('affiliate_profiles')
        .update({
          total_referrals: supabase.rpc('increment_referral_count', {
            p_affiliate_id: affiliate.id
          }),
          updated_at: new Date().toISOString()
        })
        .eq('id', affiliate.id);

      // 5. Créer une notification pour l'affilié
      await supabase
        .from('notifications')
        .insert([{
          user_id: affiliate.user_id,
          type: 'SYSTEM',
          message: `Un nouveau client a utilisé votre code d'affiliation`,
          created_at: new Date().toISOString()
        }]);

      return {
        success: true,
        affiliateId: affiliate.id
      };
    } catch (error) {
      console.error('[AffiliateProfileService] Apply affiliate code error:', error);
      throw error;
    }
  }

  private static getNextLevel(currentReferrals: number) {
    if (currentReferrals < 10) {
      return {
        rate: COMMISSION_LEVELS.LEVEL2.rate,
        requiredReferrals: 10,
        remaining: 10 - currentReferrals
      };
    } else if (currentReferrals < 20) {
      return {
        rate: COMMISSION_LEVELS.LEVEL3.rate,
        requiredReferrals: 20,
        remaining: 20 - currentReferrals
      };
    }
    return null; // Niveau maximum atteint
  }
}