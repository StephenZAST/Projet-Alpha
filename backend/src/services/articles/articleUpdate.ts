import { createClient } from '@supabase/supabase-js';
import { Article, ArticleCategory, ArticleStatus, ArticleType } from '../../models/article';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

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
