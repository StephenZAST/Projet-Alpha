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

    // Créer la requête de base
    let query = db.collection('articles');

    // Ajouter le tri
    query = query.orderBy(sortBy || 'createdAt', sortOrder || 'desc');

    // Obtenir le total des articles
    const totalSnapshot = await query.count().get();
    const totalItems = totalSnapshot.data().count;

    // Appliquer la pagination
    query = query.limit(limit).offset(offset);

    // Exécuter la requête
    const articlesSnapshot = await query.get();
    const articles = articlesSnapshot.docs.map((doc) => ({
      articleId: doc.id,
      ...doc.data(),
    } as Article));

    // Retourner la réponse paginée
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

// Ajouter une fonction de recherche avec pagination
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
    
    // Créer la requête de base
    let dbQuery = db.collection('articles');

    // Appliquer les filtres
    if (category) {
      dbQuery = dbQuery.where('articleCategory', '==', category);
    }

    if (services && services.length > 0) {
      dbQuery = dbQuery.where('availableServices', 'array-contains-any', services);
    }

    // Note: Les filtres de prix et de recherche textuelle nécessitent des index composites
    // ou doivent être appliqués après avoir récupéré les résultats

    // Ajouter le tri
    dbQuery = dbQuery.orderBy(sortBy || 'createdAt', sortOrder || 'desc');

    // Obtenir le total des résultats
    const totalSnapshot = await dbQuery.count().get();
    const totalItems = totalSnapshot.data().count;

    // Appliquer la pagination
    const offset = Pagination.getOffset(page, limit);
    dbQuery = dbQuery.limit(limit).offset(offset);

    // Exécuter la requête
    const articlesSnapshot = await dbQuery.get();
    let articles = articlesSnapshot.docs.map((doc) => ({
      articleId: doc.id,
      ...doc.data(),
    } as Article));

    // Appliquer les filtres de prix et de recherche textuelle en mémoire
    if (query) {
      articles = articles.filter(article =>
        article.articleName.toLowerCase().includes(query.toLowerCase()) ||
        article.description?.toLowerCase().includes(query.toLowerCase())
      );
    }

    if (minPrice !== undefined) {
      articles = articles.filter(article =>
        Object.values(article.prices).some(price =>
          Object.values(price).some(value => value >= minPrice)
        )
      );
    }

    if (maxPrice !== undefined) {
      articles = articles.filter(article =>
        Object.values(article.prices).some(price =>
          Object.values(price).some(value => value <= maxPrice)
        )
      );
    }

    // Retourner la réponse paginée
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
