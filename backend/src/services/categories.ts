import { Category } from '../models/category';
import {
  getCategory as getCategoryUtil,
  createCategory as createCategoryUtil,
  updateCategory as updateCategoryUtil,
  deleteCategory as deleteCategoryUtil
} from './categories/categoryManagement';

export class CategoriesService {
  async getCategory(id: string): Promise<Category | null> {
    return getCategoryUtil(id);
  }

  async getCategories(): Promise<Category[]> {
    // Assuming you have a function to fetch all categories in categoryManagement.ts
    // If not, you'll need to implement it similar to getCategoryUtil, createCategoryUtil, etc.
    return getCategoriesUtil();
  }

  async createCategory(categoryData: Category): Promise<Category> {
    return createCategoryUtil(categoryData);
  }

  async updateCategory(id: string, categoryData: Partial<Category>): Promise<Category> {
    return updateCategoryUtil(id, categoryData);
  }

  async deleteCategory(id: string): Promise<void> {
    return deleteCategoryUtil(id);
  }
}

export const categoriesService = new CategoriesService();

// Utility function to fetch all categories - Implement this in categoryManagement.ts if it doesn't exist
async function getCategoriesUtil(): Promise<Category[]> {
  // Placeholder implementation - replace with actual Supabase query
  // Example:
  // const { data, error } = await supabase.from('categories').select('*');
  // if (error) {
  //   throw new AppError(500, 'Failed to fetch categories', errorCodes.DATABASE_ERROR);
  // }
  // return data as Category[];
  throw new Error("getCategoriesUtil not implemented in categoryManagement.ts");
}
