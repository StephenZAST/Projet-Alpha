/**
 * 💰 Contrôleur: Gestion Prix & Paiement
 * Endpoints pour récupérer et mettre à jour les prix/paiements
 */

import { Request, Response } from 'express';
import { OrderPaymentManagementService } from '../services/orderPaymentManagement.service';
import { OrderPricingDTO } from '../models/orderPricing.types';

export class OrderPricingController {
  /**
   * GET /api/orders/:orderId/pricing
   * Récupérer les infos de prix/paiement d'une commande
   */
  static async getPricing(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;

      if (!orderId) {
        res.status(400).json({
          success: false,
          error: 'Order ID is required'
        });
        return;
      }

      const result = await OrderPaymentManagementService.getPricing(orderId);

      res.json({
        success: true,
        data: result
      });
    } catch (error: any) {
      console.error('[OrderPricingController] Error in getPricing:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to get pricing'
      });
    }
  }

  /**
   * PATCH /api/orders/:orderId/pricing
   * Mettre à jour le prix manuel et/ou le statut de paiement
   */
  static async updatePricing(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;
      const adminId = (req as any).user?.id;
      const dto: OrderPricingDTO = req.body;

      if (!orderId) {
        res.status(400).json({
          success: false,
          error: 'Order ID is required'
        });
        return;
      }

      if (!adminId) {
        res.status(401).json({
          success: false,
          error: 'Unauthorized - Admin ID required'
        });
        return;
      }

      // Valider les données
      if (dto.manual_price !== undefined && dto.manual_price < 0) {
        res.status(400).json({
          success: false,
          error: 'Manual price cannot be negative'
        });
        return;
      }

      const result = await OrderPaymentManagementService.updatePricing(orderId, adminId, dto);

      res.json({
        success: true,
        data: result
      });
    } catch (error: any) {
      console.error('[OrderPricingController] Error in updatePricing:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to update pricing'
      });
    }
  }

  /**
   * DELETE /api/orders/:orderId/pricing/manual-price
   * Réinitialiser le prix manuel (revenir au prix original)
   */
  static async resetManualPrice(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;
      const adminId = (req as any).user?.id;

      if (!orderId) {
        res.status(400).json({
          success: false,
          error: 'Order ID is required'
        });
        return;
      }

      if (!adminId) {
        res.status(401).json({
          success: false,
          error: 'Unauthorized - Admin ID required'
        });
        return;
      }

      const result = await OrderPaymentManagementService.resetManualPrice(orderId, adminId);

      res.json({
        success: true,
        data: result,
        message: 'Manual price reset successfully'
      });
    } catch (error: any) {
      console.error('[OrderPricingController] Error in resetManualPrice:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to reset manual price'
      });
    }
  }

  /**
   * POST /api/orders/:orderId/pricing/mark-paid
   * Marquer une commande comme payée
   */
  static async markAsPaid(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;
      const adminId = (req as any).user?.id;
      const { reason } = req.body;

      if (!orderId) {
        res.status(400).json({
          success: false,
          error: 'Order ID is required'
        });
        return;
      }

      if (!adminId) {
        res.status(401).json({
          success: false,
          error: 'Unauthorized - Admin ID required'
        });
        return;
      }

      const result = await OrderPaymentManagementService.markAsPaid(orderId, adminId, reason);

      res.json({
        success: true,
        data: result,
        message: 'Order marked as paid'
      });
    } catch (error: any) {
      console.error('[OrderPricingController] Error in markAsPaid:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to mark as paid'
      });
    }
  }

  /**
   * POST /api/orders/:orderId/pricing/mark-unpaid
   * Marquer une commande comme non payée
   */
  static async markAsUnpaid(req: Request, res: Response): Promise<void> {
    try {
      const { orderId } = req.params;
      const adminId = (req as any).user?.id;
      const { reason } = req.body;

      if (!orderId) {
        res.status(400).json({
          success: false,
          error: 'Order ID is required'
        });
        return;
      }

      if (!adminId) {
        res.status(401).json({
          success: false,
          error: 'Unauthorized - Admin ID required'
        });
        return;
      }

      const result = await OrderPaymentManagementService.markAsUnpaid(orderId, adminId, reason);

      res.json({
        success: true,
        data: result,
        message: 'Order marked as unpaid'
      });
    } catch (error: any) {
      console.error('[OrderPricingController] Error in markAsUnpaid:', error);
      res.status(400).json({
        success: false,
        error: error.message || 'Failed to mark as unpaid'
      });
    }
  }
}
