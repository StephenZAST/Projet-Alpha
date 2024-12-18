import express, { Request, Response, NextFunction } from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { 
  validateCreateZone,
  validateGetAllZones,
  validateGetZoneById,
  validateUpdateZone,
  validateDeleteZone,
  validateAssignDeliveryPerson,
  validateGetZoneStats
} from '../middleware/zoneValidation';
import { zonesService } from '../services/zones';
import { UserRole, User } from '../models/user';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = express.Router();

// Middleware d'authentification pour toutes les routes
router.use(isAuthenticated);

// Route pour créer une nouvelle zone
router.post('/', requireAdminRolePath([UserRole.SUPER_ADMIN]), validateCreateZone, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const zone = await zonesService.createZone(req.body);
    res.status(201).json(zone);
  } catch (error) {
    next(error);
  }
});

// Route pour obtenir toutes les zones
router.get('/', validateGetAllZones, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { name, isActive, deliveryPersonId, location, page, limit } = req.query;
    const zones = await zonesService.getAllZones({
      name: name as string,
      isActive: isActive === 'true',
      deliveryPersonId: deliveryPersonId as string,
      location: location as any, // Assuming location is a GeoJSON object
      page: Number(page) || 1,
      limit: Number(limit) || 10
    });
    res.status(200).json(zones);
  } catch (error) {
    next(error);
  }
});

// Route pour obtenir une zone spécifique
router.get('/:zoneId', validateGetZoneById, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const zoneId = req.params.zoneId;
    const zone = await zonesService.getZoneById(zoneId);
    if (!zone) {
      res.status(404).json({ message: 'Zone not found' });
      return;
    }
    res.status(200).json(zone);
  } catch (error) {
    next(error);
  }
});

// Route pour mettre à jour une zone
router.put('/:zoneId', requireAdminRolePath([UserRole.SUPER_ADMIN]), validateUpdateZone, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const zoneId = req.params.zoneId;
    const success = await zonesService.updateZone(zoneId, req.body);
    if (success) {
      res.status(200).json({ message: 'Zone updated successfully' });
    } else {
      res.status(404).json({ message: 'Zone not found' });
    }
  } catch (error) {
    next(error);
  }
});

// Route pour supprimer une zone
router.delete('/:zoneId', requireAdminRolePath([UserRole.SUPER_ADMIN]), validateDeleteZone, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const zoneId = req.params.zoneId;
    await zonesService.deleteZone(zoneId); 
    res.status(200).json({ message: 'Zone deleted successfully' });
  } catch (error) {
    next(error);
  }
});

// Route pour assigner un livreur à une zone
router.post('/:zoneId/assign', requireAdminRolePath([UserRole.SUPER_ADMIN]), validateAssignDeliveryPerson, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const zoneId = req.params.zoneId;
    const { deliveryPersonId } = req.body;
    const success = await zonesService.assignDeliveryPerson(zoneId, deliveryPersonId);
    if (success) {
      res.status(200).json({ message: 'Delivery person assigned to zone successfully' });
    } else {
      res.status(400).json({ message: 'Failed to assign delivery person to zone' });
    }
  } catch (error) {
    next(error);
  }
});

// Route pour obtenir les statistiques d'une zone
router.get('/:zoneId/stats', requireAdminRolePath([UserRole.SUPER_ADMIN]), validateGetZoneStats, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const zoneId = req.params.zoneId;
    const { startDate, endDate } = req.query;
    const stats = await zonesService.getZoneStatistics(
      zoneId,
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined
    );
    res.status(200).json(stats);
  } catch (error) {
    next(error);
  }
});

export default router;
