import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPermissionById = async (req: Request, res: Response, next: NextFunction) => {
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
