import { Request, Response, NextFunction } from 'express';
import { BlogArticle, BlogArticleStatus, CreateBlogArticleInput, UpdateBlogArticleInput } from '../models/blogArticle';
import { db } from '../config/firebase';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole } from '../models/user';

export class BlogArticleController {
    // Créer un nouvel article
    async createArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const articleData: CreateBlogArticleInput = req.body;
            const user = req.user;

            // Vérifier si l'utilisateur est autorisé (pas un livreur)
            if (user.role === UserRole.LIVREUR) {
                throw new AppError(403, "Les livreurs ne peuvent pas créer d'articles de blog", errorCodes.FORBIDDEN);
            }

            const slug = this.generateSlug(articleData.title);
            
            const newArticle: BlogArticle = {
                id: '', // Sera défini par Firebase
                title: articleData.title,
                slug,
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
                likes: 0,
                createdAt: new Date(),
                updatedAt: new Date()
            };

            const docRef = await db.collection('blog_articles').add(newArticle);
            newArticle.id = docRef.id;

            res.status(201).json({
                success: true,
                data: newArticle
            });
        } catch (error) {
            next(error);
        }
    }

    // Mettre à jour un article
    async updateArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const updateData: UpdateBlogArticleInput = req.body;
            const user = req.user;

            const articleRef = db.collection('blog_articles').doc(id);
            const article = await articleRef.get();

            if (!article.exists) {
                throw new AppError(404, "Article non trouvé", errorCodes.NOT_FOUND);
            }

            const articleData = article.data() as BlogArticle;

            // Vérifier les permissions
            if (articleData.authorId !== user.id && user.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, "Non autorisé à modifier cet article", errorCodes.FORBIDDEN);
            }

            const updatedArticle = {
                ...updateData,
                slug: updateData.title ? this.generateSlug(updateData.title) : articleData.slug,
                updatedAt: new Date()
            };

            await articleRef.update(updatedArticle);

            res.json({
                success: true,
                data: { ...articleData, ...updatedArticle }
            });
        } catch (error) {
            next(error);
        }
    }

    // Supprimer un article
    async deleteArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const user = req.user;

            const articleRef = db.collection('blog_articles').doc(id);
            const article = await articleRef.get();

            if (!article.exists) {
                throw new AppError(404, "Article non trouvé", errorCodes.NOT_FOUND);
            }

            const articleData = article.data() as BlogArticle;

            // Vérifier les permissions
            if (articleData.authorId !== user.id && user.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, "Non autorisé à supprimer cet article", errorCodes.FORBIDDEN);
            }

            await articleRef.delete();

            res.json({
                success: true,
                message: "Article supprimé avec succès"
            });
        } catch (error) {
            next(error);
        }
    }

    // Obtenir tous les articles (avec pagination et filtres)
    async getArticles(req: Request, res: Response, next: NextFunction) {
        try {
            const {
                page = 1,
                limit = 10,
                status = BlogArticleStatus.PUBLISHED,
                category,
                authorId
            } = req.query;

            let query = db.collection('blog_articles')
                .where('status', '==', status);

            if (category) {
                query = query.where('category', '==', category);
            }

            if (authorId) {
                query = query.where('authorId', '==', authorId);
            }

            const startAt = (Number(page) - 1) * Number(limit);
            const snapshot = await query
                .orderBy('createdAt', 'desc')
                .offset(startAt)
                .limit(Number(limit))
                .get();

            const articles = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));

            res.json({
                success: true,
                data: articles,
                pagination: {
                    page: Number(page),
                    limit: Number(limit),
                    total: snapshot.size
                }
            });
        } catch (error) {
            next(error);
        }
    }

    // Obtenir un article par son ID ou son slug
    async getArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const { identifier } = req.params; // peut être un ID ou un slug
            let article;

            // Chercher par ID
            const articleRef = db.collection('blog_articles').doc(identifier);
            article = await articleRef.get();

            // Si non trouvé, chercher par slug
            if (!article.exists) {
                const snapshot = await db.collection('blog_articles')
                    .where('slug', '==', identifier)
                    .limit(1)
                    .get();

                if (!snapshot.empty) {
                    article = snapshot.docs[0];
                }
            }

            if (!article?.exists) {
                throw new AppError(404, "Article non trouvé", errorCodes.NOT_FOUND);
            }

            // Incrémenter le nombre de vues
            await articleRef.update({
                views: (article.data()?.views || 0) + 1
            });

            res.json({
                success: true,
                data: {
                    id: article.id,
                    ...article.data()
                }
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
