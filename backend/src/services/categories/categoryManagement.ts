import { createClient } from '@supabase/supabase-js';
import { Category, CategoryStatus } from '../../models/category';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const categoriesTable = 'categories';

export async function getCategory(id: string): Promise<Category | null> {
  try {
    const { data, error } = await supabase.from(categoriesTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch category', errorCodes.DATABASE_ERROR);
    }

    return data as Category;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch category', errorCodes.DATABASE_ERROR);
  }
}

export async function createCategory(categoryData: Category): Promise<Category> {
  try {
    const { data, error } = await supabase.from(categoriesTable).insert([categoryData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create category', errorCodes.DATABASE_ERROR);
    }

    return data as Category;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create category', errorCodes.DATABASE_ERROR);
  }
}

export async function updateCategory(id: string, categoryData: Partial<Category>): Promise<Category> {
  try {
    const currentCategory = await getCategory(id);

    if (!currentCategory) {
      throw new AppError(404, 'Category not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(categoriesTable).update(categoryData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update category', errorCodes.DATABASE_ERROR);
    }

    return data as Category;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update category', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteCategory(id: string): Promise<void> {
  try {
    const category = await getCategory(id);

    if (!category) {
      throw new AppError(404, 'Category not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(categoriesTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete category', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete category', errorCodes.DATABASE_ERROR);
  }
}
