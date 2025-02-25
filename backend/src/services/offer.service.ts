import supabase from '../config/database'; 
import { 
  CreateOfferDTO,
  Offer, 
  OfferDiscountType,
  OfferSubscription
} from '../models/offer.types';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

export class OfferService {
  static async createOffer(data: CreateOfferDTO): Promise<Offer> {
    try {
      const { data: offer, error } = await supabase
        .from('offers')
        .insert([{
          name: data.name,
          description: data.description,
          discount_type: data.discountType,
          discount_value: data.discountValue,
          min_purchase_amount: data.minPurchaseAmount,
          max_discount_amount: data.maxDiscountAmount,
          is_cumulative: data.isCumulative,
          start_date: data.startDate,
          end_date: data.endDate,
          is_active: true,
          points_required: data.pointsRequired,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) throw error;

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
    const { data, error } = await supabase
      .from('offers')
      .select(`
        *,
        articles:offer_articles(articles(*))
      `)
      .eq('is_active', true)
      .lte('startDate', new Date().toISOString())
      .gte('endDate', new Date().toISOString());

    if (error) throw error;
    return data;
  }

  static async getOfferById(offerId: string): Promise<Offer> {
    const { data, error } = await supabase
      .from('offers')
      .select(`
        *,
        articles:offer_articles(articles(*))
      `)
      .eq('id', offerId)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Offer not found');
    
    return data;
  }

  static async updateOffer(offerId: string, updateData: Partial<CreateOfferDTO>): Promise<Offer> {
    const { articleIds, ...offerDetails } = updateData;

    const { data, error } = await supabase
      .from('offers')
      .update({
        ...offerDetails,
        updated_at: new Date()
      })
      .eq('id', offerId)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Offer not found');

    // Handle article IDs update if provided
    if (articleIds && articleIds.length > 0) {
      // First delete existing links
      await supabase
        .from('offer_articles')
        .delete()
        .eq('offer_id', offerId);

      // Create new article links
      const offerArticles = articleIds.map((articleId: string) => ({
        offer_id: offerId,
        article_id: articleId
      }));

      const { error: linkError } = await supabase
        .from('offer_articles')
        .insert(offerArticles);

      if (linkError) throw linkError;
    }

    return data;
  }

  static async deleteOffer(offerId: string): Promise<void> {
    const { error } = await supabase
      .from('offers')
      .delete()
      .eq('id', offerId);

    if (error) throw error;
  }

  static async toggleOfferStatus(offerId: string, isActive: boolean): Promise<Offer> {
    const { data, error } = await supabase
      .from('offers')
      .update({
        is_active: isActive,
        updated_at: new Date()
      })
      .eq('id', offerId)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Offer not found');

    return data;
  }

  static async subscribeToOffer(
    userId: string, 
    offerId: string
  ): Promise<OfferSubscription> {
    try {
      // 1. Check if offer exists and is active
      const { data: offer, error: offerError } = await supabase
        .from('offers')
        .select('*')
        .eq('id', offerId)
        .eq('is_active', true)
        .single();

      if (offerError || !offer) {
        throw new Error('Offer not found or inactive');
      }

      // 2. If offer is not cumulative, deactivate existing subscriptions
      if (!offer.is_cumulative) {
        await supabase
          .from('offer_subscriptions')
          .update({ 
            status: 'INACTIVE',
            updated_at: new Date()
          })
          .eq('user_id', userId);
      }

      // 3. Create new subscription
      const { data: subscription, error: subError } = await supabase
        .from('offer_subscriptions')
        .insert([{
          user_id: userId,
          offer_id: offerId,
          status: 'ACTIVE',
          subscribed_at: new Date(),
          updated_at: new Date()
        }])
        .select(`
          *,
          offer:offers(*)
        `)
        .single();

      if (subError) throw subError;

      // 4. Notify user
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
    const { data, error } = await supabase
      .from('offer_subscriptions')
      .select(`
        *,
        offer:offers(*)
      `)
      .eq('user_id', userId)
      .eq('status', 'ACTIVE');

    if (error) throw error;
    
    return data?.map(subscription => ({
      id: subscription.id,
      userId: subscription.user_id,
      offerId: subscription.offer_id,
      status: subscription.status,
      subscribedAt: new Date(subscription.subscribed_at),
      updatedAt: new Date(subscription.updated_at),
      offer: subscription.offer ? {
        id: subscription.offer.id,
        name: subscription.offer.name,
        description: subscription.offer.description,
        discountType: subscription.offer.discount_type,
        discountValue: subscription.offer.discount_value,
        minPurchaseAmount: subscription.offer.min_purchase_amount,
        maxDiscountAmount: subscription.offer.max_discount_amount,
        isCumulative: subscription.offer.is_cumulative,
        startDate: new Date(subscription.offer.start_date),
        endDate: new Date(subscription.offer.end_date),
        isActive: subscription.offer.is_active,
        pointsRequired: subscription.offer.points_required,
        createdAt: new Date(subscription.offer.created_at),
        updatedAt: new Date(subscription.offer.updated_at)
      } : undefined
    })) || [];
  }

  static async getSubscribers(offerId: string): Promise<OfferSubscription[]> {
    const { data, error } = await supabase
      .from('offer_subscriptions')
      .select(`
        *,
        user:users(
          id,
          email,
          first_name,
          last_name,
          phone
        ),
        offer:offers(*)
      `)
      .eq('offer_id', offerId)
      .eq('status', 'ACTIVE');

    if (error) throw error;
    
    return data?.map(subscription => ({
      id: subscription.id,
      userId: subscription.user_id,
      offerId: subscription.offer_id,
      status: subscription.status,
      subscribedAt: new Date(subscription.subscribed_at),
      updatedAt: new Date(subscription.updated_at),
      user: {
        id: subscription.user.id,
        email: subscription.user.email,
        firstName: subscription.user.first_name,
        lastName: subscription.user.last_name,
        phone: subscription.user.phone
      },
      offer: subscription.offer ? {
        id: subscription.offer.id,
        name: subscription.offer.name,
        description: subscription.offer.description,
        discountType: subscription.offer.discount_type,
        discountValue: subscription.offer.discount_value,
        minPurchaseAmount: subscription.offer.min_purchase_amount,
        maxDiscountAmount: subscription.offer.max_discount_amount,
        isCumulative: subscription.offer.is_cumulative,
        startDate: new Date(subscription.offer.start_date),
        endDate: new Date(subscription.offer.end_date),
        isActive: subscription.offer.is_active,
        pointsRequired: subscription.offer.points_required,
        createdAt: new Date(subscription.offer.created_at),
        updatedAt: new Date(subscription.offer.updated_at)
      } : undefined
    })) || [];
  }

  static async unsubscribeFromOffer(userId: string, offerId: string): Promise<void> {
    const { error } = await supabase
      .from('offer_subscriptions')
      .update({ 
        status: 'INACTIVE',
        updated_at: new Date()
      })
      .eq('user_id', userId)
      .eq('offer_id', offerId);

    if (error) throw error;
  }

  static async calculateOrderDiscounts(
    userId: string,
    subtotal: number
  ): Promise<{
    subtotal: number;
    discounts: Array<{offerId: string; amount: number}>;
    total: number;
  }> {
    try {
      const { data: subscriptions } = await supabase
        .from('offer_subscriptions')
        .select(`
          *,
          offer:offers(*)
        `)
        .eq('user_id', userId)
        .eq('status', 'ACTIVE');

      let total = subtotal;
      const discounts = [];

      if (subscriptions) {
        for (const sub of subscriptions) {
          const offer = sub.offer;
          if (!this.isOfferValid(offer, subtotal)) continue;

          const discountAmount = this.calculateDiscountAmount(
            offer,
            total
          );

          discounts.push({
            offerId: offer.id,
            amount: discountAmount
          });

          if (!offer.is_cumulative) break;
          total -= discountAmount;
        }
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
    const now = new Date();
    return (
      offer.is_active &&
      new Date(offer.start_date) <= now &&
      new Date(offer.end_date) >= now &&
      (!offer.min_purchase_amount || subtotal >= offer.min_purchase_amount)
    );
  }

  private static calculateDiscountAmount(offer: any, total: number): number {
    let amount = 0;
    
    if (offer.discount_type === OfferDiscountType.PERCENTAGE) {
      amount = (total * offer.discount_value) / 100;
    } else {
      amount = offer.discount_value;
    }

    if (offer.max_discount_amount) {
      amount = Math.min(amount, offer.max_discount_amount);
    }

    return amount;
  }

  private static formatOffer(data: any): Offer {
    return {
      id: data.id,
      name: data.name,
      description: data.description,
      discountType: data.discount_type,
      discountValue: data.discount_value,
      minPurchaseAmount: data.min_purchase_amount,
      maxDiscountAmount: data.max_discount_amount,
      isCumulative: data.is_cumulative,
      startDate: new Date(data.start_date),
      endDate: new Date(data.end_date),
      isActive: data.is_active,
      pointsRequired: data.points_required,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at)
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
      offer: data.offer ? this.formatOffer(data.offer) : undefined
    };
  }
}
