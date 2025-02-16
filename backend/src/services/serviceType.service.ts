import supabase from '../config/database';
import { ServiceType, NotificationType } from '../models/types';
import { NotificationService } from './notification.service';

export class ServiceTypeService {
  static async create(data: Partial<ServiceType>): Promise<ServiceType> {
    try {
      const { data: serviceType, error } = await supabase
        .from('service_types')
        .insert([{
          name: data.name,
          description: data.description,
          is_default: data.is_default || false,
          requires_weight: data.requires_weight || false,
          supports_premium: data.supports_premium || false,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) throw new Error(error.message);
      return serviceType;
    } catch (error) {
      console.error('Error creating service type:', error);
      throw error;
    }
  }
 
  static async update(id: string, data: Partial<ServiceType>): Promise<ServiceType> {
    const { data: serviceType, error } = await supabase
      .from('service_types')
      .update({
        ...data,
        updated_at: new Date()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return serviceType;
  }

  static async delete(id: string): Promise<void> {
    const { error } = await supabase
      .from('service_types')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  static async getById(id: string): Promise<ServiceType> {
    const { data, error } = await supabase
      .from('service_types')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Service type not found');
    return data;
  }

  static async getAll(includeInactive = false): Promise<ServiceType[]> {
    const { data, error } = await supabase
      .from('service_types')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw error;
    return data || [];
  }

  static async getDefaultServiceType(): Promise<ServiceType | null> {
    try {
      const { data, error } = await supabase
        .from('service_types')
        .select('*')
        .eq('is_default', true)
        .single();

      if (error && error.code !== 'PGRST116') throw error;
      return data;
    } catch (error) {
      console.error('[ServiceTypeService] Get default service type error:', error);
      throw error;
    }
  }

  static async setDefaultServiceType(serviceTypeId: string): Promise<ServiceType> {
    try {
      // 1. Réinitialiser tous les services types comme non par défaut
      await supabase
        .from('service_types')
        .update({ is_default: false })
        .neq('id', serviceTypeId);

      // 2. Définir le nouveau service type par défaut
      const { data, error } = await supabase
        .from('service_types')
        .update({ is_default: true })
        .eq('id', serviceTypeId)
        .select()
        .single();

      if (error) throw error;
      if (!data) throw new Error('Service type not found');

      // 3. Notifier les admins du changement
      if (data) {
        await this.notifyAdmins(NotificationType.SERVICE_TYPE_UPDATED, data);
      }

      return data;
    } catch (error) {
      console.error('[ServiceTypeService] Set default service type error:', error);
      throw error;
    }
  }

  private static async notifyAdmins(
    type: NotificationType.SERVICE_TYPE_CREATED | NotificationType.SERVICE_TYPE_UPDATED,
    serviceType: ServiceType
  ) {
    const { data: admins } = await supabase
      .from('users')
      .select('id')
      .in('role', ['ADMIN', 'SUPER_ADMIN']);

    if (admins) {
      await Promise.all(
        admins.map(admin => 
          NotificationService.sendNotification(
            admin.id,
            type,
            {
              title: type === NotificationType.SERVICE_TYPE_CREATED ? 'Nouveau type de service' : 'Type de service mis à jour',
              message: `Le type de service "${serviceType.name}" a été ${type === NotificationType.SERVICE_TYPE_CREATED ? 'créé' : 'mis à jour'}`,
              data: serviceType
            }
          )
        )
      );
    }
  }
}
