import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';
import { Permission } from '../../models/permission';

export const createPermission = async (req: Request, res: Response, next: NextFunction) => {
  const { name, description, roles } = req.body;

  if (!name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA'));
  }

  try {
    const permission: Permission = { name, description, roles };
    const result = await permissionService.createPermission(permission);
    res.status(201).json({ message: 'Permission created successfully', result });
  } catch (error) {
    next(new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR'));
  }
};
