const express = require('express');
const admin = require('firebase-admin');
const { BlogArticleController } = require('../../src/controllers/blogArticleController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { isAuthenticated, hasRole } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');
const {
    validateCreateBlogArticle,
    validateUpdateBlogArticle
} = require('../../src/middleware/blogArticleValidation');

const router = express.Router();
const blogArticleController = new BlogArticleController();

// Middleware pour vérifier l'authentification avec Firebase
const firebaseAuth = async (req, res, next) => {
    try {
        const idToken = req.headers.authorization?.split('Bearer ')[1];
        if (!idToken) {
            return res.status(401).json({ error: 'Token manquant' });
        }

        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken;
        next();
    } catch (error) {
        console.error('Erreur de vérification du token:', error);
        res.status(401).json({ error: 'Non autorisé' });
    }
};

// Routes publiques
router.get('/', async (req, res) => {
    try {
        const articles = await blogArticleController.getArticles(req, res);
        res.json(articles);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

router.get('/:identifier', async (req, res) => {
    try {
        const article = await blogArticleController.getArticle(req, res);
        res.json(article);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

// Routes protégées
router.use(firebaseAuth);

// Routes pour la création et la gestion des articles (tous les admins sauf les livreurs)
const allowedRoles = [
    UserRole.SUPER_ADMIN,
    UserRole.SERVICE_CLIENT,
    UserRole.SECRETAIRE,
    UserRole.SUPERVISEUR
];

router.post(
    '/',
    hasRole(allowedRoles),
    validateRequest(validateCreateBlogArticle),
    async (req, res) => {
        try {
            const newArticle = await blogArticleController.createArticle(req, res);
            res.status(201).json(newArticle);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

router.put(
    '/:id',
    hasRole(allowedRoles),
    validateRequest(validateUpdateBlogArticle),
    async (req, res) => {
        try {
            const updatedArticle = await blogArticleController.updateArticle(req, res);
            res.json(updatedArticle);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

router.delete(
    '/:id',
    hasRole(allowedRoles),
    async (req, res) => {
        try {
            await blogArticleController.deleteArticle(req, res);
            res.status(204).send();
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

module.exports = router;
