import supabase from '../config/database';
import { ServiceCompatibility } from '../models/types';

interface ArticleServiceData {
  is_compatible: boolean;
  restrictions: string[];
  article: {
    id: string;
    name: string;
  };
  service: {
    id: string;
    name: string;
  };
}

export class CompatibilityValidatorService {
  static async validateOrderCompatibility(
    items: Array<{articleId: string; serviceId: string}>
  ) {
    try {
      const incompatibilities = [];

      for (const item of items) {
        const { data, error } = await supabase
          .from('article_service_compatibility')
          .select(`
            is_compatible,
            restrictions,
            article:articles!inner(
              id,
              name
            ),
            service:services!inner(
              id,
              name
            )
          `)
          .eq('article_id', item.articleId)
          .eq('service_id', item.serviceId)
          .single();

        if (error) throw error; 

        const typedData = data as unknown as ArticleServiceData;

        if (!typedData?.is_compatible) {
          incompatibilities.push({
            articleId: item.articleId,
            articleName: typedData.article.name,
            serviceId: item.serviceId,
            serviceName: typedData.service.name,
            restrictions: typedData.restrictions || []
          });
        }
      }

      return {
        isValid: incompatibilities.length === 0,
        incompatibilities
      };
    } catch (error) {
      console.error('[CompatibilityValidatorService] Validation error:', error);
      throw error;
    }
  }
}
