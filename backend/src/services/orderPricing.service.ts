import { Article, OrderItem } from '../models/types';
import supabase from '../config/database';

export class OrderPricingService {
  static async calculateItemPrice(item: OrderItem): Promise<number> {
    const { data: article } = await supabase
      .from('articles')
      .select('basePrice, premiumPrice')
      .eq('id', item.articleId)
      .single();

    if (!article) {
      throw new Error('Article not found');
    }

    const price = item.isPremium ? article.premiumPrice : article.basePrice;
    return price * item.quantity;
  }

  static async calculateTotalPrice(items: OrderItem[]): Promise<number> {
    const pricePromises = items.map(item => this.calculateItemPrice(item));
    const prices = await Promise.all(pricePromises);
    return prices.reduce((total, price) => total + price, 0);
  }
}
 