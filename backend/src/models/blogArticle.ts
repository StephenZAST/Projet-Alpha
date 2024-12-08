import { Timestamp } from 'firebase-admin/firestore';
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
    publishedAt?: Timestamp;
    createdAt: Timestamp;
    updatedAt: Timestamp;
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
