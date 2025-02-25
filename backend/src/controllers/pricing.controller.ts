import { Request, Response } from 'express';
import { PricingService } from '../services/pricing.service';
import { PriceCalculationParams } from '../models/pricing.types'; 

export class PricingController {
  static async calculatePrice(req: Request, res: Response) {
    try {
      const priceParams: PriceCalculationParams = {
        articleId: req.body.articleId,
        serviceTypeId: req.body.serviceTypeId,
        quantity: req.body.quantity,
        weight: req.body.weight,
        isPremium: req.body.isPremium
      };

      const priceDetails = await PricingService.calculatePrice(priceParams);

      res.json({
        success: true,
        data: priceDetails
      });
    } catch (error) {
      console.error('[PricingController] Calculate price error:', error);
      res.status(400).json({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }  

  static async getPricingConfiguration(req: Request, res: Response) {
    try {
      const { serviceTypeId } = req.params;
      const { data: pricing, error } = await PricingService.getPricingConfiguration(serviceTypeId);

      if (error) throw error;

      res.json({
        success: true,
        data: pricing
      });
    } catch (error) {
      console.error('[PricingController] Get pricing configuration error:', error);
      res.status(400).json({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}
