/**
 * 📝 Blog Article Generator Routes - Routes pour la génération d'articles
 */

import express from 'express';
import { BlogArticleGeneratorController } from '../controllers/blogArticleGenerator.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Routes publiques (lecture seule)
router.get(
  '/trends',
  asyncHandler((req, res) => BlogArticleGeneratorController.getTrends(req, res))
);

router.get(
  '/stats',
  asyncHandler((req, res) => BlogArticleGeneratorController.getStats(req, res))
);

// Routes admin
router.use(authenticateToken as express.RequestHandler);
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler);

// Route pour insérer les articles pilotes (admin uniquement)
router.post(
  '/seed',
  asyncHandler((req, res) => BlogArticleGeneratorController.seedPilotArticles(req, res))
);

// Générer des articles
router.post(
  '/generate',
  asyncHandler((req, res) => BlogArticleGeneratorController.generateFromTrends(req, res))
);

// Récupérer les articles en attente
router.get(
  '/pending',
  asyncHandler((req, res) => BlogArticleGeneratorController.getPendingArticles(req, res))
);

// Publier un article
router.post(
  '/:articleId/publish',
  asyncHandler((req, res) => BlogArticleGeneratorController.publishArticle(req, res))
);

// Mettre à jour le statut de publication d'un article
router.put(
  '/:articleId/status',
  asyncHandler((req, res) => BlogArticleGeneratorController.updatePublicationStatus(req, res))
);

export default router;
