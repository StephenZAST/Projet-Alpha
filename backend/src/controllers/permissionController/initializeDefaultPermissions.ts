import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const initializeDefaultPermissions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await PermissionService.initializeDefaultPermissions();
    res.status(200).json({ message: 'Default permissions initialized successfully' });
  } catch (error) {
    next(new AppError(500, 'Failed to initialize default permissions', 'INTERNAL_SERVER_ERROR'));
  }
};
