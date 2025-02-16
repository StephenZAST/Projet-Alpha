import express from 'express';
import { OrderController } from '../controllers/order.controller/index';
import { FlashOrderController } from '../controllers/order.controller/flashOrder.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { validateOrder } from '../middleware/validators';
import { validateCreateFlashOrder, validateCompleteFlashOrder } from '../middleware/flashOrderValidator';
import { asyncHandler } from '../utils/asyncHandler';

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

// Regrouper les routes flash en premier pour éviter les conflits
router.route('/flash')
  .post(
    authenticateToken,
    validateCreateFlashOrder,
    asyncHandler(FlashOrderController.createFlashOrder)
  )
  // Corriger la méthode ici
  .get(
    authenticateToken,
    authorizeRoles(['ADMIN']),
    asyncHandler(FlashOrderController.getDraftFlashOrders)  // Utiliser getDraftFlashOrders au lieu de getAllFlashOrders
  );

// Route spécifique pour les commandes flash en DRAFT
router.get(
  '/flash/draft',
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN', 'MANAGER']), // Ajouter plus de rôles si nécessaire
  asyncHandler(FlashOrderController.getDraftFlashOrders)
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
router.post(
  '/flash',
  authenticateToken,
  validateCreateFlashOrder,
  asyncHandler(FlashOrderController.createFlashOrder)
);

router.get(
  '/flash/pending',
  authenticateToken,
  authorizeRoles(['ADMIN', 'DELIVERY']),
  asyncHandler(FlashOrderController.getAllPendingOrders)
);

router.patch(
  '/flash/:orderId/complete',
  authenticateToken,
  authorizeRoles(['ADMIN', 'DELIVERY']),
  validateCompleteFlashOrder,
  asyncHandler(FlashOrderController.completeFlashOrder)
);

// Routes commande flash
router.post(
  '/flash',
  validateCreateFlashOrder,
  asyncHandler(FlashOrderController.createFlashOrder)
);

// Routes admin et livreur pour les commandes flash
router.get(
  '/flash/pending',
  authorizeRoles(['ADMIN', 'DELIVERY']),
  asyncHandler(FlashOrderController.getAllPendingOrders)
);

router.patch(
  '/flash/:orderId/complete',
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
