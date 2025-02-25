import supabase from '../config/database';
import { ServiceCompatibility } from '../models/types'; 

export class ServiceCompatibilityService {
  static async setCompatibility(
articleId: string, serviceId: string, isCompatible: boolean, restrictions: any  ): Promise<ServiceCompatibility> {
    try {
      const { data, error } = await supabase
        .from('service_compatibilities')
        .upsert({
          article_id: articleId,
          service_id: serviceId,
          is_compatible: isCompatible,
          updated_at: new Date()
        })
        .select(`
          *,
          article:articles(id, name),
          service:services(id, name)
        `)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error setting compatibility:', error);
      throw error;
    }
  } 

  static async getCompatibilities(articleId: string): Promise<ServiceCompatibility[]> {
    const { data, error } = await supabase
      .from('service_compatibilities')
      .select(`
        *,
        article:articles(id, name),
        service:services(id, name)
      `)
      .eq('article_id', articleId);

    if (error) throw error;
    return data || [];
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
