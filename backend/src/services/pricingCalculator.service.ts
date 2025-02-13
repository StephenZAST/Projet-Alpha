import supabase from '../config/database';
import { OrderItem } from '../models/types';

export class PricingCalculatorService {
  static async calculateOrderPrice(
    items: Array<{articleId: string; serviceId: string; quantity: number}>,
    weight?: number
  ): Promise<{ total: number; breakdown: any[] }> {
    try {
      let total = 0;
      const breakdown = [];

      // Calcul basé sur le poids si disponible
      if (weight) {
        const { data: weightPrice, error: weightError } = await supabase
          .from('weight_based_pricing')
          .select('price_per_kg')
          .single();

        if (weightError) throw weightError;
        
        const weightCost = weight * (weightPrice?.price_per_kg || 0);
        total += weightCost;
        breakdown.push({
          type: 'WEIGHT',
          weight,
          pricePerKg: weightPrice?.price_per_kg,
          cost: weightCost
        });
      }

      // Calcul basé sur les articles
      for (const item of items) {
        const { data: price, error: priceError } = await supabase
          .from('service_specific_prices')
          .select('base_price, premium_price')
          .eq('article_id', item.articleId)
          .eq('service_id', item.serviceId)
          .single();

        if (priceError) throw priceError;

        const itemCost = (price?.base_price || 0) * item.quantity;
        total += itemCost;
        breakdown.push({
          type: 'ITEM',
          ...item,
          basePrice: price?.base_price,
          cost: itemCost
        });
      }

      return { total, breakdown };
    } catch (error) {
      console.error('[PricingCalculatorService] Calculate price error:', error);
      throw error;
    }
  }
}
