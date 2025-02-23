import supabase from '../config/database';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types'; 

export class ArticleRestrictionService {
  static async setRestrictions(
    articleId: string, 
    serviceId: string, 
    restrictions: string[]
  ) {
    try {
      const { data, error } = await supabase
        .from('article_service_compatibility')
        .upsert({
          article_id: articleId,
          service_id: serviceId,
          restrictions,
          is_compatible: restrictions.length === 0,
          updated_at: new Date()
        })
        .select()
        .single(); 

      if (error) throw error;

      // Notifier les administrateurs des changements
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
                title: 'Restrictions mises à jour',
                message: `Les restrictions pour l'article ont été mises à jour`,
                data: { articleId, serviceId, restrictions }
              }
            )
          )
        );
      }

      return data;
    } catch (error) {
      console.error('[ArticleRestrictionService] Set restrictions error:', error);
      throw error;
    }
  }
}
