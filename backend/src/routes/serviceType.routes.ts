import express from 'express';
import { ServiceTypeController } from '../controllers/serviceType.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler'; 

const router = express.Router();

// Routes publiques (pas d'authentification requise pour la lecture)
router.get('/', 
  asyncHandler((req, res) => ServiceTypeController.getAllServiceTypes(req, res))
);

router.get('/:id', 
  asyncHandler((req, res) => ServiceTypeController.getServiceType(req, res))
);

// Routes admin (nécessitent authentification + rôle ADMIN)
router.post('/', 
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler((req, res) => ServiceTypeController.createServiceType(req, res))
);

router.put('/:id', 
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler((req, res) => ServiceTypeController.updateServiceType(req, res))
);

router.delete('/:id', 
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler((req, res) => ServiceTypeController.deleteServiceType(req, res))
);

export default router;
  