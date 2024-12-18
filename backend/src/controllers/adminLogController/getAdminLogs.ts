import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../../services/adminLogService';
import { AdminAction } from '../../models/adminLog';

export const getAdminLogs = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const { adminId, action, startDate, endDate, limit, skip } = req.query;

  try {
    const logs = await AdminLogService.getAdminLogs(
      adminId as string | undefined,
      action as AdminAction | undefined,
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined,
      limit ? parseInt(limit as string, 10) : undefined,
      skip ? parseInt(skip as string, 10) : undefined
    );

    res.status(200).json(logs);
  } catch (error) {
    next(error);
  }
};
