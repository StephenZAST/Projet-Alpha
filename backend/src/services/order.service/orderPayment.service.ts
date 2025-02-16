import supabase from '../../config/database';
import { AppliedDiscount } from '../../models/types';

export class OrderPaymentService {
  static async getCurrentLoyaltyPoints(userId: string): Promise<number> {
    try {
      const { data, error } = await supabase
        .from('loyalty_points')
        .select('pointsBalance')
        .eq('user_id', userId)
        .single();

      if (error) {
        console.error('[OrderPaymentService] Error fetching loyalty points:', error);
        throw error;
      }

      return data?.pointsBalance || 0;
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

    const { data: availableOffers } = await supabase
      .from('offers')
      .select('*, articles:offer_articles(article_id)')
      .eq('is_active', true)
      .lte('start_date', new Date().toISOString())
      .gte('end_date', new Date().toISOString())
      .in('id', appliedOfferIds);

    if (!availableOffers) return { finalAmount, appliedDiscounts };

    const sortedOffers = availableOffers.sort((a, b) =>
      (a.isCumulative === b.isCumulative) ? 0 : a.isCumulative ? 1 : -1
    );

    for (const offer of sortedOffers) {
      const offerArticleIds = offer.articles.map((a: any) => a.article_id);
      const hasValidArticles = articleIds.some(id => offerArticleIds.includes(id));

      if (!hasValidArticles) continue;
      if (offer.minPurchaseAmount && totalAmount < offer.minPurchaseAmount) continue;

      let discountAmount = 0;

      switch (offer.discountType) {
        case 'PERCENTAGE':
          discountAmount = (totalAmount * offer.discountValue) / 100;
          break;
        case 'FIXED_AMOUNT':
          discountAmount = offer.discountValue;
          break;
        case 'POINTS_EXCHANGE':
          const { data: loyalty } = await supabase
            .from('loyalty_points')
            .select('points_balance')
            .eq('user_id', userId)
            .single();

          if (!loyalty || loyalty.points_balance < offer.pointsRequired!) continue;

          discountAmount = offer.discountValue;

          await supabase
            .from('loyalty_points')
            .update({
              points_balance: loyalty.points_balance - offer.pointsRequired!
            })
            .eq('user_id', userId);
          break;
      }

      if (offer.maxDiscountAmount) {
        discountAmount = Math.min(discountAmount, offer.maxDiscountAmount);
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
    // 1. Vérifier si l'affilié existe
    const { data: affiliate, error: affiliateError } = await supabase
      .from('affiliate_profiles')
      .select(`
        *,
        level:affiliate_levels!left(
          id,
          commissionRate
        ),
        user:users(
          email,
          first_name,
          last_name
        )
      `)
      .eq('affiliate_code', affiliateCode)
      .single();

    if (affiliateError) {
      console.error('[OrderPaymentService] Error finding affiliate:', affiliateError);
      throw new Error('Failed to find affiliate');
    }

    if (!affiliate) {
      console.error('[OrderPaymentService] No affiliate found for code:', affiliateCode);
      throw new Error('Affiliate not found');
    }

    // 2. Vérifier le statut et l'état actif
    if (!affiliate.is_active || affiliate.status !== 'ACTIVE') {
      console.error('[OrderPaymentService] Affiliate is not active:', {
        code: affiliateCode,
        is_active: affiliate.is_active,
        status: affiliate.status,
        user: affiliate.user
      });
      throw new Error(`Affiliate is not active. Status: ${affiliate.status}, IsActive: ${affiliate.is_active}`);
    }

    console.log('[OrderPaymentService] Found active affiliate:', {
      id: affiliate.id,
      code: affiliate.affiliate_code,
      level: affiliate.level,
      user: affiliate.user
    });

    try {
      const commissionRate = affiliate.level?.commissionRate || affiliate.commission_rate || 10;
      const commissionAmount = totalAmount * (commissionRate / 100);

      const { error: updateError } = await supabase
        .from('affiliate_profiles')
        .update({
          commission_balance: affiliate.commission_balance + commissionAmount,
          total_earned: affiliate.total_earned + commissionAmount,
          total_referrals: affiliate.total_referrals + 1
        })
        .eq('id', affiliate.id);

      if (updateError) {
        console.error('[OrderPaymentService] Error updating affiliate balance:', updateError);
        throw new Error(`Failed to update affiliate balance: ${updateError.message || 'Unknown error'}`);
      }

      const { error: transactionError } = await supabase
        .from('commissionTransactions')
        .insert([{
          affiliate_id: affiliate.id,
          order_id: orderId,
          amount: commissionAmount,
          status: 'PENDING',
          created_at: new Date()
        }]);

      if (transactionError) {
        console.error('[OrderPaymentService] Error creating commission transaction:', transactionError);
        throw new Error(`Failed to create commission transaction: ${transactionError.message || 'Unknown error'}`);
      }
    } catch (error) {
      console.error('[OrderService] Error processing affiliate commission:', error);
      throw error;
    }
  }

  static async calculateTotal(items: { articleId: string; quantity: number }[]): Promise<number> {
    let totalAmount = 0;

    const { data: articles } = await supabase
      .from('articles')
      .select('*')
      .in('id', items.map(item => item.articleId));

    if (!articles || articles.length !== items.length) {
      throw new Error('One or more articles not found');
    }

    items.forEach(item => {
      const article = articles.find(a => a.id === item.articleId);
      if (article) {
        totalAmount += article.basePrice * item.quantity;
      }
    });

    return totalAmount;
  }

  static async updatePaymentStatus(
    orderId: string,
    paymentStatus: string,
    userId: string
  ): Promise<void> {
    const { error } = await supabase
      .from('orders')
      .update({
        paymentStatus,
        updatedAt: new Date()
      })
      .eq('id', orderId);

    if (error) throw error;
  }
}