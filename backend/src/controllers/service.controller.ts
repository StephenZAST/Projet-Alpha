import { Request, Response } from 'express';
import { ServiceService } from '../services/service.service';
import { PricingService } from '../services/pricing.service';
import { Service } from '../models/types';

export class ServiceController {
  static async createService(req: Request, res: Response) {
    try {
      const { name, price, description } = req.body;
      const service = await ServiceService.createService(name, price, description);
      res.json({ data: service });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllServices(req: Request, res: Response) {
    try {
      const services = await ServiceService.getAllServices();
      return res.status(200).json({
        success: true,
        data: services,
        message: 'Services retrieved successfully'
      });
    } catch (error) {
      console.error('Error in getAllServices controller:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to retrieve services',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async updateService(req: Request, res: Response) {
    try {
      const serviceId = req.params.serviceId;
      const { name, price, description } = req.body;
      const service = await ServiceService.updateService(serviceId, name, price, description);
      res.json({ data: service });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteService(req: Request, res: Response) {
    try {
      const serviceId = req.params.serviceId;
      await ServiceService.deleteService(serviceId);
      res.json({ message: 'Service deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getServicePrice(req: Request, res: Response) {
    try {
      const { 
        articleId, 
        serviceTypeId, 
        quantity = 1,
        weight = null,
        isPremium = false 
      } = req.body;

      const priceDetails = await PricingService.calculatePrice({
        articleId,
        serviceTypeId,
        quantity,
        weight,
        isPremium
      });

      return res.json({
        success: true,
        data: priceDetails
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}
