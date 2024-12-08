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

const router = express.Router();
const orderController = new OrderController();

const createOrderRateLimit = require('../../src/middleware/rateLimit')({
  windowMs: 15 * 60 * 1000,
  max: 5,
});

const resetPasswordRateLimit = require('../../src/middleware/rateLimit')({
  windowMs: 60 * 60 * 1000,
  max: 3,
});

router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

router.post(
    '/create',
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

router.get(
    '/get',
    async (req, res) => {
      try {
        const orders = await orderController.getOrders(req, res);
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

router.put(
    '/:id/status',
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
    '/:id/assign',
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
    '/:id/schedule',
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

module.exports = router;
