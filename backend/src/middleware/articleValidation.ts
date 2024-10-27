import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { MainService, PriceType } from '../models/order';
import { ArticleCategory } from '../models/article';
import { AppError, errorCodes } from '../utils/errors';

const articleSchema = Joi.object({
  articleName: Joi.string().required(),
  articleCategory: Joi.string().valid(...Object.values(ArticleCategory)).required(),
  prices: Joi.object().pattern(
    Joi.string().valid(...Object.values(MainService)),
    Joi.object().pattern(
      Joi.string().valid(...Object.values(PriceType)),
      Joi.number().min(0)
    )
  ).required(),
  availableServices: Joi.array().items(
    Joi.string().valid(...Object.values(MainService))
  ).required(),
  availableAdditionalServices: Joi.array().items(Joi.string()).required()
});

export const validateArticle = (req: Request, res: Response, next: NextFunction) => {
  const { error } = articleSchema.validate(req.body);
  if (error) {
    const errorMessage = error.details[0].message;
    throw new AppError(400, errorMessage, errorCodes.INVALID_ARTICLE_DATA);
  }
  next();
};
