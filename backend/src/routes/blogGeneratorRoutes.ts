import express from 'express';
import { BlogGeneratorController } from '../controllers/blogGeneratorController';
import { isAuthenticated, hasRole } from '../middleware/auth';
import { validateBlogGenerationConfig } from '../middleware/blogGeneratorValidation';
import { UserRole } from '../models/user';

const router = express.Router();
const blogGeneratorController = new BlogGeneratorController();

// Routes protégées nécessitant une authentification
router.use(isAuthenticated);

// Routes pour les administrateurs (sauf livreurs)
router.use(hasRole([
    UserRole.SUPER_ADMIN,
    UserRole.SERVICE_CLIENT,
    UserRole.SECRETAIRE,
    UserRole.SUPERVISEUR
]));

// Configuration de la clé API Google AI
router.post('/api-key', blogGeneratorController.updateGoogleAIKey);

// Génération d'article de blog
router.post('/generate', validateBlogGenerationConfig, blogGeneratorController.generateBlogArticle);

export default router;
