import supabase from '../config/database';
import { NotificationService } from './notification.service'; 
import { 
  AdditionalService, 
  OrderAdditionalService, 
  CreateAdditionalServiceDTO 
} from '../models/additionalService.types';
import { NotificationType } from '../models/types';

export class AdditionalServiceService {
  static async createService(data: CreateAdditionalServiceDTO): Promise<AdditionalService> {
    try {
      const { data: service, error } = await supabase
        .from('additional_services')
        .insert([{
          ...data,
          is_active: true,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select() 
        .single();

      if (error) throw error;

      // Notifier les admins
      const { data: admins } = await supabase
        .from('users')
        .select('id')
        .in('role', ['ADMIN', 'SUPER_ADMIN']);

      // Envoyer une notification à chaque admin
      const notificationPromises = (admins || []).map(admin => 
        NotificationService.sendNotification(
          admin.id,
          NotificationType.SERVICE_CREATED,
          {
            title: 'Nouveau service créé',
            message: `Le service ${service.name} a été créé`,
            data: {
              serviceId: service.id,
              serviceName: service.name,
              serviceType: service.type
            }
          }
        )
      );

      await Promise.all(notificationPromises);

      return service;
    } catch (error) {
      console.error('[AdditionalServiceService] Create service error:', error);
      throw error;
    }
  }

  static async addServiceToOrder(
    orderId: string,
    serviceData: { service_id: string; item_id?: string; notes?: string }
  ): Promise<OrderAdditionalService> {
    try {
      // 1. Obtenir le prix du service
      const { data: service, error: serviceError } = await supabase
        .from('additional_services')
        .select('price, name, type')
        .eq('id', serviceData.service_id)
        .single();

      if (serviceError || !service) throw new Error('Service not found');

      // 2. Créer l'entrée dans order_additional_services
      const { data: orderService, error } = await supabase
        .from('order_additional_services')
        .insert([{
          order_id: orderId,
          service_id: serviceData.service_id,
          item_id: serviceData.item_id,
          notes: serviceData.notes,
          price: service.price,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select(`
          *,
          service:additional_services(*)
        `)
        .single();

      if (error) throw error;

      // 3. Obtenir les administrateurs pour la notification
      const { data: admins } = await supabase
        .from('users')
        .select('id')
        .in('role', ['ADMIN', 'SUPER_ADMIN']);

      // 4. Notifier les administrateurs
      const notificationPromises = (admins || []).map(admin => 
        NotificationService.sendNotification(
          admin.id,
          NotificationType.SERVICE_ADDED,
          {
            title: 'Service additionnel ajouté',
            message: `Le service ${service.name} a été ajouté à la commande ${orderId}`,
            data: {
              orderId: orderId,
              serviceName: service.name,
              serviceType: service.type,
              notes: serviceData.notes
            }
          }
        )
      ); 

      await Promise.all(notificationPromises);

      return orderService;
    } catch (error) {
      console.error('[AdditionalServiceService] Add service to order error:', error);
      throw error;
    }
  }

  static async getOrderServices(orderId: string): Promise<OrderAdditionalService[]> {
    const { data, error } = await supabase
      .from('order_additional_services')
      .select(`
        *,
        service:additional_services(*)
      `)
      .eq('order_id', orderId);

    if (error) throw error;
    return data || [];
  }

  static async getActiveServices(): Promise<AdditionalService[]> {
    const { data, error } = await supabase
      .from('additional_services')
      .select('*')
      .eq('is_active', true)
      .order('created_at', { ascending: true });

    if (error) throw error;
    return data;
  }
}
