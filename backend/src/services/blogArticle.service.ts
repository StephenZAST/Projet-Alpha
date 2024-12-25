import supabase from '../config/database';
import { BlogArticle } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import axios from 'axios';
import googleTrends from 'google-trends-api';

export class BlogArticleService {
  static async createArticle(title: string, content: string, categoryId: string, authorId: string): Promise<BlogArticle> {
    const newArticle: BlogArticle = {
      id: uuidv4(),
      title,
      content,
      categoryId,
      createdAt: new Date(),
      updatedAt: new Date(),
      authorId
    };

    const { data, error } = await supabase
      .from('blog_articles')
      .insert([newArticle])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getAllArticles(): Promise<BlogArticle[]> {
    const { data, error } = await supabase
      .from('blog_articles')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async updateArticle(articleId: string, title: string, content: string, categoryId: string): Promise<BlogArticle> {
    const { data, error } = await supabase
      .from('blog_articles')
      .update({ title, content, categoryId, updatedAt: new Date() })
      .eq('id', articleId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async deleteArticle(articleId: string): Promise<void> {
    const { error } = await supabase
      .from('blog_articles')
      .delete()
      .eq('id', articleId);

    if (error) throw error;
  }

  static async generateArticle(title: string, context: string, prompts: string[], apiKey: string): Promise<string> {
    const response = await axios.post(
      'https://api.google.com/ai/generate',
      {
        title,
        context,
        prompts
      },
      {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (response.status !== 200) {
      throw new Error('Failed to generate article');
    }

    return response.data.content;
  }

  static async getTrendingTopics(): Promise<string[]> {
    const trends = await googleTrends.dailyTrends({
      geo: 'US', // Change to your target region
    });

    const parsedTrends = JSON.parse(trends);
    const trendingTopics = parsedTrends.default.trendingSearchesDays[0].trendingSearches.map((search: any) => search.title.query);

    return trendingTopics;
  }
}
