import { Request, Response } from 'express';
import { ArticleCategoryService } from '../services/articleCategory.service';

export class ArticleCategoryController {
  static async createArticleCategory(req: Request, res: Response) {
    try {
      const categoryData = req.body;
      const result = await ArticleCategoryService.createArticleCategory(categoryData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getArticleCategoryById(req: Request, res: Response) {
    try {
      const categoryId = req.params.categoryId;
      const result = await ArticleCategoryService.getArticleCategoryById(categoryId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(error.message === 'Article category not found' ? 404 : 500)
         .json({ error: error.message });
    }
  }

  static async getAllArticleCategories(req: Request, res: Response) {
    try {
      const result = await ArticleCategoryService.getAllArticleCategories();
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateArticleCategory(req: Request, res: Response) {
    try {
      const categoryId = req.params.categoryId;
      const categoryData = req.body;
      const result = await ArticleCategoryService.updateArticleCategory(categoryId, categoryData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteArticleCategory(req: Request, res: Response) {
    try {
      const categoryId = req.params.categoryId;
      await ArticleCategoryService.deleteArticleCategory(categoryId);
      res.json({ message: 'Article category deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
