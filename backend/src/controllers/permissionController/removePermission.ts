import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const removePermission = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', 'INVALID_ID'));
  }

  try {
    const permission = await PermissionService.removePermission(id);
    if (!permission) {
      return next(new AppError(404, 'Permission not found', 'NOT_FOUND'));
    }
    res.status(200).json({ message: 'Permission removed successfully' });
  } catch (error) {
    next(new AppError(500, 'Failed to remove permission', 'INTERNAL_SERVER_ERROR'));
  }
};
