import supabase from '../config/database';
import { ArticleService } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class ArticleServiceService {
  static async createArticleService(articleId: string, serviceId: string, priceMultiplier: number): Promise<ArticleService> {
    const newArticleService: ArticleService = {
      id: uuidv4(),
      articleId: articleId,
      serviceId: serviceId,
      priceMultiplier: priceMultiplier,
      createdAt: new Date()
    };

    const { data, error } = await supabase
      .from('article_services')
      .insert([newArticleService])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getAllArticleServices(): Promise<ArticleService[]> {
    const { data, error } = await supabase
      .from('article_services')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async updateArticleService(articleServiceId: string, priceMultiplier: number): Promise<ArticleService> {
    const { data, error } = await supabase
      .from('article_services')
      .update({ priceMultiplier, updatedAt: new Date() })
      .eq('id', articleServiceId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async deleteArticleService(articleServiceId: string): Promise<void> {
    const { error } = await supabase
      .from('article_services')
      .delete()
      .eq('id', articleServiceId);

    if (error) throw error;
  }
}
