import supabase from '../config/database';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

export class ServiceNotificationService {
  static async notifyServiceChange(
    serviceId: string,
    changes: { [key: string]: any }
  ): Promise<void> {
    try {
      const { data: service, error } = await supabase
        .from('services')
        .select('name')
        .eq('id', serviceId)
        .single();

      if (error) throw error;

      // 1. Notifier les administrateurs
      const { data: admins } = await supabase
        .from('users')
        .select('id')
        .in('role', ['ADMIN', 'SUPER_ADMIN']);

      if (admins) {
        await Promise.all(
          admins.map(admin => 
            NotificationService.sendNotification(
              admin.id,
              NotificationType.SERVICE_UPDATED,
              {
                title: 'Service mis à jour',
                message: `Le service "${service?.name}" a été mis à jour`,
                data: {
                  serviceId,
                  serviceName: service?.name,
                  changes
                }
              }
            )
          )
        );
      }
 
      // 2. Notifier les utilisateurs ayant des commandes actives avec ce service
      const { data: activeOrders } = await supabase
        .from('orders')
        .select('user_id')
        .eq('service_id', serviceId)
        .in('status', ['PENDING', 'PROCESSING'])
        .not('user_id', 'in', admins?.map(a => a.id) || []);

      if (activeOrders) {
        const uniqueUserIds = [...new Set(activeOrders.map(order => order.user_id))];
        
        await Promise.all(
          uniqueUserIds.map(userId =>
            NotificationService.sendNotification(
              userId,
              NotificationType.SERVICE_UPDATED,
              {
                title: 'Mise à jour de service',
                message: `Le service "${service?.name}" que vous utilisez a été mis à jour`,
                data: {
                  serviceId,
                  serviceName: service?.name,
                  changes
                }
              }
            )
          )
        );
      }
    } catch (error) {
      console.error('[ServiceNotificationService] Notification error:', error);
      throw error;
    }
  }
}
