import express, { Request, Response, NextFunction } from 'express';
import { AdminController } from '../controllers/admin.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { AdminService } from '../services/admin.service';
import { ServiceManagementController } from '../controllers/admin/serviceManagement.controller';
import { validatePriceData } from '../middleware/priceValidation.middleware';
import { order_status } from '@prisma/client';  // Correction ici

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Routes de gestion des commandes
router.get(
  '/orders',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;
      const status = req.query.status as order_status | undefined;  // Correction ici
      const sortField = req.query.sort_field as string || 'createdAt';
      const sortOrder = (req.query.sort_order as 'asc' | 'desc') || 'desc';

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
          totalPages: result.pages
        }
      });
    } catch (error) {
      console.error('Error handling orders request:', error);
      res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: 'Failed to fetch orders'
      });
    }
  })
);

router.get(
  '/orders/by-status',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(AdminController.getOrdersByStatus)
);

// Route pour créer une commande au nom d'un client
router.post(
  '/orders/create-for-customer',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.createOrderForCustomer(req, res);
  })
);

// Routes statistiques et dashboard
router.get(
  '/statistics',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    const stats = await AdminService.getStatistics();
    // S'assurer que les données sont dans le bon format
    res.json({
      success: true,
      data: {
        totalRevenue: Number(stats.totalRevenue || 0),
        totalOrders: Number(stats.totalOrders || 0),
        totalCustomers: Number(stats.totalCustomers || 0),
        recentOrders: stats.recentOrders || [],
        ordersByStatus: stats.ordersByStatus || {}
      }
    });
  })
);

router.get(
  '/revenue-chart',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    const data = await AdminService.getRevenueChartData();
    // Utiliser la structure correcte du type RevenueChartData
    res.json({
      success: true,
      data: {
        labels: data.labels,
        data: data.data
      }
    });
  })
);

router.get(
  '/revenue',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    const stats = await AdminService.getStatistics();
    res.json({ 
      success: true, 
      data: stats.totalRevenue 
    });
  })
);

router.get(
  '/customers',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    const stats = await AdminService.getStatistics();
    res.json({ 
      success: true, 
      data: stats.totalCustomers 
    });
  })
);

// Routes super admin
router.post(
  '/configure-commissions',
  authorizeRoles(['SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.configureCommissions(req, res);
  })
);

router.post(
  '/configure-rewards',
  authorizeRoles(['SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.configureRewards(req, res);
  })
);

// Routes gestion des services et articles
router.post(
  '/create-service',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.createService(req, res);
  })
);

router.post(
  '/create-article',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.createArticle(req, res);
  })
);

router.get(
  '/services',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.getAllServices(req, res);
  })
);

router.get(
  '/articles',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.getAllArticles(req, res);
  })
);

router.patch(
  '/services/:serviceId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.updateService(req, res);
  })
);

router.patch(
  '/articles/:articleId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.updateArticle(req, res);
  })
);

router.patch(
  '/affiliates/:affiliateId/status',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.updateAffiliateStatus(req, res);
  })
);

router.delete(
  '/services/:serviceId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.deleteService(req, res);
  })
);

router.delete(
  '/articles/:articleId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.deleteArticle(req, res);
  })
);

// Routes de gestion des services
router.get(
  '/services/configuration',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(ServiceManagementController.getServiceConfiguration)
);

router.put(
  '/articles/:articleId/services',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  validatePriceData as express.RequestHandler,
  asyncHandler(ServiceManagementController.updateArticleServices)
);

export default router;
