/**
 * 💰 Routes: Gestion Prix & Paiement
 * Endpoints pour les prix manuels et statuts de paiement
 */

import express from 'express';
import { OrderPricingController } from '../controllers/orderPricing.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = express.Router();

/**
 * GET /api/orders/:orderId/pricing
 * Récupérer les infos de prix/paiement
 * Accessible à: Tous les utilisateurs authentifiés
 */
router.get(
  '/:orderId/pricing',
  authMiddleware,
  OrderPricingController.getPricing
);

/**
 * PATCH /api/orders/:orderId/pricing
 * Mettre à jour le prix manuel et/ou le statut de paiement
 * Accessible à: ADMIN, SUPER_ADMIN
 */
router.patch(
  '/:orderId/pricing',
  authMiddleware,
  OrderPricingController.updatePricing
);

/**
 * DELETE /api/orders/:orderId/pricing/manual-price
 * Réinitialiser le prix manuel
 * Accessible à: ADMIN, SUPER_ADMIN
 */
router.delete(
  '/:orderId/pricing/manual-price',
  authMiddleware,
  OrderPricingController.resetManualPrice
);

/**
 * POST /api/orders/:orderId/pricing/mark-paid
 * Marquer une commande comme payée
 * Accessible à: ADMIN, SUPER_ADMIN
 */
router.post(
  '/:orderId/pricing/mark-paid',
  authMiddleware,
  OrderPricingController.markAsPaid
);

/**
 * POST /api/orders/:orderId/pricing/mark-unpaid
 * Marquer une commande comme non payée
 * Accessible à: ADMIN, SUPER_ADMIN
 */
router.post(
  '/:orderId/pricing/mark-unpaid',
  authMiddleware,
  OrderPricingController.markAsUnpaid
);

export default router;
