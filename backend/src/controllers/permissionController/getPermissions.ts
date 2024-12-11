import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPermissions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const permissions = await PermissionService.getPermissions();
    res.status(200).json({ permissions });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR'));
  }
};
