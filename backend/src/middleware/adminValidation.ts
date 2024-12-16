import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';

export const validateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_ADMIN_DATA));
  }

  next();
};

export const validateCreateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return next(new AppError(400, 'All fields are required', errorCodes.INVALID_ADMIN_DATA));
  }

  next();
};

export const validateGetAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  next();
};

export const validateUpdateAdmin = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { name, email, password } = req.body;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  if (!name && !email && !password) {
    return next(new AppError(400, 'At least one field is required for update', errorCodes.INVALID_ADMIN_DATA));
  }

  next();
};
