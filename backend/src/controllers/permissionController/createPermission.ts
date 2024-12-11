import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const createPermission = async (req: Request, res: Response, next: NextFunction) => {
  const { name, description, roles } = req.body;

  if (!name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA'));
  }

  try {
    const permission = await PermissionService.createPermission(name, description, roles);
    res.status(201).json({ message: 'Permission created successfully', permission });
  } catch (error) {
    next(new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR'));
  }
};
