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
    }> = {},
    userId: string,
    userRole: string
  ): Promise<Order> {
    console.log(`[OrderUpdateService] patchOrderFields for order ${orderId} by user ${userId} (${userRole})`, updateFields);
    // Autorisation : ADMIN, SUPER_ADMIN, ou propriétaire de la commande
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
    // Construction dynamique des champs à mettre à jour
    const data: any = {};
    if (updateFields.paymentMethod) data.paymentMethod = updateFields.paymentMethod;
    if (updateFields.collectionDate) data.collectionDate = new Date(updateFields.collectionDate);
    if (updateFields.deliveryDate) data.deliveryDate = new Date(updateFields.deliveryDate);
    if (updateFields.affiliateCode !== undefined) {
      if (updateFields.affiliateCode) {
        // Vérifier que le code affilié existe et est actif
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
        // Suppression du code affilié
        data.affiliateCode = null;
      }
    }
    if (updateFields.status) data.status = updateFields.status;
    if (Object.keys(data).length === 0) {
      console.warn(`[OrderUpdateService] No valid fields to update for order ${orderId}`);
      throw new Error('No valid fields to update');
    }
    data.updatedAt = new Date();
    let updatedOrder;
    try {
      updatedOrder = await prisma.orders.update({
        where: { id: orderId },
        data
      });
    } catch (err) {
      console.error(`[OrderUpdateService] Error updating order ${orderId}:`, err);
      throw new Error('Database error while updating order');
    }
    console.log(`[OrderUpdateService] Order updated successfully:`, updatedOrder);
    return updatedOrder as unknown as Order;
  }
}
