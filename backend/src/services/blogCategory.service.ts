import supabase from '../config/database';
import { BlogCategory } from '../models/types';
import { v4 as uuidv4 } from 'uuid'; 

export class BlogCategoryService {
  static async createCategory(name: string, description?: string): Promise<BlogCategory> {
    const newCategory: BlogCategory = {
      id: uuidv4(),
      name,
      description,
      createdAt: new Date()
    };

    const { data, error } = await supabase
      .from('blog_categories')
      .insert([newCategory])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getAllCategories(): Promise<BlogCategory[]> {
    const { data, error } = await supabase
      .from('blog_categories')
      .select('*');

    if (error) throw error; 
    return data;
  }
 
  static async updateCategory(categoryId: string, name: string, description?: string): Promise<BlogCategory> {
    const { data, error } = await supabase
      .from('blog_categories')
      .update({ name, description, updatedAt: new Date() })
      .eq('id', categoryId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async deleteCategory(categoryId: string): Promise<void> {
    const { error } = await supabase
      .from('blog_categories')
      .delete()
      .eq('id', categoryId);

    if (error) throw error;
  }
}
