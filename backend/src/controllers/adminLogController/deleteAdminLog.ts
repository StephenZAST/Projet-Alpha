import { Request, Response, NextFunction } from 'express';
import { supabase } from '../../config';
import AppError from '../../utils/AppError';

// Define the expected structure of the Supabase response
interface SupabaseResponse<T> {
  data: T | null;
  error: Error | null;
}

export const deleteAdminLog = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', 'INVALID_ID'));
  }

  try {
    const response: SupabaseResponse<any> = await supabase.from('admin_logs').delete().eq('id', id);

    if (response.error) {
      return next(new AppError(500, 'Failed to delete admin log', 'INTERNAL_SERVER_ERROR'));
    }

    if (!response.data) {
      return next(new AppError(404, 'Admin log not found', 'NOT_FOUND'));
    }

    res.status(200).json({ message: 'Admin log deleted successfully' });
  } catch (error) {
    next(new AppError(500, 'Failed to delete admin log', 'INTERNAL_SERVER_ERROR'));
  }
};
