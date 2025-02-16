import express, { Request, Response, NextFunction } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { validateRegistration, validateLogin } from '../middleware/validators';
import { asyncHandler } from '../utils/asyncHandler';
import { AuthService } from '../services/auth.service';

const router = express.Router();

// Routes publiques d'authentification client
router.post('/register', validateRegistration, asyncHandler(AuthController.register));
router.post('/login', validateLogin, asyncHandler(AuthController.login));

// Route d'authentification admin
router.post('/admin/login', validateLogin, asyncHandler(async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const { user, token } = await AuthService.login(email, password);

    // Vérifier si l'utilisateur est un admin
    if (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Access denied. Admin privileges required.' });
    } 

    // Envoyer la réponse avec le token
    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
        },
        token,
      },
    });
  } catch (error: any) {
    console.error('Admin login error:', error);
    res.status(401).json({
      success: false,
      error: error.message || 'Authentication failed'
    });
  }
}));

// Routes publiques (sans authentification)
router.post('/register/affiliate', asyncHandler(async (req: Request, res: Response) => {
  try {
    const { email, password, firstName, lastName, phone, parentAffiliateCode } = req.body;
    
    if (!email || !password || !firstName || !lastName) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    console.log('Registering affiliate with data:', { email, firstName, lastName, phone });
    
    const result = await AuthService.registerAffiliate(
      email,
      password,
      firstName,
      lastName,
      phone,
      parentAffiliateCode
    );
    
    res.json(result);
  } catch (error: any) {
    console.error('Register affiliate error:', error);
    if (error.message === 'Email already exists') {
      res.status(409).json({ error: 'Email already exists' });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
}));

// Routes de réinitialisation de mot de passe
router.post('/reset-password', asyncHandler(AuthController.resetPassword));
router.post('/verify-code-and-reset-password', asyncHandler(AuthController.verifyCodeAndResetPassword));
router.post('/verify-code', asyncHandler(async (req: Request, res: Response) => {
  const { email, code } = req.body;
  const isValid = await AuthService.validateResetCode(email, code);
  
  if (isValid) {
    res.json({ success: true });
  } else {
    res.status(400).json({ 
      success: false, 
      error: 'Code invalide ou expiré' 
    });
  }
}));

// Routes protégées par authentification
router.use(authenticateToken);

// Route pour obtenir l'utilisateur courant (admin)
router.get('/admin/me', authorizeRoles(['ADMIN', 'SUPER_ADMIN']), asyncHandler(async (req: Request, res: Response) => {
  try {
    if (!req.user?.id) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const userData = await AuthService.getCurrentUser(req.user.id);
    res.json({
      success: true,
      data: userData
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}));

// Routes authentifiées standard
router.get('/me', asyncHandler(AuthController.getCurrentUser));
router.post('/become-affiliate', asyncHandler(AuthController.createAffiliate));
router.patch('/update-profile', asyncHandler(AuthController.updateProfile));
router.post('/change-password', asyncHandler(AuthController.changePassword));
router.delete('/delete-account', asyncHandler(AuthController.deleteAccount));

// Routes admin avec autorisation
router.get('/users', authorizeRoles(['SUPER_ADMIN', 'ADMIN']), asyncHandler(AuthController.getAllUsers));
router.delete('/users/:userId', authorizeRoles(['SUPER_ADMIN', 'ADMIN']), asyncHandler(AuthController.deleteUser));
router.patch('/users/:userId', authorizeRoles(['SUPER_ADMIN', 'ADMIN']), asyncHandler(AuthController.updateUser));

// Routes super admin uniquement
router.post('/create-admin', authorizeRoles(['SUPER_ADMIN']), asyncHandler(AuthController.createAdmin));

// Route de déconnexion
router.post('/logout', asyncHandler(AuthController.logout));

export default router;
