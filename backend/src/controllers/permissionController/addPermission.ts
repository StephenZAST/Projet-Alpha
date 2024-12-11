import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';
import { Permission } from '../../models/permission';

export const addPermission = async (req: Request, res: Response, next: NextFunction) => {
  const { name, description, roles } = req.body;

  if (!name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA'));
  }

  try {
    const permission = await PermissionService.addPermission({ name, description, roles });
    res.status(201).json({ message: 'Permission added successfully', permission });
  } catch (error) {
    next(new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR'));
  }
};
