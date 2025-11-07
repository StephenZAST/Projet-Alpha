import { PrismaClient } from '@prisma/client';
import { OrderPricingDTO, OrderPricingResponse, PricingCalculation } from '../models/orderPricing.types';

const prisma = new PrismaClient();

export class OrderPaymentManagementService {
  /**
   * Récupérer les infos de prix manuel et paiement d'une commande
   */
  static async getPricing(orderId: string): Promise<OrderPricingResponse> {
    try {
      // Récupérer la commande
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        select: { 
          id: true, 
          totalAmount: true,
          pricing: true
        }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      // Calculer les prix
      const pricing = this.calculatePricing(
        Number(order.totalAmount),
        order.pricing?.manual_price ? Number(order.pricing.manual_price) : undefined
      );

      return {
        orderId: order.id,
        originalPrice: Number(order.totalAmount),
        manualPrice: order.pricing?.manual_price ? Number(order.pricing.manual_price) : undefined,
        displayPrice: pricing.displayPrice,
        discount: pricing.discount,
        discountPercentage: pricing.discountPercentage,
        isPaid: order.pricing?.is_paid ?? false,
        paidAt: order.pricing?.paid_at ?? undefined,
        reason: order.pricing?.reason ?? undefined,
        updatedAt: order.pricing?.updated_at ?? undefined
      };
    } catch (error) {
      console.error('[OrderPaymentManagementService] Error getting pricing:', error);
      throw error;
    }
  }

  /**
   * Mettre à jour le prix manuel et/ou le statut de paiement
   */
  static async updatePricing(
    orderId: string,
    adminId: string,
    dto: OrderPricingDTO
  ): Promise<OrderPricingResponse> {
    try {
      // Vérifier que la commande existe
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        select: { id: true, totalAmount: true }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      // Créer ou mettre à jour les infos de prix/paiement
      const updatedPricing = await prisma.order_pricing.upsert({
        where: { order_id: orderId },
        create: {
          order_id: orderId,
          manual_price: dto.manual_price ? Number(dto.manual_price) : null,
          is_paid: dto.is_paid ?? false,
          paid_at: dto.is_paid ? new Date() : null,
          reason: dto.reason ?? null,
          updated_by: adminId,
          updated_at: new Date()
        },
        update: {
          manual_price: dto.manual_price !== undefined ? Number(dto.manual_price) : undefined,
          is_paid: dto.is_paid !== undefined ? dto.is_paid : undefined,
          paid_at: dto.is_paid ? new Date() : undefined,
          reason: dto.reason !== undefined ? dto.reason : undefined,
          updated_by: adminId,
          updated_at: new Date()
        }
      });

      // Calculer les prix
      const pricing = this.calculatePricing(
        Number(order.totalAmount),
        updatedPricing.manual_price ? Number(updatedPricing.manual_price) : undefined
      );

      return {
        orderId: order.id,
        originalPrice: Number(order.totalAmount),
        manualPrice: updatedPricing.manual_price ? Number(updatedPricing.manual_price) : undefined,
        displayPrice: pricing.displayPrice,
        discount: pricing.discount,
        discountPercentage: pricing.discountPercentage,
        isPaid: updatedPricing.is_paid,
        paidAt: updatedPricing.paid_at ?? undefined,
        reason: updatedPricing.reason ?? undefined,
        updatedAt: updatedPricing.updated_at ?? undefined
      };
    } catch (error) {
      console.error('[OrderPaymentManagementService] Error updating pricing:', error);
      throw error;
    }
  }

  /**
   * Calculer les prix (original, manuel, réduction/augmentation, pourcentage)
   * ✅ Supporte AUSSI les augmentations (manualPrice > originalPrice)
   */
  private static calculatePricing(
    originalPrice: number,
    manualPrice?: number
  ): PricingCalculation {
    const displayPrice = manualPrice ?? originalPrice;
    
    let discount: number | undefined;
    let discountPercentage: number | undefined;

    // ✅ CALCUL DE LA RÉDUCTION OU AUGMENTATION
    if (manualPrice !== undefined && manualPrice !== originalPrice) {
      // Réduction si manualPrice < originalPrice (discount positif)
      // Augmentation si manualPrice > originalPrice (discount négatif)
      discount = originalPrice - manualPrice;
      discountPercentage = (discount / originalPrice) * 100;
    }

    return {
      originalPrice,
      manualPrice,
      displayPrice,
      discount,
      discountPercentage
    };
  }

  /**
   * Réinitialiser le prix manuel (revenir au prix original)
   */
  static async resetManualPrice(
    orderId: string,
    adminId: string
  ): Promise<OrderPricingResponse> {
    try {
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        select: { id: true, totalAmount: true }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      // Mettre à jour: supprimer le prix manuel
      const updatedPricing = await prisma.order_pricing.upsert({
        where: { order_id: orderId },
        create: {
          order_id: orderId,
          manual_price: null,
          is_paid: false,
          updated_by: adminId
        },
        update: {
          manual_price: null,
          reason: null,
          updated_by: adminId,
          updated_at: new Date()
        }
      });

      const pricing = this.calculatePricing(Number(order.totalAmount));

      return {
        orderId: order.id,
        originalPrice: Number(order.totalAmount),
        displayPrice: pricing.displayPrice,
        isPaid: updatedPricing.is_paid,
        paidAt: updatedPricing.paid_at ?? undefined,
        updatedAt: updatedPricing.updated_at ?? undefined
      };
    } catch (error) {
      console.error('[OrderPaymentManagementService] Error resetting manual price:', error);
      throw error;
    }
  }

  /**
   * Marquer une commande comme payée
   */
  static async markAsPaid(
    orderId: string,
    adminId: string,
    reason?: string
  ): Promise<OrderPricingResponse> {
    try {
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        select: { id: true, totalAmount: true, pricing: true }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      const updatedPricing = await prisma.order_pricing.upsert({
        where: { order_id: orderId },
        create: {
          order_id: orderId,
          is_paid: true,
          paid_at: new Date(),
          reason: reason ?? 'Marked as paid by admin',
          updated_by: adminId
        },
        update: {
          is_paid: true,
          paid_at: new Date(),
          reason: reason ?? 'Marked as paid by admin',
          updated_by: adminId,
          updated_at: new Date()
        }
      });

      const pricing = this.calculatePricing(
        Number(order.totalAmount),
        order.pricing?.manual_price ? Number(order.pricing.manual_price) : undefined
      );

      return {
        orderId: order.id,
        originalPrice: Number(order.totalAmount),
        manualPrice: updatedPricing.manual_price ? Number(updatedPricing.manual_price) : undefined,
        displayPrice: pricing.displayPrice,
        discount: pricing.discount,
        discountPercentage: pricing.discountPercentage,
        isPaid: updatedPricing.is_paid,
        paidAt: updatedPricing.paid_at ?? undefined,
        reason: updatedPricing.reason ?? undefined,
        updatedAt: updatedPricing.updated_at ?? undefined
      };
    } catch (error) {
      console.error('[OrderPaymentManagementService] Error marking as paid:', error);
      throw error;
    }
  }

  /**
   * Marquer une commande comme non payée
   */
  static async markAsUnpaid(
    orderId: string,
    adminId: string,
    reason?: string
  ): Promise<OrderPricingResponse> {
    try {
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        select: { id: true, totalAmount: true, pricing: true }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      const updatedPricing = await prisma.order_pricing.upsert({
        where: { order_id: orderId },
        create: {
          order_id: orderId,
          is_paid: false,
          paid_at: null,
          reason: reason ?? 'Marked as unpaid by admin',
          updated_by: adminId
        },
        update: {
          is_paid: false,
          paid_at: null,
          reason: reason ?? 'Marked as unpaid by admin',
          updated_by: adminId,
          updated_at: new Date()
        }
      });

      const pricing = this.calculatePricing(
        Number(order.totalAmount),
        updatedPricing.manual_price ? Number(updatedPricing.manual_price) : undefined
      );

      return {
        orderId: order.id,
        originalPrice: Number(order.totalAmount),
        manualPrice: updatedPricing.manual_price ? Number(updatedPricing.manual_price) : undefined,
        displayPrice: pricing.displayPrice,
        discount: pricing.discount,
        discountPercentage: pricing.discountPercentage,
        isPaid: updatedPricing.is_paid,
        paidAt: updatedPricing.paid_at ?? undefined,
        reason: updatedPricing.reason ?? undefined,
        updatedAt: updatedPricing.updated_at ?? undefined
      };
    } catch (error) {
      console.error('[OrderPaymentManagementService] Error marking as unpaid:', error);
      throw error;
    }
  }
}
