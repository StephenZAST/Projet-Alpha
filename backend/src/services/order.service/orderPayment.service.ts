import { PrismaClient, Prisma, order_status } from '@prisma/client';
import { AppliedDiscount } from '../../models/types';

const prisma = new PrismaClient();

export class OrderPaymentService {
  static async getCurrentLoyaltyPoints(userId: string): Promise<number> {
    try {
      const loyaltyPoints = await prisma.loyalty_points.findUnique({
        where: {
          userId: userId
        },
        select: {
          pointsBalance: true
        }
      });

      return loyaltyPoints?.pointsBalance || 0;
    } catch (error) {
      console.error('[OrderPaymentService] Error:', error);
      throw error;
    }
  }

  static async calculateDiscounts(
    userId: string,
    totalAmount: number,
    articleIds: string[],
    appliedOfferIds: string[]
  ): Promise<{
    finalAmount: number;
    appliedDiscounts: AppliedDiscount[];
  }> {
    let finalAmount = totalAmount;
    const appliedDiscounts: AppliedDiscount[] = [];

    const availableOffers = await prisma.offers.findMany({
      where: {
        id: { in: appliedOfferIds },
        is_active: true,
        startDate: { lte: new Date() },
        endDate: { gte: new Date() }
      },
      include: {
        offer_articles: {
          select: {
            article_id: true
          }
        }
      }
    });

    if (!availableOffers.length) return { finalAmount, appliedDiscounts };

    const sortedOffers = availableOffers.sort((a, b) =>
      (a.isCumulative === b.isCumulative) ? 0 : a.isCumulative ? 1 : -1
    );

    for (const offer of sortedOffers) {
      const offerArticleIds = offer.offer_articles.map(a => a.article_id);
      const hasValidArticles = articleIds.some(id => offerArticleIds.includes(id));

      if (!hasValidArticles) continue;
      if (offer.minPurchaseAmount && totalAmount < Number(offer.minPurchaseAmount)) continue;

      let discountAmount = 0;

      switch (offer.discountType) {
        case 'PERCENTAGE':
          discountAmount = (totalAmount * Number(offer.discountValue)) / 100;
          break;
        case 'FIXED_AMOUNT':
          discountAmount = Number(offer.discountValue);
          break;
        case 'POINTS_EXCHANGE':
          const loyalty = await prisma.loyalty_points.findUnique({
            where: { userId: userId },
            select: { pointsBalance: true }
          });

          if (!loyalty || loyalty.pointsBalance! < Number(offer.pointsRequired)) continue;

          discountAmount = Number(offer.discountValue);

          await prisma.loyalty_points.update({
            where: { userId: userId },
            data: {
              pointsBalance: loyalty.pointsBalance! - Number(offer.pointsRequired)
            }
          });
          break;
      }

      if (offer.maxDiscountAmount) {
        discountAmount = Math.min(discountAmount, Number(offer.maxDiscountAmount));
      }

      finalAmount -= discountAmount;
      appliedDiscounts.push({ offerId: offer.id, discountAmount });

      if (!offer.isCumulative) break;
    }

    return {
      finalAmount: Math.max(finalAmount, 0),
      appliedDiscounts
    };
  }

  static async processAffiliateCommission(
    orderId: string,
    affiliateCode: string,
    totalAmount: number
  ): Promise<void> {
    const affiliate = await prisma.affiliate_profiles.findFirst({
      where: {
        affiliate_code: affiliateCode
      },
      include: {
        affiliate_levels: true,
        users: {
          select: {
            email: true,
            first_name: true,
            last_name: true
          }
        }
      }
    });

    if (!affiliate) {
      throw new Error('Affiliate not found');
    }

    if (!affiliate.is_active || affiliate.status !== 'ACTIVE') {
      throw new Error(`Affiliate is not active. Status: ${affiliate.status}, IsActive: ${affiliate.is_active}`);
    }

    try {
      const commissionRate = Number(affiliate.affiliate_levels?.commissionRate || affiliate.commission_rate || 10);
      const commissionAmount = totalAmount * (commissionRate / 100);

      await prisma.affiliate_profiles.update({
        where: { id: affiliate.id },
        data: {
          commission_balance: new Prisma.Decimal(Number(affiliate.commission_balance) + commissionAmount),
          total_earned: new Prisma.Decimal(Number(affiliate.total_earned) + commissionAmount),
          total_referrals: (affiliate.total_referrals || 0) + 1
        }
      });

      await prisma.commission_transactions.create({
        data: {
          affiliate_id: affiliate.id,
          order_id: orderId,
          amount: new Prisma.Decimal(commissionAmount),
          created_at: new Date(),
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('[OrderService] Error processing affiliate commission:', error);
      throw error;
    }
  }

  static async calculateTotal(items: { articleId: string; quantity: number }[]): Promise<number> {
    const articles = await prisma.articles.findMany({
      where: {
        id: { in: items.map(item => item.articleId) }
      }
    });

    if (!articles || articles.length !== items.length) {
      throw new Error('One or more articles not found');
    }

    return items.reduce((total, item) => {
      const article = articles.find(a => a.id === item.articleId);
      return total + (article ? Number(article.basePrice) * item.quantity : 0);
    }, 0);
  }

  static async updatePaymentStatus(
    orderId: string,
    paymentStatus: string,
    userId: string
  ): Promise<void> {
    await prisma.orders.update({
      where: { 
        id: orderId 
      },
      data: {
        status: paymentStatus as order_status, // Conversion vers le type enum
        updatedAt: new Date()
      }
    });
  }
}