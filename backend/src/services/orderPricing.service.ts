import { PrismaClient } from '@prisma/client';
import { Article, OrderItem } from '../models/types';

const prisma = new PrismaClient();

export class OrderPricingService {
  static async calculateItemPrice(item: OrderItem & { serviceTypeId?: string; weight?: number }): Promise<number> {
    try {
      // Récupérer le prix via la table centralisée
      const priceEntry = await prisma.article_service_prices.findFirst({
        where: {
          article_id: item.articleId,
          service_type_id: item.serviceTypeId
        },
        include: {
          service_types: true
        }
      });
      if (!priceEntry || !priceEntry.is_available) throw new Error('No price available for this article/service type');
      let price = 0;
      if (priceEntry.service_types?.pricing_type === 'PER_WEIGHT' || priceEntry.price_per_kg) {
        if (!item.weight) throw new Error('Weight required for PER_WEIGHT service');
        price = Number(priceEntry.price_per_kg) * Number(item.weight);
      } else {
        price = item.isPremium ? Number(priceEntry.premium_price) : Number(priceEntry.base_price);
        price = price * (item.quantity || 1);
      }
      return price;
    } catch (error) {
      console.error('Calculate item price error:', error);
      throw error;
    }
  }

  static async calculateTotalPrice(items: Array<OrderItem & { serviceTypeId?: string; weight?: number }>): Promise<number> {
    try {
      const pricePromises = items.map(item => this.calculateItemPrice(item));
      const prices = await Promise.all(pricePromises);
      return prices.reduce((total, price) => total + price, 0);
    } catch (error) {
      console.error('Calculate total price error:', error);
      throw error;
    }
  }
}
