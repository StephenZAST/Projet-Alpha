import supabase from '../../config/database';
import { CreateOrderDTO, CreateOrderResponse, AppliedDiscount, NotificationType } from '../../models/types';
import { NotificationService } from '../notification.service';
import { LoyaltyService } from '../loyalty.service';
import { OrderPaymentService } from './orderPayment.service';

export class OrderCreateService {
  // Important: Cette classe utilise la procédure stockée 'create_order_with_items'
  // Pour plus de détails sur la procédure, voir: backend/prisma/migrations/[timestamp]_stored_procedures.sql
  // La procédure gère de manière atomique :
  // - La création de la commande
  // - L'ajout des articles
  // - Le calcul des prix
  // - La gestion des transactions

  private static readonly ORDER_SELECT = `
    *,
    user:users(*),
    service:services(*),
    address:addresses(*),
    items:order_items(
      *,
      article:articles!inner( 
        *,
        isDeleted:eq(false),
        category:article_categories(*)
      )
    )
  `;

  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    console.log('[OrderService] Starting order creation process');
    try {
      // Log initial data
      console.log('[OrderService] Input data:', {
        userId: orderData.userId,
        serviceId: orderData.serviceId,
        serviceTypeId: orderData.serviceTypeId,
        service_type_id: orderData.service_type_id,
        itemsCount: orderData.items?.length
      });

      // Vérification explicite du service_type_id
      if (!orderData.service_type_id && !orderData.serviceTypeId) {
        console.error('[OrderService] Missing service_type_id');
        throw new Error('service_type_id is required');
      }

      const dbOrderData = {
        ...orderData,
        service_type_id: orderData.service_type_id || orderData.serviceTypeId
      };

      console.log('[OrderService] Prepared DB data:', {
        ...dbOrderData,
        items: `${dbOrderData.items?.length} items`
      });

      // Vérifier que tous les articles sont actifs
      const articleIds = orderData.items.map(item => item.articleId);
      const { data: articles, error: checkError } = await supabase
        .from('articles')
        .select('id')
        .in('id', articleIds)
        .eq('isDeleted', false);

      if (checkError) throw checkError;
      
      if (articles.length !== articleIds.length) {
        throw new Error('One or more articles are not available');
      }

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
      try {
        await NotificationService.sendNotification(
          userId,
          NotificationType.ORDER_CREATED,
          {
            orderId: orderResult[0].id,
            totalAmount: finalAmount,
            items: completeOrder.items.map((item: { article: { name: string }, quantity: number }) => ({
              name: item.article.name,
              quantity: item.quantity
            }))
          }
        );
      } catch (notifError) {
        console.error('[OrderCreateService] Notification error:', notifError);
        // Continue le processus même si la notification échoue
      }

      // 7. Obtenir le solde actuel des points
      const currentPoints = await OrderPaymentService.getCurrentLoyaltyPoints(userId);

      console.log('[OrderService] Order creation completed successfully');
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
      console.error('[OrderService] Error creating order:', error);
      throw error;
    }
  }
}