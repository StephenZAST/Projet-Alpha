const express = require('express');
const admin = require('firebase-admin');
const { DeliveryController } = require('../../src/controllers/deliveryController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');
const {
  createDeliverySchema,
  updateDeliverySchema,
  getDeliverySchema,
} = require('../../src/validation/delivery');

const router = express.Router();
const deliveryController = new DeliveryController();

router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

router.post(
    '/create',
    validateRequest(createDeliverySchema),
    async (req, res) => {
      try {
        const newDelivery = await deliveryController.createDelivery(req, res);
        res.status(201).json(newDelivery);
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
    validateRequest(getDeliverySchema),
    async (req, res) => {
      try {
        const deliveries = await deliveryController.getDeliveries(req, res);
        res.json(deliveries);
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
    validateRequest(updateDeliverySchema),
    async (req, res) => {
      try {
        const updatedDelivery = await deliveryController.updateDelivery(req, res);
        res.json(updatedDelivery);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

module.exports = router;
