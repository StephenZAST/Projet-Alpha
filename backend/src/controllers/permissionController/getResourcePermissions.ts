import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getResourcePermissions = async (req: Request, res: Response, next: NextFunction) => {
  const { resource } = req.params;

  if (!resource) {
    return next(new AppError(400, 'Resource is required', 'INVALID_RESOURCE'));
  }

  try {
    const permissions = await PermissionService.getResourcePermissions(resource);
    res.status(200).json({ permissions });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch resource permissions', 'INTERNAL_SERVER_ERROR'));
  }
};
