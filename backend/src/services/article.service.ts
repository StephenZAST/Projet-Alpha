import supabase from '../config/database';
import { Article } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class ArticleService {
  static async createArticle(name: string, basePrice: number, premiumPrice: number, categoryId: string, description?: string): Promise<Article> {
    const newArticle: Article = {
      id: uuidv4(),
      categoryId: categoryId,
      name: name,
      description: description,
      basePrice: basePrice,
      premiumPrice: premiumPrice,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const { data, error } = await supabase
      .from('articles')
      .insert([newArticle])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getAllArticles(): Promise<Article[]> {
    const { data, error } = await supabase
      .from('articles')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async updateArticle(articleId: string, name: string, basePrice: number, premiumPrice: number, categoryId: string, description?: string): Promise<Article> {
    const { data, error } = await supabase
      .from('articles')
      .update({ name, basePrice, premiumPrice, description, categoryId, updatedAt: new Date() })
      .eq('id', articleId)
      .select()
      .single();

    if (error) throw error;

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
