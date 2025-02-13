import supabase from '../config/database';

export class DefaultServiceService {
  static async setDefaultService(
    categoryId: string,
    serviceId: string,
    restrictions: string[] = []
  ) {
    try {
      const { data, error } = await supabase
        .from('category_default_services')
        .upsert({
          category_id: categoryId,
          service_id: serviceId,
          restrictions: restrictions,
          updated_at: new Date()
        })
        .select(`
          *,
          service:services(*),
          category:categories(*)
        `)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('[DefaultServiceService] Set default service error:', error);
      throw error;
    }
  }

  static async getDefaultServices(categoryId: string) {
    const { data, error } = await supabase
      .from('category_default_services')
      .select(`
        *,
        service:services(*),
        category:categories(*)
      `)
      .eq('category_id', categoryId);

    if (error) throw error;
    return data || [];
  }

  static async removeDefaultService(categoryId: string, serviceId: string) {
    const { error } = await supabase
      .from('category_default_services')
      .delete()
      .match({ category_id: categoryId, service_id: serviceId });

    if (error) throw error;
  }
}
