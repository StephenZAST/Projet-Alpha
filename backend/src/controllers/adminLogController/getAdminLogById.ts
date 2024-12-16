import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAdminLogById = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  try {
    const adminLog = await AdminLogService.getAdminLog(id);

    if (!adminLog) {
      return next(new AppError(404, 'Admin log not found', errorCodes.NOT_FOUND));
    }

    res.status(200).json({ adminLog });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch admin log', errorCodes.DATABASE_ERROR));
  }
};
