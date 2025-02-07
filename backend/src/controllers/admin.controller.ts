import { Request, Response } from 'express';
import { AdminService } from '../services/admin.service';
import { AdminCreateOrderDTO, OrderStatus } from '../models/types';
import supabase from '../config/database';

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

  static async createOrderForCustomer(req: Request, res: Response) {
    try {
      const adminId = req.user?.id;
      const userRole = req.user?.role;

      if (!adminId || !userRole || !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized: Only administrators can create orders for customers'
        });
      }

      const orderData: AdminCreateOrderDTO = {
        ...req.body,
        createdBy: adminId
      };

      console.log('[AdminController] Creating order for customer:', orderData.customerId);

      const order = await AdminService.createOrderForCustomer(orderData);

      return res.status(201).json({
        success: true,
        data: order,
        message: 'Order created successfully'
      });

    } catch (error) {
      console.error('[AdminController] Error creating order:', error);
      const status = (error as Error).message.includes('not found') ? 404 : 500;
      return res.status(status).json({
        success: false,
        message: (error as Error).message || 'Failed to create order',
        error: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }
  }

  static async getAllOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;
      
      // Correction du typage pour status
      const status: string | undefined = req.query.status as string | undefined;
      
      const sortQuery = (req.query.sort as string) || 'createdAt:desc';
      const [sortField, sortOrder] = sortQuery.split(':');

      const result = await AdminService.getAllOrders({
        page,
        limit,
        status: status || undefined, // Si status est une chaîne vide ou null, on renvoie undefined
        sortField: sortField || 'createdAt',
        sortOrder: sortOrder || 'desc'
      });

      return res.json({
        success: true,
        data: result.data,
        pagination: {
          total: result.total,
          page,
          limit,
          totalPages: result.totalPages
        }
      });
    } catch (error) {
      console.error('[AdminController] Error fetching orders:', error);
      res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: 'Failed to fetch orders'
      });
    }
  }

  static async getOrdersByStatus(req: Request, res: Response) {
    try {
      const { data, error } = await supabase
        .from('orders')
        .select('*')
        .then(result => {
          if (result.error) throw result.error;
          
          const counts: { [key: string]: number } = {};
          result.data?.forEach(order => {
            const status = order.status;
            counts[status] = (counts[status] || 0) + 1;
          });
          
          return {
            data: counts,
            error: null
          };
        });

      if (error) throw error;

      return res.json({
        success: true,
        data: data
      });
    } catch (error) {
      console.error('Error getting orders by status:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch orders by status'
      });
    }
  }
}
