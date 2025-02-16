import supabase from '../config/database';
import { ServiceSpecificPrice } from '../models/types';

export class ServiceSpecificPriceService {
  static async setPrice(
    articleId: string,
    serviceId: string,
    basePrice: number,
    premiumPrice?: number
  ): Promise<ServiceSpecificPrice> {
    try {
      const { data, error } = await supabase
        .from('service_specific_prices')
        .upsert({
          article_id: articleId,
          service_id: serviceId,
          base_price: basePrice,
          premium_price: premiumPrice,
          updated_at: new Date()
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('[ServiceSpecificPriceService] Set price error:', error);
      throw error;
    }
  }
 
  static async getPrice(
    articleId: string,
    serviceId: string
  ): Promise<ServiceSpecificPrice | null> {
    const { data, error } = await supabase
      .from('service_specific_prices')
      .select('*')
      .eq('article_id', articleId)
      .eq('service_id', serviceId)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  static async getArticlePrices(articleId: string): Promise<ServiceSpecificPrice[]> {
    const { data, error } = await supabase
      .from('service_specific_prices')
      .select(`
        *,
        service:services(*)
      `)
      .eq('article_id', articleId);

    if (error) throw error;
    return data || [];
  }
}
