import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { AppError, errorCodes } from '../../utils/errors';

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const validatedData = await schema.validateAsync(req.body);
      req.body = validatedData;
      next();
    } catch (error) {
      if (error instanceof Joi.ValidationError) {
        next(new AppError(400, error.message, errorCodes.VALIDATION_ERROR));
      } else {
        next(new AppError(500, 'Internal Server Error', errorCodes.SERVER_ERROR));
      }
    }
  };
};
