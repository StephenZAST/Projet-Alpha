import { PrismaClient } from '@prisma/client';
import { ServiceCompatibility } from '../models/types';

const prisma = new PrismaClient();

export class ServiceCompatibilityService {
  static async setCompatibility(
    articleId: string,
    serviceId: string,
    isCompatible: boolean,
    restrictions: any
  ): Promise<ServiceCompatibility> {
    try {
      const compatibility = await prisma.article_service_compatibility.upsert({
        where: {
          service_id_article_id: {
            article_id: articleId,
            service_id: serviceId
          }
        },
        update: {
          is_compatible: isCompatible
        },
        create: {
          article_id: articleId,
          service_id: serviceId,
          is_compatible: isCompatible
        },
        include: {
          articles: true,
          services: true
        }
      });

      return {
        id: compatibility.id,
        article_id: compatibility.article_id ?? '',
        service_id: compatibility.service_id ?? '',
        is_compatible: compatibility.is_compatible,
        article: compatibility.articles ? {
          id: compatibility.articles.id,
          name: compatibility.articles.name
        } : undefined,
        service: compatibility.services ? {
          id: compatibility.services.id,
          name: compatibility.services.name
        } : undefined,
        created_at: new Date(),
        updated_at: new Date()
      };
    } catch (error) {
      console.error('Error setting compatibility:', error);
      throw error;
    }
  }

  static async getCompatibilities(articleId: string): Promise<ServiceCompatibility[]> {
    try {
      const compatibilities = await prisma.article_service_compatibility.findMany({
        where: {
          article_id: articleId
        },
        include: {
          articles: true,
          services: true
        }
      });

      return compatibilities.map(comp => ({
        id: comp.id,
        article_id: comp.article_id ?? '',
        service_id: comp.service_id ?? '',
        is_compatible: comp.is_compatible,
        article: comp.articles ? {
          id: comp.articles.id,
          name: comp.articles.name
        } : undefined,
        service: comp.services ? {
          id: comp.services.id,
          name: comp.services.name
        } : undefined,
        created_at: new Date(),
        updated_at: new Date()
      }));
    } catch (error) {
      console.error('Error getting compatibilities:', error);
      throw error;
    }
  }

  static async checkCompatibility(
    articleId: string,
    serviceId: string
  ): Promise<boolean> {
    try {
      const compatibility = await prisma.article_service_compatibility.findUnique({
        where: {
          service_id_article_id: {
            article_id: articleId,
            service_id: serviceId
          }
        }
      });

      return compatibility?.is_compatible ?? false;
    } catch (error) {
      console.error('[ServiceCompatibilityService] Check compatibility error:', error);
      throw error;
    }
  }
}
