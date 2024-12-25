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
      res.json({ data: services });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
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
