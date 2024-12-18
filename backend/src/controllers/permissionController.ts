import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../services/permissionService';
import { AppError, errorCodes } from '../utils/errors';
import { Permission } from '../models/permission';

export const createPermission = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { name, description, roles } = req.body;

  if (!name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_PERMISSION_DATA));
  }

  try {
    const permission: Permission = { name, description, roles };
    const result = await permissionService.createPermission(permission);
    res.status(201).json({ message: 'Permission created successfully', result });
  } catch (error) {
    next(error);
  }
};

export const getPermissions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const permissions = await permissionService.getPermissions();
    res.status(200).json({ permissions });
  } catch (error) {
    next(error);
  }
};

export const getPermissionById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  try {
    const permission = await permissionService.getPermissionById(id);
    if (!permission) {
      return next(new AppError(404, 'Permission not found', errorCodes.NOT_FOUND));
    }
    res.status(200).json({ permission });
  } catch (error) {
    next(error);
  }
};

export const updatePermission = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;
  const { name, description, roles } = req.body;

  if (!id || !name || !description || !roles) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_PERMISSION_DATA));
  }

  try {
    const permission = await permissionService.updatePermission(id, name, description, roles);
    res.status(200).json({ message: 'Permission updated successfully', permission });
  } catch (error) {
    next(error);
  }
};

export const deletePermission = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  try {
    await permissionService.deletePermission(id);
    res.status(200).json({ message: 'Permission deleted successfully' });
  } catch (error) {
    next(error);
  }
};

export const initializeDefaultPermissions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await permissionService.initializeDefaultPermissions();
    res.status(200).json({ message: 'Default permissions initialized successfully' });
  } catch (error) {
    next(error);
  }
};

export const getPermissionsByRole = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

export const addPermission = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

export const removePermission = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  try {
    await permissionService.removePermission(id);
    res.status(200).json({ message: 'Permission removed successfully' });
  } catch (error) {
    next(error);
  }
};

export const getRoleMatrix = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const roleMatrix = await permissionService.getRoleMatrix();
    res.status(200).json({ roleMatrix });
  } catch (error) {
    next(error);
  }
};

export const getResourcePermissions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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
