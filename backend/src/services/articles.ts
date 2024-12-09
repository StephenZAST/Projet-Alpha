import { db } from './firebase';
import { Article } from '../models/article';
import { AppError, errorCodes } from '../utils/errors';
import Joi from 'joi';
import { MainService, PriceType } from '../models/order';
import { PaginationParams, PaginatedResponse, Pagination } from '../utils/pagination';

const articleValidationSchema = Joi.object({
  articleName: Joi.string().required(),
  articleCategory: Joi.string().required(),
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

export async function createArticle(articleData: Article): Promise<Article | null> {
  try {
    const validationResult = articleValidationSchema.validate(articleData);
    if (validationResult.error) {
      const errorMessage = validationResult.error.details[0].message;
      throw new AppError(400, errorMessage, errorCodes.INVALID_ARTICLE_DATA);
    }

    const articleRef = await db.collection('articles').add({
      ...articleData,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
    return { ...articleData, articleId: articleRef.id };
  } catch (error) {
    if (error instanceof AppError) {
      return null;
    }
    throw new AppError(500, 'Failed to create article', errorCodes.DATABASE_ERROR);
  }
}

export async function getArticles(params: PaginationParams): Promise<PaginatedResponse<Article>> {
  try {
    const { page, limit, sortBy, sortOrder } = params;
    const offset = Pagination.getOffset(page, limit);

    // Create the base query
    const querySnapshot = await db.collection('articles').orderBy(sortBy || 'createdAt', sortOrder || 'desc').get();

    // Get the total number of articles
    const totalItems = querySnapshot.docs.length;

    // Apply pagination
    const articles = querySnapshot.docs.slice(offset, offset + limit).map((doc) => ({
      articleId: doc.id,
      ...doc.data(),
    } as Article));

    // Return the paginated response
    return Pagination.createResponse<Article>(
      articles,
      totalItems,
      page,
      limit
    );
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    } else {
      throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
    }
  }
}

export async function updateArticle(articleId: string, articleData: Partial<Article>): Promise<Article | null> {
  try {
    const articleRef = db.collection('articles').doc(articleId);
    const article = await articleRef.get();

    if (!article.exists) {
      throw new AppError(404, 'Article not found', errorCodes.ARTICLE_NOT_FOUND);
    }

    await articleRef.update(articleData);
    return {
      articleId,
      ...article.data(),
      ...articleData
    } as Article;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update article', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteArticle(articleId: string): Promise<boolean> {
  try {
    const articleRef = db.collection('articles').doc(articleId);
    const article = await articleRef.get();

    if (!article.exists) {
      throw new AppError(404, 'Article not found', errorCodes.ARTICLE_NOT_FOUND);
    }

    await articleRef.delete();
    return true;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to delete article', errorCodes.DATABASE_ERROR);
  }
}

// Add a search function with pagination
export async function searchArticles(
  params: PaginationParams,
  searchParams: {
    query?: string;
    category?: string;
    minPrice?: number;
    maxPrice?: number;
    services?: string[];
  }
): Promise<PaginatedResponse<Article>> {
  try {
    const { page, limit, sortBy, sortOrder } = params;
    const { query, category, minPrice, maxPrice, services } = searchParams;

    // Create the base query
    let queryRef: FirebaseFirestore.Query<FirebaseFirestore.DocumentData> = db.collection('articles');

    // Apply filters
    if (category) {
      queryRef = queryRef.where('articleCategory', '==', category);
    }

    if (services && services.length > 0) {
      queryRef = queryRef.where('availableServices', 'array-contains-any', services);
    }

    // Note: Price and text search filters require composite indexes
    // or should be applied after retrieving the results

    // Add sorting
    queryRef = queryRef.orderBy(sortBy || 'createdAt', sortOrder || 'desc');

    // Get the total number of results
    const totalSnapshot = await queryRef.get();
    const totalItems = totalSnapshot.docs.length;

    // Apply pagination
    const offset = Pagination.getOffset(page, limit);
    queryRef = queryRef.limit(limit).offset(offset);

    // Execute the query
    const articlesSnapshot = await queryRef.get();
    let articles = articlesSnapshot.docs.map((doc) => ({
      articleId: doc.id,
      ...doc.data(),
    } as Article));

    // Apply price and text search filters in memory
    if (query) {
      articles = articles.filter((article) =>
        article.articleName.toLowerCase().includes(query.toLowerCase())
      );
    }

    if (minPrice !== undefined) {
      articles = articles.filter((article) =>
        Object.values(article.prices).some((price) =>
          Object.values(price).some((value) => value >= minPrice)
        )
      );
    }

    if (maxPrice !== undefined) {
      articles = articles.filter((article) =>
        Object.values(article.prices).some((price) =>
          Object.values(price).some((value) => value <= maxPrice)
        )
      );
    }

    // Return the paginated response
    return Pagination.createResponse<Article>(
      articles,
      totalItems,
      page,
      limit
    );
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    } else {
      throw new AppError(500, 'Failed to search articles', errorCodes.DATABASE_ERROR);
    }
  }
}
