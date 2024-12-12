import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface BlogArticle {
  id?: string;
  title: string;
  content: string;
  authorId: string;
  category: string;
  status: 'draft' | 'published' | 'archived';
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store blog article data
const blogArticlesTable = 'blogArticles';

// Function to get blog article data
export async function getBlogArticle(id: string): Promise<BlogArticle | null> {
  const { data, error } = await supabase.from(blogArticlesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch blog article', 'INTERNAL_SERVER_ERROR');
  }

  return data as BlogArticle;
}

// Function to create blog article
export async function createBlogArticle(blogArticleData: BlogArticle): Promise<BlogArticle> {
  const { data, error } = await supabase.from(blogArticlesTable).insert([blogArticleData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create blog article', 'INTERNAL_SERVER_ERROR');
  }

  return data as BlogArticle;
}

// Function to update blog article
export async function updateBlogArticle(id: string, blogArticleData: Partial<BlogArticle>): Promise<BlogArticle> {
  const currentBlogArticle = await getBlogArticle(id);

  if (!currentBlogArticle) {
    throw new AppError(404, 'Blog article not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(blogArticlesTable).update(blogArticleData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update blog article', 'INTERNAL_SERVER_ERROR');
  }

  return data as BlogArticle;
}

// Function to delete blog article
export async function deleteBlogArticle(id: string): Promise<void> {
  const blogArticle = await getBlogArticle(id);

  if (!blogArticle) {
    throw new AppError(404, 'Blog article not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(blogArticlesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete blog article', 'INTERNAL_SERVER_ERROR');
  }
}
