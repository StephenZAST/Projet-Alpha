import { PrismaClient, Prisma } from '@prisma/client';
import { Article } from '../models/types';
import { PriceCalculationParams, PriceDetails, PricingType } from '../models/pricing.types';
import { OrderItem } from '../models/types';

const prisma = new PrismaClient();

export class PricingService {
  static async calculateOrderTotal(orderData: {
    items: { articleId: string; quantity: number; isPremium?: boolean }[];
    userId: string;
    appliedOfferIds?: string[];
    usePoints?: number;
  }): Promise<{
    subtotal: number;
    discounts: Array<{ offerId: string; amount: number }>;
    total: number;
  }> {
    try {
      let subtotal = 0;
      const itemPrices = new Map<string, number>();

      const articles = await prisma.articles.findMany({
        where: {
          id: {
            in: orderData.items.map(item => item.articleId)
          }
        }
      });

      const articleMap = new Map(articles.map(article => [article.id, article]));
      
      // Calculer le sous-total
      for (const item of orderData.items) {
        const article = articleMap.get(item.articleId);
        if (!article) throw new Error(`Article not found: ${item.articleId}`);

        const price = item.isPremium && article.premiumPrice 
          ? Number(article.premiumPrice)
          : Number(article.basePrice);

        itemPrices.set(item.articleId, price);
        subtotal += price * item.quantity;
      }

      // Calculer les réductions
      const discounts = await this.calculateDiscounts(
        subtotal,
        orderData.items.map(item => item.articleId),
        orderData.appliedOfferIds || [],
        orderData.userId
      );

      const totalDiscount = discounts.reduce((sum, d) => sum + d.amount, 0);
      const total = Math.max(0, subtotal - totalDiscount);

      return { subtotal, discounts, total };
    } catch (error) {
      console.error('[PricingService] Error calculating order total:', error);
      throw error;
    }
  }

  private static async calculateLoyaltyDiscount(points: number, total: number): Promise<number> {
    const conversionRate = Number(process.env.POINTS_TO_DISCOUNT_RATE || '0.1');
    const maxDiscountPercentage = Number(process.env.MAX_POINTS_DISCOUNT_PERCENTAGE || '30');
    
    let discountAmount = points * conversionRate;
    const maxDiscount = (total * maxDiscountPercentage) / 100;
    discountAmount = Math.min(discountAmount, maxDiscount);
    
    return Math.round(discountAmount * 100) / 100;
  }

  static async calculateDiscounts(
    subtotal: number,
    articleIds: string[],
    appliedOfferIds: string[],
    userId: string
  ): Promise<Array<{ offerId: string; amount: number }>> {
    try {
      if (!appliedOfferIds.length) return [];

      const offers = await prisma.offers.findMany({
        where: {
          id: { in: appliedOfferIds },
          is_active: true,
          startDate: { lte: new Date() },
          endDate: { gte: new Date() }
        }
      });

      const discounts: Array<{ offerId: string; amount: number }> = [];
      
      for (const offer of offers) {
        if (!offer) continue;

        let discountAmount = 0;
        if (offer.discountType === 'PERCENTAGE') {
          discountAmount = (subtotal * Number(offer.discountValue)) / 100;
        } else {
          discountAmount = Number(offer.discountValue);
        }

        // Appliquer le montant maximum de remise si défini
        if (offer.maxDiscountAmount) {
          discountAmount = Math.min(discountAmount, Number(offer.maxDiscountAmount));
        }

        discounts.push({
          offerId: offer.id,
          amount: discountAmount
        });

        // Si l'offre n'est pas cumulative, on s'arrête à la première
        if (!offer.isCumulative) break;
      }

      return discounts;
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
      await prisma.articles.update({
        where: { id: articleId },
        data: {
          basePrice: updates.basePrice,
          premiumPrice: updates.premiumPrice,
          updatedAt: now
        }
      });
    } catch (error) {
      console.error('[PricingService] Error updating article price:', error);
      throw error;
    }
  }

  static async calculatePrice(params: PriceCalculationParams): Promise<PriceDetails> {
    const { articleId, serviceTypeId, quantity = 1, weight, isPremium = false } = params;

    const servicePrice = await prisma.article_service_prices.findFirst({
      where: {
        article_id: articleId,
        service_type_id: serviceTypeId
      },
      include: {
        service_types: true
      }
    });

    if (!servicePrice) throw new Error('Price configuration not found');

    const compatibility = await prisma.article_service_compatibility.findFirst({
      where: {
        article_id: articleId,
        service_id: serviceTypeId
      }
    });

    if (!compatibility?.is_compatible) {
      throw new Error('Service is not compatible with this article');
    }

    let basePrice = isPremium && servicePrice.premium_price 
      ? Number(servicePrice.premium_price)
      : Number(servicePrice.base_price);

    const pricingType = servicePrice.service_types?.pricing_type as PricingType || 'PER_ITEM';

    switch (pricingType) {
      case 'PER_WEIGHT':
        if (!weight) throw new Error('Weight is required for this service type');
        if (!servicePrice.price_per_kg) throw new Error('Price per kg not configured');
        basePrice = Number(servicePrice.price_per_kg) * weight;
        break;
      
      case 'SUBSCRIPTION':
        break;
      
      default: // PER_ITEM
        basePrice = basePrice * quantity;
    }

    return {
      basePrice,
      total: basePrice,
      pricingType,
      isPremium
    };
  }

  static async getPricingConfiguration(serviceTypeId: string) {
    try {
      const data = await prisma.article_service_prices.findMany({
        where: {
          service_type_id: serviceTypeId
        },
        include: {
          service_types: true
        }
      });

      return {
        data: data || [],
        error: null
      };
    } catch (error) {
      console.error('[PricingService] Get pricing configuration error:', error);
      return {
        data: null,
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }
}