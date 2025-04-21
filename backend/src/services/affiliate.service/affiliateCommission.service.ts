import { PrismaClient, Prisma } from '@prisma/client';
import { NotificationService } from '../notification.service';
import { NotificationType } from '../../models/types';

const prisma = new PrismaClient();
const MIN_WITHDRAWAL_AMOUNT = 5000; // 5000 FCFA minimum

export class AffiliateCommissionService {
  static async getCommissions(
    affiliateId: string,
    page: number = 1,
    limit: number = 10
  ) {
    try {
      const skip = (page - 1) * limit;

      const [commissions, total] = await Promise.all([
        prisma.commission_transactions.findMany({
          skip,
          take: limit,
          where: {
            affiliate_id: affiliateId
          },
          include: {
            orders: true,
            affiliate_profiles: true
          },
          orderBy: {
            created_at: 'desc'
          }
        }),
        prisma.commission_transactions.count({
          where: {
            affiliate_id: affiliateId
          }
        })
      ]);

      return {
        data: commissions.map(commission => ({
          id: commission.id,
          orderId: commission.order_id,
          amount: Number(commission.orders?.totalAmount || 0),
          createdAt: commission.created_at || new Date(),
          order: commission.orders ? {
            id: commission.orders.id,
            totalAmount: Number(commission.orders.totalAmount || 0),
            createdAt: commission.orders.createdAt
          } : null
        })),
        pagination: {
          total,
          currentPage: page,
          limit,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('[AffiliateCommissionService] Get commissions error:', error);
      throw error;
    }
  }

  static async requestWithdrawal(affiliateId: string, amount: number) {
    try {
      if (amount < MIN_WITHDRAWAL_AMOUNT) {
        throw new Error(`Le montant minimum de retrait est de ${MIN_WITHDRAWAL_AMOUNT} FCFA`);
      }

      const affiliate = await prisma.affiliate_profiles.findUnique({
        where: { id: affiliateId },
        include: {
          users: true
        }
      });

      if (!affiliate) {
        throw new Error('Profil affilié non trouvé');
      }

      if (!affiliate.is_active || affiliate.status !== 'ACTIVE') {
        throw new Error('Le compte affilié n\'est pas actif');
      }

      if (Number(affiliate.commission_balance) < amount) {
        throw new Error('Solde insuffisant');
      }

      // Utilisation d'une transaction Prisma
      const transaction = await prisma.$transaction(async (prisma) => {
        const [withdrawal, updatedProfile] = await Promise.all([
          prisma.commission_transactions.create({
            data: {
              affiliate_id: affiliateId,
              order_id: null as any, // Temporaire - à revoir dans le schéma
              amount: amount,
              created_at: new Date(),
              updated_at: new Date()
            }
          }),
          prisma.affiliate_profiles.update({
            where: { id: affiliateId },
            data: {
              commission_balance: {
                decrement: new Prisma.Decimal(amount)
              },
              updated_at: new Date()
            }
          })
        ]);

        return { withdrawal, updatedProfile };
      });

      // Utilisation du type de notification correct
      await NotificationService.sendNotification(
        affiliate.user_id,
        NotificationType.WITHDRAWAL_REQUESTED,
        {
          amount,
          transactionId: transaction.withdrawal.id,
          status: 'PENDING',
          message: `Votre demande de retrait de ${amount} FCFA a été enregistrée et est en attente de validation.`
        }
      );

      return transaction.withdrawal;
    } catch (error) {
      console.error('[AffiliateCommissionService] Request withdrawal error:', error);
      throw error;
    }
  }

  static async calculateCommissionRate(totalReferrals: number): Promise<number> {
    try {
      const level = await prisma.affiliate_levels.findFirst({
        where: {
          minEarnings: {
            lte: totalReferrals
          }
        },
        orderBy: {
          minEarnings: 'desc'
        }
      });

      return Number(level?.commissionRate || 10);
    } catch (error) {
      console.error('[AffiliateCommissionService] Calculate commission rate error:', error);
      throw error;
    }
  }

  static async processNewCommission(
    orderId: string, 
    orderAmount: number, 
    affiliateCode: string
  ): Promise<boolean> {
    try {
      const affiliate = await prisma.affiliate_profiles.findFirst({
        where: { 
          affiliate_code: affiliateCode,
          is_active: true,
          status: 'ACTIVE'
        }
      });

      if (!affiliate) {
        throw new Error('Active affiliate not found');
      }

      const commissionRate = await this.calculateCommissionRate(affiliate.total_referrals || 0);
      const commissionAmount = orderAmount * (commissionRate / 100);

      await prisma.$transaction([
        prisma.affiliate_profiles.update({
          where: { id: affiliate.id },
          data: {
            commission_balance: {
              increment: commissionAmount
            },
            total_earned: {
              increment: commissionAmount
            },
            monthly_earnings: {
              increment: commissionAmount
            },
            total_referrals: {
              increment: 1
            },
            updated_at: new Date()
          }
        }),
        prisma.commission_transactions.create({
          data: {
            affiliate_id: affiliate.id,
            order_id: orderId,
            amount: commissionAmount,
            created_at: new Date(),
            updated_at: new Date()
          }
        })
      ]);

      return true;
    } catch (error) {
      console.error('[AffiliateCommissionService] Process commission error:', error);
      throw error;
    }
  }

  static async resetMonthlyEarnings(): Promise<void> {
    try {
      await prisma.affiliate_profiles.updateMany({
        data: {
          monthly_earnings: new Prisma.Decimal(0),
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[AffiliateCommissionService] Reset monthly earnings error:', error);
      throw error;
    }
  }
}