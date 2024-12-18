import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAdminLogById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;

  try {
    const log = await AdminLogService.getAdminLog(id);

    if (!log) {
      return next(new AppError(404, 'Admin log not found', errorCodes.NOT_FOUND));
    }

    res.status(200).json(log);
  } catch (error) {
    next(error);
  }
};
