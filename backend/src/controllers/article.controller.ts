import { Request, Response } from 'express';
import { ArticleService } from '../services/article.service';

export class ArticleController {
  static async createArticle(req: Request, res: Response) {
    try {
      const result = await ArticleService.createArticle(req.body);
      return res.status(201).json({
        success: true,
        data: result,
        message: 'Article created successfully'
      });
    } catch (error) {
      console.error('Error in createArticle controller:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to create article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async getArticleById(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      const result = await ArticleService.getArticleById(articleId);
      return res.status(200).json({
        success: true,
        data: result,
        message: 'Article retrieved successfully'
      });
    } catch (error) {
      const status = error instanceof Error && error.message === 'Article not found' ? 404 : 500;
      return res.status(status).json({
        success: false,
        message: status === 404 ? 'Article not found' : 'Failed to retrieve article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async getAllArticles(req: Request, res: Response) {
    try {
      console.log('Fetching all articles...');
      const result = await ArticleService.getAllArticles();
      console.log(`Found ${result.length} articles`);
      
      return res.status(200).json({
        success: true,
        data: result,
        message: 'Articles retrieved successfully'
      });
    } catch (error) {
      console.error('Error in getAllArticles controller:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to retrieve articles',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async updateArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      const result = await ArticleService.updateArticle(articleId, req.body);
      return res.status(200).json({
        success: true,
        data: result,
        message: 'Article updated successfully'
      });
    } catch (error) {
      const status = error instanceof Error && error.message === 'Article not found' ? 404 : 500;
      return res.status(status).json({
        success: false,
        message: status === 404 ? 'Article not found' : 'Failed to update article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async deleteArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      await ArticleService.deleteArticle(articleId);
      return res.status(200).json({
        success: true,
        message: 'Article deleted successfully'
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Failed to delete article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}
