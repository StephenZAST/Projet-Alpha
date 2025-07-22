import express from 'express';
import { OrderController } from '../controllers/order.controller/index';
import { FlashOrderController } from '../controllers/order.controller/flashOrder.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { validateOrder } from '../middleware/validators';
import { validateCreateFlashOrder, validateCompleteFlashOrder } from '../middleware/flashOrderValidator';
import { asyncHandler } from '../utils/asyncHandler';
import { AdminService } from '../services/admin.service';
import { order_status } from '@prisma/client'; // Ajout de l'import

const router = express.Router();

// Ajouter des logs pour le debugging
router.use((req, res, next) => {
  console.log('Order Route Request:', {
    path: req.path,
    method: req.method,
    headers: req.headers,
    body: req.body,
    user: req.user
  });
  next();
});

// Protection des routes avec authentification
router.use(authenticateToken);

// Ajouter cette route AVANT les autres routes
router.get(
  '/', // Correction ici
  authenticateToken,
  asyncHandler(async (req, res) => {
    try {

      // Paramètres de base
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;
      const status = req.query.status ? (req.query.status as string).toUpperCase() as order_status : undefined;
      const sortField = req.query.sortField as string || 'createdAt';
      const sortOrder = (req.query.sortOrder as 'asc' | 'desc') || 'desc';
      const startDate = req.query.startDate as string | undefined;
      const endDate = req.query.endDate as string | undefined;
      const paymentMethod = req.query.paymentMethod as string | undefined;
      const serviceTypeId = req.query.serviceTypeId as string | undefined;
      const minAmount = req.query.minAmount as string | undefined;
      const maxAmount = req.query.maxAmount as string | undefined;
      const isFlashOrder = req.query.isFlashOrder !== undefined ? req.query.isFlashOrder === 'true' : undefined;
      const query = req.query.query as string | undefined;

      // Nouveaux paramètres avancés
      // const paymentStatus = req.query.paymentStatus as string | undefined; // supprimé
      const affiliateCode = req.query.affiliateCode as string | undefined;
      const recurrenceType = req.query.recurrenceType as string | undefined;
      const city = req.query.city as string | undefined;
      const postalCode = req.query.postalCode as string | undefined;
      const collectionDateStart = req.query.collectionDateStart as string | undefined;
      const collectionDateEnd = req.query.collectionDateEnd as string | undefined;
      const deliveryDateStart = req.query.deliveryDateStart as string | undefined;
      const deliveryDateEnd = req.query.deliveryDateEnd as string | undefined;
      const isRecurring = req.query.isRecurring !== undefined ? req.query.isRecurring === 'true' : undefined;
      const sortByNextRecurrenceDate = req.query.sortByNextRecurrenceDate as 'asc' | 'desc' | undefined;

      const result = await AdminService.getAllOrders(page, limit, {
        status,
        sortField,
        sortOrder,
        startDate,
        endDate,
        paymentMethod,
        serviceTypeId,
        minAmount,
        maxAmount,
        isFlashOrder,
        query,
        affiliateCode,
        recurrenceType,
        city,
        postalCode,
        collectionDateStart,
        collectionDateEnd,
        deliveryDateStart,
        deliveryDateEnd,
        isRecurring,
        sortByNextRecurrenceDate
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
      console.error('Error fetching orders:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to fetch orders'
      });
    }
  })
);

// Regrouper les routes flash en premier pour éviter les conflits
router.route('/flash')
  .post(
    authenticateToken,
    validateCreateFlashOrder,
    asyncHandler(FlashOrderController.createFlashOrder)
  )
  .get(
    authenticateToken,
    authorizeRoles(['ADMIN']),
    asyncHandler(FlashOrderController.getAllPendingOrders)  // Changé pour utiliser une méthode existante
  );

// Route spécifique pour les commandes flash en DRAFT
router.get(
  '/flash/draft',
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(FlashOrderController.getAllPendingOrders)  // Changé pour utiliser une méthode existante
);

// Routes commande standard
router.post(
  '/',
  validateOrder,
  asyncHandler(OrderController.createOrder)
);

router.get(
  '/my-orders',
  asyncHandler(OrderController.getUserOrders)
);

// Placer ces routes AVANT la route '/:orderId'
router.get('/by-status', asyncHandler(OrderController.getOrdersByStatus));
router.get('/recent', asyncHandler(OrderController.getRecentOrders));

router.get(
  '/:orderId',
  asyncHandler(OrderController.getOrderDetails)
);

router.get(
  '/:orderId/invoice',
  asyncHandler(OrderController.generateInvoice)
);

router.post(
  '/calculate-total',
  asyncHandler(OrderController.calculateTotal)
);

// Routes pour les commandes flash
router.patch(
  '/flash/:orderId/complete',
  authenticateToken,
  authorizeRoles(['ADMIN', 'DELIVERY']),
  validateCompleteFlashOrder,
  asyncHandler(FlashOrderController.completeFlashOrder)
);

router.patch(
  '/:orderId/status',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN', 'DELIVERY']),
  asyncHandler(OrderController.updateOrderStatus)
);

router.get(
  '/all',
  authorizeRoles(['ADMIN']),
  asyncHandler(OrderController.getAllOrders)
);

router.delete(
  '/:orderId',
  authorizeRoles(['ADMIN']),
  asyncHandler(OrderController.deleteOrder)
);

export default router;
