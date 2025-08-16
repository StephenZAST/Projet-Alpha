import { PrismaClient, Prisma } from '@prisma/client';
import { WeightBasedPricing, CreateWeightPricingDTO, WeightRecordDTO } from '../models/weightPricing.types';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

const prisma = new PrismaClient();

export class WeightPricingService {
  static async createPricing(data: CreateWeightPricingDTO): Promise<WeightBasedPricing> {
    try {
      // Vérifier les chevauchements (à adapter si besoin, ici on ne filtre plus par serviceTypeId)
      const hasOverlap = await this.checkOverlappingRanges(
        data.min_weight,
        data.max_weight
      );
      if (hasOverlap) {
        throw new Error('Weight ranges cannot overlap');
      }
      const pricing = await prisma.weight_based_pricing.create({
        data: {
          min_weight: new Prisma.Decimal(data.min_weight),
          max_weight: new Prisma.Decimal(data.max_weight),
          price_per_kg: new Prisma.Decimal(data.price_per_kg),
          created_at: new Date(),
          updated_at: new Date()
        }
      });
      return {
        id: pricing.id,
        min_weight: Number(pricing.min_weight),
        max_weight: Number(pricing.max_weight),
        price_per_kg: Number(pricing.price_per_kg),
        created_at: pricing.created_at,
        updated_at: pricing.updated_at
      };
    } catch (error) {
      console.error('[WeightPricingService] Create pricing error:', error);
      throw error;
    }
  }

  private static async checkOverlappingRanges(
    minWeight: number,
    maxWeight: number
  ): Promise<boolean> {
    const existingRanges = await prisma.weight_based_pricing.findMany({
      where: {
        AND: [
          { min_weight: { lte: new Prisma.Decimal(maxWeight) } },
          { max_weight: { gte: new Prisma.Decimal(minWeight) } }
        ]
      }
    });
    return existingRanges.length > 0;
  }

  static async calculatePrice(weight: number): Promise<number> {
    const pricing = await prisma.weight_based_pricing.findFirst({
      where: {
        AND: [
          { min_weight: { lte: weight } },
          { max_weight: { gt: weight } }
        ]
      }
    });
    if (!pricing) {
      throw new Error('No pricing found for this weight range');
    }
    return Number(pricing.price_per_kg) * weight;
  }

  static async getAll() {
    try {
      return await prisma.weight_based_pricing.findMany({
        orderBy: {
          min_weight: 'asc'
        }
      });
    } catch (error) {
      console.error('Get all weight pricing error:', error);
      throw error;
    }
  }


  static async create(data: {
    minWeight: number;
    maxWeight: number;
    pricePerKg: number;
  }) {
    try {
      return await prisma.weight_based_pricing.create({
        data: {
          min_weight: data.minWeight,
          max_weight: data.maxWeight,
          price_per_kg: data.pricePerKg
        }
      });
    } catch (error) {
      console.error('Create weight pricing error:', error);
      throw error;
    }
  }

  static async update(id: string, data: {
    minWeight?: number;
    maxWeight?: number;
    pricePerKg?: number;
  }) {
    try {
      return await prisma.weight_based_pricing.update({
        where: { id },
        data: {
          min_weight: data.minWeight,
          max_weight: data.maxWeight,
          price_per_kg: data.pricePerKg,
          updated_at: new Date()
        }
      });
    } catch (error) {
      console.error('Update weight pricing error:', error);
      throw error;
    }
  }

  static async delete(id: string) {
    try {
      return await prisma.weight_based_pricing.delete({
        where: { id }
      });
    } catch (error) {
      console.error('Delete weight pricing error:', error);
      throw error;
    }
  }

  static async findByWeight(weight: number) {
    try {
      return await prisma.weight_based_pricing.findFirst({
        where: {
          AND: [
            { min_weight: { lte: weight } },
            { max_weight: { gte: weight } }
          ]
        }
      });
    } catch (error) {
      console.error('Find by weight error:', error);
      throw error;
    }
  }
}
