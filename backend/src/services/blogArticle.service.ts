import { PrismaClient } from '@prisma/client';
import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';
import type { TrendsApiOptions, TrendsResult } from '../types';
import googleTrends from 'google-trends-api';

const prisma = new PrismaClient();

export class BlogArticleService {
  static async createArticle(title: string, content: string, categoryId: string, authorId: string) {
    try {
      const article = await prisma.blog_articles.create({
        data: {
          id: uuidv4(),
          author_id: authorId,
          published_at: new Date()
        },
        include: {
          users: {
            select: {
              id: true,
              first_name: true,
              last_name: true
            }
          }
        }
      });

      return article;
    } catch (error) {
      console.error('[BlogArticleService] Create article error:', error);
      throw error;
    }
  }

  static async getAllArticles(includeUnpublished = false) {
    try {
      const articles = await prisma.blog_articles.findMany({
        where: includeUnpublished ? undefined : {
          published_at: { not: null }
        },
        orderBy: {
          published_at: 'desc'
        },
        include: {
          users: {
            select: {
              id: true,
              first_name: true,
              last_name: true
            }
          }
        }
      });

      return articles;
    } catch (error) {
      console.error('[BlogArticleService] Get all articles error:', error);
      throw error;
    }
  }

  static async updateArticle(articleId: string, title: string, content: string, categoryId: string) {
    try {
      const article = await prisma.blog_articles.update({
        where: { id: articleId },
        data: {
          published_at: new Date()
        },
        include: {
          users: {
            select: {
              id: true,
              first_name: true,
              last_name: true
            }
          }
        }
      });

      return article;
    } catch (error) {
      console.error('[BlogArticleService] Update article error:', error);
      throw error;
    }
  }

  static async deleteArticle(articleId: string) {
    try {
      await prisma.blog_articles.delete({
        where: { id: articleId }
      });
    } catch (error) {
      console.error('[BlogArticleService] Delete article error:', error);
      throw error;
    }
  }

  static async getDefaultCategory() {
    try {
      const category = await prisma.blog_categories.findFirst({
        where: {
          name: 'Nettoyage à Sec'
        }
      });

      if (!category) {
        return await prisma.blog_categories.create({
          data: {
            id: uuidv4(),
            name: 'Nettoyage à Sec',
            description: 'Catégorie par défaut'
          }
        });
      }

      return category;
    } catch (error) {
      console.error('[BlogArticleService] Get default category error:', error);
      throw error;
    }
  }

  static async generateArticle(title: string, context: string, prompts: string[], apiKey: string): Promise<string> {
    try {
      const response = await axios.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateText',
        {
          contents: [{
            parts: [{
              text: `
                Titre: ${title}
                Contexte: ${context}
                Questions à aborder:
                ${prompts.join('\n')}
                
                Générez un article de blog professionnel et engageant qui répond à toutes ces questions.
                L'article doit être structuré avec une introduction, des sections bien définies, et une conclusion.
              `
            }]
          }],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          },
          safetySettings: [
            {
              category: "HARM_CATEGORY_HARASSMENT",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              category: "HARM_CATEGORY_HATE_SPEECH",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              category: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              category: "HARM_CATEGORY_DANGEROUS_CONTENT",
              threshold: "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey
          }
        }
      );

      if (!response.data.candidates?.[0]?.content?.parts?.[0]?.text) {
        throw new Error('No content generated from AI');
      }

      return response.data.candidates[0].content.parts[0].text;
    } catch (error: any) {
      if (axios.isAxiosError(error)) {
        console.error('Error generating article:', error.response?.data || error.message);
      } else {
        console.error('Error generating article:', error);
      }
      throw new Error('Failed to generate article');
    }
  }

  static async getTrendingTopics(): Promise<string[]> {
    try {
      const trends = await googleTrends.dailyTrends({
        geo: 'US'
      });

      const parsedTrends = JSON.parse(trends);
      return parsedTrends.default.trendingSearchesDays[0].trendingSearches.map(
        (search: any) => search.title.query
      );
    } catch (error) {
      console.error('[BlogArticleService] Get trending topics error:', error);
      throw error;
    }
  }
}
