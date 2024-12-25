import cron from 'node-cron';
import { BlogArticleService } from './services/blogArticle.service';
import dotenv from 'dotenv';

dotenv.config();

const apiKey = process.env.GOOGLE_AI_API_KEY;

if (!apiKey) {
  console.error('API key not configured');
  process.exit(1);
}

// Planifier une tâche cron pour générer un article de blog tous les jours à 2h du matin
cron.schedule('0 2 * * *', async () => {
  try {
    const trendingTopics = await BlogArticleService.getTrendingTopics();
    const randomTopic = trendingTopics[Math.floor(Math.random() * trendingTopics.length)];
    const title = `Les avantages du nettoyage à sec : ${randomTopic}`;
    const context = `Expliquez les avantages du nettoyage à sec pour les vêtements délicats et comment Alpha Laundry offre ce service en relation avec ${randomTopic}.`;
    const prompts = [
      `Quels sont les avantages du nettoyage à sec par rapport au lavage traditionnel en relation avec ${randomTopic} ?`,
      `Comment Alpha Laundry garantit-elle la qualité de ses services de nettoyage à sec en relation avec ${randomTopic} ?`,
      `Quels types de vêtements sont les plus adaptés au nettoyage à sec en relation avec ${randomTopic} ?`
    ];
    const categoryId = 'category_id'; // Remplacer par un ID de catégorie valide
    const authorId = 'admin_id'; // Remplacer par un ID d'administrateur valide

    const content = await BlogArticleService.generateArticle(title, context, prompts, apiKey);
    await BlogArticleService.createArticle(title, content, categoryId, authorId);

    console.log('Article de blog généré automatiquement avec succès');
  } catch (error) {
    console.error('Erreur lors de la génération automatique de l\'article de blog:', error);
  }
});
