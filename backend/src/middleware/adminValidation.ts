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

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return next(new AppError(400, 'Email and password are required', errorCodes.INVALID_LOGIN_DATA));
  }

  next();
};

export const validateToggleStatus = (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { isActive } = req.body;

  if (!id) {
    return next(new AppError(400, 'ID is required', errorCodes.INVALID_ID));
  }

  if (isActive === undefined) {
    return next(new AppError(400, 'isActive is required', errorCodes.INVALID_STATUS));
  }

  next();
};
