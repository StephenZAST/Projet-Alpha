import { createClient } from '@supabase/supabase-js';
import { Article, ArticleCategory, ArticleStatus, ArticleType } from '../../models/article';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

export async function updateArticle(articleId: string, articleData: Partial<Article>): Promise<Article> {
  try {
    const { data: currentArticleData, error: fetchError } = await supabase
      .from('articles')
      .select('*')
      .eq('articleId', articleId)
      .single();

    if (fetchError || !currentArticleData) {
      throw new AppError(404, 'Article not found', errorCodes.ARTICLE_NOT_FOUND);
    }

    const { data, error } = await supabase
      .from('articles')
      .update(articleData)
      .eq('articleId', articleId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update article', errorCodes.DATABASE_ERROR);
    }

    return data as Article;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to update article', errorCodes.DATABASE_ERROR);
  }
}
