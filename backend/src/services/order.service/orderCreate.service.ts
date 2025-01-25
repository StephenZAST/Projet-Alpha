import supabase from '../../config/database';
import { CreateOrderDTO, CreateOrderResponse, AppliedDiscount } from '../../models/types';
import { NotificationService } from '../notification.service';
import { LoyaltyService } from '../loyalty.service';
import { v4 as uuidv4 } from 'uuid';
import { OrderPaymentService } from './orderPayment.service';

export class OrderCreateService {
  static async createOrder(orderData: CreateOrderDTO): Promise<CreateOrderResponse> {
    const { userId, serviceId, addressId, isRecurring, recurrenceType, collectionDate, deliveryDate, affiliateCode, serviceTypeId, paymentMethod } = orderData;

    const { data: service } = await supabase
      .from('services')
      .select('*')
      .eq('id', serviceId)
      .single();

    if (!service) {
      throw new Error('Service not found');
    }

    const { data: address } = await supabase
      .from('addresses')
      .select('*')
      .eq('id', addressId)
      .single();

    if (!address) {
      throw new Error('Address not found');
    }

    const items = orderData.items;
    const { data: articles, error: articlesQueryError } = await supabase
      .from('articles')
      .select(`
        *,
        category:article_categories(
          id,
          name
        )
      `)
      .in('id', items.map(item => item.articleId));

    if (articlesQueryError) {
      console.error('Error fetching articles:', articlesQueryError);
      throw articlesQueryError;
    }

    if (!articles || articles.length !== items.length) {
      throw new Error('One or more articles not found');
    }

    let subtotalAmount = service.price || 0;
    items.forEach(item => {
      const article = articles.find(a => a.id === item.articleId);
      if (article) {
        const price = item.premiumPrice ? article.premiumPrice : article.basePrice;
        if (typeof price === 'number' && typeof item.quantity === 'number') {
          subtotalAmount += price * item.quantity;
        } else {
          throw new Error(`Invalid price or quantity for article ${item.articleId}`);
        }
      } else {
        throw new Error(`Article not found: ${item.articleId}`);
      }
    });

    let finalAmount = subtotalAmount;
    let appliedDiscounts: AppliedDiscount[] = [];

    const orderToInsert = {
      id: uuidv4(),
      userId,
      service_id: serviceId,
      service_type_id: serviceTypeId,
      address_id: addressId,
      affiliateCode,
      status: 'PENDING',
      isRecurring,
      recurrenceType,
      nextRecurrenceDate: isRecurring ? collectionDate : null,
      totalAmount: subtotalAmount,
      collectionDate: collectionDate || null,
      deliveryDate: deliveryDate || null,
      createdAt: new Date(),
      updatedAt: new Date(),
      paymentStatus: 'PENDING',
      paymentMethod
    };

    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert([orderToInsert])
      .select()
      .single();

    if (orderError) throw orderError;

    const itemPromises = items.map(async (item) => {
      const article = articles.find(a => a.id === item.articleId);
      if (!article) throw new Error(`Article not found: ${item.articleId}`);

      const unitPrice = item.premiumPrice ? article.premiumPrice : article.basePrice;

      const { data: orderItem, error: insertError } = await supabase
        .from('order_items')
        .insert([{
          orderId: order.id,
          articleId: item.articleId,
          serviceId: serviceId,
          quantity: item.quantity,
          unitPrice: unitPrice
        }])
        .select(`
          *,
          article:articles(
            *,
            category:article_categories(*)
          )
        `)
        .single();

      if (insertError || !orderItem) throw insertError || new Error('Failed to create order item');
      return orderItem;
    });

    const insertedItems = await Promise.all(itemPromises);

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
    }

    if (affiliateCode) {
      await OrderPaymentService.processAffiliateCommission(order.id, affiliateCode, finalAmount);
    }

    await NotificationService.sendNotification(
      userId,
      'ORDER_CREATED',
      {
        orderId: order.id,
        totalAmount: finalAmount,
        items: items.map(item => ({
          name: articles.find(a => a.id === item.articleId)?.name,
          quantity: item.quantity
        }))
      }
    );

    try {
      await LoyaltyService.earnPoints(userId, Math.floor(finalAmount), 'ORDER', order.id);
    } catch (error) {
      console.error('Error attributing loyalty points:', error);
    }

    const currentLoyaltyPoints = await OrderPaymentService.getCurrentLoyaltyPoints(userId);

    return {
      order: {
        ...order,
        items: insertedItems,
        service,
        address
      },
      pricing: {
        subtotal: subtotalAmount,
        discounts: appliedDiscounts,
        total: finalAmount
      },
      rewards: {
        pointsEarned: Math.floor(finalAmount),
        currentBalance: currentLoyaltyPoints
      }
    };
  }
}