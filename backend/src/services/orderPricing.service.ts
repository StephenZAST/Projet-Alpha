import { PrismaClient } from '@prisma/client';
import { Article, OrderItem } from '../models/types';

const prisma = new PrismaClient();

export class OrderPricingService {
  static async calculateItemPrice(item: OrderItem): Promise<number> {
    try {
      const article = await prisma.articles.findUnique({
        where: { id: item.articleId },
        select: {
          basePrice: true,
          premiumPrice: true
        }
      });

      if (!article) {
        throw new Error('Article not found');
      }

      const price = item.isPremium 
        ? Number(article.premiumPrice) || Number(article.basePrice)
        : Number(article.basePrice);

      return price * item.quantity;
    } catch (error) {
      console.error('Calculate item price error:', error);
      throw error;
    }
  }

  static async calculateTotalPrice(items: OrderItem[]): Promise<number> {
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
