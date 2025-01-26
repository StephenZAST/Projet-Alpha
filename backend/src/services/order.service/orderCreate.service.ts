import supabase from '../../config/database';
import { CreateOrderDTO, CreateOrderResponse, AppliedDiscount } from '../../models/types';
import { NotificationService } from '../notification.service';
import { LoyaltyService } from '../loyalty.service';
import { OrderPaymentService } from './orderPayment.service';

export class OrderCreateService {
  private static readonly ORDER_SELECT = `
    *,
    user:users(*),
    service:services(*),
    address:addresses(*),
    items:order_items(
      *,
      article:articles(
        *,
        category:article_categories(*)
      )
    )
  `;

  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    try {
      const { 
        userId, 
        serviceId, 
        addressId, 
        isRecurring, 
        recurrenceType, 
        collectionDate, 
        deliveryDate, 
        affiliateCode, 
        serviceTypeId, 
        paymentMethod,
        items 
      } = orderData;

      // 1. Utiliser la procédure stockée pour créer la commande avec ses items
      const { data: orderResult, error: procedureError } = await supabase.rpc(
        'create_order_with_items',
        {
          p_userid: userId,
          p_serviceid: serviceId,
          p_addressid: addressId,
          p_isrecurring: isRecurring,
          p_recurrencetype: recurrenceType,
          p_collectiondate: collectionDate,
          p_deliverydate: deliveryDate,
          p_affiliatecode: affiliateCode,
          p_service_type_id: serviceTypeId,
          p_paymentmethod: paymentMethod,
          p_items: items.map(item => ({
            articleId: item.articleId,
            quantity: item.quantity,
            isPremium: item.premiumPrice || false
          }))
        }
      );

      if (procedureError) throw procedureError;

      // 2. Récupérer la commande complète avec toutes les relations
      const { data: completeOrder, error: fetchError } = await supabase
        .from('orders')
        .select(this.ORDER_SELECT)
        .eq('id', orderResult[0].id)
        .single();

      if (fetchError) throw fetchError;

      const totalAmount = orderResult[0].totalAmount;

      // 3. Appliquer les réductions si nécessaire
      let finalAmount = totalAmount;
      let appliedDiscounts: AppliedDiscount[] = [];

      if (orderData.offerIds?.length) {
        const articleIds = items.map(item => item.articleId);
        const discountResult = await OrderPaymentService.calculateDiscounts(
          userId,
          finalAmount,
          articleIds,
          orderData.offerIds
        );
        finalAmount = discountResult.finalAmount;
        appliedDiscounts = discountResult.appliedDiscounts;

        // Mettre à jour le montant total après réductions
        await supabase
          .from('orders')
          .update({ totalAmount: finalAmount })
          .eq('id', orderResult[0].id);
      }

      // 4. Traiter la commission d'affilié
      if (affiliateCode) {
        await OrderPaymentService.processAffiliateCommission(
          orderResult[0].id,
          affiliateCode,
          finalAmount
        );
      }

      // 5. Traiter les points de fidélité
      const earnedPoints = Math.floor(finalAmount);
      await LoyaltyService.earnPoints(userId, earnedPoints, 'ORDER', orderResult[0].id);

      // 6. Envoyer la notification
      await NotificationService.sendNotification(
        userId,
        'ORDER_CREATED',
        {
          orderId: orderResult[0].id,
          totalAmount: finalAmount,
          items: completeOrder.items.map((item: { article: { name: string }, quantity: number }) => ({
            name: item.article.name,
            quantity: item.quantity
          }))
        }
      );

      // 7. Obtenir le solde actuel des points
      const currentPoints = await OrderPaymentService.getCurrentLoyaltyPoints(userId);

      return {
        order: completeOrder,
        pricing: {
          subtotal: totalAmount,
          discounts: appliedDiscounts,
          total: finalAmount
        },
        rewards: {
          pointsEarned: earnedPoints,
          currentBalance: currentPoints
        }
      };

    } catch (error) {
      console.error('[OrderCreateService] Error:', error);
      throw error;
    }
  }
}