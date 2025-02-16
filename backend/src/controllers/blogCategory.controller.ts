import { Request, Response } from 'express';
import { BlogCategoryService } from '../services/blogCategory.service';

export class BlogCategoryController {
  static async createCategory(req: Request, res: Response) {
    try {
      const { name, description } = req.body;
      const category = await BlogCategoryService.createCategory(name, description);
      res.json({ data: category });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async getAllCategories(req: Request, res: Response) {
    try {
      const categories = await BlogCategoryService.getAllCategories();
      res.json({ data: categories });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateCategory(req: Request, res: Response) {
    try {
      const { categoryId } = req.params;
      const { name, description } = req.body;
      const category = await BlogCategoryService.updateCategory(categoryId, name, description);
      res.json({ data: category });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteCategory(req: Request, res: Response) {
    try {
      const { categoryId } = req.params;
      await BlogCategoryService.deleteCategory(categoryId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
