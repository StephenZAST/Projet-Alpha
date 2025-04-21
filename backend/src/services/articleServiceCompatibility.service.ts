import { PrismaClient } from '@prisma/client';
import { ArticleServiceCompatibility } from '../models/types'; 
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

export class ArticleServiceCompatibilityService {
  static async setCompatibility(
    articleId: string,
    serviceId: string,
    isCompatible: boolean
  ): Promise<ArticleServiceCompatibility> {
    try {
      const data = await prisma.article_service_compatibility.upsert({
        where: {
          service_id_article_id: {
            article_id: articleId,
            service_id: serviceId
          }
        },
        update: {
          is_compatible: isCompatible // Corrected field name
        },
        create: {
          id: uuidv4(),
          article_id: articleId,
          service_id: serviceId,
          is_compatible: isCompatible // Corrected field name
        }
      });

      // Transformation des données pour correspondre au type ArticleServiceCompatibility
      return {
        id: data.id,
        article_id: data.article_id || '',
        service_id: data.service_id || '',
        is_compatible: data.is_compatible, // Corrected field name
        created_at: new Date(),
        updated_at: new Date()
      };
    } catch (error) {
      console.error('[ArticleServiceCompatibilityService] Set compatibility error:', error);
      throw error;
    }
  }

  static async checkCompatibility(
    articleId: string,
    serviceId: string
  ): Promise<boolean> {
    try {
      const data = await prisma.article_service_compatibility.findUnique({
        where: {
          service_id_article_id: {
            article_id: articleId,
            service_id: serviceId
          }
        }
      });

      return data?.is_compatible ?? false; // Corrected field name
    } catch (error) {
      console.error('[ArticleServiceCompatibilityService] Check compatibility error:', error);
      throw error;
    }
  }

  static async getArticleCompatibilities(articleId: string): Promise<ArticleServiceCompatibility[]> {
    const data = await prisma.article_service_compatibility.findMany({
      where: { article_id: articleId },
      include: {
        services: true
      }
    });

    return data.map(item => ({
      id: item.id,
      article_id: item.article_id || '',
      service_id: item.service_id || '',
      is_compatible: item.is_compatible, // Corrected field name
      service: item.services ? {
        id: item.services.id,
        name: item.services.name,
        description: item.services.description || undefined
      } : undefined,
      created_at: new Date(),
      updated_at: new Date()
    }));
  }
}
