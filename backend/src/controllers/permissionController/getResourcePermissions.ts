import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getResourcePermissions = async (req: Request, res: Response, next: NextFunction) => {
  const { resource } = req.params;

  if (!resource) {
    return next(new AppError(400, 'Resource is required', errorCodes.INVALID_RESOURCE));
  }

  try {
    const permissions = await permissionService.getResourcePermissions(resource);
    res.status(200).json({ permissions });
  } catch (error) {
    next(error);
  }
};
