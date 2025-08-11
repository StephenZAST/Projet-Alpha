import { PrismaClient } from '@prisma/client';
import { ArticleCategory, CreateArticleCategoryDTO } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

export class ArticleCategoryService {
  static async createArticleCategory(categoryData: CreateArticleCategoryDTO): Promise<ArticleCategory> {
    const { name, description } = categoryData;

    const data = await prisma.article_categories.create({
      data: {
        id: uuidv4(),
        name,
        description,
        createdAt: new Date()
      }
    });

    return {
      id: data.id,
      name: data.name,
      description: data.description || undefined,
      createdAt: data.createdAt || new Date()
    };
  }

  static async getArticleCategoryById(categoryId: string): Promise<ArticleCategory> {
    const data = await prisma.article_categories.findUnique({
      where: { id: categoryId }
    });

    if (!data) throw new Error('Article category not found');

    return {
      id: data.id,
      name: data.name,
      description: data.description || undefined,
      createdAt: data.createdAt || new Date()
    };
  }

  static async getAllArticleCategories(): Promise<ArticleCategory[]> {
    try {
      // Récupère toutes les catégories et compte les articles associés
      const categories = await prisma.article_categories.findMany({
        orderBy: { name: 'asc' },
        include: { articles: true }
      });

      return categories.map(category => ({
        id: category.id,
        name: category.name,
        description: category.description || undefined,
        createdAt: category.createdAt || new Date(),
        articlesCount: category.articles ? category.articles.length : 0
      }));
    } catch (error) {
      console.error('Error in getAllCategories:', error);
      throw error;
    }
  }

  static async updateArticleCategory(categoryId: string, categoryData: Partial<ArticleCategory>): Promise<ArticleCategory> {
    const data = await prisma.article_categories.update({
      where: { id: categoryId },
      data: {
        name: categoryData.name,
        description: categoryData.description
      }
    });

    if (!data) throw new Error('Article category not found');

    return {
      id: data.id,
      name: data.name,
      description: data.description || undefined,
      createdAt: data.createdAt || new Date()
    };
  }

  static async deleteArticleCategory(categoryId: string): Promise<void> {
    await prisma.article_categories.delete({
      where: { id: categoryId }
    });
  }
}
