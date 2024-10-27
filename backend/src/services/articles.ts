import { db } from './firebase';
import { Article } from '../models/article';
import { AppError, errorCodes } from '../utils/errors';
import Joi from 'joi';
import { MainService, PriceType } from '../models/order'; // Import necessary enums

const articleValidationSchema = Joi.object({
  articleName: Joi.string().required(),
  articleCategory: Joi.string().required(),
  prices: Joi.object().required(),
  availableServices: Joi.array().items(Joi.string().valid(...Object.values(MainService))).required(),
  availableAdditionalServices: Joi.array().items(Joi.string()).required()
});

export async function createArticle(articleData: Article): Promise<Article | null> {
  try {
    const validationResult = articleValidationSchema.validate(articleData);
    if (validationResult.error) {
      const errorMessage = validationResult.error.details[0].message;
      throw new AppError(400, errorMessage, errorCodes.INVALID_ARTICLE_DATA);
    }

    const articleRef = await db.collection('articles').add(articleData);
    return { ...articleData, articleId: articleRef.id };
  } catch (error) {
    if (error instanceof AppError) {
      return null; // Return null on validation or database error
    }
    throw new AppError(500, 'Failed to create article', errorCodes.DATABASE_ERROR);
  }
}

export async function getArticles(): Promise<Article[]> {
  try {
    const articlesSnapshot = await db.collection('articles').get();
    return articlesSnapshot.docs.map((doc) => ({
      articleId: doc.id,
      ...doc.data(),
    } as Article));
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    } else {
      throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
    }
  }
}
