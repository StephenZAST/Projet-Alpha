import { Request, Response, NextFunction } from 'express';
import { articleValidationSchema, categoryValidationSchema, priceRangeValidation } from './articleValidation';
import { AppError, errorCodes } from '../../utils/errors';
import { MainService } from '../../models/order';

export const validateArticleInput = async (req: Request, res: Response, next: NextFunction) => {
  try {
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
