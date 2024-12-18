import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const createAdminLog = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { action, description, userId } = req.body;

  if (!action || !description || !userId) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_ADMIN_DATA));
  }

  try {
    const adminLog = await AdminLogService.logAction(userId, action, description, req);

    res.status(201).json({ message: 'Admin log created successfully', adminLog });
  } catch (error) {
    next(error);
  }
};
