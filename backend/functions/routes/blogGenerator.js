const express = require('express');
const admin = require('firebase-admin');
const { BlogGeneratorController } = require('../../src/controllers/blogGeneratorController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { isAuthenticated, hasRole } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');
const { validateBlogGenerationConfig } = require('../../src/middleware/blogGeneratorValidation');

const router = express.Router();
const blogGeneratorController = new BlogGeneratorController();

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

// Toutes les routes nécessitent une authentification
router.use(firebaseAuth);

// Vérification des rôles autorisés
const allowedRoles = [
  UserRole.SUPER_ADMIN,
  UserRole.SERVICE_CLIENT,
  UserRole.SECRETAIRE,
  UserRole.SUPERVISEUR,
];

// Route pour mettre à jour la clé API Google AI
router.post(
    '/api-key',
    hasRole(allowedRoles),
    async (req, res) => {
      try {
        await blogGeneratorController.updateGoogleAIKey(req, res);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

// Route pour générer un article de blog avec l'IA
router.post(
    '/generate',
    hasRole(allowedRoles),
    validateRequest(validateBlogGenerationConfig),
    async (req, res) => {
      try {
        const generatedArticle = await blogGeneratorController.generateBlogArticle(req, res);
        res.status(201).json(generatedArticle);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
          details: error.details,
        });
      }
    },
);

module.exports = router;
