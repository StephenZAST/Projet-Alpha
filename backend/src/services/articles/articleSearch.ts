import { createClient } from '@supabase/supabase-js';
import { Article, ArticleCategory, ArticleStatus, ArticleType } from '../../models/article';
import { AppError, errorCodes } from '../../utils/errors';
import { PaginationParams, PaginatedResponse, Pagination } from '../../utils/pagination';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

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
    const offset = Pagination.getOffset(page, limit);

    // Create the base query
    let queryRef = supabase.from('articles').select('*');

    // Apply filters
    if (category) {
      queryRef = queryRef.eq('articleCategory', category);
    }

    if (services && services.length > 0) {
      queryRef = queryRef.in('availableServices', services);
    }

    // Add sorting
    queryRef = queryRef.order(sortBy || 'createdAt', { ascending: sortOrder === 'asc' });

    // Perform a separate query to count items
    let countQueryRef = supabase.from('articles').select('*', { count: 'exact', head: true });

    if (category) {
      countQueryRef = countQueryRef.eq('articleCategory', category);
    }

    if (services && services.length > 0) {
      countQueryRef = countQueryRef.in('availableServices', services);
    }

    if (sortBy) {
      countQueryRef = countQueryRef.order(sortBy, { ascending: sortOrder === 'asc' });
    }

    const { count: totalItems, error: countError } = await countQueryRef;

    if (countError) {
      throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
    }

    // Apply pagination
    queryRef = queryRef.range(offset, offset + limit - 1);

    // Execute the query
    const { data: articlesData, error: queryError } = await queryRef;

    if (queryError) {
      throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
    }

    let articles = articlesData.map((article) => ({
      ...article
    }));

    // Apply price and text search filters in memory
    if (query) {
      articles = articles.filter((article: { articleName: string; }) =>
        article.articleName.toLowerCase().includes(query.toLowerCase())
      );
    }

    if (minPrice !== undefined) {
      articles = articles.filter((article: { prices: { [s: string]: { [s: string]: number; }; } }) =>
        Object.values(article.prices).some((price) =>
          Object.values(price).some((value: number) => value >= minPrice)
        )
      );
    }

    if (maxPrice !== undefined) {
      articles = articles.filter((article: { prices: { [s: string]: { [s: string]: number; }; } }) =>
        Object.values(article.prices).some((price) =>
          Object.values(price).some((value: number) => value <= maxPrice)
        )
      );
    }

    // Return the paginated response
    return Pagination.createResponse<Article>(
      articles,
      totalItems ?? 0,
      page,
      limit
    );
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to search articles', errorCodes.DATABASE_ERROR);
  }
}
