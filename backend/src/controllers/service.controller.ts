import { Request, Response } from 'express';
import { ServiceService } from '../services/service.service';
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
      const formattedServices = services.map(service => ({
        id: service.id || '',
        name: service.name || '',
        price: service.price || 0,
        description: service.description || null,
        created_at: service.createdAt?.toISOString() || new Date().toISOString(), // Changé de created_at à createdAt
        updated_at: service.updatedAt?.toISOString() || new Date().toISOString()  // Changé de updated_at à updatedAt
      }));
      
      res.json({ 
        success: true, 
        data: formattedServices
      });
    } catch (error: any) {
      console.error('Error in getAllServices:', error);
      res.status(500).json({ 
        success: false, 
        error: 'Failed to fetch services' 
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
}
