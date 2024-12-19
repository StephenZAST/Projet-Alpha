import express, { Request, Response, NextFunction } from 'express';
import  affiliateController  from '../controllers/affiliateController';
import { requireAdminRolePath, isAuthenticated } from '../middleware/auth';
import { UserRole } from '../models/user';

const router = express.Router();

// Routes for affiliates
router.get('/', isAuthenticated, requireAdminRolePath([UserRole.ADMIN, UserRole.SECRETAIRE]) as express.RequestHandler, affiliateController.getAllAffiliates);
router.get('/:id', isAuthenticated, requireAdminRolePath([UserRole.ADMIN, UserRole.SECRETAIRE]) as express.RequestHandler, affiliateController.getAffiliateById);
router.post('/', isAuthenticated, requireAdminRolePath([UserRole.ADMIN]) as express.RequestHandler, affiliateController.createAffiliate);
router.put('/:id', isAuthenticated, requireAdminRolePath([UserRole.ADMIN]) as express.RequestHandler, affiliateController.updateAffiliate);
router.delete('/:id', isAuthenticated, requireAdminRolePath([UserRole.ADMIN]) as express.RequestHandler, affiliateController.deleteAffiliate);

export default router;
