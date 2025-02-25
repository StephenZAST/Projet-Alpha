import supabase from '../config/database'; 
import { OrderItem } from '../models/types';
import { ServiceCompatibilityService } from './serviceCompatibility.service';

export class PricingCalculatorService {
  static async calculateOrderPrice(
    items: Array<{articleId: string; serviceId: string; quantity: number; isPremium?: boolean}>,
    weight?: number
  ): Promise<{ total: number; breakdown: any[] }> {
    try {
      // Validation du poids
      if (weight && !await this.validateWeightRange(weight)) {
        throw new Error('Invalid weight range');
      }

      // Vérification de la compatibilité des services
      await this.validateServiceCompatibility(items);

      let total = 0;
      const breakdown = [];

      // Calcul basé sur le poids si disponible
      if (weight) {
        const weightCost = await this.calculateWeightBasedPrice(weight);
        total += weightCost.cost;
        breakdown.push(weightCost);
      }

      // Calcul basé sur les articles
      const itemCosts = await this.calculateItemBasedPrices(items);
      total += itemCosts.total;
      breakdown.push(...itemCosts.breakdown);
 
      return { total, breakdown };
    } catch (error) {
      console.error('[PricingCalculatorService] Calculate price error:', error);
      throw error;
    }
  }

  private static async validateWeightRange(weight: number): Promise<boolean> {
    const { data } = await supabase
      .from('weight_based_pricing')
      .select('*')
      .lte('min_weight', weight)
      .gte('max_weight', weight)
      .eq('is_active', true);

    // Correction : Assurer un retour booléen explicite
    return Array.isArray(data) && data.length > 0;
  }

  private static async validateServiceCompatibility(
    items: Array<{articleId: string; serviceId: string}>
  ): Promise<void> {
    for (const item of items) {
      const isCompatible = await ServiceCompatibilityService.checkCompatibility(
        item.articleId,
        item.serviceId
      );
      if (!isCompatible) {
        throw new Error(`Service ${item.serviceId} is not compatible with article ${item.articleId}`);
      }
    }
  }

  private static async calculateWeightBasedPrice(weight: number) {
    const { data: weightPrice } = await supabase
      .from('weight_based_pricing')
      .select('price_per_kg')
      .lte('min_weight', weight)
      .gte('max_weight', weight)
      .eq('is_active', true)
      .single();

    const cost = weight * (weightPrice?.price_per_kg || 0);
    return {
      type: 'WEIGHT',
      weight,
      pricePerKg: weightPrice?.price_per_kg,
      cost
    };
  }

  private static async calculateItemBasedPrices(
    items: Array<{articleId: string; serviceId: string; quantity: number; isPremium?: boolean}>
  ) {
    let total = 0;
    const breakdown = [];

    for (const item of items) {
      const { data: price } = await supabase
        .from('service_specific_prices')
        .select('base_price, premium_price')
        .eq('article_id', item.articleId)
        .eq('service_id', item.serviceId)
        .single();

      if (price) {
        const basePrice = item.isPremium ? (price.premium_price || price.base_price) : price.base_price;
        const itemCost = basePrice * item.quantity;
        total += itemCost;
        breakdown.push({
          type: 'ITEM',
          ...item,
          basePrice,
          cost: itemCost
        });
      }
    }

    return { total, breakdown };
  }
}
