import express from 'express';
import { AdminLogController } from '../controllers/adminLogController';
import { authenticate, authorize } from '../middleware/auth';
import { AdminRole } from '../models/admin';

const router = express.Router();
const adminLogController = new AdminLogController();

// Protéger toutes les routes
router.use(authenticate);

// Routes pour Super Admin Master et Super Admin
router.use(authorize([AdminRole.SUPER_ADMIN_MASTER, AdminRole.SUPER_ADMIN]));

// Obtenir tous les logs avec filtres
router.get('/', adminLogController.getLogs);

// Obtenir l'activité récente d'un admin
router.get('/recent-activity', adminLogController.getRecentActivity);

// Obtenir les tentatives de connexion échouées
router.get('/failed-attempts/:adminId', adminLogController.getFailedLoginAttempts);

export default router;
