/**
 * 💰 Contrôleur: Gestion Prix & Paiement
 * Endpoints pour récupérer et mettre à jour les prix/paiements
 * 
 * ⚠️ IMPORTANT : Lors de la mise à jour du prix manuel, ce contrôleur
 * déclenche automatiquement la réattribution des points de fidélité
 * et des commissions affiliés via OrderPriceAdjustmentService
 */

import { Request, Response } from 'express';
import { OrderPaymentManagementService } from '../services/orderPaymentManagement.service';
import { OrderPriceAdjustmentService } from '../services/order.service/orderPriceAdjustment.service';
import { OrderPricingDTO } from '../models/orderPricing.types';
import prisma from '../config/prisma';

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
   * 
   * ⚠️ DÉCLENCHE AUTOMATIQUEMENT :
   * - Réattribution des points de fidélité
   * - Réajustement des commissions affiliés
   * - Enregistrement d'un log d'audit
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

      // Récupérer l'ancien prix manuel avant la mise à jour
      const oldPricing = await prisma.order_pricing.findUnique({
        where: { order_id: orderId }
      });
      const oldManualPrice = oldPricing?.manual_price ? Number(oldPricing.manual_price) : null;

      // Mettre à jour le pricing
      const result = await OrderPaymentManagementService.updatePricing(orderId, adminId, dto);

      // Si le prix manuel a changé, réajuster les points et commissions
      if (dto.manual_price !== undefined && dto.manual_price !== oldManualPrice) {
        try {
          console.log(
            `[OrderPricingController] Price change detected - triggering loyalty/commission adjustment`
          );
          
          const adjustment = await OrderPriceAdjustmentService.reprocessLoyaltyAndCommissions(
            orderId,
            oldManualPrice,
            dto.manual_price
          );
          
          res.json({
            success: true,
            data: result,
            priceAdjustment: adjustment
          });
        } catch (adjustmentError: any) {
          console.error('[OrderPricingController] Error adjusting loyalty/commissions:', adjustmentError);
          // Retourner quand même le résultat de la mise à jour du pricing
          res.json({
            success: true,
            data: result,
            warning: `Price updated but adjustment failed: ${adjustmentError.message}`
          });
        }
      } else {
        res.json({
          success: true,
          data: result
        });
      }
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
   * 
   * ⚠️ DÉCLENCHE AUTOMATIQUEMENT :
   * - Réattribution des points de fidélité (ajustement inverse)
   * - Réajustement des commissions affiliés (ajustement inverse)
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

      // Récupérer l'ancien prix manuel avant la suppression
      const oldPricing = await prisma.order_pricing.findUnique({
        where: { order_id: orderId }
      });
      const oldManualPrice = oldPricing?.manual_price ? Number(oldPricing.manual_price) : null;

      // Réinitialiser le prix manuel
      const result = await OrderPaymentManagementService.resetManualPrice(orderId, adminId);

      // Déclencher l'ajustement inverse (retour au prix originel)
      if (oldManualPrice !== null) {
        try {
          console.log(
            `[OrderPricingController] Manual price reset detected - triggering inverse loyalty/commission adjustment`
          );
          
          const adjustment = await OrderPriceAdjustmentService.reprocessLoyaltyAndCommissions(
            orderId,
            oldManualPrice,
            null  // null = retour au prix originel
          );
          
          res.json({
            success: true,
            data: result,
            message: 'Manual price reset successfully',
            priceAdjustment: adjustment
          });
        } catch (adjustmentError: any) {
          console.error('[OrderPricingController] Error adjusting loyalty/commissions:', adjustmentError);
          // Retourner quand même le résultat de la réinitialisation
          res.json({
            success: true,
            data: result,
            message: 'Manual price reset successfully',
            warning: `Price reset but adjustment failed: ${adjustmentError.message}`
          });
        }
      } else {
        res.json({
          success: true,
          data: result,
          message: 'Manual price reset successfully (no manual price was set)'
        });
      }
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
