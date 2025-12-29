/**
 * 📝 Blog Article Queue Controller - Contrôle de la génération asynchrone
 */

import { Request, Response } from 'express';
import { BlogArticleQueueService } from '../services/blogArticleQueue.service';
import { BlogArticleGeneratorService } from '../services/blogArticleGenerator.service';

export class BlogArticleQueueController {
  /**
   * Générer un seul article (asynchrone)
   */
  static async generateArticle(req: Request, res: Response) {
    try {
      console.log(`[QueueController] Génération d'un article...`);

      // Récupérer les tendances
      const trends = await BlogArticleGeneratorService['getTrendingTopics']();
      
      if (trends.length === 0) {
        return res.status(400).json({
          error: 'No topics available',
          success: false
        });
      }

      // Prendre le premier sujet
      const topic = trends[0];
      console.log(`[QueueController] Topic sélectionné: ${topic}`);

      // Ajouter à la queue
      const job = await BlogArticleQueueService.addToQueue(topic);

      res.json({
        success: true,
        message: 'Article ajouté à la queue de génération',
        jobId: job.id,
        topic: job.topic,
        status: job.status
      });
    } catch (error: any) {
      console.error('[QueueController] Error:', error);
      res.status(500).json({
        error: 'Failed to add article to queue',
        message: error.message,
        success: false
      });
    }
  }

  /**
   * Obtenir le statut d'un job
   */
  static async getJobStatus(req: Request, res: Response) {
    try {
      const { jobId } = req.params;

      const job = BlogArticleQueueService.getJobStatus(jobId);

      if (!job) {
        return res.status(404).json({
          error: 'Job not found',
          success: false
        });
      }

      res.json({
        success: true,
        job
      });
    } catch (error: any) {
      console.error('[QueueController] Error:', error);
      res.status(500).json({
        error: 'Failed to get job status',
        message: error.message,
        success: false
      });
    }
  }

  /**
   * Obtenir tous les jobs
   */
  static async getAllJobs(req: Request, res: Response) {
    try {
      const jobs = BlogArticleQueueService.getAllJobs();

      res.json({
        success: true,
        count: jobs.length,
        jobs
      });
    } catch (error: any) {
      console.error('[QueueController] Error:', error);
      res.status(500).json({
        error: 'Failed to get jobs',
        message: error.message,
        success: false
      });
    }
  }

  /**
   * Obtenir les statistiques de la queue
   */
  static async getQueueStats(req: Request, res: Response) {
    try {
      const stats = BlogArticleQueueService.getQueueStats();

      res.json({
        success: true,
        stats
      });
    } catch (error: any) {
      console.error('[QueueController] Error:', error);
      res.status(500).json({
        error: 'Failed to get queue stats',
        message: error.message,
        success: false
      });
    }
  }

  /**
   * Nettoyer les anciens jobs
   */
  static async cleanupOldJobs(req: Request, res: Response) {
    try {
      const cleaned = BlogArticleQueueService.cleanupOldJobs();

      res.json({
        success: true,
        message: `${cleaned} anciens jobs supprimés`,
        cleaned
      });
    } catch (error: any) {
      console.error('[QueueController] Error:', error);
      res.status(500).json({
        error: 'Failed to cleanup jobs',
        message: error.message,
        success: false
      });
    }
  }
}
