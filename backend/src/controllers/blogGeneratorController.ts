import { Request, Response, NextFunction } from 'express';
import { GoogleAIService } from '../services/googleAI';
import { BlogArticle, BlogArticleStatus, BlogArticleCategory } from '../models/blogArticle';
import { db } from '../config/firebase';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole } from '../models/user';

export class BlogGeneratorController {
    async updateGoogleAIKey(req: Request, res: Response, next: NextFunction) {
        try {
            const { googleAIKey } = req.body;
            const adminId = req.user.id;

            // Vérifier si l'utilisateur est un admin
            if (req.user.role === UserRole.LIVREUR) {
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
            await db.collection('admins').doc(adminId).update({
                googleAIKey: googleAIKey,
                updatedAt: new Date()
            });

            res.json({
                success: true,
                message: "Clé API Google AI mise à jour avec succès"
            });
        } catch (error) {
            if (error.message.includes('API key')) {
                next(new AppError(400, "Clé API Google AI invalide", errorCodes.INVALID_API_KEY));
            } else {
                next(error);
            }
        }
    }

    async generateBlogArticle(req: Request, res: Response, next: NextFunction) {
        try {
            const adminId = req.user.id;
            const config = req.body;

            // Récupérer l'admin et sa clé API
            const adminDoc = await db.collection('admins').doc(adminId).get();
            const admin = adminDoc.data();

            if (!admin?.googleAIKey) {
                throw new AppError(400, "Clé API Google AI non configurée", errorCodes.MISSING_API_KEY);
            }

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
                authorName: `${req.user.firstName} ${req.user.lastName}`,
                authorRole: req.user.role,
                category: this.determineCategory(generatedContent.tags),
                tags: generatedContent.tags,
                status: BlogArticleStatus.DRAFT,
                seoTitle: generatedContent.seoTitle,
                seoDescription: generatedContent.seoDescription,
                seoKeywords: generatedContent.seoKeywords,
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
