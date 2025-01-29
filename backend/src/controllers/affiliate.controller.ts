import { Request, Response } from 'express';
import { AffiliateService } from '../services/affiliate.service/index';
import { validatePaginationParams } from '../utils/pagination';
import { NotificationService } from '../services/notification.service';

export class AffiliateController {
  static async getProfile(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const profile = await AffiliateService.getProfile(userId);
      res.json({ data: profile });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getLevels(req: Request, res: Response) {
    try {
      const levels = [
        {
          id: "LEVEL1",
          name: "Débutant",
          minReferrals: 0,
          maxReferrals: 9,
          commissionRate: 0.10,
          description: "10% de commission sur les ventes directes"
        },
        {
          id: "LEVEL2",
          name: "Intermédiaire",
          minReferrals: 10,
          maxReferrals: 19,
          commissionRate: 0.15,
          description: "15% de commission sur les ventes directes"
        },
        {
          id: "LEVEL3",
          name: "Expert",
          minReferrals: 20,
          maxReferrals: null,
          commissionRate: 0.20,
          description: "20% de commission sur les ventes directes"
        }
      ];

      const additionalInfo = {
        indirectCommission: {
          rate: 0.10,
          description: "10% de commission sur les ventes des filleuls directs"
        },
        profitMargin: {
          rate: 0.40,
          description: "Le bénéfice net est calculé comme 40% du prix total"
        }
      };

      res.json({
        data: {
          levels,
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

      const result = await AffiliateService.requestWithdrawal(userId, amount);
      res.json({ data: result });
    } catch (error: any) {
      console.error('Withdrawal request error:', error);
      res.status(error.message.includes('not found') ? 404 : 500)
        .json({ error: error.message });
    }
  }

  static async getWithdrawals(req: Request, res: Response) {
    try {
      const pagination = validatePaginationParams(req.query);
      const { status } = req.query;
      
      const withdrawals = await AffiliateService.getWithdrawals(
        pagination,
        status as string | undefined
      );
      
      res.json({ data: withdrawals });
    } catch (error: any) {
      console.error('Get withdrawals error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async rejectWithdrawal(req: Request, res: Response) {
    try {
      const { withdrawalId } = req.params;
      const { reason } = req.body;

      if (!reason) {
        return res.status(400).json({
          error: 'Reason is required for rejection'
        });
      }

      const result = await AffiliateService.rejectWithdrawal(withdrawalId, reason);
      res.json({ data: result });
    } catch (error: any) {
      console.error('Reject withdrawal error:', error);
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
