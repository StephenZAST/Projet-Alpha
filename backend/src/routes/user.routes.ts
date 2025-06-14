import express from 'express';
import { AuthService } from '../services/auth.service';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { UserController } from '../controllers/user.controller';

const router = express.Router();

// Protection des routes avec authentification 
router.use(authenticateToken);

// Route pour créer un utilisateur par un admin
router.post('/',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    // Validation basique des champs requis
    const { email, password, firstName, lastName, phone } = req.body;
    
    if (!email || !password || !firstName || !lastName) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
        details: {
          email: !email ? 'Email is required' : null,
          password: !password ? 'Password is required' : null,
          firstName: !firstName ? 'First name is required' : null,
          lastName: !lastName ? 'Last name is required' : null
        }
      });
    }

    // Validation du format de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email format'
      });
    }

    // Validation du mot de passe
    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 8 characters long'
      });
    }

    try {
      const newUser = await AuthService.register(
        email,
        password,
        firstName,
        lastName,
        phone,
        undefined, // pas de code d'affiliation pour la création par admin
        'CLIENT' // forcer le rôle CLIENT
      );

      // Masquer le mot de passe dans la réponse
      const { password: _, ...userWithoutPassword } = newUser;

      res.status(201).json({
        success: true,
        data: userWithoutPassword
      });
    } catch (error: any) {
      if (error.message === 'Email already exists') {
        return res.status(409).json({
          success: false,
          error: 'Email already exists'
        });
      }
      throw error;
    }
  })
);

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

// Ajouter cette route avant les autres routes
router.get(
  '/search',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    await UserController.searchUsers(req, res);
  })
);

// Note : Suppression de la route PUT /users/:userId car elle existe déjà dans auth.routes.ts

export default router;
