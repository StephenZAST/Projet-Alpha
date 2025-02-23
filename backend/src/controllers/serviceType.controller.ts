import { Request, Response } from 'express';
import { ServiceTypeService } from '../services/serviceType.service';

export class ServiceTypeController {
  static async createServiceType(req: Request, res: Response): Promise<void> {
    const serviceType = await ServiceTypeService.create(req.body);
    res.status(201).json({
      success: true,
      data: serviceType
    });
  }

  static async updateServiceType(req: Request, res: Response): Promise<void> {
    const { id } = req.params;
    const serviceType = await ServiceTypeService.update(id, req.body);
    res.json({
      success: true,
      data: serviceType
    });
  }

  static async deleteServiceType(req: Request, res: Response): Promise<void> {
    const { id } = req.params;
    await ServiceTypeService.delete(id);
    res.json({
      success: true,
      message: 'Service type deleted successfully'
    });
  }

  static async getServiceType(req: Request, res: Response): Promise<void> {
    const { id } = req.params;
    const serviceType = await ServiceTypeService.getById(id);
    res.json({
      success: true,
      data: serviceType
    }); 
  } 

  static async getAllServiceTypes(req: Request, res: Response): Promise<void> {
    const includeInactive = req.query.includeInactive === 'true';
    const serviceTypes = await ServiceTypeService.getAll(includeInactive);
    res.json({
      success: true,
      data: serviceTypes
    });
  }
}
