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

export async function deleteArticle(articleId: string): Promise<void> {
  try {
    const { data: currentArticleData, error: fetchError } = await supabase
      .from('articles')
      .select('*')
      .eq('articleId', articleId)
      .single();

    if (fetchError || !currentArticleData) {
      throw new AppError(404, 'Article not found', errorCodes.ARTICLE_NOT_FOUND);
    }

    const { error } = await supabase.from('articles').delete().eq('articleId', articleId);

    if (error) {
      throw new AppError(500, 'Failed to delete article', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to delete article', errorCodes.DATABASE_ERROR);
  }
}
