import express, { Request, Response, NextFunction } from 'express';
import { BlogArticleController } from '../controllers/blogArticle.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler'; 

const router = express.Router();

// Routes publiques (lecture seule - pas d'authentification requise)
router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => BlogArticleController.getAllArticles(req, res))
);

// Route pour récupérer un article par slug (public)
router.get(
  '/slug/:slug',
  asyncHandler(async (req: Request, res: Response) => BlogArticleController.getArticleBySlug(req, res))
);

// Routes admin (authentification requise)
router.use(authenticateToken as express.RequestHandler);
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler);

router.post(
  '/',
  asyncHandler(async (req: Request, res: Response) => BlogArticleController.createArticle(req, res))
);

router.put(
  '/:articleId',
  asyncHandler(async (req: Request, res: Response) => BlogArticleController.updateArticle(req, res))
);

router.delete(
  '/:articleId',
  asyncHandler(async (req: Request, res: Response) => BlogArticleController.deleteArticle(req, res))
);

router.post(
  '/generate',
  asyncHandler(async (req: Request, res: Response) => BlogArticleController.generateArticle(req, res))
);

export default router; 