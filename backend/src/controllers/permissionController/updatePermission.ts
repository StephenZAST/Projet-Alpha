import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const updatePermission = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { name, description, roles } = req.body;

  if (!id || !name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA'));
  }

  try {
    const permission = await PermissionService.updatePermission(id, name, description, roles);
    if (!permission) {
      return next(new AppError(404, 'Permission not found', 'NOT_FOUND'));
    }
    res.status(200).json({ message: 'Permission updated successfully', permission });
  } catch (error) {
    next(new AppError(500, 'Failed to update permission', 'INTERNAL_SERVER_ERROR'));
  }
};