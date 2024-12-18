import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const updateAdminLog = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { id } = req.params;
  const updates = req.body;

  try {
    const updatedLog = await AdminLogService.updateAdminLog(id, updates);
    res.status(200).json({ message: 'Admin log updated successfully', log: updatedLog });
  } catch (error) {
    if (error instanceof AppError) {
      next(error);
    } else {
      next(new AppError(500, 'Failed to update admin log', errorCodes.DATABASE_ERROR));
    }
  }
};
