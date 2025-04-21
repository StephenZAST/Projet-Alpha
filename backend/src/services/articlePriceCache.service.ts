import NodeCache from 'node-cache';
import { PrismaClient } from '@prisma/client';
import { ArticleServicePrice, ServiceType } from '../models/types';
import { pricingConfig } from '../config/pricing.config';

const prisma = new PrismaClient();

export class ArticlePriceCacheService {
  private static cache = new NodeCache({ 
    stdTTL: pricingConfig.cacheDuration,
    checkperiod: 120
  });

  static async getPrices(articleId: string, serviceTypeId: string): Promise<ArticleServicePrice | null> {
    const cacheKey = `price_${articleId}_${serviceTypeId}`;
    let prices = this.cache.get<ArticleServicePrice>(cacheKey);

    if (!prices) {
      try {
        const data = await prisma.article_service_prices.findFirst({
          where: {
            article_id: articleId,
            service_type_id: serviceTypeId
          },
          include: {
            service_types: true
          }
        });

        if (data && data.article_id && data.service_type_id) {
          // Construction du ServiceType avec gestion stricte des types
          const serviceType: ServiceType | undefined = data.service_types ? {
            id: data.service_types.id,
            name: data.service_types.name,
            description: data.service_types.description || undefined,
            is_default: Boolean(data.service_types.is_default),
            requires_weight: Boolean(data.service_types.requires_weight),
            supports_premium: Boolean(data.service_types.supports_premium),
            is_active: Boolean(data.service_types.is_active),
            created_at: data.service_types.created_at || new Date(),
            updated_at: data.service_types.updated_at || new Date()
          } : undefined;

          // Construction de l'ArticleServicePrice avec gestion stricte des types
          prices = {
            id: data.id,
            article_id: data.article_id,
            service_type_id: data.service_type_id,
            base_price: Number(data.base_price),
            premium_price: data.premium_price ? Number(data.premium_price) : undefined,
            price_per_kg: data.price_per_kg ? Number(data.price_per_kg) : undefined,
            is_available: Boolean(data.is_available),
            created_at: data.created_at?.toISOString() || new Date().toISOString(),
            updated_at: data.updated_at?.toISOString() || new Date().toISOString(),
            service_type: serviceType
          };
          
          this.cache.set(cacheKey, prices);
        }
      } catch (error) {
        console.error('[ArticlePriceCacheService] Cache error:', error);
        return null;
      }
    }

    return prices || null;
  }

  static async invalidatePrice(articleId: string, serviceTypeId: string): Promise<void> {
    const cacheKey = `price_${articleId}_${serviceTypeId}`;
    this.cache.del(cacheKey);
  }
}
