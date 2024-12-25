import { Request, Response } from 'express';
import { AffiliateService } from '../services/affiliate.service';
import { validatePaginationParams } from '../utils/pagination';

export class AffiliateController {
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
      console.log('Request withdrawal for user:', userId); // Debug log

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

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

  static async createAffiliate(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const { parentAffiliateCode } = req.body;
      const result = await AffiliateService.createAffiliate(userId, parentAffiliateCode);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async createCustomerWithAffiliateCode(req: Request, res: Response) {
    try {
      console.log('=== Controller: createCustomerWithAffiliateCode ===');
      console.log('Request body:', req.body);
      
      const { email, password, firstName, lastName, phone, affiliateCode } = req.body;
  
      // Validation améliorée
      if (!affiliateCode || typeof affiliateCode !== 'string' || affiliateCode.includes('+')) {
        return res.status(400).json({ 
          error: 'Invalid affiliate code format',
          received: affiliateCode,
          hint: 'Affiliate code should not be a phone number'
        });
      }
  
      // Validation des données
      if (!email || !password || !firstName || !lastName || !affiliateCode) {
        console.error('Missing required fields:', { email, firstName, lastName, affiliateCode });
        return res.status(400).json({ 
          error: 'Missing required fields',
          required: ['email', 'password', 'firstName', 'lastName', 'affiliateCode'],
          received: { email, firstName, lastName, affiliateCode: !!affiliateCode }
        });
      }
  
      const result = await AffiliateService.createCustomerWithAffiliateCode(
        email, password, firstName, lastName, affiliateCode, phone
      );
      
      console.log('Customer created successfully:', {
        userId: result.id,
        email: result.email
      });
  
      res.json({ data: result });
    } catch (error: any) {
      console.error('Controller error:', error);
      res.status(error.message === 'Affiliate code not found' ? 404 : 500)
        .json({ error: error.message });
    }
  }

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

  static async getLevels(req: Request, res: Response) {
    try {
      const levels = await AffiliateService.getLevels();
      res.json({ data: levels });
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
}
