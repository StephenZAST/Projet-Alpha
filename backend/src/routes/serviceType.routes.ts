import express from 'express';
import { ServiceTypeController } from '../controllers/serviceType.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (accessibles aux utilisateurs authentifiés)
router.get('/', 
  asyncHandler((req, res) => ServiceTypeController.getAllServiceTypes(req, res))
);

router.get('/:id', 
  asyncHandler((req, res) => ServiceTypeController.getServiceType(req, res))
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post('/', 
  asyncHandler((req, res) => ServiceTypeController.createServiceType(req, res))
);

router.put('/:id', 
  asyncHandler((req, res) => ServiceTypeController.updateServiceType(req, res))
);

router.delete('/:id', 
  asyncHandler((req, res) => ServiceTypeController.deleteServiceType(req, res))
);

export default router;
 