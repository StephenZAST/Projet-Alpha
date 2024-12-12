import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Article {
  id?: string;
  title: string;
  content: string;
  authorId: string;
  category: string;
  status: 'draft' | 'published' | 'archived';
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store article data
const articlesTable = 'articles';

// Function to get article data
export async function getArticle(id: string): Promise<Article | null> {
  const { data, error } = await supabase.from(articlesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch article', 'INTERNAL_SERVER_ERROR');
  }

  return data as Article;
}

// Function to create article
export async function createArticle(articleData: Article): Promise<Article> {
  const { data, error } = await supabase.from(articlesTable).insert([articleData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create article', 'INTERNAL_SERVER_ERROR');
  }

  return data as Article;
}

// Function to update article
export async function updateArticle(id: string, articleData: Partial<Article>): Promise<Article> {
  const currentArticle = await getArticle(id);

  if (!currentArticle) {
    throw new AppError(404, 'Article not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(articlesTable).update(articleData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update article', 'INTERNAL_SERVER_ERROR');
  }

  return data as Article;
}

// Function to delete article
export async function deleteArticle(id: string): Promise<void> {
  const article = await getArticle(id);

  if (!article) {
    throw new AppError(404, 'Article not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(articlesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete article', 'INTERNAL_SERVER_ERROR');
  }
}
