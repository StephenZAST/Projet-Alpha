import { Request, Response } from 'express';
import { ArticleService } from '../../services/article.service';
import { ServiceTypeService } from '../../services/serviceType.service';

export class ServiceManagementController {
  static async updateArticleServices(req: Request, res: Response) {
    try {
      const { articleId } = req.params;
      const serviceUpdates = req.body;

      const updatedServices = await ArticleService.updateArticleServices(
        articleId,
        serviceUpdates
      ); 

      res.json({
        success: true,
        data: updatedServices
      });
    } catch (error: any) {
      console.error('[ServiceManagementController] Update error:', error);
      res.status(400).json({ 
        success: false,
        message: error.message 
      });
    }
  }

  static async getServiceConfiguration(req: Request, res: Response) {
    try {
      const [serviceTypes, defaultService] = await Promise.all([
        ServiceTypeService.getAll(true), // Utilisation de getAll au lieu de getAllServiceTypes
        ServiceTypeService.getDefaultServiceType()
      ]);

      res.json({
        success: true,
        data: {
          serviceTypes,
          defaultService,
          configuration: {
            allowPricePerKg: process.env.ALLOW_PRICE_PER_KG === 'true',
            allowPremiumPrices: process.env.ALLOW_PREMIUM_PRICES === 'true'
          }
        }
      });
    } catch (error: any) {
      console.error('[ServiceManagementController] Configuration error:', error);
      res.status(500).json({ 
        success: false,
        message: 'Failed to fetch service configuration',
        error: error.message 
      });
    }
  }

  static async setDefaultServiceType(req: Request, res: Response) {
    try {
      const { serviceTypeId } = req.params;
      const defaultService = await ServiceTypeService.setDefaultServiceType(serviceTypeId);
      
      res.json({
        success: true,
        data: defaultService
      });
    } catch (error: any) {
      console.error('[ServiceManagementController] Set default error:', error);
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
}
