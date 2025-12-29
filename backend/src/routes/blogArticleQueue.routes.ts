/**
 * 📝 Blog Article Queue Routes - Routes pour la génération asynchrone
 */

import express from 'express';
import { BlogArticleQueueController } from '../controllers/blogArticleQueueController';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Routes publiques (lecture seule)
router.get(
  '/stats',
  asyncHandler((req, res) => BlogArticleQueueController.getQueueStats(req, res))
);

router.get(
  '/jobs/:jobId',
  asyncHandler((req, res) => BlogArticleQueueController.getJobStatus(req, res))
);

// Routes admin
router.use(authenticateToken as express.RequestHandler);
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler);

// Générer un seul article
router.post(
  '/generate',
  asyncHandler((req, res) => BlogArticleQueueController.generateArticle(req, res))
);

// Obtenir tous les jobs
router.get(
  '/jobs',
  asyncHandler((req, res) => BlogArticleQueueController.getAllJobs(req, res))
);

// Nettoyer les anciens jobs
router.post(
  '/cleanup',
  asyncHandler((req, res) => BlogArticleQueueController.cleanupOldJobs(req, res))
);

export default router;
