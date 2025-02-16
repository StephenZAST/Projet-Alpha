import { Request, Response } from 'express';
import { AffiliateService, AffiliateWithdrawalService } from '../services/affiliate.service/index';
import { validatePaginationParams } from '../utils/pagination';
import supabase from '../config/database';
import { INDIRECT_COMMISSION_RATE, PROFIT_MARGIN_RATE } from '../services/affiliate.service/constants';

export class AffiliateController {
  static async getProfile(req: Request, res: Response) {
   try {
     const userId = req.user?.id;
     if (!userId) return res.status(401).json({ error: 'Unauthorized' });

     const profile = await AffiliateService.getProfile(userId);
     res.json({
       data: profile,
       meta: {
         transactionsCount: profile.recentTransactions?.length || 0
       } 
     });
   } catch (error: any) {
     console.error('[AffiliateController] GetProfile error:', error);
     const status = error.message === 'Affiliate profile not found' ? 404 : 500;
     res.status(status).json({ error: error.message });
   }
  }

  static async getLevels(req: Request, res: Response) {
    try {
      const { data: levels, error } = await supabase
        .from('affiliate_levels')
        .select('*')
        .order('min_earnings', { ascending: true });

      if (error) throw error;

      const formattedLevels = levels.map(level => ({
        id: level.id,
        name: level.name,
        minEarnings: level.min_earnings,
        commissionRate: level.commission_rate,
        description: `${level.commission_rate}% de commission sur les ventes directes`
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
      const profile = await AffiliateService.updateProfile(userId, { phone, notificationPreferences });
      res.json({ data: profile });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getCommissions(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const pagination = validatePaginationParams(req.query);
      const commissions = await AffiliateService.getCommissions(userId, pagination);
      res.json(commissions);
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

      const { data: profile } = await supabase
        .from('affiliate_profiles')
        .select('id')
        .eq('user_id', userId)
        .single();

      if (!profile) {
        return res.status(404).json({ error: 'Affiliate profile not found' });
      }

      const result = await AffiliateWithdrawalService.requestWithdrawal(profile.id, amount);
      res.json({
        data: {
          id: result.id,
          amount: Math.abs(result.amount),
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
      // Vérifier les droits admin
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
      // Vérifier les droits admin
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
      // Vérifier les droits admin
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
      // Vérifier les droits admin
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
          status: status as string | undefined,
          query: query as string | undefined,
        }
      );
      
      res.json({ data: affiliates });
    } catch (error: any) {
      console.error('Get all affiliates error:', error);
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

      const result = await AffiliateService.generateAffiliateCode(userId);
      res.json({ data: result });
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
      res.json({ data: level });
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
