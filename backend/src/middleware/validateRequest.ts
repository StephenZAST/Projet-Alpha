import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';
import { AppError, errorCodes } from '../utils/errors';

export const validateRequest = (schema: Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      // Pass the error to the error handling middleware
      next(new AppError(400, 'Validation failed', errorCodes.VALIDATION_ERROR));
    }

    next();
  };
};
