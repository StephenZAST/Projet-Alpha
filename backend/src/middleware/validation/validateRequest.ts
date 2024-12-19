import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

// Define a Joi schema for request validation
const requestValidationSchema = Joi.object({
  // Add your request validation schema here
  // Example:
  // someField: Joi.string().required(),
});

export const validateRequest = async (req: Request, res: Response, next: NextFunction) => {
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

  // Validate request body using Joi
  const { error: validationError } = requestValidationSchema.validate(req.body);

  if (validationError) {
    return next(new AppError(400, validationError.message, errorCodes.VALIDATION_ERROR));
  }

  next();
};
