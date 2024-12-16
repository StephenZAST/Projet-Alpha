import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AppError, errorCodes } from '../../utils/errors';

export const updateAdminLog = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { action, description } = req.body;

  if (!id || !action || !description) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_ADMIN_DATA));
  }

  try {
    const adminLog = await AdminLogService.getAdminLog(id);

    if (!adminLog) {
      return next(new AppError(404, 'Admin log not found', errorCodes.NOT_FOUND));
    }

    const updatedLog = { ...adminLog, action, description };

    await AdminLogService.deleteAdminLog(id);

    const newLog = await AdminLogService.logAction(adminLog.adminId, action, description, req, adminLog.targetAdminId);

    res.status(200).json({ message: 'Admin log updated successfully', newLog });
  } catch (error) {
    next(new AppError(500, 'Failed to update admin log', errorCodes.DATABASE_ERROR));
  }
};
