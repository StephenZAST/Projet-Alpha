import { Request, Response } from 'express';
import { ArticleCategoryService } from '../services/articleCategory.service';

export class ArticleCategoryController {
  static async createCategory(req: Request, res: Response) {
    try {
      const { name, description } = req.body;
      const category = await ArticleCategoryService.createCategory(name, description);
      res.json({ data: category });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllCategories(req: Request, res: Response) {
    try {
      const categories = await ArticleCategoryService.getAllCategories();
      res.json({ data: categories });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateCategory(req: Request, res: Response) {
    try {
      const { categoryId } = req.params;
      const { name, description } = req.body;
      const category = await ArticleCategoryService.updateCategory(categoryId, name, description);
      res.json({ data: category });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteCategory(req: Request, res: Response) {
    try {
      const { categoryId } = req.params;
      await ArticleCategoryService.deleteCategory(categoryId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
