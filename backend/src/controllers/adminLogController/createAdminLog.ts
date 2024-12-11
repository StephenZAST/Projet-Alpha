import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

export const createAdminLog = async (req: Request, res: Response, next: NextFunction) => {
  const { action, description, userId } = req.body;

  if (!action || !description || !userId) {
    return next(new AppError(400, 'All fields are required', 'INVALID_ADMIN_LOG_DATA'));
  }

  try {
    const { data, error } = await supabase.from('admin_logs').insert([
      {
        action,
        description,
        user_id: userId,
        created_at: new Date().toISOString()
      }
    ]);

    if (error) {
      return next(new AppError(500, 'Failed to create admin log', 'INTERNAL_SERVER_ERROR'));
    }

    res.status(201).json({ message: 'Admin log created successfully', data });
  } catch (error) {
    next(new AppError(500, 'Failed to create admin log', 'INTERNAL_SERVER_ERROR'));
  }
};
