import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { AppError, errorCodes } from '../utils/errors';

export const validateRequest = (schema: Joi.Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate({
      body: req.body,
      query: req.query,
      params: req.params,
    }, { abortEarly: false });

    if (error) {
      const errors = error.details.map((err) => ({
        field: err.path.join('.'),
        message: err.message,
      }));

      next(new AppError(400, 'Validation failed', errorCodes.VALIDATION_ERROR));
    } else {
      next();
    }
  };
};
