import { getCategory, createCategory, updateCategory, deleteCategory } from './categories/categoryManagement';
import { Category, CategoryStatus } from '../models/category';
import { AppError, errorCodes } from '../utils/errors';

export class CategoriesService {
  async getCategory(id: string): Promise<Category | null> {
    return getCategory(id);
  }

  async createCategory(categoryData: Category): Promise<Category> {
    return createCategory(categoryData);
  }

  async updateCategory(id: string, categoryData: Partial<Category>): Promise<Category> {
    return updateCategory(id, categoryData);
  }

  async deleteCategory(id: string): Promise<void> {
    return deleteCategory(id);
  }
}

export const categoriesService = new CategoriesService();
