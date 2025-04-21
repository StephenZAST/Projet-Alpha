import { PrismaClient } from '@prisma/client';
import { BlogCategory } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

export class BlogCategoryService {
  static async createCategory(name: string, description?: string): Promise<BlogCategory> {
    try {
      const newCategory = await prisma.blog_categories.create({
        data: {
          id: uuidv4(),
          name,
          description: description || null,
          created_at: new Date(),
          updated_at: new Date()  // On garde dans la BD mais pas dans le retour
        }
      });

      return {
        id: newCategory.id,
        name: newCategory.name,
        description: newCategory.description || undefined,
        createdAt: newCategory.created_at ? new Date(newCategory.created_at) : new Date()
      };
    } catch (error) {
      console.error('Create category error:', error);
      throw error;
    }
  }

  static async getAllCategories(): Promise<BlogCategory[]> {
    try {
      const categories = await prisma.blog_categories.findMany({
        orderBy: {
          created_at: 'desc'
        }
      });

      return categories.map(category => ({
        id: category.id,
        name: category.name,
        description: category.description || undefined,
        createdAt: category.created_at ? new Date(category.created_at) : new Date()
      }));
    } catch (error) {
      console.error('Get all categories error:', error);
      throw error;
    }
  }
 
  static async updateCategory(categoryId: string, name: string, description?: string): Promise<BlogCategory> {
    try {
      const updatedCategory = await prisma.blog_categories.update({
        where: {
          id: categoryId
        },
        data: {
          name,
          description: description || null,
          updated_at: new Date()
        }
      });

      return {
        id: updatedCategory.id,
        name: updatedCategory.name,
        description: updatedCategory.description || undefined,
        createdAt: updatedCategory.created_at ? new Date(updatedCategory.created_at) : new Date()
      };
    } catch (error) {
      console.error('Update category error:', error);
      throw error;
    }
  }

  static async deleteCategory(categoryId: string): Promise<void> {
    try {
      await prisma.blog_categories.delete({
        where: {
          id: categoryId
        }
      });
    } catch (error) {
      console.error('Delete category error:', error);
      throw error;
    }
  }

  static async getCategoryById(categoryId: string): Promise<BlogCategory | null> {
    try {
      const category = await prisma.blog_categories.findUnique({
        where: {
          id: categoryId
        }
      });

      if (!category) return null;

      return {
        id: category.id,
        name: category.name,
        description: category.description || undefined,
        createdAt: category.created_at ? new Date(category.created_at) : new Date()
      };
    } catch (error) {
      console.error('Get category by ID error:', error);
      throw error;
    }
  }
}
