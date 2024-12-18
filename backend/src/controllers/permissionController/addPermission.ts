import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';
import { Permission } from '../../models/permission';

export const addPermission = async (req: Request, res: Response, next: NextFunction) => {
  const { name, description, roles } = req.body;

  if (!name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_PERMISSION_DATA));
  }

  try {
    const permission: Permission = { name, description, roles };
    const result = await permissionService.createPermission(permission);
    res.status(201).json({ message: 'Permission added successfully', result });
  } catch (error) {
    next(error);
  }
};
