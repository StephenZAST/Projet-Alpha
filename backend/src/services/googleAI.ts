import { GoogleGenerativeAI, GenerativeModel, GenerationConfig } from '@google/generative-ai';
import { AppError, errorCodes } from '../utils/errors';

interface BlogGenerationConfig {
    topic: string;
    tone: 'professional' | 'casual' | 'educational';
    targetLength: 'short' | 'medium' | 'long';
    keywords: string[];
    targetAudience: string;
    includeCallToAction: boolean;
}

interface GeneratedBlogContent {
    title: string;
    seoTitle: string;
    seoDescription: string;
    seoKeywords: string[];
    sections: {
        title: string;
        content: string;
    }[];
    tags: string[];
}

export class GoogleAIService {
    private genAI: GoogleGenerativeAI;
    private model: GenerativeModel;
    private readonly MODEL_NAME = 'Gemini-1.5-Flash';
    private readonly MAX_RETRIES = 3;
    private readonly RETRY_DELAY = 1000; // 1 second

    constructor(apiKey: string) {
        if (!apiKey) {
            throw new AppError(400, "Clé API Google AI manquante", errorCodes.INVALID_CREDENTIALS);
        }

        try {
            this.genAI = new GoogleGenerativeAI(apiKey);
            this.model = this.genAI.getGenerativeModel({ model: this.MODEL_NAME });
        } catch (error) {
            throw new AppError(
                500,
                "Erreur d'initialisation de Google AI",
                errorCodes.AI_INITIALIZATION_ERROR
            );
        }
    }

    private getGenerationConfig(length: 'short' | 'medium' | 'long'): GenerationConfig {
        const configs = {
            short: {
                maxOutputTokens: 1024,
                temperature: 0.7,
            },
            medium: {
                maxOutputTokens: 2048,
                temperature: 0.7,
            },
            long: {
                maxOutputTokens: 4096,
                temperature: 0.7,
            }
        };

        return configs[length];
    }

    private generatePrompt(config: BlogGenerationConfig): string {
        const lengthGuide = {
            short: '500-800 mots',
            medium: '800-1200 mots',
            long: '1200-2000 mots'
        };

        const toneGuide = {
            professional: 'formel et expert',
            casual: 'décontracté et accessible',
            educational: 'pédagogique et informatif'
        };

        return `En tant qu'expert en blanchisserie et pressing, rédigez un article de blog professionnel en français.

CONTEXTE :
- Sujet : ${config.topic}
- Ton : ${toneGuide[config.tone]}
- Longueur cible : ${lengthGuide[config.targetLength]}
- Public cible : ${config.targetAudience}
- Mots-clés à intégrer naturellement : ${config.keywords.join(', ')}

STRUCTURE REQUISE :
1. Un titre principal accrocheur (70 caractères max)
2. Un titre SEO optimisé (60 caractères max)
3. Une méta-description SEO (160 caractères max)
4. 3-5 sections principales avec sous-titres
5. Une conclusion ${config.includeCallToAction ? "avec appel à l'action" : 'synthétique'}
6. 5-8 mots-clés SEO
7. 3-5 tags pertinents

CONSIGNES SPÉCIFIQUES :
- Adoptez un ton ${toneGuide[config.tone]}
- Intégrez des exemples concrets liés à la blanchisserie
- Incluez des conseils pratiques
- Utilisez un vocabulaire précis du secteur
- Optimisez pour le référencement local

FORMAT DE SORTIE (JSON) :
{
    "title": "Titre principal",
    "seoTitle": "Titre SEO",
    "seoDescription": "Description SEO",
    "seoKeywords": ["mot-clé1", "mot-clé2", ...],
    "sections": [
        {
            "title": "Titre de section",
            "content": "Contenu détaillé"
        }
    ],
    "tags": ["tag1", "tag2", ...]
}

IMPORTANT : La réponse doit être un JSON valide et structuré exactement comme indiqué ci-dessus.`;
    }

    private async retry<T>(
        operation: () => Promise<T>,
        retries = this.MAX_RETRIES
    ): Promise<T> {
        try {
            return await operation();
        } catch (error) {
            if (retries > 0 && this.isRetryableError(error)) {
                await new Promise(resolve => setTimeout(resolve, this.RETRY_DELAY));
                return this.retry(operation, retries - 1);
            }
            throw error;
        }
    }

    private isRetryableError(error: any): boolean {
        const retryableErrors = [
            'RESOURCE_EXHAUSTED',
            'UNAVAILABLE',
            'DEADLINE_EXCEEDED',
            'INTERNAL'
        ];
        return retryableErrors.includes(error?.code);
    }

    private validateGeneratedContent(content: any): content is GeneratedBlogContent {
        const required = ['title', 'seoTitle', 'seoDescription', 'seoKeywords', 'sections', 'tags'];
        const isValid = required.every(field => {
            if (field === 'sections') {
                return Array.isArray(content[field]) && content[field].length > 0 &&
                    content[field].every((section: any) =>
                        section.title && typeof section.title === 'string' &&
                        section.content && typeof section.content === 'string'
                    );
            }
            if (field === 'seoKeywords' || field === 'tags') {
                return Array.isArray(content[field]) && content[field].length > 0;
            }
            return content[field] && typeof content[field] === 'string';
        });

        return isValid;
    }

    async generateBlogArticle(config: BlogGenerationConfig): Promise<GeneratedBlogContent> {
        try {
            const prompt = this.generatePrompt(config);
            const generationConfig = this.getGenerationConfig(config.targetLength);

            const result = await this.retry(async () => {
                const response = await this.model.generateContent({
                    contents: [{ role: 'user', parts: [{ text: prompt }] }],
                    generationConfig
                });

                if (!response.response.text()) {
                    throw new Error('Réponse vide de l\'API');
                }

                return response.response.text();
            });

            let generatedContent: GeneratedBlogContent;
            try {
                generatedContent = JSON.parse(result);
            } catch (error) {
                throw new AppError(
                    500,
                    "Erreur de parsing de la réponse de l'API",
                    errorCodes.AI_PARSING_ERROR
                );
            }

            if (this.validateGeneratedContent(generatedContent)) {
                return generatedContent;
            }

            throw new AppError(
                500,
                "Format de réponse invalide",
                errorCodes.AI_INVALID_RESPONSE
            );

        } catch (error) {
          if (error instanceof AppError) {
            throw error;
          } else if (error instanceof Error) {
            throw new AppError(
                500,
                "Erreur lors de la génération de l'article avec Google AI",
                errorCodes.AI_GENERATION_ERROR
            );
          } else {
            // Handle cases where 'error' is of an unknown type
            throw new AppError(
                500,
                "Erreur inconnue lors de la génération de l'article avec Google AI",
                errorCodes.AI_GENERATION_ERROR
            );
          }
        }
    }
}
