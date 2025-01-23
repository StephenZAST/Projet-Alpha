import express, { Request, Response, NextFunction } from 'express';
import { AdminController } from '../controllers/admin.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { AdminService } from '../services/admin.service';

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Route pour obtenir toutes les commandes avec pagination et filtres
router.get(
  '/orders',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.getAllOrders(req, res);
  })
);

// Routes statistiques et dashboard
router.get(
  '/statistics',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.getDashboardStatistics(req, res);
  })
);
router.get(
  '/revenue-chart',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await AdminController.getRevenueChartData(req, res);
  })
);

router.get(
  '/total-revenue',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    const revenue = await AdminService.getTotalRevenue();
    res.json({ 
      success: true, 
      data: revenue 
    });
  })
);

router.get(
  '/total-customers',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    const customers = await AdminService.getTotalCustomers();
    res.json({ 
      success: true, 
      data: customers 
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

export default router;
