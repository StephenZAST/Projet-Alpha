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

// Endpoint pour récupérer les adresses d'un utilisateur par son id
router.get(
  '/user/:userId',
  asyncHandler(AddressController.getAddressesByUserId)
);

// Routes admin
router.patch(
  '/update/:addressId',
  // Suppression de authorizeRoles
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
  // Suppression de authorizeRoles pour permettre à tous les utilisateurs authentifiés
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    try {
      await AddressController.deleteAddress(req, res);
    } catch (error) {
      next(error);
    }
  })
);

export default router;
