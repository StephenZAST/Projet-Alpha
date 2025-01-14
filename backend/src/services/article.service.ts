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
    try {
      const { data, error } = await supabase
        .from('articles')
        .select(`
          *,
          category:article_categories(*)
        `);

      if (error) {
        console.error('Supabase error in getAllArticles:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Error in getAllArticles:', error);
      throw error;
    }
  }

  static async getArticles(): Promise<Article[]> {
    try {
      const { data, error } = await supabase
        .from('articles')
        .select(`
          *,
          category:article_categories(name)
        `);

      if (error) {
        console.error('Supabase error in getArticles:', error);
        throw error;
      }

      // Transform the data to include category as a string
      const articles = data?.map(article => ({
        ...article,
        category: article.category?.name || 'Uncategorized'
      })) || [];

      return articles;
    } catch (error) {
      console.error('Error in getArticles:', error);
      throw error;
    }
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
