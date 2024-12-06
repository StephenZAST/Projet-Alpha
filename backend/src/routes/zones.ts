import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  createZoneSchema,
  updateZoneSchema,
  assignDeliveryPersonSchema,
  searchZonesSchema,
  zoneStatsSchema
} from '../validation/zones';
import { ZoneStatus } from '../models/zone';
import { zoneService } from '../services/zones'; // Assuming you have a zoneService

const router = express.Router();

// Middleware d'authentification pour toutes les routes
router.use(isAuthenticated);

// Route pour créer une nouvelle zone
router.post('/', requireAdminRole, validateRequest(createZoneSchema), async (req, res, next) => {
  try {
    const zone = await zoneService.createZone(req.body);
    res.status(201).json(zone);
  } catch (error) {
    next(error);
  }
});

// Route pour obtenir toutes les zones
router.get('/', validateRequest(searchZonesSchema), async (req, res, next) => {
  try {
    const { name, isActive, deliveryPersonId, location, page, limit } = req.query;
    const zones = await zoneService.getAllZones({
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
router.get('/:zoneId', async (req, res, next) => {
  try {
    const zoneId = req.params.zoneId;
    const zone = await zoneService.getZoneById(zoneId);
    if (!zone) {
      return res.status(404).json({ message: 'Zone not found' });
    }
    res.status(200).json(zone);
  } catch (error) {
    next(error);
  }
});

// Route pour mettre à jour une zone
router.put('/:zoneId', requireAdminRole, validateRequest(updateZoneSchema), async (req, res, next) => {
  try {
    const zoneId = req.params.zoneId;
    const success = await zoneService.updateZone(zoneId, req.body);
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
router.delete('/:zoneId', requireAdminRole, async (req, res, next) => {
  try {
    const zoneId = req.params.zoneId;
    const success = await zoneService.deleteZone(zoneId);
    if (success) {
      res.status(200).json({ message: 'Zone deleted successfully' });
    } else {
      res.status(404).json({ message: 'Zone not found' });
    }
  } catch (error) {
    next(error);
  }
});

// Route pour assigner un livreur à une zone
router.post('/:zoneId/assign', requireAdminRole, validateRequest(assignDeliveryPersonSchema), async (req, res, next) => {
  try {
    const zoneId = req.params.zoneId;
    const { deliveryPersonId } = req.body;
    const success = await zoneService.assignDeliveryPerson(zoneId, deliveryPersonId);
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
router.get('/:zoneId/stats', requireAdminRole, validateRequest(zoneStatsSchema), async (req, res, next) => {
  try {
    const zoneId = req.params.zoneId;
    const { startDate, endDate } = req.query;
    const stats = await zoneService.getZoneStatistics(
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
