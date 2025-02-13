import supabase from '../config/database';
import { ArticleServicePrice, CreateArticleServicePriceDTO, UpdateArticleServicePriceDTO } from '../models/serviceManagement.types';

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
}
