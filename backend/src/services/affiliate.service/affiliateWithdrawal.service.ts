import { PrismaClient, Prisma } from '@prisma/client';
import { PaginationParams } from '../../utils/pagination';
import { NotificationService } from '../notification.service';
import { NotificationType } from '../../models/types';

// Définition d'un type pour la transaction
interface WithdrawalTransaction {
  id: string;
  amount: number;
  created_at?: Date | null;
  updated_at?: Date | null;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  affiliate_profile?: {
    id: string;
    user?: {
      id: string;
      email: string;
      first_name: string;
      last_name: string;
      phone?: string;
    };
  };
}

const prisma = new PrismaClient();

export class AffiliateWithdrawalService {
  static async requestWithdrawal(affiliateId: string, amount: number) {
    try {
      return await prisma.$transaction(async (tx) => {
        // Vérifier le solde
        const affiliate = await tx.affiliate_profiles.findUnique({
          where: { id: affiliateId },
          select: {
            commission_balance: true,
            user_id: true
          }
        });

        if (!affiliate || Number(affiliate.commission_balance) < amount) {
          throw new Error('Insufficient balance');
        }

        // Créer la transaction
        const withdrawal = await tx.commission_transactions.create({
          data: {
            affiliate_id: affiliateId,
            amount: new Prisma.Decimal(amount),
            order_id: null,
            created_at: new Date(),
            updated_at: new Date()
          }
        });

        // Mettre à jour le solde
        await tx.affiliate_profiles.update({
          where: { id: affiliateId },
          data: {
            commission_balance: {
              decrement: new Prisma.Decimal(amount)
            },
            updated_at: new Date()
          }
        });

        return withdrawal;
      });
    } catch (error) {
      console.error('[AffiliateWithdrawalService] Request withdrawal error:', error);
      throw error;
    }
  }

  static async getWithdrawals(pagination: PaginationParams, withdrawalStatus?: string) {
    const { page = 1, limit = 10 } = pagination;
    const skip = (page - 1) * limit;

    try {
      const [withdrawals, total] = await Promise.all([
        prisma.commission_transactions.findMany({
          skip,
          take: limit,
          where: {
            order_id: null, // transactions de retrait uniquement
          },
          include: {
            affiliate_profiles: {
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
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        }),
        prisma.commission_transactions.count({
          where: {
            order_id: null
          }
        })
      ]);

      return {
        data: withdrawals.map(w => this.formatWithdrawalResponse(w)),
        pagination: {
          total,
          currentPage: page,
          limit,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('[AffiliateWithdrawalService] Get withdrawals error:', error);
      throw error;
    }
  }

  private static formatWithdrawalResponse(withdrawal: any): WithdrawalTransaction {
    return {
      id: withdrawal.id,
      amount: Number(withdrawal.amount || 0),
      created_at: withdrawal.created_at,
      updated_at: withdrawal.updated_at,
      status: withdrawal.status || 'PENDING',
      affiliate_profile: withdrawal.affiliate_profiles ? {
        id: withdrawal.affiliate_profiles.id,
        user: withdrawal.affiliate_profiles.users ? {
          id: withdrawal.affiliate_profiles.users.id,
          email: withdrawal.affiliate_profiles.users.email,
          first_name: withdrawal.affiliate_profiles.users.first_name,
          last_name: withdrawal.affiliate_profiles.users.last_name,
          phone: withdrawal.affiliate_profiles.users.phone
        } : undefined
      } : undefined
    };
  }

  static async rejectWithdrawal(withdrawalId: string, reason: string) {
    try {
      return await prisma.$transaction(async (tx) => {
        const withdrawal = await tx.commission_transactions.findFirst({
          where: {
            id: withdrawalId,
            order_id: null,
            status: 'PENDING'
          },
          include: {
            affiliate_profiles: true
          }
        });

        if (!withdrawal) {
          throw new Error('Withdrawal not found or not in pending status');
        }

        const refundAmount = Math.abs(Number(withdrawal.amount || 0));

        // Mettre à jour le statut
        await tx.commission_transactions.update({
          where: { id: withdrawalId },
          data: {
            status: 'REJECTED',
            updated_at: new Date()
          }
        });

        // Rembourser le montant
        if (!withdrawal.affiliate_id) {
          throw new Error('Invalid affiliate ID');
        }

        await tx.affiliate_profiles.update({
          where: { id: withdrawal.affiliate_id },
          data: {
            commission_balance: {
              increment: refundAmount
            },
            updated_at: new Date()
          }
        });

        // Notification
        if (withdrawal.affiliate_profiles?.user_id) {
          await NotificationService.sendNotification(
            withdrawal.affiliate_profiles.user_id,
            NotificationType.WITHDRAWAL_REJECTED,
            {
              amount: refundAmount,
              reason
            }
          );
        }

        return { message: 'Withdrawal rejected successfully' };
      });
    } catch (error) {
      console.error('[AffiliateWithdrawalService] Reject withdrawal error:', error);
      throw error;
    }
  }

  static async approveWithdrawal(withdrawalId: string) {
    try {
      return await prisma.$transaction(async (tx) => {
        const withdrawal = await tx.commission_transactions.findFirst({
          where: {
            id: withdrawalId,
            order_id: null,
            status: 'PENDING'
          },
          include: {
            affiliate_profiles: true
          }
        });

        if (!withdrawal) {
          throw new Error('Withdrawal not found or not in pending status');
        }

        await tx.commission_transactions.update({
          where: { id: withdrawalId },
          data: {
            status: 'APPROVED',
            updated_at: new Date()
          }
        });

        // Notification
        if (withdrawal.affiliate_profiles?.user_id) {
          await NotificationService.sendNotification(
            withdrawal.affiliate_profiles.user_id,
            NotificationType.WITHDRAWAL_PROCESSED,
            {
              amount: Math.abs(Number(withdrawal.amount || 0)),
              transactionId: withdrawal.id
            }
          );
        }

        return { message: 'Withdrawal approved successfully' };
      });
    } catch (error) {
      console.error('[AffiliateWithdrawalService] Approve withdrawal error:', error);
      throw error;
    }
  }

  static async getPendingWithdrawals(pagination: PaginationParams) {
    const { page = 1, limit = 10 } = pagination;
    const skip = (page - 1) * limit;

    try {
      const [withdrawals, total] = await Promise.all([
        prisma.commission_transactions.findMany({
          skip,
          take: limit,
          where: {
            order_id: null,
            status: 'PENDING'
          },
          include: {
            affiliate_profiles: {
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
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        }),
        prisma.commission_transactions.count({
          where: {
            order_id: null,
            status: 'PENDING'
          }
        })
      ]);

      return {
        data: withdrawals.map(w => this.formatWithdrawalResponse(w)),
        pagination: {
          total,
          currentPage: page,
          limit,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('[AffiliateWithdrawalService] Get pending withdrawals error:', error);
      throw error;
    }
  }
}