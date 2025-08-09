import { PrismaClient } from '@prisma/client';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

const prisma = new PrismaClient();

export class ArticleRestrictionService {
  static async setRestrictions(
    articleId: string, 
    serviceId: string
  ) {

    try {
      // Migration : on utilise la table centralisée service_specific_prices
      const data = await prisma.article_service_prices.upsert({
        where: {
          service_type_id_article_id_service_id: {
            service_type_id: serviceId,
            article_id: articleId,
            service_id: ''
          }
        },
        update: {
          is_available: true,
          updated_at: new Date()
        },
        create: {
          article_id: articleId,
          service_type_id: serviceId,
          base_price: 0, // valeur par défaut, à ajuster si besoin
          is_available: true,
          created_at: new Date(),
          updated_at: new Date()
        },
        include: {}
      });


      // Notifier les administrateurs des changements
      const admins = await prisma.users.findMany({
        where: {
          role: {
            in: ['ADMIN', 'SUPER_ADMIN']
          }
        },
        select: {
          id: true
        }
      });

      await Promise.all(
        admins.map(admin => 
          NotificationService.sendNotification(
            admin.id,
            NotificationType.SERVICE_UPDATED,
            {
              title: 'Restrictions mises à jour',
              message: `Les restrictions pour l'article ont été mises à jour`,
              data: { articleId, serviceId }
            }
          )
        )
      );

      return data;
    } catch (error) {
      console.error('[ArticleRestrictionService] Set restrictions error:', error);
      throw error;
    }
  }
}
