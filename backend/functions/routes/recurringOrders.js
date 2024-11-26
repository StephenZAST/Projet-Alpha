const express = require('express');
const admin = require('firebase-admin');
const { recurringOrderController } = require('../../src/controllers/recurringOrderController');
const { isAuthenticated, requireAdminRole } = require('../middleware/auth'); // Assuming you have an auth middleware
const { validateRequest } = require('../../src/middleware/validateRequest');
const { recurringOrderValidation } = require('../../src/validations/recurringOrderValidation');

const router = express.Router();

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// POST /recurring-orders
router.post('/', validateRequest(recurringOrderValidation.create), recurringOrderController.createRecurringOrder);

// PUT /recurring-orders/:id
router.put('/:id', validateRequest(recurringOrderValidation.params), validateRequest(recurringOrderValidation.update), recurringOrderController.updateRecurringOrder);

// POST /recurring-orders/:id/cancel
router.post('/:id/cancel', validateRequest(recurringOrderValidation.params), recurringOrderController.cancelRecurringOrder);

// GET /recurring-orders
router.get('/', recurringOrderController.getRecurringOrders);

// Admin-only route
router.post('/process', requireAdminRole, recurringOrderController.processRecurringOrders);

module.exports = router;
