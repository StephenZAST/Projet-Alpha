import NodeCache from 'node-cache';
import { ArticleServicePrice } from '../models/types';
import { pricingConfig } from '../config/pricing.config';
import supabase from '../config/database';

export class ArticlePriceCacheService {
  private static cache = new NodeCache({ 
    stdTTL: pricingConfig.cacheDuration,
    checkperiod: 120
  });

  static async getPrices(articleId: string, serviceTypeId: string): Promise<ArticleServicePrice | null> {
    const cacheKey = `price_${articleId}_${serviceTypeId}`;
    let prices = this.cache.get<ArticleServicePrice>(cacheKey);

    if (!prices) {
      try {
        // Récupérer de la base de données
        const { data, error } = await supabase
          .from('article_service_prices')
          .select('*')
          .eq('article_id', articleId)
          .eq('service_type_id', serviceTypeId)
          .single();

        if (error) throw error;
        if (data) {
          prices = data; 
          this.cache.set(cacheKey, prices);
        }
      } catch (error) {
        console.error('[ArticlePriceCacheService] Cache error:', error);
        return null;
      }
    } 

    return prices || null;
  }

  static async invalidatePrice(articleId: string, serviceTypeId: string): Promise<void> {
    const cacheKey = `price_${articleId}_${serviceTypeId}`;
    this.cache.del(cacheKey);
  }
}
