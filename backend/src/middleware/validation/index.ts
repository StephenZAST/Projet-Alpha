import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { AppError, errorCodes } from '../../utils/errors';
import { MainService } from '../../models/order';
import { supabase } from '../../config';
import { articleValidationSchema, priceRangeValidation } from './articleValidation';
import { validateRequest } from '../validateRequest';

export const validateArticleInput = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Supabase authentication check
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

    // Existing validation logic
    const validatedData = await articleValidationSchema.validateAsync(req.body);
    
    // Type-safe price validation
    const prices = validatedData.prices as Record<MainService, Record<string, number>>;
    Object.entries(prices).forEach(([service, servicePrice]) => {
      Object.values(servicePrice).forEach(price => {
        if (!priceRangeValidation(price, service as MainService)) {
          throw new AppError(400, `Invalid price range for service: ${service}`, errorCodes.INVALID_PRICE_RANGE);
        }
      });
    });

    // Validate service availability
    validatedData.availableServices.forEach((service: MainService) => {
      if (!prices[service as MainService]) {
        throw new AppError(400, `Price must be set for available service: ${service}`, errorCodes.INVALID_SERVICE);
      }
    });

    req.body = validatedData;
    next();
  } catch (error) {
    next(error);
  }
};

export { validateRequest };
