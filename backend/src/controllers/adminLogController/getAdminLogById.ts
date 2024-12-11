import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const getAdminLogById = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', 'INVALID_ID'));
  }

  try {
    const { data, error } = await supabase.from('admin_logs').select('*').eq('id', id).single();

    if (error) {
      return next(new AppError(500, 'Failed to fetch admin log', 'INTERNAL_SERVER_ERROR'));
    }

    if (!data) {
      return next(new AppError(404, 'Admin log not found', 'NOT_FOUND'));
    }

    res.status(200).json({ data });
  } catch (error) {
    next(new AppError(500, 'Failed to fetch admin log', 'INTERNAL_SERVER_ERROR'));
  }
};
