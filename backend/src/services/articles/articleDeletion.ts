import { createClient } from '@supabase/supabase-js';
import { Article, ArticleCategory, ArticleStatus, ArticleType } from '../../models/article';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

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
