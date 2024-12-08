const express = require('express');
const admin = require('firebase-admin');
const { OrderController } = require('../../src/controllers/orderController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { isAuthenticated, hasRole } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');
const { 
    createOrderSchema,
    updateOrderSchema,
    updateOrderStatusSchema,
    assignDeliverySchema,
    scheduleDeliverySchema
} = require('../../src/validation/orders');
const { rateLimit } = require('../../src/middleware/rateLimit');

const router = express.Router();
const orderController = new OrderController();

// Middleware de limitation de taux pour la création de commandes
const createOrderRateLimit = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 heure
    max: 10 // 10 commandes par heure
});

// Middleware Firebase Auth
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

// Routes pour les clients
router.post(
    '/',
    createOrderRateLimit,
    validateRequest(createOrderSchema),
    async (req, res) => {
        try {
            const newOrder = await orderController.createOrder(req, res);
            res.status(201).json(newOrder);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

router.get('/my-orders', async (req, res) => {
    try {
        const orders = await orderController.getMyOrders(req, res);
        res.json(orders);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

// Routes pour les administrateurs
router.get(
    '/',
    hasRole([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SUPERVISEUR]),
    async (req, res) => {
        try {
            const orders = await orderController.getAllOrders(req, res);
            res.json(orders);
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
    hasRole([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SUPERVISEUR]),
    validateRequest(updateOrderSchema),
    async (req, res) => {
        try {
            const updatedOrder = await orderController.updateOrder(req, res);
            res.json(updatedOrder);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

router.patch(
    '/:id/status',
    hasRole([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SUPERVISEUR, UserRole.LIVREUR]),
    validateRequest(updateOrderStatusSchema),
    async (req, res) => {
        try {
            const updatedOrder = await orderController.updateOrderStatus(req, res);
            res.json(updatedOrder);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

// Routes pour la livraison
router.post(
    '/:id/assign-delivery',
    hasRole([UserRole.SUPER_ADMIN, UserRole.SUPERVISEUR]),
    validateRequest(assignDeliverySchema),
    async (req, res) => {
        try {
            const updatedOrder = await orderController.assignDelivery(req, res);
            res.json(updatedOrder);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

router.post(
    '/:id/schedule-delivery',
    hasRole([UserRole.SUPER_ADMIN, UserRole.SUPERVISEUR, UserRole.LIVREUR]),
    validateRequest(scheduleDeliverySchema),
    async (req, res) => {
        try {
            const schedule = await orderController.scheduleDelivery(req, res);
            res.json(schedule);
        } catch (error) {
            res.status(error.statusCode || 500).json({
                error: error.message,
                code: error.errorCode
            });
        }
    }
);

// Route pour annuler une commande
router.post('/:id/cancel', async (req, res) => {
    try {
        const cancelledOrder = await orderController.cancelOrder(req, res);
        res.json(cancelledOrder);
    } catch (error) {
        res.status(error.statusCode || 500).json({
            error: error.message,
            code: error.errorCode
        });
    }
});

module.exports = router;
