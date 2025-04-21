import { Request, Response } from 'express';
import prisma from '../config/prisma';
import { handleError } from '../utils/errorHandler';

export class WeightPricingController {
  static async setWeightPrice(req: Request, res: Response) {
    try {
      const { service_type_id, min_weight, max_weight, price_per_kg } = req.body;

      if (!service_type_id || !min_weight || !max_weight || !price_per_kg) {
        return res.status(400).json({
          success: false,
          error: { message: 'All fields are required' }
        });
      }

      const data = await prisma.weight_based_pricing.create({
        data: {
          service_type_id, 
          min_weight: Number(min_weight),
          max_weight: Number(max_weight),
          price_per_kg: Number(price_per_kg),
          is_active: true,
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      res.status(201).json({ success: true, data });
    } catch (error: any) {
      handleError(res, error);
    }
  }

  static async calculatePrice(req: Request, res: Response) {
    try {
      const { service_type_id, weight } = req.body;

      if (!service_type_id || !weight) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'service_type_id and weight are required',
            code: 'VALIDATION_ERROR'
          }
        });
      }

      // Trouver la règle de prix applicable
      const pricing = await prisma.weight_based_pricing.findFirst({
        where: {
          service_type_id,
          min_weight: {
            lte: weight
          },
          max_weight: {
            gte: weight
          },
          is_active: true
        }
      });

      if (!pricing) {
        return res.status(404).json({
          success: false,
          error: {
            message: 'No pricing rule found for this weight range',
            code: 'PRICING_NOT_FOUND'
          }
        });
      }

      const price = Number(pricing.price_per_kg) * Number(weight);

      res.json({
        success: true,
        data: { price }
      });
    } catch (error: any) {
      handleError(res, error);
    }
  }

  static async getPricingForService(req: Request, res: Response) {
    try {
      const { service_type_id } = req.params;

      const data = await prisma.weight_based_pricing.findMany({
        where: {
          service_type_id,
          is_active: true
        },
        orderBy: {
          min_weight: 'asc'
        }
      });

      res.json({
        success: true,
        data
      });
    } catch (error: any) {
      handleError(res, error);
    }
  }
}
