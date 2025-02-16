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
      const categories = await ArticleCategoryService.getAllArticleCategories();
      return res.status(200).json({
        success: true,
        data: categories,
        message: 'Categories retrieved successfully'
      });
    } catch (error) {
      console.error('Error in getAllArticleCategories controller:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to retrieve categories',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async updateArticleCategory(req: Request, res: Response) {
    try {
      console.log('[ArticleCategoryController] Update request:', {
        id: req.params.categoryId,
        data: req.body
      });

      const categoryId = req.params.categoryId;
      const categoryData = req.body;

      const result = await ArticleCategoryService.updateArticleCategory(
        categoryId,
        categoryData
      );

      return res.status(200).json({
        success: true,
        data: result,
        message: 'Category updated successfully'
      });
    } catch (error) {
      console.error('[ArticleCategoryController] Update error:', error);
      
      if (error instanceof Error) {
        if (error.message.includes('not found')) {
          return res.status(404).json({
            success: false,
            message: 'Category not found',
            error: error.message
          });
        }
      }

      return res.status(500).json({
        success: false,
        message: 'Failed to update category',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
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
