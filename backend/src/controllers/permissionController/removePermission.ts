import { Request, Response, NextFunction } from 'express';
import { permissionService } from '../../services/permissionService';
import { AppError, errorCodes } from '../../utils/errors';

export const removePermission = async (req: Request, res: Response, next: NextFunction) => {
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
