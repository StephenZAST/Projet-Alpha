import { Request, Response } from 'express';
import { ServiceCompatibilityService } from '../services/serviceCompatibility.service';

export class ServiceCompatibilityController {
  static async setCompatibility(req: Request, res: Response): Promise<void> {
    try {
      const { article_id, service_id, is_compatible, restrictions } = req.body;

      const compatibility = await ServiceCompatibilityService.setCompatibility(
        article_id,
        service_id,
        is_compatible,
        restrictions
      );

      res.json({
        success: true,
        data: compatibility
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }

  static async getCompatibilities(req: Request, res: Response): Promise<void> {
    try {
      const { articleId } = req.params;
      const compatibilities = await ServiceCompatibilityService.getCompatibilities(articleId);

      res.json({
        success: true,
        data: compatibilities
      });
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
} 
 