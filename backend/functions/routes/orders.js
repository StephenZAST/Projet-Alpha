const express = require('express');
const admin = require('firebase-admin');
const { OrderService } = require('../../src/services/orders');
const { validateRequest } = require('../../src/middleware/validateRequest');
const {
  createOrderSchema,
  updateOrderSchema,
  updateOrderStatusSchema,
} = require('../../src/validation/orders');
const { AppError } = require('../../src/utils/errors');

const router = express.Router();
const orderService = new OrderService();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Middleware to check if the user has the admin role
const requireAdminRole = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  next();
};

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// POST /orders
router.post('/', validateRequest(createOrderSchema), async (req, res) => {
  try {
    const userId = req.user.uid;
    const order = await orderService.createOrder({
      ...req.body,
      userId,
    });
    res.status(201).json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// GET /orders
router.get('/', async (req, res) => {
  try {
    const userId = req.user.uid;
    const {
      page = 1,
      limit = 10,
      status,
      startDate,
      endDate,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query;

    const orders = await orderService.getOrdersByUser(userId, {
      page: Number(page),
      limit: Number(limit),
      status: status,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      sortBy: sortBy,
      sortOrder: sortOrder,
    });

    res.json(orders);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// GET /orders/:id
router.get('/:id', async (req, res) => {
  try {
    const userId = req.user.uid;
    const order = await orderService.getOrderById(req.params.id, userId);
    res.json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// PUT /orders/:id
router.put('/:id', validateRequest(updateOrderSchema), async (req, res) => {
  try {
    const userId = req.user.uid;
    const order = await orderService.updateOrder(req.params.id, userId, req.body);
    res.json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// PATCH /orders/:id/status
router.patch('/:id/status', validateRequest(updateOrderStatusSchema), async (req, res) => {
  try {
    const userId = req.user.uid;
    const { status } = req.body;
    const order = await orderService.updateOrderStatus(req.params.id, status, userId);
    res.json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// POST /orders/:id/cancel
router.post('/:id/cancel', async (req, res) => {
  try {
    const userId = req.user.uid;
    const order = await orderService.cancelOrder(req.params.id, userId);
    res.json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// Admin-only routes
router.use(requireAdminRole);

// GET /orders/admin/all
router.get('/admin/all', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      userId,
      startDate,
      endDate,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query;

    const orders = await orderService.getAllOrders({
      page: Number(page),
      limit: Number(limit),
      status: status,
      userId: userId,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      sortBy: sortBy,
      sortOrder: sortOrder,
    });

    res.json(orders);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

module.exports = router;
