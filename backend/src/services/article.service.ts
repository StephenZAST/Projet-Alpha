import supabase from '../config/database';
import { Article, ArticleServiceUpdate, CreateArticleDTO } from '../models/types';
import { v4 as uuidv4 } from 'uuid';

export class ArticleService {
  static async createArticle(articleData: CreateArticleDTO): Promise<Article> {
    const { categoryId, name, description, basePrice, premiumPrice } = articleData;

    const newArticle: Article = {
      id: uuidv4(),
      categoryId,
      name,
      description,
      basePrice,
      premiumPrice,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const { data, error } = await supabase
      .from('articles')
      .insert([newArticle])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getArticleById(articleId: string): Promise<Article> {
    const { data, error } = await supabase
      .from('articles')
      .select('*')
      .eq('id', articleId)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Article not found');

    return data;
  }

  static async getAllArticles(): Promise<Article[]> {
    try {
      const { data, error } = await supabase
        .from('articles')
        .select(`
          *,
          category:article_categories(*)
        `)
        .eq('isDeleted', false);  // Ne retourner que les articles actifs

      if (error) {
        console.error('Supabase error in getAllArticles:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Error in getAllArticles:', error);
      throw error;
    }
  }

  static async getArticles(): Promise<Article[]> {
    try {
      const { data, error } = await supabase
        .from('articles')
        .select(`
          *,
          category:article_categories(name)
        `);

      if (error) {
        console.error('Supabase error in getArticles:', error);
        throw error;
      }

      // Transform the data to include category as a string
      const articles = data?.map(article => ({
        ...article,
        category: article.category?.name || 'Uncategorized'
      })) || [];

      return articles;
    } catch (error) {
      console.error('Error in getArticles:', error);
      throw error;
    }
  }

  static async getArticlesForOrder(): Promise<Article[]> {
    try {
      const { data, error } = await supabase
        .from('articles')
        .select(`
          *,
          category:article_categories(name)
        `)
        .eq('isDeleted', false)
        .order('name');

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('[ArticleService] Error getting articles for order:', error);
      throw error;
    }
  }

  static async getArticleWithServices(articleId: string) {
    const { data, error } = await supabase
      .from('articles')
      .select(`
        *,
        article_service_prices (
          *,
          service_types (
            name,
            description,
            is_default
          )
        ),
        article_categories (
          name,
          description
        )
      `)
      .eq('id', articleId)
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  static async updateArticleServices(
    articleId: string, 
    serviceUpdates: ArticleServiceUpdate[]
  ) {
    const { data, error } = await supabase.rpc(
      'update_article_services',
      {
        p_article_id: articleId,
        p_service_updates: serviceUpdates
      }
    );

    if (error) throw new Error(error.message);
    return data;
  }

  static async updateArticle(articleId: string, updateData: Partial<Article>) {
    try {
      console.log('[ArticleService] Starting update for article:', articleId);

      const { data: existingArticle, error: findError } = await supabase
        .from('articles')
        .select('*')
        .eq('id', articleId)
        .single();

      if (findError || !existingArticle) {
        throw new Error('Article not found');
      }

      // Mise à jour avec les champs exacts de la BD
      const updatePayload = {
        name: updateData.name,
        description: updateData.description,
        basePrice: updateData.basePrice,
        premiumPrice: updateData.premiumPrice,
        categoryId: updateData.categoryId,
        // Ne pas inclure updatedAt car il est mis à jour automatiquement par Supabase
      };

      console.log('[ArticleService] Update payload:', updatePayload);

      const { data: updatedArticle, error: updateError } = await supabase
        .from('articles')
        .update(updatePayload)
        .eq('id', articleId)
        .select('*')
        .single();

      if (updateError) {
        console.error('[ArticleService] Update error:', updateError);
        throw updateError;
      }

      return updatedArticle;
    } catch (error) {
      console.error('[ArticleService] Error updating article:', error);
      throw error;
    }
  }

  static async deleteArticle(articleId: string): Promise<void> {
    try {
      console.log('[ArticleService] Attempting to delete article:', articleId);

      // Vérifier si l'article existe
      const { data: existingArticle, error: findError } = await supabase
        .from('articles')
        .select('*')
        .eq('id', articleId)
        .single();

      if (findError || !existingArticle) {
        throw new Error('Article not found');
      }

      // Marquer comme supprimé au lieu de supprimer physiquement
      const { error: updateError } = await supabase
        .from('articles')
        .update({
          isDeleted: true,
          deletedAt: new Date().toISOString()
        })
        .eq('id', articleId);

      if (updateError) throw updateError;

      console.log('[ArticleService] Article marked as deleted:', articleId);
    } catch (error) {
      console.error('[ArticleService] Error deleting article:', error);
      throw error;
    }
  }

  static async archiveArticle(articleId: string, reason: string): Promise<void> {
    try {
      console.log('[ArticleService] Attempting to archive article:', articleId);

      const { error } = await supabase.rpc('archive_article', {
        p_article_id: articleId,
        p_reason: reason
      });

      if (error) {
        console.error('[ArticleService] Archive error:', error);
        throw error;
      }

      console.log('[ArticleService] Article archived successfully:', articleId);
    } catch (error) {
      console.error('[ArticleService] Error archiving article:', error);
      throw error;
    }
  }
}
