import express, { Request, Response, NextFunction } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { validateRegistration, validateLogin } from '../middleware/validators';
import { asyncHandler } from '../utils/asyncHandler';
import { AuthService } from '../services/auth.service';

const router = express.Router();

// Routes publiques
router.post('/register', validateRegistration, asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await AuthController.register(req, res);
}));

router.post('/login', validateLogin, asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await AuthController.login(req, res);
}));

// Routes publiques (sans authentification)
router.post('/register/affiliate', async (req: Request, res: Response) => {
  try {
    const { email, password, firstName, lastName, phone, parentAffiliateCode } = req.body;
    
    if (!email || !password || !firstName || !lastName) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    console.log('Registering affiliate with data:', { email, firstName, lastName, phone }); // Debug log
    
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
    console.error('Register affiliate error:', error); // Debug log
    if (error.message === 'Email already exists') {
      res.status(409).json({ error: 'Email already exists' });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

// Routes authentifiées
// router.use(authenticateToken as express.RequestHandler);

router.get('/me', authenticateToken as express.RequestHandler, asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await AuthController.getCurrentUser(req, res);
}));

router.post('/become-affiliate', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await AuthController.createAffiliate(req, res);
}));

// Routes for updating user information and deleting accounts
router.patch(
  '/update-profile',
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.updateProfile(req, res);
  })
);

router.post(
  '/change-password',
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.changePassword(req, res);
  })
);

router.delete(
  '/delete-account',
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.deleteAccount(req, res);
  })
);

// Routes admin
router.get(
  '/users', 
  authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.getAllUsers(req, res);
  })
);

router.delete(
  '/users/:userId',
  authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.deleteUser(req, res);
  })
);

router.patch(
  '/users/:userId',
  authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.updateUser(req, res);
  })
);

// Routes super admin
router.post(
  '/create-admin',
  authorizeRoles(['SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await AuthController.createAdmin(req, res);
  })
);


router.post('/logout', asyncHandler(async (req: Request, res: Response) => {
  await AuthController.logout(req, res);
}));

export default router;
