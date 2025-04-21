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
      const data = await prisma.article_service_compatibility.upsert({
        where: {
          service_id_article_id: {
            article_id: articleId,
            service_id: serviceId
          }
        },
        update: {
          is_compatible: true
          // Suppression du champ updated_at qui n'existe pas dans le modèle
        },
        create: {
          article_id: articleId,
          service_id: serviceId,
          is_compatible: true
        },
        include: {
          articles: true,
          services: true
        }
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
