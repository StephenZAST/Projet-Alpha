import { Request, Response } from 'express';
import { BlogArticleService } from '../services/blogArticle.service'; 

export class BlogArticleController {
  static async createArticle(req: Request, res: Response) {
    try {
      const { title, content, categoryId } = req.body;
      const authorId = req.user?.id;
      if (!authorId) return res.status(401).json({ error: 'Unauthorized' });

      const article = await BlogArticleService.createArticle(title, content, categoryId, authorId);
      res.json({ data: article });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async getAllArticles(req: Request, res: Response) {
    try {
      const articles = await BlogArticleService.getAllArticles();
      res.json({ data: articles });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateArticle(req: Request, res: Response) {
    try {
      const { articleId } = req.params;
      const { title, content, categoryId } = req.body;
      const article = await BlogArticleService.updateArticle(articleId, title, content, categoryId);
      res.json({ data: article });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async deleteArticle(req: Request, res: Response) {
    try {
      const { articleId } = req.params;
      await BlogArticleService.deleteArticle(articleId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async generateArticle(req: Request, res: Response) {
    try {
      const { title, context, prompts } = req.body;
      const apiKey = process.env.GOOGLE_AI_API_KEY;
      if (!apiKey) return res.status(500).json({ error: 'API key not configured' });

      const content = await BlogArticleService.generateArticle(title, context, prompts, apiKey);
      res.json({ data: content });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
