import supabase from '../config/database';
import { ServiceCompatibility } from '../models/types';

export class ServiceCompatibilityService {
  static async setCompatibility(
    articleId: string, 
    serviceId: string, 
    isCompatible: boolean,
    restrictions: string[] = []
  ): Promise<ServiceCompatibility> {
    try {
      const { data, error } = await supabase
        .from('article_service_compatibility')
        .upsert({
          article_id: articleId,
          service_id: serviceId,
          is_compatible: isCompatible,
          restrictions,
          updated_at: new Date()
        })
        .select(`
          *,
          article:articles(*),
          service:services(*)
        `)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('[ServiceCompatibilityService] Set compatibility error:', error);
      throw error;
    }
  }

  static async getCompatibilities(articleId: string): Promise<ServiceCompatibility[]> {
    try {
      const { data, error } = await supabase
        .from('article_service_compatibility')
        .select(`
          *,
          article:articles(*),
          service:services(*)
        `)
        .eq('article_id', articleId);

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('[ServiceCompatibilityService] Get compatibilities error:', error);
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
      console.error('[ServiceCompatibilityService] Check compatibility error:', error);
      throw error;
    }
  }
}
