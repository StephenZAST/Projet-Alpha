import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class WeightPricingController {
  static async create(req: Request, res: Response) {
    try {
      const { minWeight, maxWeight, pricePerKg, serviceTypeId } = req.body;

      const weightPricing = await prisma.weight_based_pricing.create({
        data: {
          min_weight: minWeight,
          max_weight: maxWeight,
          price_per_kg: pricePerKg,
          service_type: {
            connect: { id: serviceTypeId }
          },
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      res.json({
        success: true,
        data: weightPricing
      });
    } catch (error) {
      console.error('Create weight pricing error:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to create weight pricing'
      });
    }
  }

  static async getAll(req: Request, res: Response) {
    try {
      const weightPricings = await prisma.weight_based_pricing.findMany({
        orderBy: {
          min_weight: 'asc'
        }
      });

      res.json({
        success: true,
        data: weightPricings
      });
    } catch (error) {
      console.error('Get weight pricings error:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to get weight pricings'
      });
    }
  }

  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { minWeight, maxWeight, pricePerKg } = req.body;

      const weightPricing = await prisma.weight_based_pricing.update({
        where: { id },
        data: {
          min_weight: minWeight,
          max_weight: maxWeight,
          price_per_kg: pricePerKg,
          updated_at: new Date()
        }
      });

      res.json({
        success: true,
        data: weightPricing
      });
    } catch (error) {
      console.error('Update weight pricing error:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to update weight pricing'
      });
    }
  }

  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      await prisma.weight_based_pricing.delete({
        where: { id }
      });

      res.json({
        success: true,
        message: 'Weight pricing deleted successfully'
      });
    } catch (error) {
      console.error('Delete weight pricing error:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to delete weight pricing'
      });
    }
  }

  static async calculatePrice(req: Request, res: Response) {
    try {
      const { weight, serviceTypeId } = req.query;

      if (!weight || isNaN(Number(weight))) {
        return res.status(400).json({
          success: false,
          error: 'Valid weight is required'
        });
      }

      const weightNum = Number(weight);
      const pricing = await prisma.weight_based_pricing.findFirst({
        where: {
          min_weight: {
            lte: weightNum
          },
          max_weight: {
            gte: weightNum
          }
        }
      });

      if (!pricing) {
        return res.status(404).json({
          success: false,
          error: 'No pricing found for this weight range'
        });
      }

      const totalPrice = weightNum * Number(pricing.price_per_kg);

      res.json({
        success: true,
        data: {
          basePrice: totalPrice,
          weight: weightNum,
          pricePerKg: pricing.price_per_kg
        }
      });
    } catch (error) {
      console.error('Calculate price error:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to calculate price'
      });
    }
  }
}
