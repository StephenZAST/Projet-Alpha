import express, { Request, Response, NextFunction } from 'express';
import  affiliateController  from '../controllers/affiliateController';
import { requireAdminRolePath } from '../middleware/auth';
import { UserRole } from '../models/user';

const router = express.Router();

// Middleware to check if the user is authenticated
const isAuthenticated = (req: Request, res: Response, next: NextFunction) => {
  if (req.user) {
    next();
  } else {
    res.status(401).json({ message: 'Not authenticated' });
  }
};

// Routes for affiliates
router.get('/', isAuthenticated, requireAdminRolePath([UserRole.ADMIN, UserRole.SECRETAIRE]) as express.RequestHandler, affiliateController.getAllAffiliates);
router.get('/:id', isAuthenticated, requireAdminRolePath([UserRole.ADMIN, UserRole.SECRETAIRE]) as express.RequestHandler, affiliateController.getAffiliateById);
router.post('/', isAuthenticated, requireAdminRolePath([UserRole.ADMIN]) as express.RequestHandler, affiliateController.createAffiliate);
router.put('/:id', isAuthenticated, requireAdminRolePath([UserRole.ADMIN]) as express.RequestHandler, affiliateController.updateAffiliate);
router.delete('/:id', isAuthenticated, requireAdminRolePath([UserRole.ADMIN]) as express.RequestHandler, affiliateController.deleteAffiliate);

export default router;
