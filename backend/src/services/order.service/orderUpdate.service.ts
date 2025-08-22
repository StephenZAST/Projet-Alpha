import { PrismaClient, order_status, payment_method_enum } from '@prisma/client';
import { Order, PaymentMethod } from '../../models/types';

const prisma = new PrismaClient();

export class OrderUpdateService {
  /**
   * Met à jour un ou plusieurs champs d'une commande (paiement, dates, code affilié, etc.)
   * @param orderId string
   * @param updateFields Partial<{ paymentMethod, collectionDate, deliveryDate, affiliateCode }>
   * @param userId string
   * @param userRole string
   */
  static async patchOrderFields(
    orderId: string,
    updateFields: Partial<{
      paymentMethod: PaymentMethod | payment_method_enum;
      collectionDate: Date | string;
      deliveryDate: Date | string;
      affiliateCode: string;
      status: string;
      items: any[];
      service_type_id: string;
    }> = {},
    userId: string,
    userRole: string
  ): Promise<Order> {
    console.log(`[OrderUpdateService] patchOrderFields for order ${orderId} by user ${userId} (${userRole})`, updateFields);
    const allowedRoles = ['ADMIN', 'SUPER_ADMIN'];
    let order;
    try {
      order = await prisma.orders.findUnique({ where: { id: orderId } });
    } catch (err) {
      console.error(`[OrderUpdateService] Error fetching order ${orderId}:`, err);
      throw new Error('Database error while fetching order');
    }
    if (!order) {
      console.warn(`[OrderUpdateService] Order not found: ${orderId}`);
      throw new Error('Order not found');
    }
    if (order.userId !== userId && !allowedRoles.includes(userRole)) {
      console.warn(`[OrderUpdateService] Unauthorized update attempt by user ${userId} (${userRole}) on order ${orderId}`);
      throw new Error('Unauthorized to update order');
    }
    const data: any = {};
    if (updateFields.paymentMethod) data.paymentMethod = updateFields.paymentMethod;
    if (updateFields.collectionDate) data.collectionDate = new Date(updateFields.collectionDate);
    if (updateFields.deliveryDate) data.deliveryDate = new Date(updateFields.deliveryDate);
    if (updateFields.affiliateCode !== undefined) {
      if (updateFields.affiliateCode) {
        const affiliate = await prisma.affiliate_profiles.findFirst({
          where: {
            affiliate_code: updateFields.affiliateCode,
            is_active: true,
            status: 'ACTIVE'
          }
        });
        if (!affiliate) {
          throw new Error("Le code affilié fourni n'est pas valide ou n'existe pas.");
        }
        data.affiliateCode = updateFields.affiliateCode;
      } else {
        data.affiliateCode = null;
      }
    }
    if (updateFields.status) data.status = updateFields.status;
    if (updateFields.service_type_id) data.service_type_id = updateFields.service_type_id;
    data.updatedAt = new Date();

    // PATCH ORDER ITEMS LOGIC
    let newServiceTypeId = updateFields.service_type_id || order.service_type_id;
    if (updateFields.items) {
      await prisma.order_items.deleteMany({ where: { orderId } });
      if (Array.isArray(updateFields.items) && updateFields.items.length > 0) {
        const PricingService = require('../../services/pricing.service').PricingService;
        let recalculatedItems: any[] = [];
        for (const item of updateFields.items) {
            let priceDetails;
            try {
              priceDetails = await PricingService.calculatePrice({
                articleId: item.articleId,
                serviceTypeId: newServiceTypeId,
                quantity: item.quantity,
                weight: item.weight,
                isPremium: item.isPremium || false
              });
            } catch (err) {
              let msg = 'Erreur inconnue';
              if (err instanceof Error) {
                msg = err.message;
              }
              throw new Error(`Erreur de calcul du prix pour l'article ${item.articleId}: ${msg}`);
            }
            recalculatedItems.push({
              orderId: orderId,
              articleId: item.articleId,
              serviceId: item.serviceId || null,
              quantity: item.quantity,
              unitPrice: priceDetails.unitPrice,
              isPremium: item.isPremium || false,
              weight: item.weight !== undefined ? item.weight : null,
              createdAt: item.createdAt ? new Date(item.createdAt) : new Date(),
              updatedAt: new Date()
            });
        }
        // Filtrage strict des propriétés autorisées (inclut weight)
        const filteredItems = recalculatedItems.map(item => ({
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          isPremium: item.isPremium,
          weight: item.weight,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        }));
        // Log pour traquer la présence de propriétés inattendues
        console.log('[OrderUpdateService] Items à insérer dans order_items:', JSON.stringify(filteredItems, null, 2));
        await prisma.order_items.createMany({ data: filteredItems });
      }
    }

    // Mise à jour de la commande si des champs ont changé (hors updatedAt)
    const dataKeys = Object.keys(data);
    if (dataKeys.length > 0 && !(dataKeys.length === 1 && dataKeys[0] === 'updatedAt')) {
      let updatedOrder;
      try {
        updatedOrder = await prisma.orders.update({
          where: { id: orderId },
          data: data
        });
      } catch (err) {
        console.error(`[OrderUpdateService] Error updating order ${orderId}:`, err);
        throw new Error('Database error while updating order');
      }
      console.log(`[OrderUpdateService] Order updated successfully:`, updatedOrder);
    }

    // Return the updated order with items
    const orderWithItems = await prisma.orders.findUnique({
      where: { id: orderId },
      include: {
        order_items: true
      }
    });
    return orderWithItems as unknown as Order;
  }
}
