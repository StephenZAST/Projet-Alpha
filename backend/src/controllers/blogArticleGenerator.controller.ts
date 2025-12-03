/**
 * 📝 Blog Article Generator Controller - Contrôle de la génération d'articles
 */

import { Request, Response } from 'express';
import { BlogArticleGeneratorService } from '../services/blogArticleGenerator.service';

export class BlogArticleGeneratorController {
  /**
   * Générer des articles basés sur les tendances
   */
  static async generateFromTrends(req: Request, res: Response) {
    try {
      const { count = 3 } = req.body;
      const apiKey = process.env.GOOGLE_AI_API_KEY;

      console.log(`🚀 [Controller] Génération de ${count} articles...`);
      console.log(`🔑 [Controller] API Key configured: ${!!apiKey}`);
      console.log(`📊 [Controller] Count: ${count}`);

      if (!apiKey) {
        console.error('❌ [Controller] Google AI API key not configured');
        return res.status(500).json({ 
          error: 'Google AI API key not configured',
          success: false 
        });
      }

      console.log(`🚀 [Controller] Calling BlogArticleGeneratorService.generateArticlesFromTrends...`);
      const articles = await BlogArticleGeneratorService.generateArticlesFromTrends(count, apiKey);

      console.log(`✅ [Controller] Generated ${articles.length} articles`);
      res.json({
        success: true,
        message: `${articles.length} articles générés avec succès`,
        data: articles
      });
    } catch (error: any) {
      console.error('[Controller] Error generating articles:', error);
      console.error('[Controller] Error stack:', error.stack);
      res.status(500).json({
        error: 'Failed to generate articles',
        message: error.message,
        success: false
      });
    }
  }

  /**
   * Récupérer les tendances actuelles
   */
  static async getTrends(req: Request, res: Response) {
    try {
      const { geo = 'BF' } = req.query;

      console.log(`🔍 [Controller] Récupération des tendances pour: ${geo}`);
      const trends = await BlogArticleGeneratorService.getTrendingTopics(geo as string);

      res.json({
        success: true,
        data: trends
      });
    } catch (error: any) {
      console.error('[Controller] Error getting trends:', error);
      res.status(500).json({
        error: 'Failed to get trends',
        message: error.message
      });
    }
  }

  /**
   * Publier un article brouillon
   */
  static async publishArticle(req: Request, res: Response) {
    try {
      const { articleId } = req.params;

      console.log(`📤 [Controller] Publication de l'article: ${articleId}`);
      const article = await BlogArticleGeneratorService.publishArticle(articleId);

      res.json({
        success: true,
        message: 'Article publié avec succès',
        data: article
      });
    } catch (error: any) {
      console.error('[Controller] Error publishing article:', error);
      res.status(500).json({
        error: 'Failed to publish article',
        message: error.message
      });
    }
  }

  /**
   * Récupérer les articles en attente
   */
  static async getPendingArticles(req: Request, res: Response) {
    try {
      console.log('📋 [Controller] Récupération des articles en attente');
      const articles = await BlogArticleGeneratorService.getPendingArticles();

      res.json({
        success: true,
        data: articles,
        count: articles.length
      });
    } catch (error: any) {
      console.error('[Controller] Error getting pending articles:', error);
      res.status(500).json({
        error: 'Failed to get pending articles',
        message: error.message
      });
    }
  }

  /**
   * Obtenir les statistiques de génération
   */
  static async getStats(req: Request, res: Response) {
    try {
      console.log('📊 [Controller] Récupération des statistiques');
      const stats = await BlogArticleGeneratorService.getGenerationStats();

      res.json({
        success: true,
        data: stats
      });
    } catch (error: any) {
      console.error('[Controller] Error getting stats:', error);
      res.status(500).json({
        error: 'Failed to get stats',
        message: error.message
      });
    }
  }

  /**
   * Insérer les 4 articles pilotes
   */
  static async seedPilotArticles(req: Request, res: Response) {
    try {
      console.log('🌱 [Controller] Insertion des articles pilotes');
      const articles = await BlogArticleGeneratorService.seedPilotArticles();

      res.json({
        success: true,
        message: `${articles.length} articles pilotes insérés avec succès`,
        data: articles
      });
    } catch (error: any) {
      console.error('[Controller] Error seeding pilot articles:', error);
      res.status(500).json({
        error: 'Failed to seed pilot articles',
        message: error.message
      });
    }
  }
}
