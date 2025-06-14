import { PrismaClient, Prisma } from '@prisma/client';
import { WeightBasedPricing, CreateWeightPricingDTO, WeightRecordDTO } from '../models/weightPricing.types';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

const prisma = new PrismaClient();

export class WeightPricingService {
  static async createPricing(data: CreateWeightPricingDTO): Promise<WeightBasedPricing> {
    try {
      // Vérifier le type de service d'abord
      const serviceType = await prisma.service_types.findUnique({
        where: { id: data.service_type_id }
      });

      if (!serviceType?.requires_weight) {
        throw new Error('This service type does not support weight-based pricing');
      }

      // Vérifier les chevauchements
      const hasOverlap = await this.checkOverlappingRanges(
        data.service_type_id,
        data.min_weight,
        data.max_weight
      );

      if (hasOverlap) {
        throw new Error('Weight ranges cannot overlap');
      }

      const pricing = await prisma.weight_based_pricing.create({
        data: {
          service_type: {
            connect: {
              id: data.service_type_id
            }
          },
          min_weight: new Prisma.Decimal(data.min_weight),
          max_weight: new Prisma.Decimal(data.max_weight),
          price_per_kg: new Prisma.Decimal(data.price_per_kg),
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      return {
        id: pricing.id,
        service_type_id: data.service_type_id,
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
    serviceTypeId: string,
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

  static async calculatePrice(service_type_id: string, weight: number): Promise<number> {
    const serviceType = await prisma.service_types.findUnique({
      where: { id: service_type_id }
    });

    if (!serviceType?.requires_weight) {
      throw new Error('This service type does not support weight-based pricing');
    }

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

    return Number(pricing.min_weight) * weight;
  }

  static async getPricingForService(serviceId: string): Promise<WeightBasedPricing[]> {
    const pricings = await prisma.weight_based_pricing.findMany({
      orderBy: { min_weight: 'asc' }
    });

    return pricings.map(pricing => ({
      id: pricing.id,
      service_type_id: serviceId,
      min_weight: Number(pricing.min_weight),
      max_weight: Number(pricing.max_weight),
      price_per_kg: 0, // Cette valeur devra être ajoutée au schéma Prisma
      created_at: new Date(),
      updated_at: new Date()
    }));
  }

  static async getAll(serviceTypeId?: string) {
    try {
      return await prisma.weight_based_pricing.findMany({
        where: serviceTypeId ? {
          service_type_id: serviceTypeId
        } : undefined,
        include: {
          service_type: true
        },
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
    serviceTypeId: string;
  }) {
    try {
      return await prisma.weight_based_pricing.create({
        data: {
          min_weight: data.minWeight,
          max_weight: data.maxWeight,
          price_per_kg: data.pricePerKg,
          service_type: {
            connect: {
              id: data.serviceTypeId
            }
          }
        },
        include: {
          service_type: true
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
