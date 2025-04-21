import { PrismaClient } from '@prisma/client';
import { ServiceCompatibility } from '../models/types';

const prisma = new PrismaClient();

export class CompatibilityValidatorService {
  static async validateOrderCompatibility(
    items: Array<{articleId: string; serviceId: string}>
  ) {
    try {
      const incompatibilities = [];

      for (const item of items) {
        const compatibility = await prisma.article_service_compatibility.findFirst({
          where: {
            article_id: item.articleId,
            service_id: item.serviceId
          },
          include: {
            articles: {
              select: {
                id: true,
                name: true
              }
            },
            services: {
              select: {
                id: true,
                name: true
              }
            }
          }
        });

        if (!compatibility?.is_compatible) {
          incompatibilities.push({
            articleId: item.articleId,
            articleName: compatibility?.articles?.name || 'Unknown Article',
            serviceId: item.serviceId,
            serviceName: compatibility?.services?.name || 'Unknown Service',
            restrictions: []
          });
        }
      }

      return {
        isValid: incompatibilities.length === 0,
        incompatibilities
      };
    } catch (error) {
      console.error('[CompatibilityValidatorService] Validation error:', error);
      throw error;
    }
  }
}
