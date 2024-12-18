import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPermissions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const permissions = await permissionService.getPermissions();
    res.status(200).json({ permissions });
  } catch (error) {
    next(error); 
  }
};
