import { PrismaClient } from '@prisma/client';
import { NotificationType } from '../models/types';
import { CreateOfferDTO, Offer, OfferSubscription } from '../models/offer.types';
import { NotificationService } from './notification.service';

const prisma = new PrismaClient();

export class OfferService {
  static async createOffer(data: CreateOfferDTO): Promise<Offer> {
    try {
      const offer = await prisma.offers.create({
        data: {
          name: data.name,
          description: data.description,
          discountType: data.discountType,
          discountValue: data.discountValue,
          minPurchaseAmount: data.minPurchaseAmount,
          maxDiscountAmount: data.maxDiscountAmount,
          isCumulative: data.isCumulative,
          startDate: data.startDate,
          endDate: data.endDate,
          is_active: true,
          pointsRequired: data.pointsRequired,
          created_at: new Date(),
          updated_at: new Date(),
          offer_articles: data.articleIds ? {
            create: data.articleIds.map(articleId => ({
              article_id: articleId
            }))
          } : undefined
        },
        include: {
          offer_articles: {
            include: {
              articles: true
            }
          }
        }
      });

      // Notify admins
      await NotificationService.sendNotification(
        'ADMIN',
        NotificationType.OFFER_CREATED,
        {
          offerId: offer.id,
          offerName: offer.name
        }
      );

      return this.formatOffer(offer);
    } catch (error) {
      console.error('[OfferService] Create offer error:', error);
      throw error;
    }
  }

  static async getAvailableOffers(userId: string): Promise<Offer[]> {
    const offers = await prisma.offers.findMany({
      where: {
        is_active: true,
        startDate: { lte: new Date() },
        endDate: { gte: new Date() }
      },
      include: {
        offer_articles: {
          include: {
            articles: true
          }
        }
      }
    });

    return offers.map(offer => this.formatOffer(offer));
  }

  static async getOfferById(offerId: string): Promise<Offer> {
    const offer = await prisma.offers.findUnique({
      where: { id: offerId },
      include: {
        offer_articles: {
          include: {
            articles: true
          }
        }
      }
    });

    if (!offer) throw new Error('Offer not found');
    return this.formatOffer(offer);
  }

  static async updateOffer(offerId: string, updateData: Partial<CreateOfferDTO>): Promise<Offer> {
    const { articleIds, ...offerDetails } = updateData;

    const updatedOffer = await prisma.offers.update({
      where: { id: offerId },
      data: {
        ...offerDetails,
        updated_at: new Date(),
        offer_articles: articleIds ? {
          deleteMany: {},
          create: articleIds.map(articleId => ({
            article_id: articleId
          }))
        } : undefined
      },
      include: {
        offer_articles: {
          include: {
            articles: true
          }
        }
      }
    });

    return this.formatOffer(updatedOffer);
  }

  static async deleteOffer(offerId: string): Promise<void> {
    await prisma.offers.delete({
      where: { id: offerId }
    });
  }

  static async toggleOfferStatus(offerId: string, isActive: boolean): Promise<Offer> {
    const updatedOffer = await prisma.offers.update({
      where: { id: offerId },
      data: {
        is_active: isActive,
        updated_at: new Date()
      }
    });

    return this.formatOffer(updatedOffer);
  }

  static async subscribeToOffer(userId: string, offerId: string): Promise<OfferSubscription> {
    try {
      const offer = await prisma.offers.findFirst({
        where: {
          id: offerId,
          is_active: true
        }
      });

      if (!offer) throw new Error('Offer not found or inactive');

      if (!offer.isCumulative) {
        await prisma.offer_subscriptions.updateMany({
          where: { user_id: userId },
          data: {
            status: 'INACTIVE',
            updated_at: new Date()
          }
        });
      }

      const subscription = await prisma.offer_subscriptions.create({
        data: {
          user_id: userId,
          offer_id: offerId,
          status: 'ACTIVE',
          subscribed_at: new Date(),
          updated_at: new Date()
        },
        include: {
          offers: true
        }
      });

      await NotificationService.sendNotification(
        userId,
        NotificationType.OFFER_SUBSCRIBED,
        {
          offerId,
          offerName: offer.name
        }
      );

      return this.formatSubscription(subscription);
    } catch (error) {
      console.error('[OfferService] Subscribe error:', error);
      throw error;
    }
  }

  static async getUserSubscriptions(userId: string): Promise<OfferSubscription[]> {
    const subscriptions = await prisma.offer_subscriptions.findMany({
      where: {
        user_id: userId,
        status: 'ACTIVE'
      },
      include: {
        offers: true
      }
    });

    return subscriptions.map(subscription => this.formatSubscription(subscription));
  }

  static async getSubscribers(offerId: string): Promise<OfferSubscription[]> {
    try {
      const subscriptions = await prisma.offer_subscriptions.findMany({
        where: {
          offer_id: offerId,
          status: 'ACTIVE'
        },
        include: {
          users: true,
          offers: true
        }
      });

      return subscriptions
        .filter(subscription => {
          const offer = subscription.offers;
          return subscription.users && subscription.user_id && offer;
        })
        .map(subscription => ({
          id: subscription.id,
          userId: subscription.user_id!,
          offerId: subscription.offer_id ?? '',
          status: subscription.status ?? 'ACTIVE',
          subscribedAt: new Date(subscription.subscribed_at || new Date()),
          updatedAt: new Date(subscription.updated_at || new Date()),
          user: subscription.users ? {
            id: subscription.users.id,
            email: subscription.users.email,
            firstName: subscription.users.first_name,
            lastName: subscription.users.last_name,
            phone: subscription.users.phone ?? null
          } : undefined,
          offer: subscription.offers ? this.formatOffer(subscription.offers) : undefined
        }));
    } catch (error) {
      console.error('[OfferService] Get subscribers error:', error);
      throw error;
    }
  }

  static async unsubscribeFromOffer(userId: string, offerId: string): Promise<void> {
    await prisma.offer_subscriptions.updateMany({
      where: {
        user_id: userId,
        offer_id: offerId
      },
      data: {
        status: 'INACTIVE',
        updated_at: new Date()
      }
    });
  }

  static async calculateOrderDiscounts(
    userId: string,
    subtotal: number
  ): Promise<{
    subtotal: number;
    discounts: Array<{ offerId: string; amount: number }>;
    total: number;
  }> {
    try {
      const subscriptions = await prisma.offer_subscriptions.findMany({
        where: {
          user_id: userId,
          status: 'ACTIVE'
        },
        include: {
          offers: true
        }
      });

      let total = subtotal;
      const discounts = [];

      for (const sub of subscriptions) {
        const offer = sub.offers;
        if (!offer || !this.isOfferValid(offer, subtotal)) continue;

        const discountAmount = this.calculateDiscountAmount(offer, total);

        discounts.push({
          offerId: offer.id,
          amount: discountAmount
        });

        if (!offer.isCumulative) break;
        total -= discountAmount;
      }

      return {
        subtotal,
        discounts,
        total: Math.max(0, total)
      };
    } catch (error) {
      console.error('[OfferService] Calculate discounts error:', error);
      throw error;
    }
  }

  private static isOfferValid(offer: any, subtotal: number): boolean {
    if (!offer) return false;
    
    const now = new Date();
    return (
      offer.is_active &&
      new Date(offer.startDate) <= now &&
      new Date(offer.endDate) >= now &&
      (!offer.minPurchaseAmount || subtotal >= offer.minPurchaseAmount)
    );
  }

  private static calculateDiscountAmount(offer: any, total: number): number {
    if (!offer) return 0;

    let amount = 0;

    if (offer.discountType === 'PERCENTAGE') {
      amount = (total * Number(offer.discountValue)) / 100;
    } else {
      amount = Number(offer.discountValue);
    }

    if (offer.maxDiscountAmount) {
      amount = Math.min(amount, Number(offer.maxDiscountAmount));
    }

    return amount;
  }

  private static formatOffer(data: any): Offer {
    if (!data) throw new Error('Invalid offer data');

    return {
      id: data.id,
      name: data.name,
      description: data.description,
      discountType: data.discountType,
      discountValue: Number(data.discountValue),
      minPurchaseAmount: data.minPurchaseAmount ? Number(data.minPurchaseAmount) : undefined,
      maxDiscountAmount: data.maxDiscountAmount ? Number(data.maxDiscountAmount) : undefined,
      isCumulative: data.isCumulative ?? false,
      startDate: new Date(data.startDate || new Date()),
      endDate: new Date(data.endDate || new Date()),
      isActive: data.is_active ?? false,
      pointsRequired: data.pointsRequired ? Number(data.pointsRequired) : undefined,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
      articles: data.offer_articles?.map((oa: any) => ({
        id: oa.articles.id,
        name: oa.articles.name,
        description: oa.articles.description
      })) || []
    };
  }

  private static formatSubscription(data: any): OfferSubscription {
    return {
      id: data.id,
      userId: data.user_id,
      offerId: data.offer_id,
      status: data.status,
      subscribedAt: new Date(data.subscribed_at),
      updatedAt: new Date(data.updated_at),
      offer: data.offers ? this.formatOffer(data.offers) : undefined
    };
  }
}
