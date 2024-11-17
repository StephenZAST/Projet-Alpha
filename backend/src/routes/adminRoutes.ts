import express from 'express';
import { AdminController } from '../controllers/adminController';
import { authenticate, authorize } from '../middleware/auth';
import { AdminRole } from '../models/admin';

const router = express.Router();
const adminController = new AdminController();

// Routes publiques
router.post('/login', adminController.login);

// Route protégée pour la création du Super Admin Master (à utiliser une seule fois)
router.post('/master/create', adminController.createMasterAdmin);

// Routes protégées nécessitant une authentification
router.use(authenticate);

// Routes pour Super Admin Master et Super Admin
router.use(authorize([AdminRole.SUPER_ADMIN_MASTER, AdminRole.SUPER_ADMIN]));
router.get('/all', adminController.getAllAdmins);
router.post('/create', adminController.createAdmin);

// Routes spécifiques au Super Admin Master
router.use('/super-admin', authorize([AdminRole.SUPER_ADMIN_MASTER]));
router.post('/super-admin/create', adminController.createAdmin);
router.delete('/super-admin/:id', adminController.deleteAdmin);
router.put('/super-admin/:id', adminController.updateAdmin);

// Routes pour tous les admins (pour voir/modifier leur propre profil)
router.get('/profile', adminController.getAdminById);
router.put('/profile', adminController.updateAdmin);

// Routes pour la gestion des autres admins
router.get('/:id', adminController.getAdminById);
router.put('/:id', adminController.updateAdmin);
router.delete('/:id', adminController.deleteAdmin);
router.put('/:id/status', adminController.toggleAdminStatus);

export default router;
