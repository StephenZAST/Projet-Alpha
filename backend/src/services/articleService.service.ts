import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class ArticleServiceService {
  static async createArticleService(articleId: string, serviceId: string, priceMultiplier: number) {
    return await prisma.article_services.create({
      data: {
        article_id: articleId,
        service_id: serviceId,
        price_multiplier: priceMultiplier
      },
      include: {
        articles: true,
        services: true
      }
    });
  }

  static async getAllArticleServices() {
    return await prisma.article_services.findMany({
      include: {
        articles: true,
        services: true
      }
    });
  }

  static async updateArticleService(id: string, priceMultiplier: number) {
    return await prisma.article_services.update({
      where: { id },
      data: { price_multiplier: priceMultiplier },
      include: {
        articles: true,
        services: true
      }
    });
  }

  static async deleteArticleService(id: string) {
    return await prisma.article_services.delete({
      where: { id }
    });
  }

  static async getByArticleId(articleId: string) {
    return await prisma.article_services.findMany({
      where: { article_id: articleId },
      include: {
        services: true
      }
    });
  }
}
