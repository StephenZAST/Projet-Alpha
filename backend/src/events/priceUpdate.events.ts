import { EventEmitter } from 'events';
import { ArticlePriceCacheService } from '../services/articlePriceCache.service';
import { NotificationService } from '../services/notification.service';
import { NotificationType } from '../models/types';
import supabase from '../config/database';

export const priceUpdateEmitter = new EventEmitter();

priceUpdateEmitter.on('price.updated', async (data) => {
  try {
    // 1. Invalider le cache
    await ArticlePriceCacheService.invalidatePrice(data.articleId, data.serviceTypeId);

    // 2. Récupérer les administrateurs
    const { data: admins, error } = await supabase
      .from('users')
      .select('id')
      .in('role', ['ADMIN', 'SUPER_ADMIN']);

    if (error) {
      throw new Error('Failed to fetch admin users');
    }

    const notificationType = NotificationType.PRICE_UPDATED;

    // 3. Notifier chaque administrateur
    const notificationPromises = admins.map(admin => 
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
