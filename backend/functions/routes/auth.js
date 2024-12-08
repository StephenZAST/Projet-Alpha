const express = require('express');
const admin = require('firebase-admin');
const { AuthController } = require('../../src/controllers/authController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { 
    loginSchema, 
    registerSchema, 
    resetPasswordSchema,
    updateProfileSchema,
    changePasswordSchema 
} = require('../../src/validation/auth');
const { isAuthenticated } = require('../../src/middleware/auth');
const { rateLimit } = require('../../src/middleware/rateLimit');

const router = express.Router();
const authController = new AuthController();

// Middleware de limitation de taux pour les tentatives de connexion
const loginRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5 // 5 tentatives
});

// Middleware de limitation de taux pour la réinitialisation de mot de passe
const resetPasswordRateLimit = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 heure
    max: 3 // 3 tentatives
});

// Routes publiques
router.post('/login', loginRateLimit, validateRequest(loginSchema), async (req, res) => {
    try {
        const authData = await authController.login(req, res);
        res.json(authData);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

router.post('/register', validateRequest(registerSchema), async (req, res) => {
    try {
        const userData = await authController.register(req, res);
        res.status(201).json(userData);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

router.post('/reset-password', resetPasswordRateLimit, validateRequest(resetPasswordSchema), async (req, res) => {
    try {
        await authController.resetPassword(req, res);
        res.json({ message: 'Email de réinitialisation envoyé avec succès' });
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

// Routes protégées
router.use(isAuthenticated);

router.put('/profile', validateRequest(updateProfileSchema), async (req, res) => {
    try {
        const updatedProfile = await authController.updateProfile(req, res);
        res.json(updatedProfile);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

router.post('/change-password', validateRequest(changePasswordSchema), async (req, res) => {
    try {
        await authController.changePassword(req, res);
        res.json({ message: 'Mot de passe modifié avec succès' });
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

router.post('/logout', async (req, res) => {
    try {
        await authController.logout(req, res);
        res.json({ message: 'Déconnexion réussie' });
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

// Vérification du token
router.get('/verify-token', async (req, res) => {
    try {
        const userData = await authController.verifyToken(req, res);
        res.json(userData);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

module.exports = router;
