/**
 * 📝 Blog Article Queue Service - Génération asynchrone d'articles
 * Utilise une queue pour générer les articles un par un
 */

import { PrismaClient } from '@prisma/client';
import { BlogArticleGeneratorService } from './blogArticleGenerator.service';
import { RetryHandler, RetryOptions } from '../utils/retryHandler';

const prisma = new PrismaClient();

interface GenerationJob {
  id: string;
  topic: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  result?: any;
  error?: string;
  createdAt: Date;
  completedAt?: Date;
}

// Queue en mémoire (à remplacer par Redis/Bull en production)
const generationQueue: Map<string, GenerationJob> = new Map();

export class BlogArticleQueueService {
  /**
   * Ajouter un article à la queue de génération
   */
  static async addToQueue(topic: string): Promise<GenerationJob> {
    const jobId = `job-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const job: GenerationJob = {
      id: jobId,
      topic,
      status: 'pending',
      createdAt: new Date()
    };

    generationQueue.set(jobId, job);
    console.log(`[BlogArticleQueue] Job ajouté: ${jobId} - Topic: ${topic}`);

    // Traiter le job de manière asynchrone (sans attendre)
    this.processJob(jobId).catch(error => {
      console.error(`[BlogArticleQueue] Erreur lors du traitement du job ${jobId}:`, error);
    });

    return job;
  }

  /**
   * Traiter un job de la queue avec retry automatique et rate limiting
   */
  private static async processJob(jobId: string): Promise<void> {
    const job = generationQueue.get(jobId);
    if (!job) {
      console.error(`[BlogArticleQueue] Job non trouvé: ${jobId}`);
      return;
    }

    try {
      job.status = 'processing';
      console.log(`[BlogArticleQueue] Traitement du job: ${jobId}`);

      // Attendre avant de traiter pour respecter le rate limit de Gemini (2 req/min = 30s min)
      await this.waitForRateLimit();

      const apiKey = process.env.GOOGLE_AI_API_KEY;
      if (!apiKey) {
        throw new Error('GOOGLE_AI_API_KEY not configured');
      }

      // Récupérer la catégorie et l'auteur
      const category = await prisma.blog_categories.findFirst({
        where: { name: 'Conseils & Astuces' }
      });

      if (!category) {
        throw new Error('Default category not found');
      }

      const author = await prisma.users.findFirst({
        where: { role: 'ADMIN' }
      });

      if (!author) {
        throw new Error('Default author not found');
      }

      // Générer l'article avec retry automatique
      const retryOptions: RetryOptions = {
        maxAttempts: 3,
        initialDelayMs: 2000,
        maxDelayMs: 10000,
        backoffMultiplier: 2,
        jitter: true
      };

      const article = await RetryHandler.execute(
        async () => {
          const keywords = BlogArticleGeneratorService['extractKeywords'](job.topic);
          return await BlogArticleGeneratorService['generateArticleWithAI'](
            job.topic,
            keywords,
            apiKey
          );
        },
        retryOptions
      );

      // Créer l'article en base de données
      const createdArticle = await BlogArticleGeneratorService['createGeneratedArticle'](
        article,
        category.id,
        author.id
      );

      job.status = 'completed';
      job.result = createdArticle;
      job.completedAt = new Date();

      console.log(`✅ [BlogArticleQueue] Job complété: ${jobId}`);
    } catch (error: any) {
      job.status = 'failed';
      job.error = error.message;
      job.completedAt = new Date();

      console.error(`❌ [BlogArticleQueue] Job échoué: ${jobId} - ${error.message}`);
    }
  }

  /**
   * Attendre pour respecter le rate limit de Gemini (2 requêtes par minute)
   * Minimum 30 secondes entre chaque requête
   */
  private static lastGeminiRequestTime: number = 0;
  private static readonly GEMINI_RATE_LIMIT_MS = 30000; // 30 secondes (2 req/min)

  private static async waitForRateLimit(): Promise<void> {
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastGeminiRequestTime;

    if (timeSinceLastRequest < this.GEMINI_RATE_LIMIT_MS) {
      const waitTime = this.GEMINI_RATE_LIMIT_MS - timeSinceLastRequest;
      console.log(`[BlogArticleQueue] ⏳ Rate limit: attente de ${waitTime}ms avant la prochaine requête Gemini...`);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }

    this.lastGeminiRequestTime = Date.now();
  }

  /**
   * Obtenir le statut d'un job
   */
  static getJobStatus(jobId: string): GenerationJob | null {
    return generationQueue.get(jobId) || null;
  }

  /**
   * Obtenir tous les jobs
   */
  static getAllJobs(): GenerationJob[] {
    return Array.from(generationQueue.values());
  }

  /**
   * Obtenir les jobs en cours
   */
  static getProcessingJobs(): GenerationJob[] {
    return Array.from(generationQueue.values()).filter(job => job.status === 'processing');
  }

  /**
   * Obtenir les jobs complétés
   */
  static getCompletedJobs(): GenerationJob[] {
    return Array.from(generationQueue.values()).filter(job => job.status === 'completed');
  }

  /**
   * Obtenir les jobs échoués
   */
  static getFailedJobs(): GenerationJob[] {
    return Array.from(generationQueue.values()).filter(job => job.status === 'failed');
  }

  /**
   * Nettoyer les anciens jobs (plus de 24h)
   */
  static cleanupOldJobs(): number {
    const now = Date.now();
    const oneDayMs = 24 * 60 * 60 * 1000;
    let cleaned = 0;

    for (const [jobId, job] of generationQueue.entries()) {
      if (now - job.createdAt.getTime() > oneDayMs) {
        generationQueue.delete(jobId);
        cleaned++;
      }
    }

    console.log(`[BlogArticleQueue] ${cleaned} anciens jobs supprimés`);
    return cleaned;
  }

  /**
   * Générer plusieurs articles (un par un)
   */
  static async generateMultipleArticles(topics: string[]): Promise<GenerationJob[]> {
    const jobs: GenerationJob[] = [];

    for (const topic of topics) {
      const job = await this.addToQueue(topic);
      jobs.push(job);
      
      // Délai entre les jobs pour éviter les limites de taux
      await new Promise(resolve => setTimeout(resolve, 1000));
    }

    return jobs;
  }

  /**
   * Obtenir les statistiques de la queue
   */
  static getQueueStats() {
    const allJobs = Array.from(generationQueue.values());
    
    return {
      total: allJobs.length,
      pending: allJobs.filter(j => j.status === 'pending').length,
      processing: allJobs.filter(j => j.status === 'processing').length,
      completed: allJobs.filter(j => j.status === 'completed').length,
      failed: allJobs.filter(j => j.status === 'failed').length
    };
  }
}
