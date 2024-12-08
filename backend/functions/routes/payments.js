const express = require('express');
const admin = require('firebase-admin');
const { PaymentController } = require('../../src/controllers/paymentController');
const { validateRequest } = require('../../src/middleware/validateRequest');
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');
const {
  createPaymentSchema,
  updatePaymentSchema,
  getPaymentSchema,
} = require('../../src/validation/payments');

const router = express.Router();
const paymentController = new PaymentController();

router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

router.post(
    '/create',
    validateRequest(createPaymentSchema),
    async (req, res) => {
      try {
        const newPayment = await paymentController.createPayment(req, res);
        res.status(201).json(newPayment);
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
    validateRequest(getPaymentSchema),
    async (req, res) => {
      try {
        const payments = await paymentController.getPayments(req, res);
        res.json(payments);
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
    validateRequest(updatePaymentSchema),
    async (req, res) => {
      try {
        const updatedPayment = await paymentController.updatePayment(req, res);
        res.json(updatedPayment);
      } catch (error) {
        res.status(error.statusCode || 500).json({
          error: error.message,
          code: error.errorCode,
        });
      }
    },
);

module.exports = router;
