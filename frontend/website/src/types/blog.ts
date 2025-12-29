/**
 * 📝 Blog Types - Types pour le système de blog
 * Alignés avec le backend Prisma
 */

export interface BlogArticle {
  id: string;
  title: string;
  slug: string;
  content: string;
  excerpt: string;
  category_id?: string;
  author_id?: string;
  featured_image?: string;
  published_at?: string;
  created_at?: string;
  updated_at?: string;
  reading_time?: number;
  seo_keywords: string[];
  seo_description?: string;
  views_count?: number;
  is_published?: boolean;
  // Relations
  category?: BlogCategory;
  author?: BlogAuthor;
}

export interface BlogCategory {
  id: string;
  name: string;
  description?: string;
  created_at?: string;
  updated_at?: string;
}

export interface BlogAuthor {
  id: string;
  first_name?: string;
  last_name?: string;
  email: string;
  role?: string;
}

export interface BlogListResponse {
  data: BlogArticle[];
  total: number;
  page?: number;
  limit?: number;
}

export interface BlogArticleResponse {
  data: BlogArticle;
}

export interface BlogCategoryResponse {
  data: BlogCategory[];
}

/**
 * Helper pour obtenir le nom complet de l'auteur
 */
export function getAuthorName(author?: BlogAuthor): string {
  if (!author) return 'Alpha Laundry';
  const firstName = author.first_name || '';
  const lastName = author.last_name || '';
  return `${firstName} ${lastName}`.trim() || 'Alpha Laundry';
}

/**
 * Helper pour formater une date
 */
export function formatDate(date?: string | Date, locale: string = 'fr-FR'): string {
  if (!date) return '';
  try {
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    return dateObj.toLocaleDateString(locale, {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  } catch {
    return '';
  }
}

/**
 * Helper pour formater une date courte
 */
export function formatDateShort(date?: string | Date, locale: string = 'fr-FR'): string {
  if (!date) return '';
  try {
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    return dateObj.toLocaleDateString(locale, {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  } catch {
    return '';
  }
}

/**
 * Helper pour vérifier si une date est valide
 */
export function isValidDate(date?: string | Date): boolean {
  if (!date) return false;
  try {
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    return !isNaN(dateObj.getTime());
  } catch {
    return false;
  }
}

/**
 * SEO Metadata for Blog Articles
 */
export interface BlogSEOMetadata {
  title: string;
  description: string;
  keywords: string[];
  canonical: string;
  ogImage?: string;
  ogType: string;
  twitterCard: string;
  author: string;
  publishedDate: string;
  modifiedDate: string;
}
