import { PrismaClient, Prisma } from '@prisma/client';
import { Article } from '../models/types';
import { PriceCalculationParams, PriceDetails, PricingType } from '../models/pricing.types';
import { OrderItem } from '../models/types';

const prisma = new PrismaClient();

export class PricingService {
  static async calculateOrderTotal(orderData: {
  items: { articleId: string; quantity: number; isPremium?: boolean; serviceTypeId?: string; serviceId?: string; weight?: number }[];
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
      const PricingService = require('./pricing.service').PricingService;

      for (const item of orderData.items) {
        const serviceTypeId = item.serviceTypeId;
        if (!serviceTypeId) throw new Error('serviceTypeId is required for price calculation');
        const priceDetails = await PricingService.calculatePrice({
          articleId: item.articleId,
          serviceTypeId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          isPremium: item.isPremium || false,
          weight: item.weight
        });
        itemPrices.set(item.articleId, priceDetails.unitPrice);
        console.log(`[OrderTotal] articleId=${item.articleId} | serviceTypeId=${serviceTypeId} | unitPrice=${priceDetails.unitPrice} | quantity=${item.quantity} | lineTotal=${priceDetails.lineTotal}`);
        subtotal += priceDetails.lineTotal;
      }

  // Rétablit la logique normale : subtotal non modifié

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
  const { articleId, serviceTypeId, serviceId, quantity = 1, weight, isPremium = false } = params;

    if (!serviceId) {
      console.error(`[PricingService] ERREUR: serviceId manquant pour articleId=${articleId}, serviceTypeId=${serviceTypeId}`);
    }
    let servicePrice = await prisma.article_service_prices.findFirst({
      where: {
        article_id: articleId,
        service_type_id: serviceTypeId,
        service_id: serviceId
      },
      include: {
        service_types: true
      }
    });

    // Si le lien n'existe pas, créer automatiquement une entrée avec prix par défaut
    if (!servicePrice) {
      const serviceType = await prisma.service_types.findUnique({ where: { id: serviceTypeId } });
      servicePrice = await prisma.article_service_prices.create({
        data: {
          article_id: articleId,
          service_type_id: serviceTypeId,
          base_price: 1,
          premium_price: 1,
          is_available: true,
          price_per_kg: 1,
          pricing_type: serviceType?.pricing_type || 'PER_ITEM',
        },
        include: {
          service_types: true
        }
      });
    }

    const pricingType = servicePrice.service_types?.pricing_type as PricingType || 'PER_ITEM';
    let unitPrice: number;
    let lineTotal: number;

    // Log stratégique : affiche le pricingType et les prix en base
    console.log(`[PricingService] articleId=${articleId} serviceTypeId=${serviceTypeId} serviceId=${params.serviceId} pricingType=${pricingType} basePrice=${servicePrice.base_price} premiumPrice=${servicePrice.premium_price} pricePerKg=${servicePrice.price_per_kg}`);

    if (pricingType === 'PER_WEIGHT') {
      if (!weight) throw new Error('Weight is required for this service type');
      if (!servicePrice.price_per_kg) throw new Error('Price per kg not configured');
      unitPrice = Number(servicePrice.price_per_kg);
      lineTotal = unitPrice * weight;
      console.log(`[PricingService] PER_WEIGHT: unitPrice=${unitPrice} * weight=${weight} = lineTotal=${lineTotal}`);
    } else if (pricingType === 'PER_ITEM') {
      unitPrice = isPremium ? Number(servicePrice.premium_price) : Number(servicePrice.base_price);
      lineTotal = unitPrice * quantity;
      console.log(`[PricingService] PER_ITEM: unitPrice=${unitPrice} * quantity=${quantity} = lineTotal=${lineTotal}`);
    } else if (pricingType === 'FIXED') {
      unitPrice = isPremium ? Number(servicePrice.premium_price) : Number(servicePrice.base_price);
      lineTotal = unitPrice * quantity;
      console.log(`[PricingService] FIXED: unitPrice=${unitPrice} * quantity=${quantity} = lineTotal=${lineTotal}`);
    } else {
      // Autre type ou fallback
      unitPrice = 1;
      lineTotal = unitPrice * quantity;
      console.warn(`[PricingService] Fallback: type inconnu ou prix non trouvé, unitPrice=1`);
    }

    // Fallback automatique : si le prix unitaire est <= 0, on force à 1 et on log
    if (unitPrice <= 0) {
      console.warn(`[PricingService] Fallback: prix unitaire <= 0 pour article/service (${articleId}/${serviceTypeId}), fallback à 1.`);
      unitPrice = 1;
      lineTotal = unitPrice * (pricingType === 'PER_WEIGHT' ? (weight || 1) : quantity);
    }

    return {
      unitPrice, // prix unitaire réel
      lineTotal, // prix total pour la ligne (unitPrice * quantity ou * weight)
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