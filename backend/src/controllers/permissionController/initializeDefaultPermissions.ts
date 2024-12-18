import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const initializeDefaultPermissions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await permissionService.initializeDefaultPermissions();
    res.status(200).json({ message: 'Default permissions initialized successfully' });
  } catch (error) {
    next(error);
  }
};
