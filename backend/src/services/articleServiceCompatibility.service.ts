import supabase from '../config/database';
import { ArticleServiceCompatibility } from '../models/types';

export class ArticleServiceCompatibilityService {
  static async setCompatibility(
    articleId: string,
    serviceId: string,
    isCompatible: boolean
  ): Promise<ArticleServiceCompatibility> {
    try {
      const { data, error } = await supabase
        .from('article_service_compatibility')
        .upsert({
          article_id: articleId,
          service_id: serviceId,
          is_compatible: isCompatible,
          updated_at: new Date()
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('[ArticleServiceCompatibilityService] Set compatibility error:', error);
      throw error;
    }
  } 

  static async checkCompatibility(
    articleId: string,
    serviceId: string
  ): Promise<boolean> {
    try {
      const { data, error } = await supabase
        .from('article_service_compatibility')
        .select('is_compatible')
        .eq('article_id', articleId)
        .eq('service_id', serviceId)
        .single();

      if (error && error.code !== 'PGRST116') throw error;
      return data?.is_compatible ?? false;
    } catch (error) {
      console.error('[ArticleServiceCompatibilityService] Check compatibility error:', error);
      throw error;
    }
  }

  static async getArticleCompatibilities(articleId: string): Promise<ArticleServiceCompatibility[]> {
    const { data, error } = await supabase
      .from('article_service_compatibility')
      .select(`
        *,
        service:services(*)
      `)
      .eq('article_id', articleId);

    if (error) throw error;
    return data || [];
  }
}
