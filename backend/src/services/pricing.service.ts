import supabase from '../config/database';
import { Article, Order, Offer } from '../models/types';

interface OrderItemInput {
  articleId: string;
  quantity: number;
  isPremium?: boolean;
}

export class PricingService {
  static async calculateOrderTotal(orderData: {
    items: OrderItemInput[];
    userId: string;
    appliedOfferIds?: string[];
  }): Promise<{
    subtotal: number;
    discounts: Array<{ offerId: string; amount: number }>;
    total: number;
  }> {
    try {
      console.log('[PricingService] Calculating order total for items:', orderData.items);
      
      // 1. Calculer le sous-total
      let subtotal = 0;
      const itemPrices = new Map<string, number>();

      // Récupérer tous les articles en une seule requête
      const articleIds = orderData.items.map(item => item.articleId);
      const { data: articles, error: articlesError } = await supabase
        .from('articles')
        .select('id, basePrice, premiumPrice')
        .in('id', articleIds);

      if (articlesError) {
        console.error('[PricingService] Error fetching articles:', articlesError);
        throw articlesError;
      }

      // Créer un Map pour un accès rapide aux articles
      const articleMap = new Map(articles.map(article => [article.id, article]));

      // Calculer le sous-total
      for (const item of orderData.items) {
        const article = articleMap.get(item.articleId);
        if (!article) {
          throw new Error(`Article not found: ${item.articleId}`);
        }

        const price = item.isPremium ? article.premiumPrice : article.basePrice;
        console.log(`[PricingService] Article ${item.articleId}: ${item.isPremium ? 'Premium' : 'Base'} price = ${price}`);
        
        itemPrices.set(item.articleId, price);
        const itemTotal = price * item.quantity;
        console.log(`[PricingService] Item total (${price} * ${item.quantity}) = ${itemTotal}`);
        subtotal += itemTotal;
      }

      console.log('[PricingService] Subtotal calculated:', subtotal);

      // 2. Appliquer les réductions
      const discounts = await this.calculateDiscounts(
        subtotal,
        articleIds,
        orderData.appliedOfferIds || [],
        orderData.userId
      );

      // 3. Calculer le total final
      const totalDiscount = discounts.reduce((sum, d) => sum + d.amount, 0);
      const total = Math.max(0, subtotal - totalDiscount);

      console.log('[PricingService] Final calculation:', {
        subtotal,
        totalDiscount,
        finalTotal: total
      });

      return {
        subtotal,
        discounts,
        total
      };
    } catch (error) {
      console.error('[PricingService] Error calculating order total:', error);
      throw error;
    }
  }

  static async calculateDiscounts(
    subtotal: number,
    articleIds: string[],
    appliedOfferIds: string[],
    userId: string
  ): Promise<Array<{ offerId: string; amount: number }>> {
    try {
      if (!appliedOfferIds.length) return [];

      const { data: offers, error } = await supabase
        .from('offers')
        .select('*, discount_rules(*)')
        .in('id', appliedOfferIds)
        .eq('is_active', true)
        .lte('startDate', new Date().toISOString())
        .gte('endDate', new Date().toISOString());

      if (error) throw error;
      if (!offers) return [];

      const validDiscounts: Array<{ offerId: string; amount: number }> = [];
      let remainingTotal = subtotal;

      for (const offer of offers) {
        const rule = offer.discount_rules?.[0];
        if (!rule) continue;

        if (rule.min_purchase_amount && remainingTotal < rule.min_purchase_amount) {
          continue;
        }

        let discountAmount = 0;
        switch (offer.discountType) {
          case 'PERCENTAGE':
            discountAmount = (remainingTotal * offer.discountValue) / 100;
            break;
          case 'FIXED_AMOUNT':
            discountAmount = offer.discountValue;
            break;
          case 'POINTS_EXCHANGE':
            const { data: loyalty } = await supabase
              .from('loyalty_points')
              .select('pointsBalance')
              .eq('user_id', userId)
              .single();

            if (loyalty && loyalty.pointsBalance >= offer.pointsRequired) {
              discountAmount = offer.discountValue;
            }
            break;
        }

        if (rule.max_discount_amount) {
          discountAmount = Math.min(discountAmount, rule.max_discount_amount);
        }

        discountAmount = Math.min(discountAmount, remainingTotal);

        if (discountAmount > 0) {
          validDiscounts.push({ offerId: offer.id, amount: discountAmount });
          remainingTotal -= discountAmount;
        }
      }

      return validDiscounts;
    } catch (error) {
      console.error('[PricingService] Error calculating discounts:', error);
      throw error;
    }
  }

  static async updateArticlePrice(
    articleId: string,
    updates: { basePrice?: number; premiumPrice?: number }
  ): Promise<void> {
    const now = new Date();

    try {
      const { error: updateError } = await supabase
        .from('articles')
        .update({
          basePrice: updates.basePrice,
          premiumPrice: updates.premiumPrice,
          updatedAt: now
        })
        .eq('id', articleId);

      if (updateError) throw updateError;
    } catch (error) {
      console.error('[PricingService] Error updating article price:', error);
      throw error;
    }
  }
}