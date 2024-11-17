import { Request, Response, NextFunction } from 'express';
import { AdminLogService } from '../services/adminLogService';
import { AdminAction } from '../models/adminLog';
import { AppError } from '../utils/errors';
import { catchAsync } from '../utils/catchAsync';

export class AdminLogController {
    getLogs = catchAsync(async (req: Request, res: Response) => {
        const { adminId, action, startDate, endDate, page = 1, limit = 50 } = req.query;
        
        const skip = (Number(page) - 1) * Number(limit);
        
        const logs = await AdminLogService.getAdminLogs(
            adminId as string,
            action as AdminAction,
            startDate ? new Date(startDate as string) : undefined,
            endDate ? new Date(endDate as string) : undefined,
            Number(limit),
            skip
        );

        const total = await AdminLogService.getLogCount(
            adminId as string,
            action as AdminAction,
            startDate ? new Date(startDate as string) : undefined,
            endDate ? new Date(endDate as string) : undefined
        );

        res.status(200).json({
            status: 'success',
            data: {
                logs,
                pagination: {
                    total,
                    page: Number(page),
                    pages: Math.ceil(total / Number(limit))
                }
            }
        });
    });

    getRecentActivity = catchAsync(async (req: Request, res: Response) => {
        const { limit = 10 } = req.query;
        const adminId = req.user._id;

        const logs = await AdminLogService.getRecentActivityByAdmin(
            adminId,
            Number(limit)
        );

        res.status(200).json({
            status: 'success',
            data: { logs }
        });
    });

    getFailedLoginAttempts = catchAsync(async (req: Request, res: Response) => {
        const { adminId } = req.params;
        const { timeWindow = 15 } = req.query;

        const attempts = await AdminLogService.getFailedLoginAttempts(
            adminId,
            Number(timeWindow)
        );

        res.status(200).json({
            status: 'success',
            data: { attempts }
        });
    });
}
