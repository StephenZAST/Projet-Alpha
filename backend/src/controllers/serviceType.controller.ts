import { Request, Response } from 'express';
import { ServiceTypeService } from '../services/serviceType.service'; 
import { AdminActivityService } from '../services/adminActivity.service';

export class ServiceTypeController {
  static async createServiceType(req: Request, res: Response): Promise<void> {
    const serviceType = await ServiceTypeService.create(req.body);
    await AdminActivityService.log(req, {
      action: 'CATALOG.SERVICE_TYPE_CREATED',
      details: { entityType: 'SERVICE_TYPE', entityId: serviceType.id, outcome: 'SUCCESS' },
    });
    res.status(201).json({
      success: true,
      data: serviceType
    });
  }

  static async updateServiceType(req: Request, res: Response): Promise<void> {
    const { id } = req.params;
    const serviceType = await ServiceTypeService.update(id, req.body);
    await AdminActivityService.log(req, {
      action: 'CATALOG.SERVICE_TYPE_UPDATED',
      details: { entityType: 'SERVICE_TYPE', entityId: id, outcome: 'SUCCESS' },
    });
    res.json({
      success: true,
      data: serviceType
    });
  }

  static async deleteServiceType(req: Request, res: Response): Promise<void> {
    const { id } = req.params;
    await ServiceTypeService.delete(id);
    await AdminActivityService.log(req, {
      action: 'CATALOG.SERVICE_TYPE_DELETED',
      details: { entityType: 'SERVICE_TYPE', entityId: id, outcome: 'SUCCESS' },
    });
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
