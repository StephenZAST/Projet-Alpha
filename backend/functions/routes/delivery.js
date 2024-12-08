const express = require('express');
const admin = require('firebase-admin');
const { DeliveryService } = require('../../src/services/delivery');
const { AppError } = require('../../src/utils/errors');
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');

const router = express.Router();
const deliveryService = new DeliveryService();

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

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// GET /delivery/timeslots
router.get('/timeslots', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const { date, zoneId } = req.query;

    // Validate input data
    if (!date || !zoneId) {
      throw new AppError(400, 'Missing required query parameters: date and zoneId', 'VALIDATION_ERROR');
    }

    const slots = await deliveryService.getAvailableTimeSlots(
        new Date(date),
        zoneId,
    );
    res.json({ slots });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error fetching time slots:', error);
    res.status(500).json({ error: 'Failed to fetch time slots' });
  }
});

// POST /delivery/schedule-pickup
router.post('/schedule-pickup', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const { orderId, date, timeSlot, address } = req.body;

    // Validate input data
    if (!orderId || !date || !timeSlot || !address) {
      throw new AppError(400, 'Missing required fields: orderId, date, timeSlot, and address', 'VALIDATION_ERROR');
    }

    const success = await deliveryService.schedulePickup(
        orderId,
        new Date(date),
        timeSlot,
        address,
    );

    if (success) {
      res.json({ message: 'Pickup scheduled successfully' });
    } else {
      res.status(500).json({ error: 'Failed to schedule pickup' });
    }
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error scheduling pickup:', error);
    res.status(500).json({ error: 'Failed to schedule pickup' });
  }
});

// POST /delivery/update-location
router.post('/update-location', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const { orderId, location, status } = req.body;

    // Validate input data
    if (!orderId || !location || !status) {
      throw new AppError(400, 'Missing required fields: orderId, location, and status', 'VALIDATION_ERROR');
    }

    const success = await deliveryService.updateOrderLocation(
        orderId,
        location,
        status,
    );

    if (success) {
      res.json({ message: 'Location updated successfully' });
    } else {
      res.status(500).json({ error: 'Failed to update location' });
    }
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating order location:', error);
    res.status(500).json({ error: 'Failed to update location' });
  }
});

// GET /delivery/tasks
router.get('/tasks', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    // Implement logic to fetch delivery tasks with optional filtering
    // based on req.query (status, driverId, date)
    const tasks = await deliveryService.getTasks(req.query);
    res.json(tasks);
  } catch (error) {
    console.error('Error fetching delivery tasks:', error);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// GET /delivery/tasks/:id
router.get('/tasks/:id', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const taskId = req.params.id;
    // Implement logic to fetch a specific delivery task by ID
    const task = await deliveryService.getTaskById(taskId);
    res.json(task);
  } catch (error) {
    console.error('Error fetching delivery task:', error);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

// POST /delivery/tasks
router.post('/tasks', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    // Implement logic to create a new delivery task
    const task = await deliveryService.createTask(req.body);
    res.status(201).json(task);
  } catch (error) {
    console.error('Error creating delivery task:', error);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// PUT /delivery/tasks/:id
router.put('/tasks/:id', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const taskId = req.params.id;
    // Implement logic to update an existing delivery task
    const task = await deliveryService.updateTask(taskId, req.body);
    res.json(task);
  } catch (error) {
    console.error('Error updating delivery task:', error);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// POST /delivery/optimize-tasks
router.post('/optimize-tasks', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const { taskIds, driverId, startLocation, endLocation, maxTasks, considerTraffic } = req.body;
    const route = await deliveryService.optimizeRoute(
        taskIds,
        driverId,
        startLocation,
        endLocation,
        maxTasks,
        considerTraffic,
    );
    res.json(route);
  } catch (error) {
    res.status(400).json({ error: 'Invalid input' });
  }
});

// POST /delivery/location
router.post('/location', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    // Implement logic to update driver location
    await deliveryService.updateLocation(req.body);
    res.json({ message: 'Location updated successfully' });
  } catch (error) {
    console.error('Error updating driver location:', error);
    res.status(500).json({ error: 'Failed to update location' });
  }
});

// GET /delivery/zones
router.get('/zones', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    // Implement logic to retrieve all delivery zones
    const zones = await deliveryService.getZones();
    res.json(zones);
  } catch (error) {
    console.error('Error fetching delivery zones:', error);
    res.status(500).json({ error: 'Failed to fetch zones' });
  }
});

module.exports = router;
