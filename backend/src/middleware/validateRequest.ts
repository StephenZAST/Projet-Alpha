import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { AppError, errorCodes } from '../utils/errors';

export const validateRequest = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
        }));

        next(new AppError(400, 'Validation failed', errorCodes.VALIDATION_ERROR));
      } else {
        // Handle other types of errors if needed
        next(new AppError(500, 'Internal server error', errorCodes.SERVER_ERROR));
      }
    }
  };
};
