import supabase from '../config/database';
import { Article, Order, Offer } from '../models/types';

export class PricingService {
  /**
   * Calcule le prix total d'une commande avec toutes les réductions applicables
   */
  static async calculateOrderTotal(orderData: {
    items: Array<{ articleId: string; quantity: number; isPremium?: boolean }>;
    userId: string;
    appliedOfferIds?: string[];
  }): Promise<{
    subtotal: number;
    discounts: Array<{ offerId: string; amount: number }>;
    total: number;
  }> {
    try {
      // 1. Calculer le sous-total
      let subtotal = 0;
      const itemPrices = new Map<string, number>();

      for (const item of orderData.items) {
        const price = await this.getArticlePrice(item.articleId, item.isPremium);
        itemPrices.set(item.articleId, price);
        subtotal += price * item.quantity;
      }

      // 2. Appliquer les réductions
      const discounts = await this.calculateDiscounts(
        subtotal,
        orderData.items.map(i => i.articleId),
        orderData.appliedOfferIds || [],
        orderData.userId
      );

      // 3. Calculer le total final
      const totalDiscount = discounts.reduce((sum, d) => sum + d.amount, 0);
      const total = Math.max(0, subtotal - totalDiscount);

      return {
        subtotal,
        discounts,
        total
      };
    } catch (error) {
      console.error('[PricingService] Error calculating order total:', error);
      throw new Error('Failed to calculate order total');
    }
  }

  /**
   * Récupère le prix d'un article (base ou premium)
   */
  static async getArticlePrice(articleId: string, isPremium: boolean = false): Promise<number> {
    try {
      // 1. Récupérer l'article
      const { data: article, error } = await supabase
        .from('articles')
        .select('basePrice, premiumPrice')
        .eq('id', articleId)
        .single();

      if (error) throw error;
      if (!article) throw new Error('Article not found');

      // 2. Vérifier le prix dans l'historique
      const { data: priceHistory } = await supabase
        .from('price_history')
        .select('*')
        .eq('article_id', articleId)
        .is('valid_to', null)
        .order('valid_from', { ascending: false })
        .limit(1);

      // Utiliser le prix de l'historique s'il existe, sinon utiliser le prix de l'article
      const currentPrice = priceHistory?.[0] || article;
      return isPremium ? currentPrice.premium_price : currentPrice.base_price;
    } catch (error) {
      console.error('[PricingService] Error getting article price:', error);
      throw new Error('Failed to get article price');
    }
  }

  /**
   * Calcule les réductions applicables
   */
  static async calculateDiscounts(
    subtotal: number,
    articleIds: string[],
    appliedOfferIds: string[],
    userId: string
  ): Promise<Array<{ offerId: string; amount: number }>> {
    try {
      if (!appliedOfferIds.length) return [];

      // 1. Récupérer les offres avec leurs règles
      const { data: offers, error } = await supabase
        .from('offers')
        .select(`
          *,
          discount_rules (*)
        `)
        .in('id', appliedOfferIds)
        .eq('is_active', true)
        .lte('startDate', new Date().toISOString())
        .gte('endDate', new Date().toISOString());

      if (error) throw error;
      if (!offers) return [];

      // 2. Vérifier les règles de réduction
      const validDiscounts: Array<{ offerId: string; amount: number }> = [];
      let remainingTotal = subtotal;

      // Trier les offres par priorité
      const sortedOffers = offers.sort((a, b) => {
        const ruleA = a.discount_rules?.[0];
        const ruleB = b.discount_rules?.[0];
        return (ruleB?.priority || 0) - (ruleA?.priority || 0);
      });

      for (const offer of sortedOffers) {
        const rule = offer.discount_rules?.[0];
        
        // Vérifier le montant minimum si défini
        if (rule?.min_purchase_amount && remainingTotal < rule.min_purchase_amount) {
          continue;
        }

        // Calculer la réduction
        let discountAmount = 0;
        switch (offer.discountType) {
          case 'PERCENTAGE':
            discountAmount = (remainingTotal * offer.discountValue) / 100;
            break;
          case 'FIXED_AMOUNT':
            discountAmount = offer.discountValue;
            break;
          case 'POINTS_EXCHANGE':
            // Vérifier les points disponibles
            const { data: loyalty } = await supabase
              .from('loyalty_points')
              .select('points_balance')
              .eq('user_id', userId)
              .single();

            if (loyalty && loyalty.points_balance >= (offer.pointsRequired || 0)) {
              discountAmount = offer.discountValue;
            }
            break;
        }

        // Appliquer le plafond si défini
        if (rule?.max_discount_amount) {
          discountAmount = Math.min(discountAmount, rule.max_discount_amount);
        }

        // Ne pas dépasser le montant restant
        discountAmount = Math.min(discountAmount, remainingTotal);

        if (discountAmount > 0) {
          validDiscounts.push({ offerId: offer.id, amount: discountAmount });
          
          // Si l'offre n'est pas combinable, arrêter ici
          if (!rule?.is_combinable) break;
          
          remainingTotal -= discountAmount;
        }
      }

      return validDiscounts;
    } catch (error) {
      console.error('[PricingService] Error calculating discounts:', error);
      throw new Error('Failed to calculate discounts');
    }
  }

  /**
   * Met à jour le prix d'un article
   */
  static async updateArticlePrice(
    articleId: string,
    updates: { basePrice?: number; premiumPrice?: number }
  ): Promise<void> {
    const now = new Date();

    try {
      // 1. Fermer le prix actuel dans l'historique
      await supabase
        .from('price_history')
        .update({ valid_to: now })
        .eq('article_id', articleId)
        .is('valid_to', null);

      // 2. Créer une nouvelle entrée dans l'historique
      const { error: historyError } = await supabase
        .from('price_history')
        .insert([{
          article_id: articleId,
          base_price: updates.basePrice,
          premium_price: updates.premiumPrice,
          valid_from: now
        }]);

      if (historyError) throw historyError;

      // 3. Mettre à jour l'article
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
      throw new Error('Failed to update article price');
    }
  }
}