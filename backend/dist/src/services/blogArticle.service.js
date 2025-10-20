"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BlogArticleService = void 0;
const client_1 = require("@prisma/client");
const axios_1 = __importDefault(require("axios"));
const uuid_1 = require("uuid");
const google_trends_api_1 = __importDefault(require("google-trends-api"));
const prisma = new client_1.PrismaClient();
class BlogArticleService {
    static createArticle(title, content, categoryId, authorId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const article = yield prisma.blog_articles.create({
                    data: {
                        id: (0, uuid_1.v4)(),
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
            }
            catch (error) {
                console.error('[BlogArticleService] Create article error:', error);
                throw error;
            }
        });
    }
    static getAllArticles() {
        return __awaiter(this, arguments, void 0, function* (includeUnpublished = false) {
            try {
                const articles = yield prisma.blog_articles.findMany({
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
            }
            catch (error) {
                console.error('[BlogArticleService] Get all articles error:', error);
                throw error;
            }
        });
    }
    static updateArticle(articleId, title, content, categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const article = yield prisma.blog_articles.update({
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
            }
            catch (error) {
                console.error('[BlogArticleService] Update article error:', error);
                throw error;
            }
        });
    }
    static deleteArticle(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.blog_articles.delete({
                    where: { id: articleId }
                });
            }
            catch (error) {
                console.error('[BlogArticleService] Delete article error:', error);
                throw error;
            }
        });
    }
    static getDefaultCategory() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const category = yield prisma.blog_categories.findFirst({
                    where: {
                        name: 'Nettoyage à Sec'
                    }
                });
                if (!category) {
                    return yield prisma.blog_categories.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            name: 'Nettoyage à Sec',
                            description: 'Catégorie par défaut'
                        }
                    });
                }
                return category;
            }
            catch (error) {
                console.error('[BlogArticleService] Get default category error:', error);
                throw error;
            }
        });
    }
    static generateArticle(title, context, prompts, apiKey) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c, _d, _e, _f;
            try {
                const response = yield axios_1.default.post('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateText', {
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
                }, {
                    headers: {
                        'Content-Type': 'application/json',
                        'x-goog-api-key': apiKey
                    }
                });
                if (!((_e = (_d = (_c = (_b = (_a = response.data.candidates) === null || _a === void 0 ? void 0 : _a[0]) === null || _b === void 0 ? void 0 : _b.content) === null || _c === void 0 ? void 0 : _c.parts) === null || _d === void 0 ? void 0 : _d[0]) === null || _e === void 0 ? void 0 : _e.text)) {
                    throw new Error('No content generated from AI');
                }
                return response.data.candidates[0].content.parts[0].text;
            }
            catch (error) {
                if (axios_1.default.isAxiosError(error)) {
                    console.error('Error generating article:', ((_f = error.response) === null || _f === void 0 ? void 0 : _f.data) || error.message);
                }
                else {
                    console.error('Error generating article:', error);
                }
                throw new Error('Failed to generate article');
            }
        });
    }
    static getTrendingTopics() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const trends = yield google_trends_api_1.default.dailyTrends({
                    geo: 'US'
                });
                const parsedTrends = JSON.parse(trends);
                return parsedTrends.default.trendingSearchesDays[0].trendingSearches.map((search) => search.title.query);
            }
            catch (error) {
                console.error('[BlogArticleService] Get trending topics error:', error);
                throw error;
            }
        });
    }
}
exports.BlogArticleService = BlogArticleService;
