import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const deleteAdminLog = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  try {
    await AdminLogService.deleteAdminLog(id);

    res.status(200).json({ message: 'Admin log deleted successfully' });
  } catch (error) {
    next(new AppError(500, 'Failed to delete admin log', errorCodes.DATABASE_ERROR));
  }
};
