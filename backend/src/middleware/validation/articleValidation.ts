import Joi from 'joi';
import { MainService, ArticleCategory } from '../../models/order';
import AppError from '../../utils/AppError';
import { supabase } from '../../config';
import { Request, Response, NextFunction } from 'express';

export const articleValidationSchema = Joi.object({
  articleName: Joi.string().required().min(2).max(100),
  articleCategory: Joi.string()
    .valid(...Object.values(ArticleCategory))
    .required(),
  prices: Joi.object()
    .pattern(
      Joi.string().valid(...Object.values(MainService)),
      Joi.object().pattern(
        Joi.string().valid('base', 'additional'),
        Joi.number().min(0).max(100000)
      )
    )
    .required(),
  availableServices: Joi.array()
    .items(Joi.string().valid(...Object.values(MainService)))
    .min(1)
    .required(),
  availableAdditionalServices: Joi.array()
    .items(Joi.string())
    .default([])
});

export const categoryValidationSchema = Joi.object({
  name: Joi.string().required().min(2).max(50),
  description: Joi.string().max(200),
  isActive: Joi.boolean().default(true)
});

export const priceRangeValidation = (price: number, service: MainService): boolean => {
  const maxPrices: Record<MainService, number> = {
    [MainService.LAUNDRY]: 50000,
    [MainService.DRY_CLEANING]: 75000,
    [MainService.IRONING]: 25000,
    [MainService.WASH_AND_IRON]: 75000,
    [MainService.WASH_ONLY]: 50000,
    [MainService.IRON_ONLY]: 25000,
    [MainService.PICKUP_DELIVERY]: 0,
    [MainService.REPASSAGE]: 0,
    [MainService.NETTOYAGE_SEC]: 0,
    [MainService.BLANCHISSERIE]: 0
  };

  return price >= 0 && price <= maxPrices[service];
};

export const validateArticleRequest = async (req: Request, res: Response, next: NextFunction) => {
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

  const { error: validationError } = articleValidationSchema.validate(req.body, { abortEarly: false });

  if (validationError) {
    const errors = validationError.details.map(detail => detail.message);
    return next(new AppError(400, 'Validation failed', 'VALIDATION_ERROR', errors)); // Pass errors directly
  }

  // Type-safe price validation
  const prices = req.body.prices as Record<MainService, Record<string, number>>;
  Object.entries(prices).forEach(([service, servicePrice]) => {
    Object.values(servicePrice).forEach(price => {
      if (!priceRangeValidation(price, service as MainService)) {
        return next(new AppError(400, `Invalid price range for service: ${service}`, 'INVALID_PRICE_RANGE'));
      }
    });
  });

  // Validate service availability
  req.body.availableServices.forEach((service: MainService) => {
    if (!prices[service as MainService]) {
      return next(new AppError(400, `Price must be set for available service: ${service}`, 'INVALID_SERVICE'));
    }
  });

  next();
};
