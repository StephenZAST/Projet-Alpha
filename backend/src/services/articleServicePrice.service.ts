import supabase from '../config/database';
import { ArticleServicePrice, CreateArticleServicePriceDTO, UpdateArticleServicePriceDTO } from '../models/serviceManagement.types';
import { ArticleServiceUpdate } from '../models/types';  // Ajout de l'import correct

export class ArticleServicePriceService {
  static async create(data: CreateArticleServicePriceDTO): Promise<ArticleServicePrice> {
    const { data: price, error } = await supabase
      .from('article_service_prices')
      .insert([{
        ...data,
        created_at: new Date(),
        updated_at: new Date()
      }])
      .select(`
        *,
        service_type:service_types(*),
        article:articles(*)
      `)
      .single();

    if (error) throw new Error(error.message);
    return price;
  }

  static async update(id: string, data: UpdateArticleServicePriceDTO): Promise<ArticleServicePrice> {
    const { data: price, error } = await supabase
      .from('article_service_prices')
      .update({
        ...data,
        updated_at: new Date()
      })
      .eq('id', id) 
      .select(`
        *,
        service_type:service_types(*),
        article:articles(*)
      `)
      .single();

    if (error) throw new Error(error.message);
    return price;
  }

  static async getByArticleId(articleId: string): Promise<ArticleServicePrice[]> {
    const { data, error } = await supabase
      .from('article_service_prices')
      .select(`
        *,
        service_type:service_types(*),
        article:articles(*)
      `)
      .eq('article_id', articleId);

    if (error) throw new Error(error.message);
    return data || [];
  }

  static async delete(id: string): Promise<void> {
    const { error } = await supabase
      .from('article_service_prices')
      .delete()
      .eq('id', id);

    if (error) throw new Error(error.message);
  }

  static async getAllPrices(): Promise<ArticleServicePrice[]> {
    const { data, error } = await supabase
      .from('article_service_prices')
      .select(`
        *,
        service_type:service_types(*)
      `);

    if (error) throw error;
    return data || [];
  }

  static async getArticlePrices(articleId: string): Promise<ArticleServicePrice[]> {
    const { data, error } = await supabase
      .from('article_service_prices')
      .select(`
        *,
        service_type:service_types(*)
      `)
      .eq('article_id', articleId);

    if (error) throw error;
    return data || [];
  }

  static async updatePrices(articleId: string, serviceTypeId: string, prices: {
    base_price?: number;
    premium_price?: number;
    price_per_kg?: number;
    is_available?: boolean;
  }): Promise<ArticleServicePrice> {
    const { data, error } = await supabase
      .from('article_service_prices')
      .update({
        ...prices,
        updated_at: new Date()
      })
      .eq('article_id', articleId)
      .eq('service_type_id', serviceTypeId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async setPrices(
    articleId: string,
    serviceTypeId: string,
    priceData: ArticleServiceUpdate  // Utilisation du type importé
  ): Promise<ArticleServicePrice> {
    try {
      const isValid = await this.validatePricing(priceData);
      if (!isValid) {
        throw new Error('Invalid pricing configuration');
      }

      // Extraire service_type_id de priceData pour éviter la duplication
      const { service_type_id, ...priceDataWithoutServiceType } = priceData;

      const { data, error } = await supabase
        .from('article_service_prices')
        .upsert({
          article_id: articleId,
          service_type_id: serviceTypeId,  // Utiliser le paramètre, pas celui de priceData
          ...priceDataWithoutServiceType,
          updated_at: new Date()
        })
        .select('*, service_type:service_types(*)')
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error setting prices:', error);
      throw error;
    }
  } 

  static async validatePricing(price: Partial<ArticleServicePrice>): Promise<boolean> {
    if (price.base_price !== undefined && price.base_price < 0) {
      return false;
    }
    if (price.premium_price !== undefined && price.premium_price < 0) {
      return false;
    }
    if (price.price_per_kg !== undefined && price.price_per_kg < 0) {
      return false;
    }
    if (price.premium_price && price.base_price && price.premium_price <= price.base_price) {
      return false;
    }
    return true;
  }
}
