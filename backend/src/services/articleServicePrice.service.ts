import { PrismaClient, Prisma } from '@prisma/client';
import { ArticleServicePrice, ArticleServiceUpdate } from '../models/types';

const prisma = new PrismaClient();

export class ArticleServicePriceService {
  static async create(data: Omit<ArticleServicePrice, 'id' | 'created_at' | 'updated_at'>) {
    return await prisma.article_service_prices.create({
      data: {
        article_id: data.article_id,
        service_type_id: data.service_type_id,
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
      data
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
          service_type_id_article_id: {
            article_id: articleId,
            service_type_id: serviceTypeId
          }
        },
        update: {
          base_price: priceData.base_price ? new Prisma.Decimal(priceData.base_price) : undefined,
          premium_price: priceData.premium_price ? new Prisma.Decimal(priceData.premium_price) : null,
          price_per_kg: priceData.price_per_kg ? new Prisma.Decimal(priceData.price_per_kg) : null,
          is_available: priceData.is_available,
          updated_at: new Date()
        },
        create: {
          article_id: articleId,
          service_type_id: serviceTypeId,
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
      return await prisma.article_service_prices.findMany({
        include: {
          articles: true,
          service_types: true
        }
      });
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
