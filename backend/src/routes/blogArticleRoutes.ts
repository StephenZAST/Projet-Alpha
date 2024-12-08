import express from 'express';
import { BlogArticleController } from '../controllers/blogArticleController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { validateCreateBlogArticle, validateUpdateBlogArticle } from '../middleware/blogArticleValidation';
import { UserRole } from '../models/user';

const router = express.Router();
const blogArticleController = new BlogArticleController();

// Routes publiques
router.get('/', blogArticleController.getArticles);
router.get('/:identifier', blogArticleController.getArticle);

// Routes protégées nécessitant une authentification
router.use(isAuthenticated);

// Routes pour la création et la gestion des articles (tous les admins sauf les livreurs)
router.post(
    '/',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SECRETAIRE, UserRole.SUPERVISEUR]),
    validateCreateBlogArticle,
    blogArticleController.createArticle
);

router.put(
    '/:id',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SECRETAIRE, UserRole.SUPERVISEUR]),
    validateUpdateBlogArticle,
    blogArticleController.updateArticle
);

router.delete(
    '/:id',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SECRETAIRE, UserRole.SUPERVISEUR]),
    blogArticleController.deleteArticle
);

export default router;
