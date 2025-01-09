import express, { Request, Response, NextFunction } from 'express';
import { AddressController } from '../controllers/address.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);  // Cette ligne exige un token JWT

// Routes client
router.post(
  '/create',
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    console.log('Received create address request');
    console.log('Request body:', req.body);
    try {
      await AddressController.createAddress(req, res);
    } catch (error) {
      console.error('Error in create address route:', error);
      next(error);
    }
  })
);

router.get(
  '/all',
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    try {
      await AddressController.getAllAddresses(req, res);
    } catch (error) {
      next(error);
    }
  })
);

// Routes admin
router.patch(
  '/update/:addressId',
  authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    try {
      await AddressController.updateAddress(req, res);
    } catch (error) {
      next(error);
    }
  })
);

router.delete(
  '/delete/:addressId',
  authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    try {
      await AddressController.deleteAddress(req, res);
    } catch (error) {
      next(error);
    }
  })
);

export default router;
