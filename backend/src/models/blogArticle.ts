import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole } from './user';

export enum BlogArticleStatus {
  DRAFT = 'DRAFT',
  PUBLISHED = 'PUBLISHED',
  ARCHIVED = 'ARCHIVED'
}

export enum BlogArticleCategory {
  LAUNDRY_TIPS = 'LAUNDRY_TIPS',
  STAIN_REMOVAL = 'STAIN_REMOVAL',
  FABRIC_CARE = 'FABRIC_CARE',
  SUSTAINABILITY = 'SUSTAINABILITY',
  COMPANY_NEWS = 'COMPANY_NEWS',
  SEASONAL_CARE = 'SEASONAL_CARE',
  PROFESSIONAL_SERVICES = 'PROFESSIONAL_SERVICES'
}

export interface BlogArticle {
  id: string;
  title: string;
  slug: string;
  content: string;
  excerpt: string;
  authorId: string;
  authorName: string;
  authorRole: UserRole;
  category: BlogArticleCategory;
  tags: string[];
  status: BlogArticleStatus;
  featuredImage?: string;
  seoTitle?: string;
  seoDescription?: string;
  seoKeywords?: string[];
  views: number;
  likes: number;
  publishedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateBlogArticleInput {
  title: string;
  content: string;
  category: BlogArticleCategory;
  tags: string[];
  featuredImage?: string;
  seoTitle?: string;
  seoDescription?: string;
  seoKeywords?: string[];
}

export interface UpdateBlogArticleInput {
  title?: string;
  content?: string;
  category?: BlogArticleCategory;
  tags?: string[];
  status?: BlogArticleStatus;
  featuredImage?: string;
  seoTitle?: string;
  seoDescription?: string;
  seoKeywords?: string[];
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
export async function createBlogArticle(articleData: CreateBlogArticleInput): Promise<BlogArticle> {
  const { data, error } = await supabase.from(blogArticlesTable).insert([{
    ...articleData,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  }]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create blog article', 'INTERNAL_SERVER_ERROR');
  }

  return data as BlogArticle;
}

// Function to update blog article
export async function updateBlogArticle(id: string, articleData: UpdateBlogArticleInput): Promise<BlogArticle> {
  const currentArticle = await getBlogArticle(id);

  if (!currentArticle) {
    throw new AppError(404, 'Blog article not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(blogArticlesTable).update({
    ...articleData,
    updatedAt: new Date().toISOString(),
  }).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update blog article', 'INTERNAL_SERVER_ERROR');
  }

  return data as BlogArticle;
}

// Function to delete blog article
export async function deleteBlogArticle(id: string): Promise<void> {
  const article = await getBlogArticle(id);

  if (!article) {
    throw new AppError(404, 'Blog article not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(blogArticlesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete blog article', 'INTERNAL_SERVER_ERROR');
  }
}
