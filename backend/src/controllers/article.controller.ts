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
      console.log('[ArticleController] Update request:', {
        id: req.params.articleId,
        body: req.body
      });

      const articleId = req.params.articleId;
      if (!articleId) {
        return res.status(400).json({
          success: false,
          message: 'Article ID is required'
        });
      }

      // Construire l'objet de mise à jour avec les champs corrects
      const updateData = {
        name: req.body.name,
        description: req.body.description,
        basePrice: req.body.basePrice,
        premiumPrice: req.body.premiumPrice,
        categoryId: req.body.categoryId,
      };

      console.log('[ArticleController] Prepared update data:', updateData);

      const result = await ArticleService.updateArticle(articleId, updateData);

      return res.status(200).json({
        success: true,
        data: result,
        message: 'Article updated successfully'
      });
    } catch (error) {
      console.error('[ArticleController] Update error:', error);
      
      if (error instanceof Error && error.message.includes('not found')) {
        return res.status(404).json({
          success: false,
          message: 'Article not found',
          error: error.message
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Failed to update article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async deleteArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      console.log('[ArticleController] Delete request for article:', articleId);

      await ArticleService.deleteArticle(articleId);
      
      return res.status(200).json({
        success: true,
        message: 'Article deleted successfully'
      });
    } catch (error) {
      console.error('[ArticleController] Delete error:', error);
      
      if (error instanceof Error) {
        if (error.message.includes('not found')) {
          return res.status(404).json({
            success: false,
            message: 'Article not found',
            error: error.message
          });
        } else if (error.message.includes('referenced in existing orders')) {
          return res.status(400).json({
            success: false,
            message: 'Cannot delete article: It is used in existing orders',
            error: error.message
          });
        }
      }

      return res.status(500).json({
        success: false,
        message: 'Failed to delete article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async archiveArticle(req: Request, res: Response) {
    try {
      const articleId = req.params.articleId;
      const { reason } = req.body;

      if (!reason) {
        return res.status(400).json({
          success: false,
          message: 'Archive reason is required'
        });
      }

      await ArticleService.archiveArticle(articleId, reason);
      
      return res.status(200).json({
        success: true,
        message: 'Article archived successfully'
      });
    } catch (error) {
      console.error('[ArticleController] Archive error:', error);
      
      return res.status(500).json({
        success: false,
        message: 'Failed to archive article',
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}
