import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPermissionsByRole = async (req: Request, res: Response, next: NextFunction) => {
  const { role } = req.params;

  if (!role) {
    return next(new AppError(400, 'Role is required', 'INVALID_ROLE'));
  }

  try {
    const permissions = await PermissionService.getPermissionsByRole(role);
    res.status(200).json({ permissions });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch permissions by role', 'INTERNAL_SERVER_ERROR'));
  }
};
