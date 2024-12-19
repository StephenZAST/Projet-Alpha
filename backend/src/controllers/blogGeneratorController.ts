import { Request, Response, NextFunction } from 'express';
import { GoogleAIService } from '../services/googleAI';
import { BlogArticle, BlogArticleStatus, BlogArticleCategory } from '../models/blogArticle';
import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole, User } from '../models/user';

interface AuthenticatedRequest extends Request {
    user?: User;
}

export class BlogGeneratorController {
    async updateGoogleAIKey(req: AuthenticatedRequest, res: Response, next: NextFunction) {
        try {
            const { googleAIKey } = req.body;
            const user = req.user;

            if (!user) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
            }

            const adminId = user.id;

            // Vérifier si l'utilisateur est un admin
            if (user.role !== UserRole.ADMIN) {
                throw new AppError(403, "Non autorisé à configurer l'API Google AI", errorCodes.FORBIDDEN);
            }

            // Tester la clé API
            const aiService = new GoogleAIService(googleAIKey);
            await aiService.generateBlogArticle({
                topic: "Test de la clé API",
                tone: "professional",
                targetLength: "short",
                keywords: ["test"],
                targetAudience: "test",
                includeCallToAction: false
            });

            // Mettre à jour la clé API dans la base de données
            await supabase.from('admins').update({
                googleAIKey: googleAIKey,
                updatedAt: new Date().toISOString()
            }).eq('id', adminId);

            res.json({
                success: true,
                message: "Clé API Google AI mise à jour avec succès"
            });
        } catch (error: any) {
            if (error.message.includes('API key')) {
                next(new AppError(400, "Clé API Google AI invalide", 'INVALID_API_KEY'));
            } else {
                next(error);
            }
        }
    }

    async generateBlogArticle(req: AuthenticatedRequest, res: Response, next: NextFunction) {
        try {
            const user = req.user;

            if (!user) {
                throw new AppError(401, 'Unauthorized', errorCodes.UNAUTHORIZED);
            }

            const adminId = user.id;
            const config = req.body;

            // Récupérer l'admin et sa clé API
            const { data: adminData, error: adminError } = await supabase.from('admins').select('googleAIKey').eq('id', adminId).single();

            if (adminError || !adminData?.googleAIKey) {
                 throw new AppError(400, "Clé API Google AI non configurée", 'MISSING_API_KEY');
            }

            const admin = adminData;

            // Générer l'article avec Google AI
            const aiService = new GoogleAIService(admin.googleAIKey);
            const generatedContent = await aiService.generateBlogArticle(config);

            // Créer l'article dans la base de données
            const slug = this.generateSlug(generatedContent.title);
            
            const newArticle: BlogArticle = {
                id: '',
                title: generatedContent.title,
                slug,
                content: generatedContent.sections.map(section => 
                    `## ${section.title}\n\n${section.content}`
                ).join('\n\n'),
                excerpt: generatedContent.seoDescription,
                authorId: adminId,
                authorName: `${user.firstName} ${user.lastName}`,
                authorRole: user.role,
                category: this.determineCategory(generatedContent.tags),
                tags: generatedContent.tags,
                status: BlogArticleStatus.DRAFT,
                seoTitle: generatedContent.seoTitle,
                seoDescription: generatedContent.seoDescription,
                seoKeywords: generatedContent.seoKeywords,
                views: 0,
                likes: 0,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            const { data, error } = await supabase.from('blog_articles').insert([newArticle]).select().single();

            if (error) {
                throw new AppError(500, 'Failed to create blog article', 'INTERNAL_SERVER_ERROR');
            }

            newArticle.id = data.id;

            res.status(201).json({
                success: true,
                data: newArticle
            });
        } catch (error: any) {
            next(error);
        }
    }

    private generateSlug(title: string): string {
        return title
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)+/g, '');
    }

    private determineCategory(tags: string[]): BlogArticleCategory {
        // Logique pour déterminer la catégorie en fonction des tags
        const tagMap = {
            'nettoyage': BlogArticleCategory.LAUNDRY_TIPS,
            'taches': BlogArticleCategory.STAIN_REMOVAL,
            'tissu': BlogArticleCategory.FABRIC_CARE,
            'environnement': BlogArticleCategory.SUSTAINABILITY,
            'actualités': BlogArticleCategory.COMPANY_NEWS,
            'saison': BlogArticleCategory.SEASONAL_CARE,
            'services': BlogArticleCategory.PROFESSIONAL_SERVICES
        };

        for (const tag of tags) {
            for (const [key, value] of Object.entries(tagMap)) {
                if (tag.toLowerCase().includes(key)) {
                    return value;
                }
            }
        }

        return BlogArticleCategory.PROFESSIONAL_SERVICES;
    }
}
