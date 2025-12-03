/**
 * 📝 Blog Article Generator Service - Génération automatique d'articles
 * Utilise Google Trends et IA pour créer du contenu optimisé SEO
 */

import { PrismaClient } from '@prisma/client';
import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';
import { JSONParser } from '../utils/jsonParser';
import { RetryHandler, RetryOptions } from '../utils/retryHandler';

const prisma = new PrismaClient();

interface GeneratedArticle {
  title: string;
  slug: string;
  content: string;
  excerpt: string;
  seo_keywords: string[];
  seo_description: string;
  reading_time: number;
}

export class BlogArticleGeneratorService {
  /**
   * Récupérer les tendances actuelles (utilise des sujets pertinents par défaut)
   * Google Trends API est peu fiable, on utilise une liste de sujets pertinents
   */
  static async getTrendingTopics(geo: string = 'BF'): Promise<string[]> {
    try {
      console.log('[BlogArticleGenerator] Récupération des sujets pertinents...');
      
      // Sujets pertinents pour la blanchisserie et le nettoyage
      // Basés sur les recherches courantes et les tendances du secteur
      const relevantTopics = [
        'Guide du nettoyage à sec professionnel',
        'Comment enlever les taches tenaces',
        'Entretien des vêtements de marque',
        'Nettoyage écologique et durable',
        'Conseils de blanchisserie pour vêtements délicats',
        'Préservation des couleurs lors du lavage',
        'Nettoyage des tissus spécialisés',
        'Élimination des odeurs des vêtements',
        'Repassage professionnel des chemises',
        'Entretien des vêtements de sport'
      ];

      console.log(`[BlogArticleGenerator] ${relevantTopics.length} sujets pertinents disponibles`);
      
      // Mélanger et sélectionner aléatoirement pour plus de variété
      const shuffled = [...relevantTopics].sort(() => Math.random() - 0.5);
      const selected = shuffled.slice(0, 5);

      console.log('[BlogArticleGenerator] Sujets sélectionnés:', selected);
      
      return selected;
    } catch (error) {
      console.error('[BlogArticleGenerator] Error getting topics:', error);
      console.log('[BlogArticleGenerator] Utilisation de sujets par défaut en cas d\'erreur');
      return [
        'Guide du nettoyage à sec',
        'Comment enlever les taches',
        'Entretien des vêtements',
        'Nettoyage écologique',
        'Conseils de blanchisserie'
      ];
    }
  }

  /**
   * Générer un article avec IA (Gemini)
   */
  static async generateArticleWithAI(
    topic: string,
    keywords: string[],
    apiKey: string
  ): Promise<GeneratedArticle> {
    try {
      console.log(`📝 [BlogArticleGenerator] Génération d'article pour: ${topic}`);

      const prompt = `RESPOND ONLY WITH VALID JSON. NO OTHER TEXT.

You are an expert in laundry, dry cleaning and garment care.
Generate a professional, detailed and engaging blog article on the following topic:

Topic: ${topic}
Keywords to include: ${keywords.join(', ')}

The article MUST have:
1. A catchy SEO-optimized title
2. An engaging introduction (2-3 paragraphs)
3. MINIMUM 5-6 well-structured sections with subtitles
4. Each section must have 2-3 detailed paragraphs
5. Practical, detailed and useful advice
6. Concrete and specific examples
7. An FAQ section with 3-4 questions/answers
8. A conclusion with a CTA
9. Written in French
10. Approximately 2500-3500 words (VERY IMPORTANT)
11. Formatted in HTML with appropriate tags (h2, h3, p, ul, li)
12. Include bullet lists for tips

Respond ONLY with this exact JSON format (no markdown, no code blocks, just raw JSON):
{
  "title": "Article title here",
  "excerpt": "Summary of maximum 160 characters",
  "content": "<h2>Section 1</h2><p>Detailed content...</p><h3>Subsection</h3><p>More details...</p>",
  "reading_time": 12
}

CRITICAL: 
- Return ONLY valid JSON
- No markdown code blocks
- No explanations
- No additional text
- Content must be VERY detailed with minimum 2500 words
- Each paragraph must have 3-4 complete sentences`;

      const response = await axios.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
        {
          contents: [{
            parts: [{
              text: prompt
            }]
          }],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 8192,
          }
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey
          },
          timeout: 90000
        }
      );

      const generatedText = response.data.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!generatedText) {
        throw new Error('No content generated from AI');
      }

      console.log('[BlogArticleGenerator] Raw AI response length:', generatedText.length);

      // Parser la réponse JSON avec JSONParser robuste
      const articleData = JSONParser.parseJSON(generatedText);

      // Valider les champs requis
      if (!JSONParser.validate(articleData, ['title', 'excerpt', 'content'])) {
        throw new Error('Missing or invalid required fields in AI response');
      }

      // Générer le slug
      const slug = this.generateSlug(articleData.title);

      // Tronquer les champs pour respecter les limites de la BD
      const title = articleData.title.substring(0, 255);
      const excerpt = articleData.excerpt.substring(0, 500);
      const seoDescription = articleData.excerpt.substring(0, 160);

      return {
        title: title,
        slug: slug,
        content: articleData.content,
        excerpt: excerpt,
        seo_keywords: keywords,
        seo_description: seoDescription,
        reading_time: articleData.reading_time || 8
      };
    } catch (error) {
      console.error('[BlogArticleGenerator] Error generating article:', error);
      throw error;
    }
  }

  /**
   * Créer un article généré
   */
  static async createGeneratedArticle(
    article: GeneratedArticle,
    categoryId: string,
    authorId: string
  ) {
    try {
      console.log(`💾 [BlogArticleGenerator] Création de l'article: ${article.title}`);

      // Vérifier si l'article existe déjà
      const existing = await prisma.blog_articles.findUnique({
        where: { slug: article.slug }
      });

      if (existing) {
        console.log(`⚠️ [BlogArticleGenerator] Article déjà existant: ${article.slug}`);
        return existing;
      }

      const newArticle = await prisma.blog_articles.create({
        data: {
          id: uuidv4(),
          title: article.title,
          slug: article.slug,
          content: article.content,
          excerpt: article.excerpt,
          category_id: categoryId,
          author_id: authorId,
          seo_keywords: article.seo_keywords,
          seo_description: article.seo_description,
          reading_time: article.reading_time,
          is_published: false,
          published_at: null
        },
        include: {
          category: true,
          author: true
        }
      });

      console.log(`✅ [BlogArticleGenerator] Article créé: ${newArticle.id}`);
      return newArticle;
    } catch (error) {
      console.error('[BlogArticleGenerator] Error creating article:', error);
      throw error;
    }
  }

  /**
   * Générer plusieurs articles basés sur les tendances
   */
  static async generateArticlesFromTrends(
    count: number = 3,
    apiKey: string
  ) {
    try {
      console.log(`🚀 [BlogArticleGenerator] Génération de ${count} articles...`);

      // Récupérer les tendances
      const trends = await this.getTrendingTopics();
      if (trends.length === 0) {
        console.log('���️ [BlogArticleGenerator] Aucune tendance trouvée');
        return [];
      }

      // Récupérer la catégorie par défaut
      const category = await prisma.blog_categories.findFirst({
        where: { name: 'Conseils & Astuces' }
      });

      if (!category) {
        throw new Error('Default category not found');
      }

      // Récupérer l'auteur par défaut (admin)
      const author = await prisma.users.findFirst({
        where: { role: 'ADMIN' }
      });

      if (!author) {
        throw new Error('Default author not found');
      }

      const generatedArticles = [];

      for (let i = 0; i < Math.min(count, trends.length); i++) {
        try {
          const topic = trends[i];
          const keywords = this.extractKeywords(topic);

          // Générer l'article
          const article = await this.generateArticleWithAI(topic, keywords, apiKey);

          // Créer l'article en base de données
          const createdArticle = await this.createGeneratedArticle(
            article,
            category.id,
            author.id
          );

          generatedArticles.push(createdArticle);

          // Délai pour éviter les limites de taux
          await new Promise(resolve => setTimeout(resolve, 2000));
        } catch (error) {
          console.error(`❌ [BlogArticleGenerator] Erreur pour l'article ${i + 1}:`, error);
          continue;
        }
      }

      console.log(`✅ [BlogArticleGenerator] ${generatedArticles.length} articles générés`);
      return generatedArticles;
    } catch (error) {
      console.error('[BlogArticleGenerator] Error generating articles:', error);
      throw error;
    }
  }

  /**
   * Publier un article brouillon
   */
  static async publishArticle(articleId: string) {
    try {
      console.log(`📤 [BlogArticleGenerator] Publication de l'article: ${articleId}`);

      const article = await prisma.blog_articles.update({
        where: { id: articleId },
        data: {
          is_published: true,
          published_at: new Date()
        },
        include: {
          category: true,
          author: true
        }
      });

      console.log(`✅ [BlogArticleGenerator] Article publié: ${article.title}`);
      return article;
    } catch (error) {
      console.error('[BlogArticleGenerator] Error publishing article:', error);
      throw error;
    }
  }

  /**
   * Générer un slug à partir du titre
   */
  private static generateSlug(title: string): string {
    return title
      .toLowerCase()
      .trim()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .substring(0, 100);
  }

  /**
   * Extraire les mots-clés d'un sujet
   */
  private static extractKeywords(topic: string): string[] {
    const baseKeywords = [
      'nettoyage',
      'blanchisserie',
      'pressing',
      'vêtements',
      'textile',
      'professionnel',
      'astuces',
      'conseils',
      'entretien'
    ];

    const topicWords = topic.toLowerCase().split(' ');
    const keywords = [
      topic,
      ...topicWords.filter(word => word.length > 3),
      ...baseKeywords.slice(0, 3)
    ];

    return [...new Set(keywords)].slice(0, 10);
  }

  /**
   * Obtenir les articles en attente de publication
   */
  static async getPendingArticles() {
    try {
      const articles = await prisma.blog_articles.findMany({
        where: { is_published: false },
        orderBy: { created_at: 'desc' },
        include: {
          category: true,
          author: true
        }
      });

      return articles;
    } catch (error) {
      console.error('[BlogArticleGenerator] Error getting pending articles:', error);
      throw error;
    }
  }

  /**
   * Obtenir les statistiques de génération
   */
  static async getGenerationStats() {
    try {
      const [total, published, pending] = await Promise.all([
        prisma.blog_articles.count(),
        prisma.blog_articles.count({ where: { is_published: true } }),
        prisma.blog_articles.count({ where: { is_published: false } })
      ]);

      return {
        total,
        published,
        pending,
        generationRate: published > 0 ? ((published / total) * 100).toFixed(2) : 0
      };
    } catch (error) {
      console.error('[BlogArticleGenerator] Error getting stats:', error);
      throw error;
    }
  }

  /**
   * Insérer les 4 articles pilotes
   */
  static async seedPilotArticles() {
    try {
      console.log('🌱 [BlogArticleGenerator] Insertion des articles pilotes...');

      const pilotArticles = [
        {
          title: 'Guide Complet du Nettoyage à Sec : Tout ce que vous devez savoir',
          slug: 'guide-nettoyage-sec-complet',
          excerpt: 'Découvrez comment fonctionne le nettoyage à sec, ses avantages et comment bien entretenir vos vêtements délicats avec nos experts.',
          seo_description: 'Guide complet du nettoyage à sec professionnel. Apprenez les techniques, avantages et comment préserver vos vêtements.',
          seo_keywords: ['nettoyage à sec', 'pressing', 'guide complet', 'vêtements délicats', 'professionnel'],
          reading_time: 8,
          content: '<h2>Introduction</h2><p>Le nettoyage à sec est une technique de nettoyage sophistiquée qui utilise des solvants chimiques au lieu de l\'eau pour nettoyer les vêtements. Contrairement au lavage traditionnel, le nettoyage à sec est particulièrement adapté aux tissus délicats, aux vêtements de marque et aux pièces qui ne peuvent pas supporter l\'eau.</p><h2>Comment fonctionne le nettoyage à sec ?</h2><p>Le processus de nettoyage à sec se déroule en plusieurs étapes : inspection, pré-traitement, nettoyage, extraction, séchage et finition.</p>'
        },
        {
          title: 'Comment Enlever les Taches : Guide Expert du Détachement',
          slug: 'guide-enlever-taches-expert',
          excerpt: 'Guide complet pour enlever tous types de taches : vin, café, graisse, sang, chocolat. Techniques professionnelles et astuces pratiques.',
          seo_description: 'Guide expert pour enlever les taches. Découvrez les techniques professionnelles pour éliminer le vin, le café, la graisse et plus.',
          seo_keywords: ['enlever taches', 'détachement', 'nettoyage', 'astuces', 'taches difficiles'],
          reading_time: 7,
          content: '<h2>Introduction</h2><p>Les taches sont l\'une des plus grandes préoccupations des propriétaires de vêtements. Qu\'il s\'agisse d\'une tache de vin rouge, de café ou de graisse, savoir comment réagir rapidement peut faire la différence entre un vêtement sauvé et un vêtement ruiné.</p>'
        },
        {
          title: 'Entretien des Vêtements de Marque : Préserver la Qualité et la Valeur',
          slug: 'entretien-vetements-marque',
          excerpt: 'Comment entretenir vos vêtements de marque pour préserver leur qualité et leur durée de vie. Conseils d\'experts en textile.',
          seo_description: 'Guide complet pour entretenir les vêtements de marque. Préservez la qualité et la valeur de vos pièces de luxe.',
          seo_keywords: ['vêtements de marque', 'entretien', 'luxe', 'préserver', 'qualité'],
          reading_time: 6,
          content: '<h2>Introduction</h2><p>Les vêtements de marque représentent un investissement important. Pour protéger cet investissement et prolonger la durée de vie de vos pièces de luxe, un entretien approprié est essentiel.</p>'
        },
        {
          title: 'Nettoyage Écologique : Pourquoi c\'est Important pour Vous et la Planète',
          slug: 'nettoyage-ecologique-important',
          excerpt: 'Découvrez pourquoi le nettoyage écologique est important pour votre santé et l\'environnement. Les avantages du nettoyage durable.',
          seo_description: 'Nettoyage écologique : avantages pour la santé et l\'environnement. Découvrez le nettoyage durable et responsable.',
          seo_keywords: ['nettoyage écologique', 'durable', 'environnement', 'responsable', 'santé'],
          reading_time: 5,
          content: '<h2>Introduction</h2><p>Le nettoyage écologique n\'est pas seulement une tendance, c\'est une nécessité. Avec la prise de conscience croissante des enjeux environnementaux, de plus en plus de personnes cherchent des alternatives durables.</p>'
        }
      ];

      // Récupérer la catégorie par défaut
      let category = await prisma.blog_categories.findFirst({
        where: { name: 'Conseils & Astuces' }
      });

      if (!category) {
        category = await prisma.blog_categories.create({
          data: {
            name: 'Conseils & Astuces',
            description: 'Conseils pratiques et astuces pour prendre soin de vos vêtements'
          }
        });
      }

      // Récupérer l'auteur par défaut (admin)
      const author = await prisma.users.findFirst({
        where: { role: 'ADMIN' }
      });

      if (!author) {
        throw new Error('No admin user found');
      }

      const createdArticles = [];

      for (const article of pilotArticles) {
        const existing = await prisma.blog_articles.findUnique({
          where: { slug: article.slug }
        });

        if (existing) {
          console.log(`ℹ️ [BlogArticleGenerator] Article déjà existant: ${article.slug}`);
          createdArticles.push(existing);
          continue;
        }

        const created = await prisma.blog_articles.create({
          data: {
            title: article.title,
            slug: article.slug,
            content: article.content,
            excerpt: article.excerpt,
            category_id: category.id,
            author_id: author.id,
            seo_keywords: article.seo_keywords,
            seo_description: article.seo_description,
            reading_time: article.reading_time,
            is_published: true,
            published_at: new Date()
          },
          include: {
            category: true,
            author: true
          }
        });

        console.log(`✅ [BlogArticleGenerator] Article créé: ${article.title}`);
        createdArticles.push(created);
      }

      console.log(`✅ [BlogArticleGenerator] ${createdArticles.length} articles pilotes insérés`);
      return createdArticles;
    } catch (error) {
      console.error('[BlogArticleGenerator] Error seeding pilot articles:', error);
      throw error;
    }
  }
}
