import { Request, Response } from 'express';
import { ArticleService } from '../services/article.service';

export class ArticleController {
  static async createArticle(req: Request, res: Response) {
    try {
      const articleData = req.body;
      const result = await ArticleService.createArticle(articleData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getArticleById(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      const result = await ArticleService.getArticleById(articleId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(error.message === 'Article not found' ? 404 : 500)
         .json({ error: error.message });
    }
  }

  static async getAllArticles(req: Request, res: Response) {
    try {
      const result = await ArticleService.getAllArticles();
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      const articleData = req.body;
      const result = await ArticleService.updateArticle(articleId, articleData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      await ArticleService.deleteArticle(articleId);
      res.json({ message: 'Article deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
