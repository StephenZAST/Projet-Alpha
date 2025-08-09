import { PrismaClient } from '@prisma/client';
import { Article, ArticleServiceUpdate, CreateArticleDTO } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

export class ArticleService {
  static async createArticle(articleData: CreateArticleDTO): Promise<Article> {
    const { categoryId, name, description, basePrice, premiumPrice } = articleData;

    const data = await prisma.articles.create({
      data: {
        id: uuidv4(),
        categoryId,
        name,
        description,
        basePrice,
        premiumPrice,
        createdAt: new Date(),
        updatedAt: new Date(),
      }
    });

    return {
      id: data.id,
      name: data.name,
      categoryId: data.categoryId || '',
      description: data.description || '',
      basePrice: Number(data.basePrice),
      premiumPrice: data.premiumPrice ? Number(data.premiumPrice) : 0,
      createdAt: data.createdAt || new Date(),
      updatedAt: data.updatedAt || new Date()
    };
  }

  static async getArticleById(articleId: string): Promise<Article> {
    const data = await prisma.articles.findUnique({
      where: { id: articleId }
    });

    if (!data) throw new Error('Article not found');
    return {
      id: data.id,
      name: data.name,
      categoryId: data.categoryId || '',
      description: data.description || '',
      basePrice: Number(data.basePrice),
      premiumPrice: data.premiumPrice ? Number(data.premiumPrice) : 0,
      createdAt: data.createdAt || new Date(),
      updatedAt: data.updatedAt || new Date()
    };
  }

  static async getAllArticles(): Promise<Article[]> {
    try {
      const data = await prisma.articles.findMany({
        where: { isDeleted: false },
        include: {
          article_categories: true
        }
      });

      return data.map(article => ({
        id: article.id,
        name: article.name,
        categoryId: article.categoryId || '',
        description: article.description || '',
        basePrice: Number(article.basePrice),
        premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
        createdAt: article.createdAt || new Date(),
        updatedAt: article.updatedAt || new Date()
      }));
    } catch (error) {
      console.error('Error in getAllArticles:', error);
      throw error;
    }
  }

  static async getArticles(): Promise<Article[]> {
    try {
      const data = await prisma.articles.findMany({
        include: {
          article_categories: {
            select: { name: true }
          }
        }
      });

      return data.map(article => ({
        id: article.id,
        name: article.name,
        categoryId: article.categoryId || '',
        description: article.description || '',
        basePrice: Number(article.basePrice),
        premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
        createdAt: article.createdAt || new Date(),
        updatedAt: article.updatedAt || new Date(),
        category: article.article_categories?.name || 'Uncategorized'
      }));
    } catch (error) {
      console.error('Error in getArticles:', error);
      throw error;
    }
  }

  static async getArticlesForOrder(): Promise<Article[]> {
    try {
      const data = await prisma.articles.findMany({
        where: { isDeleted: false },
        include: {
          article_categories: {
            select: { name: true }
          }
        },
        orderBy: { name: 'asc' }
      });

      return data.map(article => ({
        id: article.id,
        name: article.name,
        categoryId: article.categoryId || '',
        description: article.description || '',
        basePrice: Number(article.basePrice),
        premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
        createdAt: article.createdAt || new Date(),
        updatedAt: article.updatedAt || new Date()
      }));
    } catch (error) {
      console.error('[ArticleService] Error getting articles for order:', error);
      throw error;
    }
  }

  static async getArticleWithServices(articleId: string) {
    const data = await prisma.articles.findUnique({
      where: { id: articleId },
      include: {
        article_service_prices: {
          include: {
            service_types: {
              select: {
                name: true,
                description: true,
                is_default: true
              }
            }
          }
        },
        article_categories: {
          select: {
            name: true,
            description: true
          }
        }
      }
    });

    if (!data) throw new Error('Article not found');
    return data;
  }

  static async updateArticleServices(
    articleId: string, 
    serviceUpdates: ArticleServiceUpdate[]
  ) {
    // Mise à jour en transaction pour assurer la cohérence
    return await prisma.$transaction(async (tx) => {
      for (const update of serviceUpdates) {
        await tx.article_service_prices.upsert({
          where: {
            service_type_id_article_id_service_id: {
              service_type_id: update.service_type_id,
              article_id: articleId,
              service_id: update.service_id ?? ''
            }
          },
          update: {
            base_price: update.base_price,
            premium_price: update.premium_price,
            price_per_kg: update.price_per_kg,
            is_available: update.is_available
          },
          create: {
            article_id: articleId,
            service_type_id: update.service_type_id,
            base_price: update.base_price || 0,
            premium_price: update.premium_price,
            price_per_kg: update.price_per_kg,
            is_available: update.is_available
          }
        });
      }
      return await tx.articles.findUnique({
        where: { id: articleId },
        include: { article_service_prices: true }
      });
    });
  }

  static async updateArticle(articleId: string, updateData: Partial<Article>) {
    try {
      const existingArticle = await prisma.articles.findUnique({
        where: { id: articleId }
      });

      if (!existingArticle) {
        throw new Error('Article not found');
      }

      const updatedArticle = await prisma.articles.update({
        where: { id: articleId },
        data: {
          name: updateData.name,
          description: updateData.description,
          basePrice: updateData.basePrice,
          premiumPrice: updateData.premiumPrice,
          categoryId: updateData.categoryId,
          updatedAt: new Date()
        }
      });

      return updatedArticle;
    } catch (error) {
      console.error('[ArticleService] Error updating article:', error);
      throw error;
    }
  }

  static async deleteArticle(articleId: string): Promise<void> {
    try {
      const existingArticle = await prisma.articles.findUnique({
        where: { id: articleId }
      });

      if (!existingArticle) {
        throw new Error('Article not found');
      }

      await prisma.articles.update({
        where: { id: articleId },
        data: {
          isDeleted: true,
          deletedAt: new Date()
        }
      });

    } catch (error) {
      console.error('[ArticleService] Error deleting article:', error);
      throw error;
    }
  }

  static async archiveArticle(articleId: string, reason: string): Promise<void> {
    try {
      await prisma.article_archives.create({
        data: {
          id: uuidv4(),
          original_id: articleId
        }
      });
    } catch (error) {
      console.error('[ArticleService] Error archiving article:', error);
      throw error;
    }
  }
}
