import supabase from '../config/database';
import { PriceHistoryEntry } from '../models/types';
import { priceUpdateEmitter } from '../events/priceUpdate.events';

export class ArticlePriceHistoryService {
  static async logPriceChange(
    articleId: string,
    serviceTypeId: string,
    oldPrice: {
      base_price?: number;
      premium_price?: number;
      price_per_kg?: number;
    },
    newPrice: {
      base_price?: number;
      premium_price?: number;
      price_per_kg?: number;
    },
    userId: string
  ): Promise<PriceHistoryEntry> {
    try {
      const { data, error } = await supabase
        .from('article_price_history')
        .insert([{
          article_id: articleId,
          service_type_id: serviceTypeId,
          old_price: oldPrice,
          new_price: newPrice,
          modified_by: userId,
          created_at: new Date() 
        }]) 
        .select(`
          *,
          modifier:users(id, email, firstName, lastName)
        `)
        .single();

      if (error) throw error;

      // Émettre l'événement de mise à jour
      priceUpdateEmitter.emit('price.updated', {
        articleId,
        serviceTypeId,
        oldPrice,
        newPrice,
        userId
      });

      return data;
    } catch (error) {
      console.error('[ArticlePriceHistoryService] Error logging price change:', error);
      throw error;
    }
  }

  static async getPriceHistory(articleId: string): Promise<PriceHistoryEntry[]> {
    const { data, error } = await supabase
      .from('article_price_history')
      .select(`
        *,
        modifier:users(id, email, firstName, lastName)
      `)
      .eq('article_id', articleId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }
}
