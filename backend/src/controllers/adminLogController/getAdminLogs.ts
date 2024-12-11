import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const getAdminLogs = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { data, error } = await supabase.from('admin_logs').select('*');

    if (error) {
      return next(new AppError(500, 'Failed to fetch admin logs', 'INTERNAL_SERVER_ERROR'));
    }

    res.status(200).json({ data });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch admin logs', 'INTERNAL_SERVER_ERROR'));
  }
};
