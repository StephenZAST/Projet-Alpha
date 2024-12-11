import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { supabase } from '../config';
import { AppError, errorCodes } from '../utils/errors';

export const validateRequest = (schema: Joi.Schema) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    const { authorization } = req.headers;

    if (!authorization) {
      return next(new AppError(401, 'Authorization header is required', errorCodes.UNAUTHORIZED));
    }

    const token = authorization.split(' ')[1];

    if (!token) {
      return next(new AppError(401, 'Token is required', errorCodes.UNAUTHORIZED));
    }

    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data?.user) {
      return next(new AppError(401, 'Invalid token', errorCodes.UNAUTHORIZED));
    }

    (req as any).user = data.user;

    const { error: validationError } = schema.validate({
      body: req.body,
      query: req.query,
      params: req.params,
    }, { abortEarly: false });

    if (validationError) {
      const errors = validationError.details.map((err) => ({
        field: err.path.join('.'),
        message: err.message,
      }));

      next(new AppError(400, 'Validation failed', errorCodes.VALIDATION_ERROR, { errors }));
    } else {
      next();
    }
  };
};
