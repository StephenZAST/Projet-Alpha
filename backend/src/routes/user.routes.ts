import express from 'express';
import { AuthService } from '../services/auth.service';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Protection des routes avec authentification 
router.use(authenticateToken);

// Routes accessibles uniquement aux admins
router.get(
  '/',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    
    const users = await AuthService.getAllUsers({page, limit});
    
    res.json({
      success: true,
      data: users.data,
      pagination: users.pagination
    });
  })
);

router.post('/',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    const { email, password, firstName, lastName, phone, role } = req.body;
    
    const newUser = await AuthService.register(
      email,
      password,
      firstName,
      lastName,
      phone,
      role
    );

    res.json({
      success: true,
      data: newUser
    });
  })
);

// Modification d'un utilisateur
router.put('/:id',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    const userId = req.params.id;
    const { email, firstName, lastName, phone, role } = req.body;
    const updatedUser = await AuthService.updateUser(userId, email, firstName, lastName, phone, role);
    res.json({ success: true, data: updatedUser });
  })
);

// Suppression d'un utilisateur
router.delete('/:id',
  authorizeRoles(['SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    const targetUserId = req.params.id;
    const currentUserId = req.user!.id;
    await AuthService.deleteUser(targetUserId, currentUserId);
    res.json({ success: true });
  })
);

// Stats des utilisateurs
router.get(
  '/stats', 
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    const stats = await AuthService.getUserStats();
    res.json({
      success: true,
      data: stats 
    });
  })
);

// Note : Suppression de la route PUT /users/:userId car elle existe déjà dans auth.routes.ts

export default router;
