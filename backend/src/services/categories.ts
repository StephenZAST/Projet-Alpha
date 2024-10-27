import { db } from './firebase';
import { AppError, errorCodes } from '../utils/errors';

export interface Category {
  id: string;
  name: string;
  description?: string;
  isActive: boolean;
}

export async function getCategories(): Promise<Category[]> {
  try {
    const categoriesSnapshot = await db.collection('categories').get();
    return categoriesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Category));
  } catch (error) {
    throw new AppError(500, 'Failed to fetch categories', errorCodes.DATABASE_ERROR);
  }
}

export async function createCategory(categoryData: Omit<Category, 'id'>): Promise<Category> {
  try {
    const categoryRef = await db.collection('categories').add(categoryData);
    return { ...categoryData, id: categoryRef.id };
  } catch (error) {
    throw new AppError(500, 'Failed to create category', errorCodes.DATABASE_ERROR);
  }
}

export async function updateCategory(categoryId: string, categoryData: Partial<Category>): Promise<Category> {
  try {
    const categoryRef = db.collection('categories').doc(categoryId);
    await categoryRef.update(categoryData);
    const updatedCategory = await categoryRef.get();
    return { id: categoryId, ...updatedCategory.data() } as Category;
  } catch (error) {
    throw new AppError(500, 'Failed to update category', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteCategory(categoryId: string): Promise<void> {
  try {
    await db.collection('categories').doc(categoryId).delete();
  } catch (error) {
    throw new AppError(500, 'Failed to delete category', errorCodes.DATABASE_ERROR);
  }
}
