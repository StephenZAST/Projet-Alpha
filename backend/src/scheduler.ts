import cron from 'node-cron';
import { BlogArticleService } from './services/blogArticle.service';
import { AffiliateCommissionService } from './services/affiliate.service/affiliateCommission.service';
import supabase from './config/database';
import dotenv from 'dotenv';
 
dotenv.config();

const apiKey = process.env.GOOGLE_AI_API_KEY;
// Planifier une tâche cron pour générer un article de blog tous les jours à 2h du matin
cron.schedule('0 2 * * *', async () => {
  try {
    if (!apiKey) {
      console.warn('API key not configured for blog generation');
      return;
    }

    // Récupérer la catégorie par défaut
    const defaultCategory = await BlogArticleService.getDefaultCategory();
    if (!defaultCategory) {
      console.error('Default blog category not found');
      return;
    }

    // Récupérer un admin pour l'auteur (à adapter selon votre logique)
    const { data: adminUser, error: adminError } = await supabase
      .from('users')
      .select('id')
      .eq('role', 'ADMIN')
      .single();

    if (adminError || !adminUser) {
      console.error('Admin user not found for blog article creation');
      return;
    } 

    const trendingTopics = await BlogArticleService.getTrendingTopics();
    const randomTopic = trendingTopics[Math.floor(Math.random() * trendingTopics.length)];
    
    const title = `Les avantages du nettoyage à sec : ${randomTopic}`;
    const context = `Expliquez les avantages du nettoyage à sec pour les vêtements délicats et comment Alpha Laundry offre ce service en relation avec ${randomTopic}.`;
    const prompts = [
      `Quels sont les avantages du nettoyage à sec par rapport au lavage traditionnel en relation avec ${randomTopic} ?`,
      `Comment Alpha Laundry garantit-elle la qualité de ses services de nettoyage à sec en relation avec ${randomTopic} ?`,
      `Quels types de vêtements sont les plus adaptés au nettoyage à sec en relation avec ${randomTopic} ?`
    ];

    const content = await BlogArticleService.generateArticle(title, context, prompts, apiKey);
    await BlogArticleService.createArticle(
      title,
      content,
      defaultCategory.id,
      adminUser.id
    );

    console.log('Article de blog généré automatiquement avec succès');
  } catch (error) {
    console.error('Erreur lors de la génération automatique de l\'article de blog:', error);
  }
});

// Réinitialisation mensuelle des gains d'affiliés (1er jour du mois à 00:00)
cron.schedule('0 0 1 * *', async () => {
  try {
    console.log('Démarrage de la réinitialisation mensuelle des gains d\'affiliés...');
    await AffiliateCommissionService.resetMonthlyEarnings();
    console.log('Réinitialisation mensuelle des gains d\'affiliés terminée avec succès');
  } catch (error) {
    console.error('Erreur lors de la réinitialisation mensuelle des gains d\'affiliés:', error);
  }
});
