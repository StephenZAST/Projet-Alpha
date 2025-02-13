import { Article } from './types';

export interface ServiceType {
  id: string;
  name: string;
  description?: string;
  is_default: boolean;
  created_at: string;
  updated_at: string;
}

export interface ArticleServicePrice {
  id: string;
  article_id: string;
  service_type_id: string;
  base_price: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available: boolean;
  created_at: string;
  updated_at: string;
  service_type?: ServiceType;
  article?: Article;
}

export interface CreateArticleServicePriceDTO {
  article_id: string;
  service_type_id: string;
  base_price: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available?: boolean;
}

export interface UpdateArticleServicePriceDTO {
  base_price?: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available?: boolean;
}

export interface ArticleServicePriceResponse {
  id: string;
  article_id: string;
  service_type_id: string;
  base_price: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available: boolean;
  created_at: Date;
  updated_at: Date;
}
