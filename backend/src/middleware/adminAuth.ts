import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config';

export const authenticateAdmin = async (req: Request, res: Response, next: NextFunction) => {
  const { authorization } = req.headers;

  if (!authorization) {
    return res.status(401).json({ message: 'Authorization header is required' });
  }

  const token = authorization.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token is required' });
  }

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    return res.status(401).json({ message: 'Invalid token' });
  }

  // Check if the user is an admin
  if (data.user.app_metadata?.provider !== 'admin') {
    return res.status(403).json({ message: 'Forbidden: User is not an admin' });
  }

  (req as any).user = data.user;
  next();
};
