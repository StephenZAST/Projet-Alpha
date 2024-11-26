/* eslint-disable no-unused-vars */
/* eslint-disable max-len */
const express = require('express');
const admin = require('firebase-admin');
const { paymentController } = require('../../src/controllers/paymentController');
const { isAuthenticated } = require('../middleware/auth'); // Assuming you have an auth middleware
const { validateRequest } = require('../../src/middleware/validateRequest');
const { paymentValidation } = require('../../src/validations/paymentValidation');

const router = express.Router();

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// GET /payments/methods
router.get('/methods', paymentController.getPaymentMethods);

// POST /payments/methods
router.post('/methods', validateRequest(paymentValidation.addPaymentMethod), paymentController.addPaymentMethod);

// DELETE /payments/methods/:id
router.delete('/methods/:id', validateRequest(paymentValidation.removePaymentMethod), paymentController.removePaymentMethod);

// PUT /payments/methods/:id/default
router.put('/methods/:id/default', validateRequest(paymentValidation.setDefaultPaymentMethod), paymentController.setDefaultPaymentMethod);

// POST /payments/process
router.post('/process', validateRequest(paymentValidation.processPayment), paymentController.processPayment);

// GET /payments/history
router.get('/history', validateRequest(paymentValidation.getPaymentHistory), paymentController.getPaymentHistory);

// POST /payments/refund
router.post('/refund', validateRequest(paymentValidation.processRefund), paymentController.processRefund);

module.exports = router;
