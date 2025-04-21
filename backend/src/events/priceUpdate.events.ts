import { EventEmitter } from 'events';
import { ArticlePriceCacheService } from '../services/articlePriceCache.service';
import { NotificationService } from '../services/notification.service';
import { NotificationType, User } from '../models/types';
import prisma from '../config/prisma';
import { user_role } from '@prisma/client';

interface PriceUpdateData {
  articleId: string;
  serviceTypeId: string;
  userId: string;
  oldPrice: number;
  newPrice: number;
}

export const priceUpdateEmitter = new EventEmitter();

priceUpdateEmitter.on('price.updated', async (data: PriceUpdateData) => {
  try {
    // 1. Invalider le cache
    await ArticlePriceCacheService.invalidatePrice(data.articleId, data.serviceTypeId);

    // 2. Récupérer les administrateurs
    const admins = await prisma.users.findMany({
      where: {
        role: {
          in: [user_role.ADMIN, user_role.SUPER_ADMIN]
        }
      },
      select: {
        id: true
      }
    });

    const notificationType = NotificationType.PRICE_UPDATED;

    // 3. Notifier chaque administrateur
    const notificationPromises = admins.map((admin: { id: string }) => 
      NotificationService.sendNotification(
        admin.id,
        notificationType,
        {
          title: 'Mise à jour des prix',
          message: `Prix mis à jour pour l'article ${data.articleId}`,
          data: {
            articleId: data.articleId,
            oldPrice: data.oldPrice,
            newPrice: data.newPrice,
            modifiedBy: data.userId
          }
        }
      )
    );

    await Promise.all(notificationPromises);

    // 4. Logger l'événement
    console.log('[PriceUpdateEvent] Price updated successfully:', {
      articleId: data.articleId,
      modifiedBy: data.userId,
      adminsNotified: admins.length
    });
  } catch (error) {
    console.error('[PriceUpdateEvent] Error handling price update:', error);
  }
});
