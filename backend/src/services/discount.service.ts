import supabase from '../config/database';
import { DiscountType, DiscountRule, Discount, DiscountResult } from '../models/discount.types';

export class DiscountService {
  static async calculateOrderDiscounts(params: {
    userId: string;
    subtotal: number;
    usePoints?: number;
    appliedOfferIds?: string[];
  }): Promise<DiscountResult> {
    try {
      const discounts: Discount[] = [];
      let remainingTotal = params.subtotal;

      // 1. First Order Discount
      const isFirstOrder = await this.isFirstOrder(params.userId);
      if (isFirstOrder) {
        const firstOrderDiscount = this.calculateFirstOrderDiscount(params.subtotal);
        discounts.push(firstOrderDiscount);
        remainingTotal -= firstOrderDiscount.amount;
      }

      // 2. Admin Offers
      if (params.appliedOfferIds && params.appliedOfferIds.length > 0) {
        const offerDiscounts = await this.calculateAdminOfferDiscounts(
          params.appliedOfferIds,
          remainingTotal,
          discounts.length === 0
        );
        discounts.push(...offerDiscounts);
        remainingTotal -= offerDiscounts.reduce((sum, d) => sum + d.amount, 0);
      }

      // 3. Loyalty Points
      if (params.usePoints && params.usePoints > 0) {
        const loyaltyDiscount = await this.calculateLoyaltyDiscount(
          params.userId,
          params.usePoints,
          remainingTotal
        );
        if (loyaltyDiscount) {
          discounts.push(loyaltyDiscount);
          remainingTotal -= loyaltyDiscount.amount;
        }
      }

      return {
        subtotal: params.subtotal,
        discounts,
        total: Math.max(0, remainingTotal)
      };
    } catch (error) {
      console.error('[DiscountService] Error calculating discounts:', error);
      throw error;
    }
  }

  private static async isFirstOrder(userId: string): Promise<boolean> {
    const { count } = await supabase
      .from('orders')
      .select('id', { count: 'exact' })
      .eq('user_id', userId);
    
    return count === 0;
  }

  private static calculateFirstOrderDiscount(subtotal: number): Discount {
    const amount = subtotal * 0.15; // 15% discount
    return {
      type: DiscountType.FIRST_ORDER,
      amount,
      description: 'Première commande (-15%)'
    };
  }

  private static async getActiveOffers(offerIds: string[]): Promise<DiscountRule[]> {
    const { data: offers } = await supabase
      .from('discount_rules')
      .select('*')
      .in('id', offerIds)
      .eq('isActive', true)
      .lte('startDate', new Date().toISOString())
      .gte('endDate', new Date().toISOString())
      .order('priority', { ascending: true });

    return offers || [];
  }

  private static async calculateAdminOfferDiscounts(
    offerIds: string[],
    remainingTotal: number,
    isFirstDiscount: boolean
  ): Promise<Discount[]> {
    const activeOffers = await this.getActiveOffers(offerIds);
    const discounts: Discount[] = [];

    for (const offer of activeOffers) {
      if (offer.isCumulative || isFirstDiscount || discounts.length === 0) {
        const amount = Math.min(
          remainingTotal * (offer.value / 100),
          offer.maxValue || Infinity
        );

        discounts.push({
          type: DiscountType.ADMIN_OFFER,
          amount,
          description: offer.name
        });
      }
    }

    return discounts;
  }

  private static async calculateLoyaltyDiscount(
    userId: string,
    points: number,
    remainingTotal: number
  ): Promise<Discount | null> {
    const { data: loyalty } = await supabase
      .from('loyalty_points')
      .select('pointsBalance')
      .eq('user_id', userId)
      .single();

    if (!loyalty || loyalty.pointsBalance < points) {
      return null;
    }

    const amount = Math.min(points / 100, remainingTotal); // 1 point = 0.01 currency
    return {
      type: DiscountType.LOYALTY,
      amount,
      description: `Points fidélité utilisés: ${points}`
    };
  }
}
