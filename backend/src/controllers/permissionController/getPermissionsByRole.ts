import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPermissionsByRole = async (req: Request, res: Response, next: NextFunction) => {
  const { role } = req.params;

  if (!role) {
    return next(new AppError(400, 'Role is required', errorCodes.INVALID_ROLE));
  }

  try {
    const permissions = await permissionService.getPermissionsByRole(role);
    res.status(200).json({ permissions });
  } catch (error) {
    next(error);
  }
};
