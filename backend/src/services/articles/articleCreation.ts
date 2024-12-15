import { createClient } from '@supabase/supabase-js';
import { Article, ArticleCategory, ArticleStatus, ArticleType } from '../../models/article';
import { AppError, errorCodes } from '../../utils/errors';
import Joi from 'joi';
import { MainService, PriceType } from '../../models/order';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const articleValidationSchema = Joi.object({
  articleName: Joi.string().required(),
  articleCategory: Joi.string().valid(...Object.values(ArticleCategory)).required(),
  prices: Joi.object().required().pattern(
    Joi.string().valid(...Object.values(MainService)),
    Joi.object().pattern(
      Joi.string().valid(...Object.values(PriceType)),
      Joi.number().min(0)
    )
  ),
  availableServices: Joi.array().items(Joi.string().valid(...Object.values(MainService))).required(),
  availableAdditionalServices: Joi.array().items(Joi.string()).required()
});

export async function createArticle(articleData: Article): Promise<Article> {
  try {
    const validationResult = articleValidationSchema.validate(articleData);
    if (validationResult.error) {
      const errorMessage = validationResult.error.details[0].message;
      throw new AppError(400, errorMessage, errorCodes.INVALID_ARTICLE_DATA);
    }

    const { data, error } = await supabase.from('articles').insert([articleData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create article', errorCodes.DATABASE_ERROR);
    }

    return data as Article;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to create article', errorCodes.DATABASE_ERROR);
  }
}
