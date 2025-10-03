import { Request, Response } from 'express';
import { PrismaClient, status } from '@prisma/client';
import { AffiliateService, AffiliateWithdrawalService } from '../services/affiliate.service/index';
import { validatePaginationParams } from '../utils/pagination';
import supabase from '../config/database';
import { INDIRECT_COMMISSION_RATE, PROFIT_MARGIN_RATE } from '../services/affiliate.service/constants';
import { NotificationSettings, AffiliateProfile } from '../models/types';

const prisma = new PrismaClient();

export class AffiliateController {
  static async getProfile(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const profile = await AffiliateService.getProfile(userId);
      if (!profile) {
        return res.status(404).json({ error: 'Profile not found' });
      }

      const recentTransactions = await prisma.commission_transactions.findMany({
        where: { affiliate_id: profile.id },
        orderBy: { created_at: 'desc' },
        take: 5
      });

      res.json({
        success: true,
        data: {
          ...profile,
          transactionsCount: recentTransactions?.length || 0,
          recentTransactions
        }
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async createProfile(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      // Vérifier si l'utilisateur a le rôle AFFILIATE
      if (req.user?.role !== 'AFFILIATE') {
        return res.status(403).json({ error: 'Only users with AFFILIATE role can create affiliate profile' });
      }

      // Vérifier si un profil existe déjà
      const existingProfile = await AffiliateService.getProfile(userId);
      if (existingProfile) {
        return res.status(409).json({ error: 'Affiliate profile already exists' });
      }

      // Créer le profil affilié
      const profile = await AffiliateService.createAffiliate({
        userId: userId,
        parentAffiliateCode: undefined // Pas de parrain pour l'auto-création
      });

      res.json({
        success: true,
        data: profile
      });
    } catch (error: any) {
      console.error('Create profile error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getLevels(req: Request, res: Response) {
    try {
      const levels = await prisma.affiliate_levels.findMany({
        orderBy: {
          minEarnings: 'asc'
        }
      });

      const formattedLevels = levels.map(level => ({
        id: level.id,
        name: level.name,
        minEarnings: Number(level.minEarnings),
        commissionRate: Number(level.commissionRate),
        description: `${level.commissionRate}% de commission sur les ventes directes`,
        createdAt: level.created_at,
        updatedAt: level.updated_at
      }));

      const additionalInfo = {
        indirectCommission: {
          rate: INDIRECT_COMMISSION_RATE * 100,
          description: `${INDIRECT_COMMISSION_RATE * 100}% de commission sur les ventes des filleuls directs`
        },
        profitMargin: {
          rate: PROFIT_MARGIN_RATE * 100,
          description: `Le bénéfice net est calculé comme ${PROFIT_MARGIN_RATE * 100}% du prix total`
        }
      };

      res.json({
        data: {
          levels: formattedLevels,
          additionalInfo
        }
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateProfile(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const { phone, notificationPreferences } = req.body;

      const preferences: NotificationSettings = {
        email: notificationPreferences?.email ?? true,
        push: notificationPreferences?.push ?? true,
        sms: notificationPreferences?.sms ?? false,
        order_updates: notificationPreferences?.order_updates ?? true,
        promotions: notificationPreferences?.promotions ?? true,
        payments: notificationPreferences?.payments ?? true,
        loyalty: notificationPreferences?.loyalty ?? true
      };
                                              
      // Mise à jour du profil affilié avec le type correct
      const profile = await AffiliateService.updateProfile(userId, {
        notificationPreferences: preferences as NotificationSettings
      });

      // Recherche des préférences existantes
      const existingPrefs = await prisma.notification_preferences.findFirst({
        where: { userId: userId }
      });

      // Mise à jour ou création des préférences
      if (existingPrefs) {
        await prisma.notification_preferences.update({
          where: { id: existingPrefs.id },
          data: preferences
        });
      } else {
        await prisma.notification_preferences.create({
          data: {
            ...preferences,
            userId: userId
          }
        });
      }

      res.json({ success: true, data: profile });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getCommissions(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const { page = 1, limit = 10 } = req.query;
      const commissions = await AffiliateService.getCommissions(
        userId,
        Number(page),
        Number(limit)
      );

      res.json({
        success: true,
        data: commissions.data.map(c => ({
          ...c,
          amount: Number(c.amount)
        })),
        pagination: commissions.pagination
      });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async requestWithdrawal(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const { amount } = req.body;
      if (!amount || amount <= 0) {
        return res.status(400).json({ error: 'Invalid amount' });
      }

      if (typeof amount !== 'number') {
        return res.status(400).json({ error: 'Amount must be a number' });
      }

      const profile = await prisma.affiliate_profiles.findUnique({
        where: {
          userId: userId
        },
        select: {
          id: true
        }
      });

      if (!profile) {
        return res.status(404).json({ error: 'Affiliate profile not found' });
      }

      const result = await AffiliateWithdrawalService.requestWithdrawal(profile.id, amount);
      res.json({
        data: {
          id: result.id,
          amount: Math.abs(result.amount.toNumber()),
          status: result.status,
          createdAt: result.created_at
        }
      });
    } catch (error: any) {
      console.error('Withdrawal request error:', error);
      res.status(error.message.includes('not found') ? 404 : 500)
        .json({ error: error.message });
    }
  }

  static async getWithdrawals(req: Request, res: Response) {
    try {
      if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const pagination = validatePaginationParams(req.query);
      const { status } = req.query;

      const withdrawals = await AffiliateWithdrawalService.getWithdrawals(
        pagination,
        status as string | undefined
      );

      res.json(withdrawals);
    } catch (error: any) {
      console.error('Get withdrawals error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getPendingWithdrawals(req: Request, res: Response) {
    try {
      if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const pagination = validatePaginationParams(req.query);
      const withdrawals = await AffiliateWithdrawalService.getWithdrawals(pagination, 'PENDING');
      res.json(withdrawals);
    } catch (error: any) {
      console.error('Get pending withdrawals error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async rejectWithdrawal(req: Request, res: Response) {
    try {
      if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const { withdrawalId } = req.params;
      const { reason } = req.body;

      if (!reason) {
        return res.status(400).json({
          error: 'Reason is required for rejection'
        });
      }

      const result = await AffiliateWithdrawalService.rejectWithdrawal(withdrawalId, reason);
      res.json({ data: result });
    } catch (error: any) {
      console.error('Reject withdrawal error:', error);
      res.status(error.message.includes('not found') ? 404 : 500)
        .json({ error: error.message });
    }
  }

  static async approveWithdrawal(req: Request, res: Response) {
    try {
      if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const { withdrawalId } = req.params;
      const result = await AffiliateWithdrawalService.approveWithdrawal(withdrawalId);
      res.json({ data: result });
    } catch (error: any) {
      console.error('Approve withdrawal error:', error);
      res.status(error.message.includes('not found') ? 404 : 500)
        .json({ error: error.message });
    }
  }

  static async getAllAffiliates(req: Request, res: Response) {
    try {
      const pagination = validatePaginationParams(req.query);
      const { status, query } = req.query;

      const affiliates = await AffiliateService.getAllAffiliates(
        pagination,
        {
          status: status as status | undefined,
          query: query as string | undefined,
        }
      );

      res.json({ data: affiliates });
    } catch (error: any) {
      console.error('Get all affiliates error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getAffiliateStats(req: Request, res: Response) {
    try {
      if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      const stats = await AffiliateService.getAffiliateStats();
      res.json({ data: stats });
    } catch (error: any) {
      console.error('Get affiliate stats error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async updateAffiliateStatus(req: Request, res: Response) {
    try {
      const { affiliateId } = req.params;
      const { status, isActive } = req.body;

      if (!status || typeof isActive !== 'boolean') {
        return res.status(400).json({
          error: 'Status and isActive are required',
          required: { status: 'string', isActive: 'boolean' },
          received: { status, isActive }
        });
      }

      const result = await AffiliateService.updateAffiliateStatus(
        affiliateId,
        status,
        isActive
      );

      res.json({ data: result });
    } catch (error: any) {
      console.error('Update affiliate status error:', error);
      res.status(error.message.includes('not found') ? 404 : 500)
        .json({ error: error.message });
    }
  }

  static async generateAffiliateCode(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const affiliateCode = await AffiliateService.generateCode(userId);
      res.json({ success: true, data: { affiliateCode } });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getReferrals(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const referrals = await AffiliateService.getReferrals(userId);
      res.json({ data: referrals });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getCurrentLevel(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const level = await AffiliateService.getCurrentLevel(userId);
      res.json({ success: true, data: level });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async createCustomerWithAffiliateCode(req: Request, res: Response) {
    try {
      const { email, password, firstName, lastName, phone, affiliateCode } = req.body;

      if (!affiliateCode || typeof affiliateCode !== 'string' || affiliateCode.includes('+')) {
        return res.status(400).json({
          error: 'Invalid affiliate code format',
          received: affiliateCode,
          hint: 'Affiliate code should not be a phone number'
        });
      }

      if (!email || !password || !firstName || !lastName || !affiliateCode) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['email', 'password', 'firstName', 'lastName', 'affiliateCode'],
          received: { email, firstName, lastName, affiliateCode: !!affiliateCode }
        });
      }

      const result = await AffiliateService.createCustomerWithAffiliateCode(
        email, password, firstName, lastName, affiliateCode, phone
      );

      res.json({ data: result });
    } catch (error: any) {
      console.error('Create customer error:', error);
      res.status(error.message === 'Affiliate code not found' ? 404 : 500)
        .json({ error: error.message });
    }
  }
}
