import { Request, Response, NextFunction } from 'express';
import { AppError, errorCodes } from '../utils/errors';

export const validateAdmin = (req: Request, res: Response, next: NextFunction) => {
  // Example validation logic
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return next(new AppError(400, 'All fields are required', 'INVALID_ADMIN_DATA'));
  }

  next();
};

export const validateCreateAdmin = (req: Request, res: Response, next: NextFunction) => {
  // Example validation logic for creating an admin
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return next(new AppError(400, 'All fields are required', 'INVALID_ADMIN_DATA'));
  }

  next();
};

export const validateGetAdmin = (req: Request, res: Response, next: NextFunction) => {
  // Example validation logic for getting an admin
  const { id } = req.params;

  if (!id) {
    return next(new AppError(400, 'ID is required', 'INVALID_ID'));
  }

  next();
};

export const validateUpdateAdmin = (req: Request, res: Response, next: NextFunction) => {
  // Example validation logic for updating an admin
  const { id } = req.params;
  const { name, email, password } = req.body;

  if (!id) {
    return next(new AppError(400, 'ID is required', 'INVALID_ID'));
  }

  if (!name && !email && !password) {
    return next(new AppError(400, 'At least one field is required for update', 'INVALID_ADMIN_DATA'));
  }

  next();
};
