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

export async function getArticles(params: PaginationParams): Promise<PaginatedResponse<Article>> {
  try {
    const { page, limit, sortBy, sortOrder } = params;
    const offset = Pagination.getOffset(page, limit);

    // Create the base query
    const queryRef = supabase
      .from('articles')
      .select('*')
      .order(sortBy || 'createdAt', { ascending: sortOrder === 'asc' })
      .range(offset, offset + limit - 1);

    const { data: articlesData, error: queryError } = await queryRef;

    if (queryError) {
      throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
    }

    // Perform a separate query to count items
    let countQueryRef = supabase.from('articles').select('*', { count: 'exact', head: true });

    if (sortBy) {
      countQueryRef = countQueryRef.order(sortBy, { ascending: sortOrder === 'asc' });
    }

    const { count: totalItems, error: countError } = await countQueryRef;

    if (countError) {
      throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
    }

    // Return the paginated response
    return Pagination.createResponse<Article>(
      articlesData.map((article) => ({
        ...article
      })),
      totalItems ?? 0,
      page,
      limit
    );
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
  }
}

export async function getArticle(id: string): Promise<Article | null> {
  try {
    const { data, error } = await supabase.from('articles').select('*').eq('articleId', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch article', errorCodes.DATABASE_ERROR);
    }

    return data as Article;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to fetch article', errorCodes.DATABASE_ERROR);
  }
}
