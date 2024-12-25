import supabase from '../config/database';
import { ArticleCategory } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class ArticleCategoryService {
  static async createCategory(name: string, description?: string): Promise<ArticleCategory> {
    const newCategory: ArticleCategory = {
      id: uuidv4(),
      name,
      description,
      createdAt: new Date()
    };

    const { data, error } = await supabase
      .from('article_categories')
      .insert([newCategory])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getAllCategories(): Promise<ArticleCategory[]> {
    const { data, error } = await supabase
      .from('article_categories')
      .select('*');

    if (error) throw error;
    return data;
  }

  static async updateCategory(categoryId: string, name: string, description?: string): Promise<ArticleCategory> {
    const { data, error } = await supabase
      .from('article_categories')
      .update({ name, description, updatedAt: new Date() })
      .eq('id', categoryId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async deleteCategory(categoryId: string): Promise<void> {
    const { error } = await supabase
      .from('article_categories')
      .delete()
      .eq('id', categoryId);

    if (error) throw error;
  }
}
