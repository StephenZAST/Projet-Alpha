import { PrismaClient, status } from '@prisma/client';
import { AffiliateProfileService } from './affiliateProfile.service';
import { AffiliateCommissionService } from './affiliateCommission.service';
import { AffiliateWithdrawalService } from './affiliateWithdrawal.service';
import { PaginationParams } from '../../utils/pagination';

const prisma = new PrismaClient();

export class AffiliateService {
  // Profile Management
  static getProfile = AffiliateProfileService.getAffiliateProfile;
  static updateProfile = AffiliateProfileService.updateAffiliateProfile;
  static getReferrals = AffiliateProfileService.getReferralsByAffiliateId;
  static createAffiliate = AffiliateProfileService.createAffiliate;

  // Commission Management
  static getCommissions = AffiliateCommissionService.getCommissions;
  static calculateCommissionRate = AffiliateCommissionService.calculateCommissionRate;
  static processNewCommission = AffiliateCommissionService.processNewCommission;

  // Withdrawal Management
  static requestWithdrawal = AffiliateWithdrawalService.requestWithdrawal;
  static getWithdrawals = AffiliateWithdrawalService.getWithdrawals;
  static approveWithdrawal = AffiliateWithdrawalService.approveWithdrawal;
  static rejectWithdrawal = AffiliateWithdrawalService.rejectWithdrawal;

  static async getAllAffiliates(
    pagination: PaginationParams,
    filters: { status?: status; query?: string; }
  ) {
    const { page = 1, limit = 10 } = pagination;
    const skip = (page - 1) * limit;

    try {
      // Construction du filtre
      const whereConditions: any = {};

      if (filters.status) {
        whereConditions.status = filters.status;
      }

      if (filters.query) {
        whereConditions.OR = [
          {
            users: {
              email: {
                contains: filters.query,
                mode: 'insensitive'
              }
            }
          },
          {
            users: {
              first_name: {
                contains: filters.query,
                mode: 'insensitive'
              }
            }
          },
          {
            users: {
              last_name: {
                contains: filters.query,
                mode: 'insensitive'
              }
            }
          },
          {
            affiliate_code: {
              contains: filters.query,
              mode: 'insensitive'
            }
          }
        ];
      }

      const [affiliates, total] = await Promise.all([
        prisma.affiliate_profiles.findMany({
          skip,
          take: limit,
          where: whereConditions,
          include: {
            users: {
              select: {
                id: true,
                email: true,
                first_name: true,
                last_name: true,
                phone: true
              }
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        }),
        prisma.affiliate_profiles.count({ where: whereConditions })
      ]);

      // Log le résultat brut pour debug
      console.log('[AffiliateService] Affiliates raw:', JSON.stringify(affiliates, null, 2));

      // Mapping correct du champ 'user'
      const mappedAffiliates = affiliates.map(affiliate => ({
        ...affiliate,
        user: affiliate.users ? {
          id: affiliate.users.id,
          email: affiliate.users.email,
          firstName: affiliate.users.first_name,
          lastName: affiliate.users.last_name,
          phone: affiliate.users.phone
        } : null
      }));

      return {
        data: mappedAffiliates,
        pagination: {
          total,
          currentPage: page,
          limit,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('[AffiliateService] Get all affiliates error:', error);
      throw error;
    }
  }

  static async updateAffiliateStatus(
    affiliateId: string,
    status: string,
    isActive: boolean
  ) {
    try {
      const updatedAffiliate = await prisma.affiliate_profiles.update({
        where: { id: affiliateId },
        data: {
          status: status as any,
          is_active: isActive,
          updated_at: new Date()
        },
        include: {
          users: {
            select: {
              id: true,
              email: true,
              first_name: true,
              last_name: true,
              phone: true
            }
          }
        }
      });

      return {
        ...updatedAffiliate,
        user: updatedAffiliate.users ? {
          id: updatedAffiliate.users.id,
          email: updatedAffiliate.users.email,
          firstName: updatedAffiliate.users.first_name,
          lastName: updatedAffiliate.users.last_name,
          phone: updatedAffiliate.users.phone
        } : null
      };
    } catch (error) {
      console.error('[AffiliateService] Update affiliate status error:', error);
      throw error;
    }
  }

  static async createCustomerWithAffiliateCode(
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    affiliateCode: string,
    phone?: string
  ) {
    try {
      const affiliate = await prisma.affiliate_profiles.findUnique({
        where: { affiliate_code: affiliateCode }
      });

      if (!affiliate) {
        throw new Error('Affiliate code not found');
      }

      const user = await prisma.users.create({
        data: {
          email,
          password,
          first_name: firstName,
          last_name: lastName,
          phone,
          role: 'CLIENT',
          referral_code: affiliateCode
        }
      });

      return {
        ...user,
        firstName: user.first_name,
        lastName: user.last_name
      };
    } catch (error) {
      console.error('[AffiliateService] Create customer with affiliate code error:', error);
      throw error;
    }
  }

  static async generateCode(userId: string): Promise<string> {
    const prefix = 'AFF';
    const timestamp = Date.now().toString(36);
    const randomStr = Math.random().toString(36).substring(2, 6);
    return `${prefix}-${timestamp}-${randomStr}`.toUpperCase();
  }

  static async getCurrentLevel(userId: string): Promise<any> {
    // Implémentation de la récupération du niveau
  }

  static async getAffiliateStats() {
    try {
      const [
        totalAffiliates,
        activeAffiliates,
        pendingAffiliates,
        suspendedAffiliates,
        totalCommissions,
        monthlyCommissions,
        totalReferrals
      ] = await Promise.all([
        // Total des affiliés
        prisma.affiliate_profiles.count(),
        
        // Affiliés actifs
        prisma.affiliate_profiles.count({
          where: { status: 'ACTIVE' }
        }),
        
        // Affiliés en attente
        prisma.affiliate_profiles.count({
          where: { status: 'PENDING' }
        }),
        
        // Affiliés suspendus
        prisma.affiliate_profiles.count({
          where: { status: 'SUSPENDED' }
        }),
        
        // Total des commissions
        prisma.commission_transactions.aggregate({
          _sum: { amount: true },
          where: { status: 'PAID' }
        }),
        
        // Commissions du mois
        prisma.commission_transactions.aggregate({
          _sum: { amount: true },
          where: {
            status: 'PAID',
            created_at: {
              gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
            }
          }
        }),
        
        // Total des référencements
        prisma.affiliate_profiles.aggregate({
          _sum: { total_referrals: true }
        })
      ]);

      // Calcul du taux moyen de commission
      const averageCommissionRate = await prisma.affiliate_profiles.aggregate({
        _avg: { commission_rate: true }
      });

      return {
        totalAffiliates,
        activeAffiliates,
        pendingAffiliates,
        suspendedAffiliates,
        totalCommissions: Number(totalCommissions._sum.amount || 0),
        monthlyCommissions: Number(monthlyCommissions._sum.amount || 0),
        averageCommissionRate: Number(averageCommissionRate._avg.commission_rate || 0),
        totalReferrals: Number(totalReferrals._sum.total_referrals || 0)
      };
    } catch (error) {
      console.error('[AffiliateService] Get affiliate stats error:', error);
      throw error;
    }
  }

  static async updateProfileSettings(userId: string, data: {
    notificationSettings?: Record<string, boolean>;
  }) {
    // Implémentation de la mise à jour du profil
  }
}

export { 
  AffiliateProfileService, 
  AffiliateCommissionService,
  AffiliateWithdrawalService
};