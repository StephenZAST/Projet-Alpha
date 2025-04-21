import { PrismaClient } from '@prisma/client';
import { ServiceSpecificPrice } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import Decimal from 'decimal.js';

const prisma = new PrismaClient();

export class ServiceSpecificPriceService {
  private static convertToServiceSpecificPrice(prismaData: any): ServiceSpecificPrice {
    return {
      id: prismaData.id,
      article_id: prismaData.article_id,
      service_id: prismaData.service_id,
      base_price: Number(prismaData.base_price),
      premium_price: prismaData.premium_price ? Number(prismaData.premium_price) : undefined,
      is_available: prismaData.is_available,
      created_at: prismaData.created_at,
      updated_at: prismaData.updated_at
    };
  }

  static async setPrice(
    articleId: string,
    serviceId: string,
    basePrice: number,
    premiumPrice?: number
  ): Promise<ServiceSpecificPrice> {
    try {
      const existingPrice = await prisma.service_specific_prices.findFirst({
        where: {
          article_id: articleId,
          service_id: serviceId
        }
      });

      const priceData = existingPrice ? 
        await prisma.service_specific_prices.update({
          where: { id: existingPrice.id },
          data: {
            base_price: new Decimal(basePrice).toNumber(),
            premium_price: premiumPrice ? new Decimal(premiumPrice).toNumber() : null,
            updated_at: new Date()
          }
        }) :
        await prisma.service_specific_prices.create({
          data: {
            id: uuidv4(),
            article_id: articleId,
            service_id: serviceId,
            base_price: new Decimal(basePrice).toNumber(),
            premium_price: premiumPrice ? new Decimal(premiumPrice).toNumber() : null,
            is_available: true,
            created_at: new Date(),
            updated_at: new Date()
          }
        });

      return this.convertToServiceSpecificPrice(priceData);
    } catch (error) {
      console.error('[ServiceSpecificPriceService] Set price error:', error);
      throw error;
    }
  }

  static async getPrice(
    articleId: string,
    serviceId: string
  ): Promise<ServiceSpecificPrice | null> {
    try {
      const price = await prisma.service_specific_prices.findFirst({
        where: {
          article_id: articleId,
          service_id: serviceId
        }
      });

      if (!price) return null;

      return this.convertToServiceSpecificPrice(price);
    } catch (error) {
      console.error('[ServiceSpecificPriceService] Get price error:', error);
      throw error;
    }
  }

  static async getArticlePrices(articleId: string): Promise<ServiceSpecificPrice[]> {
    try {
      const prices = await prisma.service_specific_prices.findMany({
        where: {
          article_id: articleId
        },
        include: {
          services: true
        }
      });

      return prices.map(price => this.convertToServiceSpecificPrice(price));
    } catch (error) {
      console.error('[ServiceSpecificPriceService] Get article prices error:', error);
      throw error;
    }
  }
}
