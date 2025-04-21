import { Request, Response } from 'express';
import { AdminService } from '../services/admin.service';
import { AdminCreateOrderDTO, OrderStatus } from '../models/types'; 
import supabase from '../config/database';
import prisma from '../config/prisma';

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
      const { name, basePrice, categoryId, description } = req.body;
      const result = await AdminService.createArticle(
        name,
        basePrice,
        categoryId,
        description
      );
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
      const articleId = req.params.articleId;
      const result = await AdminService.updateArticle(articleId, req.body);
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

      const result = await AdminService.updateAffiliateStatus(affiliateId, status);
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

      const inputData = req.body;
      if (!inputData.serviceTypeId || !inputData.addressId) {
        return res.status(400).json({
          success: false,
          message: 'serviceTypeId and addressId are required'
        });
      }

      const orderData = {
        items: inputData.items,
        serviceTypeId: inputData.serviceTypeId,
        addressId: inputData.addressId,
        collectionDate: inputData.collectionDate ? new Date(inputData.collectionDate) : undefined,
        deliveryDate: inputData.deliveryDate ? new Date(inputData.deliveryDate) : undefined
      };

      console.log('[AdminController] Creating order for customer:', inputData.customerId);

      const order = await AdminService.createOrderForCustomer(inputData.customerId, orderData);

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
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;
      const status = req.query.status as OrderStatus | undefined;
      const sortField = req.query.sort_field as string;
      const sortOrder = (req.query.sort_order as 'asc' | 'desc');

      const result = await AdminService.getAllOrders(page, limit, {
        status,
        sortField,
        sortOrder
      });

      res.json({
        success: true,
        data: result.orders,
        pagination: {
          total: result.total,
          currentPage: page,
          limit,
          totalPages: Math.ceil(result.total / limit)
        }
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch orders' });
    }
  }

  static async getOrdersByStatus(req: Request, res: Response) {
    try {
      const orders = await prisma.orders.findMany();
      const counts: { [key: string]: number } = {};
      orders.forEach(order => {
        const status = order.status || 'UNKNOWN';
        counts[status] = (counts[status] || 0) + 1;
      });
      const data = counts;

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
