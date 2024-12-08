const express = require('express');
const admin = require('firebase-admin');
const { OrderController } = require('../../src/controllers/orderController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');
const {
  createOrderSchema,
  updateOrderSchema,
  updateOrderStatusSchema,
  assignDeliverySchema,
  scheduleDeliverySchema,
} = require('../../src/validation/orders');
const { rateLimit } = require('../../src/middleware/rateLimit');

const router = express.Router();
const orderController = new OrderController();

const createOrderRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 10,
});

const firebaseAuth = async (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];
  if (!idToken) {
    return res.status(401).json({ error: 'Token manquant' });
  }
  const decodedToken = await admin.auth().verifyIdToken(idToken);
  req.user = decodedToken;
  next();
};

router.use(firebaseAuth);

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
          code: error.errorCode,
        });
      }
    },
);

router.get('/my-orders', async (req, res) => {
  try {
    const orders = await orderController.getMyOrders(req, res);
    res.json(orders);
  } catch (error) {
    res.status(error.statusCode || 500).json({
      error: error.message,
      code: error.errorCode,
    });
  }
});

router.get(
    '/',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SUPERVISEUR]),
    async (req, res) => {
      try {
        const orders = await orderController.getAllOrders(req, res);
        res.json(orders);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

router.put(
    '/:id',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SUPERVISEUR]),
    validateRequest(updateOrderSchema),
    async (req, res) => {
      try {
        const updatedOrder = await orderController.updateOrder(req, res);
        res.json(updatedOrder);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

router.patch(
    '/:id/status',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SERVICE_CLIENT, UserRole.SUPERVISEUR, UserRole.LIVREUR]),
    validateRequest(updateOrderStatusSchema),
    async (req, res) => {
      try {
        const updatedOrder = await orderController.updateOrderStatus(req, res);
        res.json(updatedOrder);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

router.post(
    '/:id/assign-delivery',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SUPERVISEUR]),
    validateRequest(assignDeliverySchema),
    async (req, res) => {
      try {
        const updatedOrder = await orderController.assignDelivery(req, res);
        res.json(updatedOrder);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

router.post(
    '/:id/schedule-delivery',
    requireAdminRolePath([UserRole.SUPER_ADMIN, UserRole.SUPERVISEUR, UserRole.LIVREUR]),
    validateRequest(scheduleDeliverySchema),
    async (req, res) => {
      try {
        const schedule = await orderController.scheduleDelivery(req, res);
        res.json(schedule);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

router.post('/:id/cancel', async (req, res) => {
  try {
    const cancelledOrder = await orderController.cancelOrder(req, res);
    res.json(cancelledOrder);
  } catch (error) {
    res.status(error.statusCode || 500).json({
      error: error.message,
      code: error.errorCode,
    });
  }
});

module.exports = router;
