import { Request, Response } from 'express';
import { ArticleServiceService } from '../services/articleService.service';

export class ArticleServiceController {
  static async createArticleService(req: Request, res: Response) {
    try {
      const { articleId, serviceId, priceMultiplier } = req.body;
      const articleService = await ArticleServiceService.createArticleService(articleId, serviceId, priceMultiplier);
      res.json({ data: articleService });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllArticleServices(req: Request, res: Response) {
    try {
      const articleServices = await ArticleServiceService.getAllArticleServices();
      res.json({ data: articleServices });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateArticleService(req: Request, res: Response) {
    try {
      const { articleServiceId } = req.params;
      const { priceMultiplier } = req.body;
      const articleService = await ArticleServiceService.updateArticleService(articleServiceId, priceMultiplier);
      res.json({ data: articleService });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteArticleService(req: Request, res: Response) {
    try {
      const { articleServiceId } = req.params;
      await ArticleServiceService.deleteArticleService(articleServiceId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
