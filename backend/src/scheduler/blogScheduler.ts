/**
 * 📅 Blog Scheduler - Planification automatique de la génération et publication d'articles
 */

import cron from 'node-cron';
import { BlogArticleGeneratorService } from '../services/blogArticleGenerator.service';
import { BlogArticleService } from '../services/blogArticle.service';

export class BlogScheduler {
  /**
   * Initialiser le scheduler
   */
  static initialize() {
    console.log('📅 [BlogScheduler] Initialisation du scheduler...');

    // Générer des articles tous les lundis à 10h
    this.scheduleArticleGeneration();

    // Publier les articles en attente tous les jours à 9h
    this.scheduleArticlePublication();

    // Mettre à jour les statistiques tous les jours à minuit
    this.scheduleStatsUpdate();

    console.log('✅ [BlogScheduler] Scheduler initialisé');
  }

  /**
   * Générer des articles basés sur les tendances
   * Cron: Tous les lundis à 10h (0 10 * * 1)
   */
  private static scheduleArticleGeneration() {
    cron.schedule('0 10 * * 1', async () => {
      try {
        console.log('🚀 [BlogScheduler] Démarrage de la génération d\'articles...');

        const apiKey = process.env.GOOGLE_AI_API_KEY;
        if (!apiKey) {
          console.error('❌ [BlogScheduler] Google AI API key not configured');
          return;
        }

        // Générer 2 articles par semaine
        const articles = await BlogArticleGeneratorService.generateArticlesFromTrends(2, apiKey);

        console.log(`✅ [BlogScheduler] ${articles.length} articles générés`);

        // Envoyer une notification
        this.sendNotification(
          'Génération d\'articles',
          `${articles.length} nouveaux articles ont été générés et sont en attente de publication.`
        );
      } catch (error) {
        console.error('❌ [BlogScheduler] Erreur lors de la génération:', error);
        this.sendNotification(
          'Erreur de génération',
          'Une erreur s\'est produite lors de la génération des articles.'
        );
      }
    });

    console.log('📅 [BlogScheduler] Génération d\'articles planifiée (Lundi 10h)');
  }

  /**
   * Publier les articles en attente
   * Cron: Tous les jours à 9h (0 9 * * *)
   */
  private static scheduleArticlePublication() {
    cron.schedule('0 9 * * *', async () => {
      try {
        console.log('📤 [BlogScheduler] Vérification des articles à publier...');

        const pendingArticles = await BlogArticleGeneratorService.getPendingArticles();

        if (pendingArticles.length === 0) {
          console.log('ℹ️ [BlogScheduler] Aucun article à publier');
          return;
        }

        // Publier le premier article en attente
        const articleToPublish = pendingArticles[0];
        const published = await BlogArticleGeneratorService.publishArticle(articleToPublish.id);

        console.log(`✅ [BlogScheduler] Article publié: ${published.title}`);

        // Envoyer une notification
        this.sendNotification(
          'Article publié',
          `L'article "${published.title}" a été publié avec succès.`
        );
      } catch (error) {
        console.error('❌ [BlogScheduler] Erreur lors de la publication:', error);
        this.sendNotification(
          'Erreur de publication',
          'Une erreur s\'est produite lors de la publication d\'un article.'
        );
      }
    });

    console.log('📅 [BlogScheduler] Publication d\'articles planifiée (Tous les jours 9h)');
  }

  /**
   * Mettre à jour les statistiques
   * Cron: Tous les jours à minuit (0 0 * * *)
   */
  private static scheduleStatsUpdate() {
    cron.schedule('0 0 * * *', async () => {
      try {
        console.log('📊 [BlogScheduler] Mise à jour des statistiques...');

        const stats = await BlogArticleGeneratorService.getGenerationStats();

        console.log('✅ [BlogScheduler] Statistiques mises à jour:', stats);

        // Envoyer une notification si trop d'articles en attente
        if (stats.pending > 5) {
          this.sendNotification(
            'Articles en attente',
            `${stats.pending} articles sont en attente de publication.`
          );
        }
      } catch (error) {
        console.error('❌ [BlogScheduler] Erreur lors de la mise à jour des stats:', error);
      }
    });

    console.log('📅 [BlogScheduler] Mise à jour des statistiques planifiée (Tous les jours minuit)');
  }

  /**
   * Envoyer une notification (à implémenter avec votre système de notifications)
   */
  private static sendNotification(title: string, message: string) {
    console.log(`📧 [BlogScheduler] Notification: ${title}`);
    console.log(`   Message: ${message}`);

    // TODO: Implémenter l'envoi de notifications
    // - Email aux admins
    // - Notification dans le dashboard
    // - Webhook
  }

  /**
   * Arrêter le scheduler
   */
  static stop() {
    console.log('⏹️ [BlogScheduler] Arrêt du scheduler');
    cron.getTasks().forEach(task => task.stop());
  }
}
