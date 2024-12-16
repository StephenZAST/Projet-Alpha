import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAdminLogs = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const adminLogs = await AdminLogService.getAdminLogs();

    res.status(200).json({ adminLogs });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch admin logs', errorCodes.DATABASE_ERROR));
  }
};
