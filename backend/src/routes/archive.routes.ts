import express from 'express';
import { ArchiveController } from '../controllers/archive.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';

const router = express.Router();

// Route accessible à tous les utilisateurs authentifiés
router.get('/orders', authenticateToken, ArchiveController.getArchivedOrders);

// Route accessible uniquement aux ADMIN et SUPER_ADMIN
router.post(
  '/cleanup',
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']), // Ajout de SUPER_ADMIN
  ArchiveController.runArchiveCleanup
);

export default router;
 