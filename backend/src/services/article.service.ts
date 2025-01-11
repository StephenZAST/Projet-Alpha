import supabase from '../config/database';
import { Article, CreateArticleDTO } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class ArticleService {
  static async createArticle(articleData: CreateArticleDTO): Promise<Article> {
    const { categoryId, name, description, basePrice, premiumPrice } = articleData;

    const newArticle: Article = {
      id: uuidv4(),
      categoryId,
      name,
      description,
      basePrice,
      premiumPrice,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const { data, error } = await supabase
      .from('articles')
      .insert([newArticle])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getArticleById(articleId: string): Promise<Article> {
    const { data, error } = await supabase
      .from('articles')
      .select('*')
      .eq('id', articleId)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Article not found');

    return data;
  }

  static async getAllArticles(): Promise<Article[]> {
    const { data, error } = await supabase
      .from('articles')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async updateArticle(articleId: string, articleData: Partial<Article>): Promise<Article> {
    const { data, error } = await supabase
      .from('articles')
      .update(articleData)
      .eq('id', articleId)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Article not found');

    return data;
  }

  static async deleteArticle(articleId: string): Promise<void> {
    const { error } = await supabase
      .from('articles')
      .delete()
      .eq('id', articleId);

    if (error) throw error;
  }
}
