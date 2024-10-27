import Joi from 'joi';
import { MainService, PriceType } from '../../models/order';
import { ArticleCategory } from '../../models/article';

export const articleValidationSchema = Joi.object({
  articleName: Joi.string().required().min(2).max(100),
  articleCategory: Joi.string()
    .valid(...Object.values(ArticleCategory))
    .required(),
  prices: Joi.object()
    .pattern(
      Joi.string().valid(...Object.values(MainService)),
      Joi.object().pattern(
        Joi.string().valid(...Object.values(PriceType)),
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
        [MainService.PRESSING]: 50000,
        [MainService.DRY_CLEANING]: 75000,
        [MainService.IRONING]: 25000,
        [MainService.WASH_AND_IRON]: 75000,
        [MainService.WASH_ONLY]: 50000,
        [MainService.IRON_ONLY]: 25000,
        [MainService.PICKUP_DELIVERY]: 0
    };
  
  return price >= 0 && price <= maxPrices[service];
};
