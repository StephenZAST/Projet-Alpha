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
exports.initializeCronJobs = void 0;
const client_1 = require("@prisma/client");
const node_cron_1 = __importDefault(require("node-cron"));
const blogArticle_service_1 = require("./services/blogArticle.service");
const affiliateCommission_service_1 = require("./services/affiliate.service/affiliateCommission.service");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const prisma = new client_1.PrismaClient();
const apiKey = process.env.GOOGLE_AI_API_KEY;
// Planifier une tâche cron pour générer un article de blog tous les jours à 2h du matin
node_cron_1.default.schedule('0 2 * * *', () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        if (!apiKey) {
            console.warn('API key not configured for blog generation');
            return;
        }
        // Récupérer la catégorie par défaut
        const defaultCategory = yield blogArticle_service_1.BlogArticleService.getDefaultCategory();
        if (!defaultCategory) {
            console.error('Default blog category not found');
            return;
        }
        // Récupérer un admin pour l'auteur (à adapter selon votre logique)
        const adminUser = yield prisma.users.findFirst({
            where: {
                role: 'ADMIN'
            },
            select: {
                id: true
            }
        });
        if (!adminUser) {
            console.error('Admin user not found for blog article creation');
            return;
        }
        const trendingTopics = yield blogArticle_service_1.BlogArticleService.getTrendingTopics();
        const randomTopic = trendingTopics[Math.floor(Math.random() * trendingTopics.length)];
        const title = `Les avantages du nettoyage à sec : ${randomTopic}`;
        const context = `Expliquez les avantages du nettoyage à sec pour les vêtements délicats et comment Alpha Laundry offre ce service en relation avec ${randomTopic}.`;
        const prompts = [
            `Quels sont les avantages du nettoyage à sec par rapport au lavage traditionnel en relation avec ${randomTopic} ?`,
            `Comment Alpha Laundry garantit-elle la qualité de ses services de nettoyage à sec en relation avec ${randomTopic} ?`,
            `Quels types de vêtements sont les plus adaptés au nettoyage à sec en relation avec ${randomTopic} ?`
        ];
        const content = yield blogArticle_service_1.BlogArticleService.generateArticle(title, context, prompts, apiKey);
        yield blogArticle_service_1.BlogArticleService.createArticle(title, content, defaultCategory.id, adminUser.id);
        console.log('Article de blog généré automatiquement avec succès');
    }
    catch (error) {
        console.error('Erreur lors de la génération automatique de l\'article de blog:', error);
    }
}));
// Réinitialisation mensuelle des gains d'affiliés (1er jour du mois à 00:00)
node_cron_1.default.schedule('0 0 1 * *', () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Démarrage de la réinitialisation mensuelle des gains d\'affiliés...');
        yield affiliateCommission_service_1.AffiliateCommissionService.resetMonthlyEarnings();
        console.log('Réinitialisation mensuelle des gains d\'affiliés terminée avec succès');
    }
    catch (error) {
        console.error('Erreur lors de la réinitialisation mensuelle des gains d\'affiliés:', error);
    }
}));
const initializeCronJobs = () => {
    // Ne pas démarrer les tâches cron en mode test
    if (process.env.NODE_ENV === 'test') {
        return;
    }
    // Démarrer les tâches cron ici si nécessaire
};
exports.initializeCronJobs = initializeCronJobs;
