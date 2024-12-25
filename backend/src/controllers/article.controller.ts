import { Request, Response } from 'express';
import { ArticleService } from '../services/article.service';

export class ArticleController {
  static async createArticle(req: Request, res: Response) {
    try {
      const { name, basePrice, premiumPrice, categoryId, description } = req.body;
      const article = await ArticleService.createArticle(name, basePrice, premiumPrice, categoryId, description);
      res.json({ data: article });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllArticles(req: Request, res: Response) {
    try {
      const articles = await ArticleService.getAllArticles();
      res.json({ data: articles });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateArticle(req: Request, res: Response) {
    try {
      const { articleId } = req.params;
      const { name, basePrice, premiumPrice, categoryId, description } = req.body;
      const article = await ArticleService.updateArticle(articleId, name, basePrice, premiumPrice, categoryId, description);
      res.json({ data: article });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteArticle(req: Request, res: Response) {
    try {
      const { articleId } = req.params;
      await ArticleService.deleteArticle(articleId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
