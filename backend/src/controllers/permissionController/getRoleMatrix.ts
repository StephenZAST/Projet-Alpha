import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getRoleMatrix = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const roleMatrix = await PermissionService.getRoleMatrix();
    res.status(200).json({ roleMatrix });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR'));
  }
};
