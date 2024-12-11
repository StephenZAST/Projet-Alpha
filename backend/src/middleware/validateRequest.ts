import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { supabase } from '../config';
import AppError from '../utils/AppError';

export const validateRequest = (schema: Joi.Schema) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    const { authorization } = req.headers;

    if (!authorization) {
      return next(new AppError(401, 'Authorization header is required', 'UNAUTHORIZED'));
    }

    const token = authorization.split(' ')[1];

    if (!token) {
      return next(new AppError(401, 'Token is required', 'UNAUTHORIZED'));
    }

    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data?.user) {
      return next(new AppError(401, 'Invalid token', 'UNAUTHORIZED'));
    }

    (req as any).user = data.user;

    const { error: validationError } = schema.validate(req.body, { abortEarly: false });

    if (validationError) {
      const errors = validationError.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      return next(new AppError(400, 'Validation failed', 'VALIDATION_ERROR', errors));
    }

    next();
  };
};  
