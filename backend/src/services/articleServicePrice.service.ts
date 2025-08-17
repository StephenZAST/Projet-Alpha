import { PrismaClient, Prisma } from '@prisma/client';
import { ArticleServicePrice, ArticleServiceUpdate } from '../models/types';

const prisma = new PrismaClient();

export class ArticleServicePriceService {
  // Retourne tous les couples article/serviceType disponibles avec prix, filtré par where
  static async getCouples(where: any) {
    try {
      const data = await prisma.article_service_prices.findMany({
        where,
        include: {
          articles: true,
          service_types: true,
          services: true
        }
      });
      // Format enrichi pour le frontend
      return data.map((item: any) => ({
        id: item.id,
        article_id: item.article_id,
        service_type_id: item.service_type_id,
        service_id: item.service_id ?? '',
  base_price: item.base_price !== null ? Number(item.base_price) : null,
  premium_price: item.premium_price !== null ? Number(item.premium_price) : null,
        price_per_kg: item.price_per_kg !== null ? Number(item.price_per_kg) : null,
        is_available: item.is_available,
        created_at: item.created_at,
        updated_at: item.updated_at,
        article_name: item.articles?.name ?? '',
        article_description: item.articles?.description ?? '',
        service_type_name: item.service_types?.name ?? '',
        service_type_description: item.service_types?.description ?? '',
        service_type_pricing_type: item.service_types?.pricing_type ?? '',
        service_type_requires_weight: item.service_types?.requires_weight ?? false,
        service_type_supports_premium: item.service_types?.supports_premium ?? false,
        service_name: item.services?.name ?? '',
      }));
    } catch (error) {
      console.error('Error getting couples:', error);
      throw error;
    }
  }
  static async create(data: Omit<ArticleServicePrice, 'id' | 'created_at' | 'updated_at'>) {
    return await prisma.article_service_prices.create({
      data: {
        article_id: data.article_id,
        service_type_id: data.service_type_id,
        service_id: data.service_id ?? null,
        base_price: data.base_price,
        premium_price: data.premium_price,
        price_per_kg: data.price_per_kg,
        is_available: data.is_available
      }
    });
  }

  static async update(id: string, data: Partial<ArticleServicePrice>) {
    return await prisma.article_service_prices.update({
      where: { id },
      data: {
        ...data,
        service_id: data.service_id ?? undefined
      }
    });
  }

  static async getByArticleId(articleId: string) {
    return await prisma.article_service_prices.findMany({
      where: { article_id: articleId },
      include: {
        service_types: true
      }
    });
  }

  static async delete(id: string) {
    return await prisma.article_service_prices.delete({
      where: { id }
    });
  }

  static async setPrices(
    articleId: string,
    serviceTypeId: string,
    priceData: ArticleServiceUpdate
  ): Promise<ArticleServicePrice> {
    try {
      const price = await prisma.article_service_prices.upsert({
        where: {
          service_type_id_article_id_service_id: {
            service_type_id: serviceTypeId,
            article_id: articleId,
            service_id: priceData.service_id ?? ''
          }
        },
        update: {
          base_price: priceData.base_price ? new Prisma.Decimal(priceData.base_price) : undefined,
          premium_price: priceData.premium_price ? new Prisma.Decimal(priceData.premium_price) : null,
          price_per_kg: priceData.price_per_kg ? new Prisma.Decimal(priceData.price_per_kg) : null,
          is_available: priceData.is_available,
          service_id: priceData.service_id ?? undefined,
          updated_at: new Date()
        },
        create: {
          article_id: articleId,
          service_type_id: serviceTypeId,
          service_id: priceData.service_id ?? null,
          base_price: new Prisma.Decimal(priceData.base_price || 0),
          premium_price: priceData.premium_price ? new Prisma.Decimal(priceData.premium_price) : null,
          price_per_kg: priceData.price_per_kg ? new Prisma.Decimal(priceData.price_per_kg) : null,
          is_available: priceData.is_available,
          created_at: new Date(),
          updated_at: new Date()
        },
        include: {
          service_types: true
        }
      });

      return this.formatArticleServicePrice(price);
    } catch (error) {
      console.error('[ArticleServicePriceService] Set prices error:', error);
      throw error;
    }
  }

  static async getAllPrices() {
    try {
      const data = await prisma.article_service_prices.findMany();
      const result = await Promise.all(data.map(async (item: any) => {
        // Récupérer les entités associées
        const articlePromise = item.article_id ? prisma.articles.findUnique({ where: { id: item.article_id } }) : null;
        const serviceTypePromise = item.service_type_id ? prisma.service_types.findUnique({ where: { id: item.service_type_id } }) : null;
        const servicePromise = item.service_id ? prisma.services.findUnique({ where: { id: item.service_id } }) : null;
        const [article, serviceType, service] = await Promise.all([
          articlePromise,
          serviceTypePromise,
          servicePromise
        ]);
        return {
          id: item.id,
          article_id: item.article_id,
          service_type_id: item.service_type_id,
          service_id: item.service_id ?? '',
          base_price: item.base_price,
          premium_price: item.premium_price,
          price_per_kg: item.price_per_kg,
          is_available: item.is_available,
          created_at: item.created_at,
          updated_at: item.updated_at,
          article_name: article?.name ?? '',
          service_type_name: serviceType?.name ?? '',
          service_name: service?.name ?? ''
        };
      }));
      return result;
    } catch (error) {
      console.error('Error getting all prices:', error);
      throw error;
    }
  }

  static async getArticlePrices(articleId: string) {
    try {
      return await prisma.article_service_prices.findMany({
        where: {
          article_id: articleId
        },
        include: {
          service_types: true
        }
      });
    } catch (error) {
      console.error('Error getting article prices:', error);
      throw error;
    }
  }

  private static formatArticleServicePrice(data: any): ArticleServicePrice {
    return {
      id: data.id,
      article_id: data.article_id,
      service_type_id: data.service_type_id,
      service_id: data.service_id ?? '',
      base_price: Number(data.base_price),
      premium_price: data.premium_price ? Number(data.premium_price) : undefined,
      price_per_kg: data.price_per_kg ? Number(data.price_per_kg) : undefined,
      is_available: data.is_available,
      created_at: data.created_at,
      updated_at: data.updated_at,
      service_type: data.service_types || undefined
    };
  }
}
