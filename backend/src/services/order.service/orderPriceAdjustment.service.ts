/**
 * 💰 Service: Ajustement des Prix, Points et Commissions
 * 
 * Gère la réattribution automatique des points de fidélité et des commissions
 * affiliés lors d'un changement du prix manuel d'une commande.
 * 
 * Cas gérés :
 * 1. Ajout d'un prix manuel (passage du prix originel au prix manuel)
 * 2. Modification du prix manuel
 * 3. Suppression du prix manuel (retour au prix originel)
 * 
 * ⚠️ SÉCURITÉ : Empêche les ajustements après paiement
 */

import { PrismaClient, Prisma } from '@prisma/client';
import { LoyaltyService } from '../loyalty.service';
import { AffiliateCommissionService } from '../affiliate.service/affiliateCommission.service';
import { getEffectiveOrderTotal, getOriginalOrderTotal } from '../../controllers/order.controller/shared';

const prisma = new PrismaClient();

export class OrderPriceAdjustmentService {
  /**
   * Réajuste les points de fidélité et les commissions affiliés
   * lors d'un changement du prix manuel
   * 
   * @param orderId - ID de la commande
   * @param oldManualPrice - Ancien prix manuel (null si aucun)
   * @param newManualPrice - Nouveau prix manuel (null si suppression)
   * @returns Résultat de l'ajustement avec détails
   */
  static async reprocessLoyaltyAndCommissions(
    orderId: string,
    oldManualPrice: number | null,
    newManualPrice: number | null
  ): Promise<{
    success: boolean;
    adjustments: {
      loyaltyAdjustment: number;
      commissionAdjustment: number;
    };
    message: string;
  }> {
    try {
      // Récupérer la commande complète
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        include: {
          user: true,
          pricing: true,
          commission_transactions: true
        }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      // ⚠️ SÉCURITÉ : Vérifier si la commande a déjà été payée
      if (order.pricing?.is_paid) {
        throw new Error(
          'Cannot adjust price after payment. Please contact support to process a refund or adjustment.'
        );
      }

      const originalPrice = getOriginalOrderTotal(order);
      const oldEffectivePrice = oldManualPrice ?? originalPrice;
      const newEffectivePrice = newManualPrice ?? originalPrice;

      // Si les prix effectifs sont identiques, pas besoin d'ajustement
      if (oldEffectivePrice === newEffectivePrice) {
        console.log(
          `[OrderPriceAdjustmentService] No adjustment needed for order ${orderId} - prices are identical`
        );
        return {
          success: true,
          adjustments: { loyaltyAdjustment: 0, commissionAdjustment: 0 },
          message: 'No adjustment needed - prices are identical'
        };
      }

      // Calculer la différence de prix
      const priceDifference = newEffectivePrice - oldEffectivePrice;

      console.log(
        `[OrderPriceAdjustmentService] Processing adjustment for order ${orderId}:
        Old Effective Price: ${oldEffectivePrice}
        New Effective Price: ${newEffectivePrice}
        Price Difference: ${priceDifference}`
      );

      // Ajuster les points de fidélité
      const loyaltyAdjustment = await this.adjustLoyaltyPoints(
        order.userId,
        priceDifference,
        orderId
      );

      // Ajuster les commissions affiliés
      const commissionAdjustment = await this.adjustAffiliateCommissions(
        orderId,
        priceDifference,
        order.affiliateCode
      );

      // Enregistrer l'ajustement dans un log d'audit
      await this.logPriceAdjustment(
        orderId,
        oldManualPrice,
        newManualPrice,
        loyaltyAdjustment,
        commissionAdjustment
      );

      return {
        success: true,
        adjustments: {
          loyaltyAdjustment,
          commissionAdjustment
        },
        message: `Price adjusted successfully. Loyalty: ${loyaltyAdjustment} points, Commission: ${commissionAdjustment} FCFA`
      };
    } catch (error) {
      console.error('[OrderPriceAdjustmentService] Error reprocessing loyalty and commissions:', error);
      throw error;
    }
  }

  /**
   * Ajuste les points de fidélité en fonction de la différence de prix
   * 
   * @param userId - ID de l'utilisateur
   * @param priceDifference - Différence de prix (positif = augmentation, négatif = diminution)
   * @param orderId - ID de la commande (pour la traçabilité)
   * @returns Nombre de points ajustés (positif ou négatif)
   */
  private static async adjustLoyaltyPoints(
    userId: string,
    priceDifference: number,
    orderId: string
  ): Promise<number> {
    try {
      const pointsMultiplier = Number(process.env.POINTS_MULTIPLIER || 0.01);
      const pointsAdjustment = Math.floor(priceDifference * pointsMultiplier);

      if (pointsAdjustment === 0) {
        console.log(
          `[OrderPriceAdjustmentService] No loyalty adjustment needed for order ${orderId} - adjustment is 0`
        );
        return 0;
      }

      if (pointsAdjustment > 0) {
        // Ajouter des points
        console.log(
          `[OrderPriceAdjustmentService] Adding ${pointsAdjustment} loyalty points to user ${userId}`
        );
        await LoyaltyService.earnPoints(
          userId,
          pointsAdjustment,
          'ORDER',
          `${orderId}-adjustment-increase`
        );
      } else {
        // Retirer des points
        console.log(
          `[OrderPriceAdjustmentService] Removing ${Math.abs(pointsAdjustment)} loyalty points from user ${userId}`
        );
        await LoyaltyService.spendPoints(
          userId,
          Math.abs(pointsAdjustment),
          'ORDER',
          `${orderId}-adjustment-decrease`
        );
      }

      return pointsAdjustment;
    } catch (error) {
      console.error('[OrderPriceAdjustmentService] Error adjusting loyalty points:', error);
      throw error;
    }
  }

  /**
   * Ajuste les commissions affiliés en fonction de la différence de prix
   * 
   * @param orderId - ID de la commande
   * @param priceDifference - Différence de prix
   * @param affiliateCode - Code affilié (peut être null)
   * @returns Montant de commission ajusté (positif ou négatif)
   */
  private static async adjustAffiliateCommissions(
    orderId: string,
    priceDifference: number,
    affiliateCode: string | null | undefined
  ): Promise<number> {
    try {
      if (!affiliateCode) {
        console.log(
          `[OrderPriceAdjustmentService] No affiliate commission adjustment for order ${orderId} - no affiliate code`
        );
        return 0;
      }

      const affiliate = await prisma.affiliate_profiles.findFirst({
        where: {
          affiliate_code: affiliateCode,
          is_active: true
          // ✅ CORRECTION : Accepter PENDING, ACTIVE, SUSPENDED - peu importe le statut tant que is_active = true
        }
      });

      if (!affiliate) {
        console.log(
          `[OrderPriceAdjustmentService] No active affiliate found for code ${affiliateCode}`
        );
        return 0;
      }

      const commissionRate = await AffiliateCommissionService.calculateCommissionRate(
        affiliate.total_referrals || 0
      );
      const commissionAdjustment = priceDifference * (commissionRate / 100);

      if (commissionAdjustment !== 0) {
        console.log(
          `[OrderPriceAdjustmentService] Adjusting commission for affiliate ${affiliate.id}: ${commissionAdjustment} FCFA`
        );

        await prisma.affiliate_profiles.update({
          where: { id: affiliate.id },
          data: {
            commission_balance: {
              increment: new Prisma.Decimal(commissionAdjustment)
            },
            total_earned: {
              increment: new Prisma.Decimal(commissionAdjustment)
            },
            monthly_earnings: {
              increment: new Prisma.Decimal(commissionAdjustment)
            },
            updated_at: new Date()
          }
        });

        // Créer une transaction d'ajustement
        await prisma.commission_transactions.create({
          data: {
            affiliate_id: affiliate.id,
            order_id: orderId,
            amount: new Prisma.Decimal(commissionAdjustment),
            created_at: new Date(),
            updated_at: new Date()
          }
        });
      }

      return commissionAdjustment;
    } catch (error) {
      console.error('[OrderPriceAdjustmentService] Error adjusting affiliate commissions:', error);
      throw error;
    }
  }

  /**
   * Enregistre l'ajustement de prix dans un log d'audit
   * 
   * @param orderId - ID de la commande
   * @param oldManualPrice - Ancien prix manuel
   * @param newManualPrice - Nouveau prix manuel
   * @param loyaltyAdjustment - Ajustement des points
   * @param commissionAdjustment - Ajustement de la commission
   */
  private static async logPriceAdjustment(
    orderId: string,
    oldManualPrice: number | null,
    newManualPrice: number | null,
    loyaltyAdjustment: number,
    commissionAdjustment: number
  ): Promise<void> {
    try {
      const auditLog = {
        orderId,
        oldManualPrice,
        newManualPrice,
        loyaltyAdjustment,
        commissionAdjustment,
        timestamp: new Date().toISOString()
      };

      console.log(
        `[OrderPriceAdjustmentService] AUDIT LOG - Price adjustment:
        ${JSON.stringify(auditLog, null, 2)}`
      );

      // TODO: Créer une table d'audit si elle n'existe pas
      // await prisma.price_adjustment_audit.create({ data: auditLog });
    } catch (error) {
      console.error('[OrderPriceAdjustmentService] Error logging price adjustment:', error);
      // Ne pas lever l'erreur, juste logger
    }
  }
}
