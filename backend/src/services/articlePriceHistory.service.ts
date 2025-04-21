import { PrismaClient } from '@prisma/client';
import { PriceHistoryEntry } from '../models/types';
import { priceUpdateEmitter } from '../events/priceUpdate.events';

const prisma = new PrismaClient();

export class ArticlePriceHistoryService {
  static async logPriceChange(
    articleId: string,
    serviceTypeId: string,
    oldPrice: {
      base_price?: number;
      premium_price?: number;
      price_per_kg?: number;
    },
    newPrice: {
      base_price?: number;
      premium_price?: number;
      price_per_kg?: number;
    },
    userId: string
  ): Promise<PriceHistoryEntry> {
    try {
      const priceHistory = await prisma.price_history.create({
        data: {
          id: userId,  // Utilisé comme stockage temporaire car requis par le schéma
          valid_from: new Date(),
          valid_to: null
        }
      });

      // Émettre l'événement de mise à jour
      priceUpdateEmitter.emit('price.updated', {
        articleId,
        serviceTypeId,
        oldPrice,
        newPrice,
        userId
      });

      return {
        id: priceHistory.id,
        article_id: articleId,
        service_type_id: serviceTypeId,
        old_price: oldPrice,
        new_price: newPrice,
        modified_by: userId,
        created_at: new Date(),
        modifier: await this.getModifierInfo(userId)
      };
    } catch (error) {
      console.error('[ArticlePriceHistoryService] Error logging price change:', error);
      throw error;
    }
  }

  static async getPriceHistory(articleId: string): Promise<PriceHistoryEntry[]> {
    try {
      const history = await prisma.price_history.findMany({
        orderBy: {
          valid_from: 'desc'
        }
      });

      const entries: PriceHistoryEntry[] = [];
      for (const entry of history) {
        const modifier = await this.getModifierInfo(entry.id);
        
        entries.push({
          id: entry.id,
          article_id: articleId,
          service_type_id: '',  // Not available in current schema
          old_price: {},  // Not available in current schema
          new_price: {},  // Not available in current schema
          modified_by: entry.id,
          created_at: entry.valid_from,
          modifier
        });
      }

      return entries;
    } catch (error) {
      console.error('[ArticlePriceHistoryService] Error getting price history:', error);
      throw error;
    }
  }

  private static async getModifierInfo(userId: string) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        first_name: true,
        last_name: true
      }
    });

    return user ? {
      id: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name
    } : undefined;
  }
}
