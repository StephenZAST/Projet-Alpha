import { Request, Response, NextFunction } from 'express';
import { PermissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

const permissionService = new PermissionService();

export const deletePermission = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  try {
    await permissionService.deletePermission(id);
    res.status(200).json({ message: 'Permission deleted successfully' });
  } catch (error) {
    next(new AppError(500, 'Failed to delete permission', errorCodes.DATABASE_ERROR));
  }
};
