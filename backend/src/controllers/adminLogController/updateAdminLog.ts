import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const updateAdminLog = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { action, description } = req.body;

  if (!id || !action || !description) {
    return next(new AppError(400, 'All fields are required', 'INVALID_ADMIN_LOG_DATA'));
  }

  try {
    const { data, error } = await supabase.from('admin_logs').update({ action, description }).eq('id', id).single();

    if (error) {
      return next(new AppError(500, 'Failed to update admin log', 'INTERNAL_SERVER_ERROR'));
    }

    if (!data) {
      return next(new AppError(404, 'Admin log not found', 'NOT_FOUND'));
    }

    res.status(200).json({ message: 'Admin log updated successfully', data });
  } catch (error) {
    next(new AppError(500, 'Failed to update admin log', 'INTERNAL_SERVER_ERROR'));
  }
};
