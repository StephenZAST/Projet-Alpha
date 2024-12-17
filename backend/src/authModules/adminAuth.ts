import { NextFunction, Request, Response } from 'express';
import { AppError } from '../utils/errors';
import { verifyToken } from './tokenUtils';

export const authenticateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return next(new AppError(401, 'Token is required', 'UNAUTHORIZED'));
  }

  const decoded = verifyToken(token);

  if (!decoded) {
    return next(new AppError(401, 'Invalid token', 'UNAUTHORIZED'));
  }

  // Fetch the admin from the database using the decoded id
  (req as any).user = decoded.id;

  next();
};
