import supabase from '../config/database';
import { ArticleCategory, CreateArticleCategoryDTO } from '../models/types';
import { v4 as uuidv4 } from 'uuid'; 

export class ArticleCategoryService {
  static async createArticleCategory(categoryData: CreateArticleCategoryDTO): Promise<ArticleCategory> {
    const { name, description } = categoryData;

    const newCategory: ArticleCategory = {
      id: uuidv4(),
      name,
      description,
      createdAt: new Date(),
    };

    const { data, error } = await supabase
      .from('article_categories')
      .insert([newCategory])
      .select()
      .single();

    if (error) throw error;

    return data;
  } 

  static async getArticleCategoryById(categoryId: string): Promise<ArticleCategory> {
    const { data, error } = await supabase
      .from('article_categories')
      .select('*')
      .eq('id', categoryId)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Article category not found');

    return data;
  } 

  static async getAllArticleCategories(): Promise<ArticleCategory[]> {
    try {
      const { data, error } = await supabase
        .from('article_categories')
        .select('*')
        .order('name');

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error in getAllCategories:', error);
      throw error;
    }
  }

  static async updateArticleCategory(categoryId: string, categoryData: Partial<ArticleCategory>): Promise<ArticleCategory> {
    const { data, error } = await supabase
      .from('article_categories')
      .update(categoryData)
      .eq('id', categoryId)
      .select()
      .single();

    if (error) throw error;
    if (!data) throw new Error('Article category not found');

    return data;
  }

  static async deleteArticleCategory(categoryId: string): Promise<void> {
    const { error } = await supabase
      .from('article_categories')
      .delete()
      .eq('id', categoryId);

    if (error) throw error;
  }
}
