import { PrismaClient, Prisma } from '@prisma/client';
import { Order, PointSource, PointTransactionType } from '../models/types';

const prisma = new PrismaClient();

export class RewardsService {
  private static readonly DEFAULT_POINTS_PER_AMOUNT = 1;
  private static readonly DEFAULT_COMMISSION_RATE = 0.1;
  private static readonly PARENT_COMMISSION_RATE = 0.1;

  static async processOrderPoints(
    userId: string,
    order: Order,
    source: PointSource = 'ORDER'
  ): Promise<void> {
    try {
      const pointsToAward = Math.floor(Number(order.totalAmount) * this.DEFAULT_POINTS_PER_AMOUNT);

      await prisma.$transaction(async (tx) => {
        // Vérifier et mettre à jour le profil de fidélité
        const loyalty = await tx.loyalty_points.upsert({
          where: { userId: userId },
          update: {
            pointsBalance: {
              increment: pointsToAward
            },
            totalEarned: {
              increment: pointsToAward
            },
            updatedAt: new Date()
          },
          create: {
            userId: userId,
            pointsBalance: pointsToAward,
            totalEarned: pointsToAward,
            createdAt: new Date(),
            updatedAt: new Date()
          }
        });

        // Créer la transaction de points
        await tx.point_transactions.create({
          data: {
            userId,
            points: pointsToAward,
            type: 'EARNED',
            source,
            referenceId: order.id,
            createdAt: new Date()
            // Ne pas inclure updated_at
          }
        });
      });
    } catch (error) {
      console.error('[RewardsService] Error processing order points:', error);
      throw error;
    }
  }

  static async processReferralPoints(
    referrerId: string,
    referredUserId: string,
    pointsAmount: number
  ): Promise<void> {
    try {
      await prisma.$transaction(async (tx) => {
        // Mettre à jour les points du parrain
        await tx.loyalty_points.upsert({
          where: { userId: referrerId },
          update: {
            pointsBalance: {
              increment: pointsAmount
            },
            totalEarned: {
              increment: pointsAmount
            },
            updatedAt: new Date()
          },
          create: {
            userId: referrerId,
            pointsBalance: pointsAmount,
            totalEarned: pointsAmount,
            createdAt: new Date(),
            updatedAt: new Date()
          }
        });

        // Enregistrer la transaction
        await tx.point_transactions.create({
          data: {
            userId: referrerId,
            points: pointsAmount,
            type: 'EARNED',
            source: 'REFERRAL',
            referenceId: referredUserId,
            createdAt: new Date()
            // Ne pas inclure updated_at
          }
        });
      });
    } catch (error) {
      console.error('[RewardsService] Error processing referral points:', error);
      throw error;
    }
  }

  static async calculateLoyaltyDiscount(points: number, total: number): Promise<number> {
    const conversionRate = Number(process.env.POINTS_TO_DISCOUNT_RATE || '0.1');
    const maxDiscountPercentage = Number(process.env.MAX_POINTS_DISCOUNT_PERCENTAGE || '30');
    
    let discountAmount = points * conversionRate;
    const maxDiscount = (total * maxDiscountPercentage) / 100;
    
    return Math.min(discountAmount, maxDiscount);
  }

  static async processAffiliateCommission(order: Order): Promise<void> {
    try {
      if (!order.affiliateCode) return;

      const affiliate = await prisma.affiliate_profiles.findFirst({
        where: {
          affiliate_code: order.affiliateCode,
          is_active: true,
          status: 'ACTIVE'
        },
        include: {
          affiliate_levels: true,
          users: {
            select: {
              email: true,
              first_name: true,
              last_name: true
            }
          }
        }
      });

      if (!affiliate) throw new Error('No active affiliate found with this code');

      const commissionRate = affiliate.affiliate_levels?.commissionRate ?? this.DEFAULT_COMMISSION_RATE;
      const commissionAmount = Number(order.totalAmount) * Number(commissionRate);

      await prisma.$transaction(async (tx) => {
        // Mettre à jour le solde de commission
        await tx.affiliate_profiles.update({
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
        });

        // Correction de la création de la transaction de commission
        await tx.commission_transactions.create({
          data: {
            affiliate_id: affiliate.id,
            order_id: order.id,
            created_at: new Date(),
            amount: commissionAmount
          }
        });

        // Process parent commissions récursivement
        if (affiliate.parent_affiliate_id) {
          await this.processParentCommissions(
            affiliate.parent_affiliate_id,
            order.id,
            commissionAmount,
            1
          );
        }
      });
    } catch (error) {
      console.error('[RewardsService] Error processing affiliate commission:', error);
      throw error;
    }
  }

  private static async processParentCommissions(
    parentAffiliateId: string,
    orderId: string,
    baseCommissionAmount: number,
    level: number,
    maxLevels: number = 3
  ): Promise<void> {
    if (!parentAffiliateId || level > maxLevels) return;

    try {
      const parentCommissionAmount = baseCommissionAmount * this.PARENT_COMMISSION_RATE;

      await prisma.$transaction(async (tx) => {
        // Mettre à jour le solde du parent
        await tx.affiliate_profiles.update({
          where: { id: parentAffiliateId },
          data: {
            commission_balance: {
              increment: parentCommissionAmount
            },
            total_earned: {
              increment: parentCommissionAmount
            },
            monthly_earnings: {
              increment: parentCommissionAmount
            },
            updated_at: new Date()
          }
        });

        // Créer la transaction en supprimant le champ status non supporté
        await tx.commission_transactions.create({
          data: {
            affiliate_id: parentAffiliateId,
            order_id: orderId,
            created_at: new Date(),
            amount: parentCommissionAmount
          }
        });

        // Récursion pour le niveau parent suivant
        const parentAffiliate = await tx.affiliate_profiles.findUnique({
          where: { id: parentAffiliateId },
          select: { parent_affiliate_id: true }
        });

        if (parentAffiliate?.parent_affiliate_id) {
          await this.processParentCommissions(
            parentAffiliate.parent_affiliate_id,
            orderId,
            parentCommissionAmount,
            level + 1,
            maxLevels
          );
        }
      });
    } catch (error) {
      console.error('[RewardsService] Error processing parent commissions:', error);
      throw error;
    }
  }

  static async convertPointsToDiscount(
    userId: string,
    points: number,
    orderId: string
  ): Promise<number> {
    try {
      await prisma.$transaction(async (tx) => {
        const loyalty = await tx.loyalty_points.findUnique({
          where: { userId: userId }
        });

        // Vérification plus stricte des points
        const currentPoints = loyalty?.pointsBalance ?? 0;
        if (!loyalty || currentPoints < points) {
          throw new Error('Insufficient points balance');
        }

        await tx.loyalty_points.update({
          where: { userId: userId },
          data: {
            pointsBalance: Math.max(0, currentPoints - points), // Éviter les valeurs négatives
            updatedAt: new Date()
          }
        });

        await tx.point_transactions.create({
          data: {
            userId,
            points: -points,
            type: 'SPENT',
            source: 'ORDER',
            referenceId: orderId,
            createdAt: new Date()
            // Ne pas inclure updated_at
          }
        });
      });

      return points;
    } catch (error) {
      console.error('[RewardsService] Error converting points to discount:', error);
      throw error;
    }
  }
}