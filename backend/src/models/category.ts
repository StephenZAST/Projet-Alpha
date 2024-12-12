import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export enum CategoryStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  DELETED = 'deleted'
}

export interface Category {
  id?: string;
  name: string;
  description: string;
  status: CategoryStatus;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store category data
const categoriesTable = 'categories';

// Function to get category data
export async function getCategory(id: string): Promise<Category | null> {
  const { data, error } = await supabase.from(categoriesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch category', 'INTERNAL_SERVER_ERROR');
  }

  return data as Category;
}

// Function to create category
export async function createCategory(categoryData: Category): Promise<Category> {
  const { data, error } = await supabase.from(categoriesTable).insert([categoryData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create category', 'INTERNAL_SERVER_ERROR');
  }

  return data as Category;
}

// Function to update category
export async function updateCategory(id: string, categoryData: Partial<Category>): Promise<Category> {
  const currentCategory = await getCategory(id);

  if (!currentCategory) {
    throw new AppError(404, 'Category not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(categoriesTable).update(categoryData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update category', 'INTERNAL_SERVER_ERROR');
  }

  return data as Category;
}

// Function to delete category
export async function deleteCategory(id: string): Promise<void> {
  const category = await getCategory(id);

  if (!category) {
    throw new AppError(404, 'Category not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(categoriesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete category', 'INTERNAL_SERVER_ERROR');
  }
}
