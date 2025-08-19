import { PrismaClient, Prisma, status } from '@prisma/client';
import { 
  AffiliateProfile, 
  CreateAffiliateDTO, 
  NotificationType 
} from '../../models/types';
import { NotificationService } from '../notification.service';
import { generateAffiliateCode } from '../../utils/codeGenerator';
import { 
  COMMISSION_LEVELS,
  DISTINCTION_LEVELS,
  MIN_WITHDRAWAL_AMOUNT,
  INDIRECT_COMMISSION_RATE 
} from './constants';

const prisma = new PrismaClient();

export class AffiliateProfileService {
  static async createProfile(data: {
    userId: string;
    affiliateCode: string;
    parent_affiliate_id?: string;
  }): Promise<AffiliateProfile> {
    const profile = await prisma.affiliate_profiles.create({
      data: {
        userId: data.userId,
        affiliate_code: data.affiliateCode,
        parent_affiliate_id: data.parent_affiliate_id,
        commission_rate: 10,
        commission_balance: 0,
        total_earned: 0,
        monthly_earnings: 0,
        is_active: true,
        status: 'PENDING' as status,  // Typage explicite pour status
        created_at: new Date(),
        updated_at: new Date()
      }
    });

    return {
      id: profile.id,
      userId: profile.userId,
      affiliateCode: profile.affiliate_code,
      parent_affiliate_id: profile.parent_affiliate_id || undefined,
      commission_rate: Number(profile.commission_rate),
      commissionBalance: Number(profile.commission_balance),
      totalEarned: Number(profile.total_earned),
      monthlyEarnings: Number(profile.monthly_earnings),
      isActive: profile.is_active ?? false,
      status: profile.status,  // Le type sera maintenant compatible
      levelId: profile.level_id || undefined,
      totalReferrals: profile.total_referrals || 0,
      createdAt: profile.created_at || new Date(),
      updatedAt: profile.updated_at || new Date()
    };
  }

  static async updateProfile(id: string, data: Partial<AffiliateProfile>): Promise<AffiliateProfile> {
    const profile = await prisma.affiliate_profiles.update({
      where: { id },
      data: {
        commission_rate: data.commission_rate,
        is_active: data.isActive,
        status: data.status || 'PENDING',
        updated_at: new Date()
      }
    });

    return this.formatProfile(profile);
  }

  private static formatProfile(profile: any): AffiliateProfile {
    return {
      id: profile.id,
      userId: profile.userId,
      affiliateCode: profile.affiliate_code,
      parent_affiliate_id: profile.parent_affiliate_id || undefined,
      commission_rate: Number(profile.commission_rate),
      commissionBalance: Number(profile.commission_balance),
      totalEarned: Number(profile.total_earned),
      monthlyEarnings: Number(profile.monthly_earnings),
      isActive: profile.is_active,
      status: profile.status || 'PENDING',
      levelId: profile.level_id || undefined,
      totalReferrals: profile.total_referrals || 0,
      createdAt: profile.created_at,
      updatedAt: profile.updated_at
    };
  }

  static async createAffiliate(data: CreateAffiliateDTO): Promise<AffiliateProfile> {
    try {
      // Vérifier si l'utilisateur existe déjà comme affilié
      const existingProfile = await prisma.affiliate_profiles.findUnique({
        where: { userId: data.userId }
      });

      if (existingProfile) {
        throw new Error('User already has an affiliate profile');
      }

      // Vérifier le code du parrain si fourni
      let parentId: string | undefined;
      if (data.parentAffiliateCode) {
        const parentProfile = await prisma.affiliate_profiles.findFirst({
          where: { 
            affiliate_code: data.parentAffiliateCode,
            is_active: true,
            status: 'ACTIVE'
          }
        });

        if (!parentProfile) {
          throw new Error('Invalid parent affiliate code');
        }
        parentId = parentProfile.id;
      }

      // Générer un code unique
      const affiliateCode = await generateAffiliateCode();

      // Créer le profil affilié
      const profile = await prisma.affiliate_profiles.create({
        data: {
          userId: data.userId,
          affiliate_code: affiliateCode,
          parent_affiliate_id: parentId,
          commission_balance: new Prisma.Decimal(0),
          total_earned: new Prisma.Decimal(0),
          commission_rate: new Prisma.Decimal(10),
          is_active: true,
          total_referrals: 0,
          monthly_earnings: new Prisma.Decimal(0),
          status: 'PENDING',
          created_at: new Date(),
          updated_at: new Date()
        },
        include: {
          users: true,
          affiliate_levels: true
        }
      });

      // Notification aux administrateurs
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        }
      });

      await Promise.all(
        admins.map(admin =>
          NotificationService.sendNotification(
            admin.id,
            NotificationType.AFFILIATE_STATUS_UPDATED,
            {
              title: 'Nouvelle demande d\'affiliation',
              message: `Un nouvel affilié attend votre validation`,
              data: { affiliateId: profile.id }
            }
          )
        )
      );

      return {
        id: profile.id,
        userId: profile.userId,
        affiliateCode: profile.affiliate_code,
        parent_affiliate_id: profile.parent_affiliate_id || undefined,
        commissionBalance: Number(profile.commission_balance),
        totalEarned: Number(profile.total_earned),
        createdAt: profile.created_at || new Date(),
        updatedAt: profile.updated_at || new Date(),
        commission_rate: Number(profile.commission_rate),
        status: profile.status || 'PENDING',
        isActive: profile.is_active || false,
        totalReferrals: profile.total_referrals || 0,
        monthlyEarnings: Number(profile.monthly_earnings),
        levelId: profile.level_id || undefined,
        level: profile.affiliate_levels ? {
          id: profile.affiliate_levels.id,
          name: profile.affiliate_levels.name,
          minEarnings: Number(profile.affiliate_levels.minEarnings),
          commissionRate: Number(profile.affiliate_levels.commissionRate),
          createdAt: profile.affiliate_levels.created_at || new Date(),
          updatedAt: profile.affiliate_levels.updated_at || new Date()
        } : undefined
      };
    } catch (error) {
      console.error('[AffiliateProfileService] Create affiliate error:', error);
      throw error;
    }
  }

  static async getAffiliateProfile(userId: string): Promise<AffiliateProfile | null>;
  static async getAffiliateProfile(profileId: string, byId: boolean): Promise<AffiliateProfile | null>;
  static async getAffiliateProfile(
    identifier: string,
    byId: boolean = false
  ): Promise<AffiliateProfile | null> {
    try {
      const where = byId 
        ? { id: identifier }
        : { userId: identifier };

      const profile = await prisma.affiliate_profiles.findUnique({
        where,
        include: {
          affiliate_levels: true,
          users: true
        }
      });

      if (!profile) return null;

      return {
        id: profile.id,
        userId: profile.userId,
        affiliateCode: profile.affiliate_code,
        parent_affiliate_id: profile.parent_affiliate_id || undefined, // Utiliser le nom exact
        commissionBalance: Number(profile.commission_balance),
        totalEarned: Number(profile.total_earned),
        createdAt: profile.created_at || new Date(),
        updatedAt: profile.updated_at || new Date(),
        commission_rate: Number(profile.commission_rate),
        status: profile.status || 'PENDING',
        isActive: profile.is_active || false,
        totalReferrals: profile.total_referrals || 0,
        monthlyEarnings: Number(profile.monthly_earnings),
        levelId: profile.level_id || undefined
      };
    } catch (error) {
      console.error('[AffiliateProfileService] Get affiliate profile error:', error);
      throw error;
    }
  }

  static async updateAffiliateProfile(
    affiliateId: string,
    data: Partial<AffiliateProfile>
  ): Promise<AffiliateProfile> {
    try {
      const affiliate = await prisma.affiliate_profiles.update({
        where: { id: affiliateId },
        data: {
          commission_rate: data.commission_rate ? new Prisma.Decimal(data.commission_rate) : undefined,
          is_active: data.isActive,
          status: data.status,
          level_id: data.levelId,
          updated_at: new Date()
        },
        include: {
          affiliate_levels: true,
          users: true
        }
      });

      if (data.status) {
        await NotificationService.sendNotification(
          affiliate.userId,
          NotificationType.AFFILIATE_STATUS_UPDATED,
          {
            title: 'Statut d\'affiliation mis à jour',
            message: `Votre statut d'affiliation est maintenant: ${data.status}`,
            data: { newStatus: data.status }
          }
        );
      }

      return {
        id: affiliate.id,
        userId: affiliate.userId,
        affiliateCode: affiliate.affiliate_code,
        parent_affiliate_id: affiliate.parent_affiliate_id || undefined,
        commissionBalance: Number(affiliate.commission_balance),
        totalEarned: Number(affiliate.total_earned),
        createdAt: affiliate.created_at || new Date(),
        updatedAt: affiliate.updated_at || new Date(),
        commission_rate: Number(affiliate.commission_rate),
        status: affiliate.status || 'PENDING',
        isActive: affiliate.is_active || false,
        totalReferrals: affiliate.total_referrals || 0,
        monthlyEarnings: Number(affiliate.monthly_earnings),
        levelId: affiliate.level_id || undefined,
        level: affiliate.affiliate_levels ? {
          id: affiliate.affiliate_levels.id,
          name: affiliate.affiliate_levels.name,
          minEarnings: Number(affiliate.affiliate_levels.minEarnings),
          commissionRate: Number(affiliate.affiliate_levels.commissionRate),
          createdAt: affiliate.affiliate_levels.created_at || new Date(),
          updatedAt: affiliate.affiliate_levels.updated_at || new Date()
        } : undefined
      };
    } catch (error) {
      console.error('[AffiliateProfileService] Update profile error:', error);
      throw error;
    }
  }

  static async getAllAffiliates(
    page: number = 1,
    limit: number = 10,
    statusFilter?: status
  ): Promise<{
    affiliates: AffiliateProfile[];
    total: number;
    pages: number;
  }> {
    try {
      const where = statusFilter ? { status: statusFilter } : {};
      const skip = (page - 1) * limit;

      const [affiliates, total] = await Promise.all([
        prisma.affiliate_profiles.findMany({
          skip,
          take: limit,
          where,
          orderBy: {
            created_at: 'desc'
          },
          include: {
            affiliate_levels: true,
            users: true
          }
        }),
        prisma.affiliate_profiles.count({ where })
      ]);

      return {
        affiliates: affiliates.map(affiliate => ({
          id: affiliate.id,
          userId: affiliate.userId,
          affiliateCode: affiliate.affiliate_code,
          parentAffiliateId: affiliate.parent_affiliate_id || undefined,
          commissionBalance: Number(affiliate.commission_balance),
          totalEarned: Number(affiliate.total_earned),
          createdAt: affiliate.created_at || new Date(),
          updatedAt: affiliate.updated_at || new Date(),
          commission_rate: Number(affiliate.commission_rate),
          status: affiliate.status || 'PENDING',
          isActive: affiliate.is_active || false,
          totalReferrals: affiliate.total_referrals || 0,
          monthlyEarnings: Number(affiliate.monthly_earnings),
          levelId: affiliate.level_id || undefined,
          level: affiliate.affiliate_levels ? {
            id: affiliate.affiliate_levels.id,
            name: affiliate.affiliate_levels.name,
            minEarnings: Number(affiliate.affiliate_levels.minEarnings),
            commissionRate: Number(affiliate.affiliate_levels.commissionRate),
            createdAt: affiliate.affiliate_levels.created_at || new Date(),
            updatedAt: affiliate.affiliate_levels.updated_at || new Date()
          } : undefined
        })),
        total,
        pages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('[AffiliateProfileService] Get all affiliates error:', error);
      throw error;
    }
  }

  static async getReferralsByAffiliateId(
    affiliateId: string
  ): Promise<AffiliateProfile[]> {
    try {
      const referrals = await prisma.affiliate_profiles.findMany({
        where: {
          parent_affiliate_id: affiliateId
        },
        include: {
          users: true,
          affiliate_levels: true
        }
      });

      return referrals.map(referral => ({
        id: referral.id,
        userId: referral.userId,
        affiliateCode: referral.affiliate_code,
        parentAffiliateId: referral.parent_affiliate_id || undefined,
        commissionBalance: Number(referral.commission_balance),
        totalEarned: Number(referral.total_earned),
        createdAt: referral.created_at || new Date(),
        updatedAt: referral.updated_at || new Date(),
        commission_rate: Number(referral.commission_rate),
        status: referral.status || 'PENDING',
        isActive: referral.is_active || false,
        totalReferrals: referral.total_referrals || 0,
        monthlyEarnings: Number(referral.monthly_earnings),
        levelId: referral.level_id || undefined,
        level: referral.affiliate_levels ? {
          id: referral.affiliate_levels.id,
          name: referral.affiliate_levels.name,
          minEarnings: Number(referral.affiliate_levels.minEarnings),
          commissionRate: Number(referral.affiliate_levels.commissionRate),
          createdAt: referral.affiliate_levels.created_at || new Date(),
          updatedAt: referral.affiliate_levels.updated_at || new Date()
        } : undefined
      }));
    } catch (error) {
      console.error('[AffiliateProfileService] Get referrals error:', error);
      throw error;
    }
  }
}