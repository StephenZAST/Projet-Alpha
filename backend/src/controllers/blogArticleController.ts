import { Request, Response, NextFunction } from 'express';
import { BlogArticle, BlogArticleStatus, CreateBlogArticleInput, UpdateBlogArticleInput } from '../models/blogArticle';
import  supabase  from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole } from '../models/user';

export class BlogArticleController {
    async createArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const articleData: CreateBlogArticleInput = req.body;
            const user = req.user as { id: string; firstName: string; lastName: string; role: UserRole; };

            if (!user) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
            }

            const slug = this.generateSlug(articleData.title);

            const newArticle: Omit<BlogArticle, 'id' | 'createdAt' | 'updatedAt'> = {
                title: articleData.title,
                slug: this.generateSlug(articleData.title),
                content: articleData.content,
                excerpt: articleData.content.substring(0, 150) + '...',
                authorId: user.id,
                authorName: `${user.firstName} ${user.lastName}`,
                authorRole: user.role,
                category: articleData.category,
                tags: articleData.tags,
                status: BlogArticleStatus.DRAFT,
                featuredImage: articleData.featuredImage,
                seoTitle: articleData.seoTitle || articleData.title,
                seoDescription: articleData.seoDescription,
                seoKeywords: articleData.seoKeywords,
                views: 0,
                likes: 0
            };

            const { data, error } = await supabase
                .from('blog_articles')
                .insert([newArticle])
                .select();

            if (error) {
                throw new AppError(500, 'Failed to create article', errorCodes.DATABASE_ERROR);
            }

            res.status(201).json({
                success: true,
                data: data[0]
            });
        } catch (error) {
            next(error);
        }
    }

    async updateArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const updateData: UpdateBlogArticleInput = req.body;
            const user = req.user as { id: string; firstName: string; lastName: string; role: UserRole; };

            if (!user) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
            }

            const { data: existingArticle, error: fetchError } = await supabase
                .from('blog_articles')
                .select('*')
                .eq('id', id)
                .single();

            if (fetchError) {
                throw new AppError(500, 'Failed to fetch article', errorCodes.DATABASE_ERROR);
            }

            if (!existingArticle) {
                throw new AppError(404, "Article non trouvé", errorCodes.NOT_FOUND);
            }

            // Vérifier les permissions
            if (existingArticle.authorId !== user.id && user.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, "Non autorisé à modifier cet article", errorCodes.FORBIDDEN);
            }

            const updatedArticle = {
                ...existingArticle,
                ...updateData,
                slug: updateData.title ? this.generateSlug(updateData.title) : existingArticle.slug,
                updatedAt: new Date().toISOString()
            };

            const { error: updateError } = await supabase
                .from('blog_articles')
                .update(updatedArticle)
                .eq('id', id);

            if (updateError) {
                throw new AppError(500, 'Failed to update article', errorCodes.DATABASE_ERROR);
            }

            res.json({
                success: true,
                data: updatedArticle
            });
        } catch (error) {
            next(error);
        }
    }

    async deleteArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const user = req.user as { id: string; firstName: string; lastName: string; role: UserRole; };

            if (!user) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
            }

            const { data: existingArticle, error: fetchError } = await supabase
                .from('blog_articles')
                .select('*')
                .eq('id', id)
                .single();

            if (fetchError) {
                throw new AppError(500, 'Failed to fetch article', errorCodes.DATABASE_ERROR);
            }

            if (!existingArticle) {
                throw new AppError(404, "Article non trouvé", errorCodes.NOT_FOUND);
            }

            // Vérifier les permissions
            if (existingArticle.authorId !== user.id && user.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, "Non autorisé à supprimer cet article", errorCodes.FORBIDDEN);
            }

            const { error: deleteError } = await supabase
                .from('blog_articles')
                .delete()
                .eq('id', id);

            if (deleteError) {
                throw new AppError(500, 'Failed to delete article', errorCodes.DATABASE_ERROR);
            }

            res.json({
                success: true,
                message: "Article supprimé avec succès"
            });
        } catch (error) {
            next(error);
        }
    }

    async getArticles(req: Request, res: Response, next: NextFunction) {
        try {
            const {
                page = 1,
                limit = 10,
                status = BlogArticleStatus.PUBLISHED,
                category,
                authorId
            } = req.query;

            let query = supabase
                .from('blog_articles')
                .select('*', { count: 'exact' })
                .eq('status', status);

            if (category) {
                query = query.eq('category', category);
            }

            if (authorId) {
                query = query.eq('authorId', authorId);
            }

            const start = (Number(page) - 1) * Number(limit);
            const end = start + Number(limit) - 1;

            const { data, error, count } = await query
                .order('createdAt', { ascending: false })
                .range(start, end);

            if (error) {
                throw new AppError(500, 'Failed to fetch articles', errorCodes.DATABASE_ERROR);
            }

            res.json({
                success: true,
                data: data,
                pagination: {
                    page: Number(page),
                    limit: Number(limit),
                    total: count
                }
            });
        } catch (error) {
            next(error);
        }
    }

    async getArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const { identifier } = req.params; // peut être un ID ou un slug

            // Chercher par ID
            let { data: articleById, error: errorById } = await supabase
                .from('blog_articles')
                .select('*')
                .eq('id', identifier)
                .single();

            // Si non trouvé, chercher par slug
            if (errorById || !articleById) {
                let { data: articleBySlug, error: errorBySlug } = await supabase
                    .from('blog_articles')
                    .select('*')
                    .eq('slug', identifier)
                    .single();

                if (errorBySlug || !articleBySlug) {
                    throw new AppError(404, "Article non trouvé", errorCodes.NOT_FOUND);
                }

                articleById = articleBySlug;
            }

            // Incrémenter le nombre de vues
            const { error: updateError } = await supabase
                .from('blog_articles')
                .update({ views: articleById.views + 1 })
                .eq('id', articleById.id);

            if (updateError) {
                console.error('Failed to update view count:', updateError);
            }

            res.json({
                success: true,
                data: articleById
            });
        } catch (error) {
            next(error);
        }
    }

    // Méthode utilitaire pour générer un slug
    private generateSlug(title: string): string {
        return title
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)+/g, '');
    }
}
