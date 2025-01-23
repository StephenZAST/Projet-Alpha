import { Request, Response } from 'express';
import { AdminService } from '../services/admin.service';
import { OrderStatus } from '../models/types';

export class AdminController {
  static async configureCommissions(req: Request, res: Response) {
    try {
      const { commissionRate, rewardPoints } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.configureCommissions(commissionRate, rewardPoints);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async configureRewards(req: Request, res: Response) {
    try {
      const { rewardPoints, rewardType } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.configureRewards(rewardPoints, rewardType);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async createService(req: Request, res: Response) {
    try {
      const { name, price, description } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.createService(name, price, description);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async createArticle(req: Request, res: Response) {
    try {
      const { name, basePrice, premiumPrice, categoryId, description } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.createArticle(name, basePrice, premiumPrice, categoryId, description);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllServices(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.getAllServices();
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllArticles(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.getAllArticles();
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateService(req: Request, res: Response) {
    try {
      const { name, price, description } = req.body;
      const serviceId = req.params.serviceId;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.updateService(serviceId, name, price, description);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateArticle(req: Request, res: Response) {
    try {
      const { name, basePrice, premiumPrice, categoryId, description } = req.body;
      const articleId = req.params.articleId;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.updateArticle(articleId, name, basePrice, premiumPrice, categoryId, description);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteService(req: Request, res: Response) {
    try {
      const serviceId = req.params.serviceId;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.deleteService(serviceId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await AdminService.deleteArticle(articleId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateAffiliateStatus(req: Request, res: Response) {
    try {
      const { affiliateId } = req.params;
      const { status, isActive } = req.body;

      if (!['PENDING', 'ACTIVE', 'SUSPENDED'].includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
      }

      const result = await AdminService.updateAffiliateStatus(affiliateId, status, isActive);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getDashboardStatistics(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const stats = await AdminService.getDashboardStatistics();
      res.json({ data: stats });
    } catch (error: any) {
      console.error('Error getting dashboard statistics:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getRevenueChartData(req: Request, res: Response) {
    try {
      console.log('[Admin Controller] Getting revenue chart data...');
      const userId = req.user?.id;
      if (!userId) {
        console.log('[Admin Controller] Unauthorized access attempt');
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const chartData = await AdminService.getRevenueChartData();
      console.log('[Admin Controller] Revenue chart data retrieved successfully');
      res.json({
        success: true,
        data: chartData
      });
    } catch (error: any) {
      console.error('[Admin Controller] Error getting revenue chart data:', error);
      res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message || 'Failed to fetch revenue chart data'
      });
    }
  }

  static async getAllOrders(req: Request, res: Response) {
    try {
      console.log('[Admin Controller] Getting all orders...');
      const userId = req.user?.id;
      if (!userId) {
        console.log('[Admin Controller] Unauthorized access attempt');
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const status = req.query.status as OrderStatus | undefined;
      const startDate = req.query.startDate ? new Date(req.query.startDate as string) : undefined;
      const endDate = req.query.endDate ? new Date(req.query.endDate as string) : undefined;

      const result = await AdminService.getAllOrders({
        page,
        limit,
        status,
        startDate,
        endDate
      });

      console.log('[Admin Controller] Orders retrieved successfully');
      res.json({
        success: true,
        data: result.data,
        pagination: {
          total: result.total,
          page,
          limit,
          totalPages: Math.ceil(result.total / limit)
        }
      });
    } catch (error: any) {
      console.error('[Admin Controller] Error getting all orders:', error);
      res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message || 'Failed to fetch orders'
      });
    }
  }
}
