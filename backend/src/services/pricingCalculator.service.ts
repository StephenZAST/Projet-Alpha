import { PrismaClient, Prisma } from '@prisma/client';
import { OrderItem } from '../models/types';

const prisma = new PrismaClient();

export class PricingCalculatorService {
  static async calculateOrderPrice(
    items: Array<{articleId: string; serviceId: string; quantity: number; isPremium?: boolean}>,
    weight?: number
  ): Promise<{ total: number; breakdown: any[] }> {
    try {
      if (weight && !await this.validateWeightRange(weight)) {
        throw new Error('Invalid weight range');
      }

      await this.validateServiceCompatibility(items);

      let total = 0;
      const breakdown = [];

      if (weight) {
        const weightCost = await this.calculateWeightBasedPrice(weight);
        total += weightCost.cost;
        breakdown.push(weightCost);
      }

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
    const pricing = await prisma.weight_based_pricing.findFirst({
      where: {
        AND: [
          { min_weight: { lte: new Prisma.Decimal(weight) } },
          { max_weight: { gte: new Prisma.Decimal(weight) } }
        ]
      }
    });

    return !!pricing;
  }

  private static async validateServiceCompatibility(
    items: Array<{articleId: string; serviceId: string}>
  ): Promise<void> {
    for (const item of items) {
      // Vérifie la compatibilité via la table centralisée article_service_prices
      const exists = await prisma.article_service_prices.findFirst({
        where: {
          article_id: item.articleId,
          service_id: item.serviceId,
          is_available: true
        }
      });
      if (!exists) {
        throw new Error(`Service ${item.serviceId} is not compatible with article ${item.articleId}`);
      }
    }
  }

  private static async calculateWeightBasedPrice(weight: number) {
    const pricing = await prisma.weight_based_pricing.findFirst({
      where: {
        AND: [
          { min_weight: { lte: new Prisma.Decimal(weight) } },
          { max_weight: { gte: new Prisma.Decimal(weight) } }
        ]
      }
    });

    const cost = pricing ? Number(pricing.price_per_kg) * weight : 0;
    return {
      type: 'WEIGHT',
      weight,
      pricePerKg: pricing ? Number(pricing.price_per_kg) : 0,
      cost
    };
  }

  private static async calculateItemBasedPrices(
    items: Array<{articleId: string; serviceId: string; quantity: number; isPremium?: boolean}>
  ) {
    let total = 0;
    const breakdown = [];

    for (const item of items) {
      const price = await prisma.article_service_prices.findFirst({
        where: {
          article_id: item.articleId,
          service_id: item.serviceId,
          is_available: true
        }
      });
      if (price) {
        const basePrice = item.isPremium ? 
          Number(price.premium_price ?? price.base_price) : 
          Number(price.base_price);
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
