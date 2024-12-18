import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getRoleMatrix = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const roleMatrix = await permissionService.getRoleMatrix();
    res.status(200).json({ roleMatrix });
  } catch (error) {
    next(error);
  }
};
