import { PrismaClient } from '@prisma/client';
import { ServiceSpecificPrice } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import Decimal from 'decimal.js';

const prisma = new PrismaClient();

export class ServiceSpecificPriceService {
  // Nouvelle version : utilise la table centralisée et la fonction stockée
  static async getCentralizedPrice(articleId: string, serviceTypeId: string, weight?: number): Promise<number | null> {
    try {
      // Appel direct à la fonction stockée pour obtenir le prix
      const result = await prisma.$queryRaw`SELECT public.calculate_service_price(${articleId}, ${serviceTypeId}, ${weight ?? null}) AS price`;
      if (Array.isArray(result) && result.length > 0 && result[0].price !== null) {
        return Number(result[0].price);
      }
      return null;
    } catch (error) {
      console.error('[ServiceSpecificPriceService] Centralized price error:', error);
      throw error;
    }
  }
}
