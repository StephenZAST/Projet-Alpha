import supabase from '../config/database';
import axios from 'axios';
import googleTrends from 'google-trends-api';
import { v4 as uuidv4 } from 'uuid';

export class BlogArticleService {
  static async createArticle(title: string, content: string, categoryId: string, authorId: string) {
    const { data, error } = await supabase
      .from('blog_articles')
      .insert([{
        id: uuidv4(),
        title,
        content,
        category_id: categoryId,
        author_id: authorId,
        is_published: true,
        published_at: new Date().toISOString()
      }])
      .select('*, blog_categories(*), users!inner(id, first_name, last_name)')
      .single();

    if (error) throw error;
    return data;
  }

  static async getAllArticles(includeUnpublished = false) {
    const query = supabase
      .from('blog_articles')
      .select(`
        *,
        blog_categories(*),
        users!inner(id, first_name, last_name)
      `)
      .order('created_at', { ascending: false });

    if (!includeUnpublished) {
      query.eq('is_published', true);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  static async updateArticle(articleId: string, title: string, content: string, categoryId: string) {
    const { data, error } = await supabase
      .from('blog_articles')
      .update({
        title,
        content,
        category_id: categoryId,
        updated_at: new Date().toISOString()
      })
      .eq('id', articleId)
      .select('*, blog_categories(*), users!inner(id, first_name, last_name)')
      .single();

    if (error) throw error;
    return data;
  }

  static async deleteArticle(articleId: string) {
    const { error } = await supabase
      .from('blog_articles')
      .delete()
      .eq('id', articleId);

    if (error) throw error;
  }

  static async getDefaultCategory() {
    const { data, error } = await supabase
      .from('blog_categories')
      .select('*')
      .eq('name', 'Nettoyage à Sec')
      .single();

    if (error) throw error;
    return data;
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
    const trends = await googleTrends.dailyTrends({
      geo: 'US', // Change to your target region
    });

    const parsedTrends = JSON.parse(trends);
    const trendingTopics = parsedTrends.default.trendingSearchesDays[0].trendingSearches.map((search: any) => search.title.query);

    return trendingTopics;
  }
}
