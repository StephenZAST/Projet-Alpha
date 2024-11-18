import express from 'express';
import { authenticateUser } from '../middleware/auth';
import { requireLivreur as requireDriver } from '../middleware/auth';
import { DeliveryService } from '../services/delivery';

const router = express.Router();
const deliveryService = new DeliveryService();

/**
 * @swagger
 * /api/delivery/timeslots:
 *   get:
 *     tags: [Delivery]
 *     summary: Get available delivery time slots
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: zoneId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of available time slots
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 slots:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       start: { type: string, format: date-time }
 *                       end: { type: string, format: date-time }
 */
router.get('/timeslots', authenticateUser, async (req, res) => {
  try {
    const { date, zoneId } = req.query;
    const slots = await deliveryService.getAvailableTimeSlots(
      new Date(date as string),
      zoneId as string
    );
    res.json({ slots });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch time slots' });
  }
});

/**
 * @swagger
 * /api/delivery/schedule-pickup:
 *   post:
 *     tags: [Delivery]
 *     summary: Schedule a laundry pickup
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - date
 *               - timeSlot
 *               - address
 *             properties:
 *               orderId: { type: string }
 *               date: { type: string, format: date }
 *               timeSlot:
 *                 type: object
 *                 properties:
 *                   start: { type: string, format: date-time }
 *                   end: { type: string, format: date-time }
 *               address:
 *                 type: object
 *                 properties:
 *                   street: { type: string }
 *                   city: { type: string }
 *                   zone: { type: string }
 *     responses:
 *       200:
 *         description: Pickup scheduled successfully
 */
router.post('/schedule-pickup', authenticateUser, async (req, res) => {
  try {
    const { orderId, date, timeSlot, address } = req.body;
    const success = await deliveryService.schedulePickup(
      orderId,
      new Date(date),
      timeSlot,
      address
    );
    
    if (success) {
      res.json({ message: 'Pickup scheduled successfully' });
    } else {
      res.status(400).json({ error: 'Failed to schedule pickup' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to schedule pickup' });
  }
});

/**
 * @swagger
 * /api/delivery/update-location:
 *   post:
 *     tags: [Delivery]
 *     summary: Update delivery location and status
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - location
 *               - status
 *             properties:
 *               orderId: { type: string }
 *               location:
 *                 type: object
 *                 properties:
 *                   latitude: { type: number }
 *                   longitude: { type: number }
 *               status: 
 *                 type: string
 *                 enum: [PENDING, IN_TRANSIT, DELIVERED]
 *     responses:
 *       200:
 *         description: Location updated successfully
 */
router.post('/update-location', authenticateUser, requireDriver, async (req, res) => {
  try {
    const { orderId, location, status } = req.body;
    const success = await deliveryService.updateOrderLocation(
      orderId,
      location,
      status
    );
    
    if (success) {
      res.json({ message: 'Location updated successfully' });
    } else {
      res.status(400).json({ error: 'Failed to update location' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to update location' });
  }
});

/**
 * @swagger
 * /api/delivery/tasks:
 *   get:
 *     tags: [Delivery]
 *     summary: Get delivery tasks
 *     description: Retrieve delivery tasks with optional filtering
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED]
 *         description: Filter tasks by status
 *       - in: query
 *         name: driverId
 *         schema:
 *           type: string
 *         description: Filter tasks by driver ID
 *       - in: query
 *         name: date
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter tasks by date
 *     responses:
 *       200:
 *         description: List of delivery tasks
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/DeliveryTask'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get(
  '/tasks',
  authenticateUser,
  async (req, res) => {
    try {
      const tasks = await deliveryService.getTasks(req.query);
      res.json(tasks);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch tasks' });
    }
  }
);

/**
 * @swagger
 * /api/delivery/tasks/{id}:
 *   get:
 *     tags: [Delivery]
 *     summary: Get delivery task by ID
 *     description: Retrieve a specific delivery task by its ID
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Task ID
 *     responses:
 *       200:
 *         description: Delivery task details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DeliveryTask'
 *       404:
 *         description: Task not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get(
  '/tasks/:id',
  authenticateUser,
  async (req, res) => {
    try {
      const task = await deliveryService.getTaskById(req.params.id);
      res.json(task);
    } catch (error) {
      res.status(404).json({ error: 'Task not found' });
    }
  }
);

/**
 * @swagger
 * /api/delivery/tasks:
 *   post:
 *     tags: [Delivery]
 *     summary: Create delivery task
 *     description: Create a new delivery task
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - pickupLocation
 *               - deliveryLocation
 *               - scheduledTime
 *             properties:
 *               orderId:
 *                 type: string
 *               pickupLocation:
 *                 $ref: '#/components/schemas/GeoLocation'
 *               deliveryLocation:
 *                 $ref: '#/components/schemas/GeoLocation'
 *               scheduledTime:
 *                 type: object
 *                 properties:
 *                   date:
 *                     type: string
 *                     format: date-time
 *                   duration:
 *                     type: number
 *                     description: Duration in minutes
 *               priority:
 *                 type: string
 *                 enum: [low, medium, high, urgent]
 *                 default: medium
 *     responses:
 *       201:
 *         description: Task created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DeliveryTask'
 *       400:
 *         description: Invalid input
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/tasks',
  authenticateUser,
  async (req, res) => {
    try {
      const task = await deliveryService.createTask(req.body);
      res.status(201).json(task);
    } catch (error) {
      res.status(400).json({ error: 'Invalid input' });
    }
  }
);

/**
 * @swagger
 * /api/delivery/tasks/{id}:
 *   put:
 *     tags: [Delivery]
 *     summary: Update delivery task
 *     description: Update an existing delivery task
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Task ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [PENDING, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED]
 *               assignedDriver:
 *                 type: string
 *               priority:
 *                 type: string
 *                 enum: [low, medium, high, urgent]
 *               scheduledTime:
 *                 type: object
 *                 properties:
 *                   date:
 *                     type: string
 *                     format: date-time
 *                   duration:
 *                     type: number
 *                     description: Duration in minutes
 *     responses:
 *       200:
 *         description: Task updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DeliveryTask'
 *       404:
 *         description: Task not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put(
  '/tasks/:id',
  authenticateUser,
  async (req, res) => {
    try {
      const task = await deliveryService.updateTask(req.params.id, req.body);
      res.json(task);
    } catch (error) {
      res.status(404).json({ error: 'Task not found' });
    }
  }
);

/**
 * @swagger
 * /api/delivery/optimize-route:
 *   post:
 *     tags: [Delivery]
 *     summary: Optimize delivery route
 *     description: Calculate optimal route for multiple delivery tasks
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - driverId
 *               - startLocation
 *             properties:
 *               driverId:
 *                 type: string
 *               startLocation:
 *                 $ref: '#/components/schemas/GeoLocation'
 *               endLocation:
 *                 $ref: '#/components/schemas/GeoLocation'
 *               maxTasks:
 *                 type: number
 *                 default: 10
 *               considerTraffic:
 *                 type: boolean
 *                 default: true
 *     responses:
 *       200:
 *         description: Optimized route
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 route:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/DeliveryTask'
 *                 totalDistance:
 *                   type: number
 *                   description: Total distance in kilometers
 *                 estimatedDuration:
 *                   type: number
 *                   description: Estimated duration in minutes
 *       400:
 *         description: Invalid input
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/optimize-route',
  authenticateUser,
  async (req, res) => {
    try {
      const route = await deliveryService.optimizeRoute(req.body);
      res.json(route);
    } catch (error) {
      res.status(400).json({ error: 'Invalid input' });
    }
  }
);

/**
 * @swagger
 * /api/delivery/location:
 *   post:
 *     tags: [Delivery]
 *     summary: Update driver location
 *     description: Update current location of delivery driver
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - location
 *             properties:
 *               location:
 *                 $ref: '#/components/schemas/GeoLocation'
 *     responses:
 *       200:
 *         description: Location updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Location updated successfully
 *       400:
 *         description: Invalid input
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/location',
  authenticateUser,
  requireDriver,
  async (req, res) => {
    try {
      const success = await deliveryService.updateLocation(req.body);
      if (success) {
        res.json({ message: 'Location updated successfully' });
      } else {
        res.status(400).json({ error: 'Failed to update location' });
      }
    } catch (error) {
      res.status(400).json({ error: 'Invalid input' });
    }
  }
);

/**
 * @swagger
 * /api/delivery/zones:
 *   get:
 *     tags: [Delivery]
 *     summary: Get delivery zones
 *     description: Retrieve all delivery zones
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of delivery zones
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: string
 *                   name:
 *                     type: string
 *                   boundaries:
 *                     type: array
 *                     items:
 *                       $ref: '#/components/schemas/GeoLocation'
 *                   assignedDrivers:
 *                     type: array
 *                     items:
 *                       type: string
 */
router.get(
  '/zones',
  authenticateUser,
  async (req, res) => {
    try {
      const zones = await deliveryService.getZones();
      res.json(zones);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch zones' });
    }
  }
);

export default router;
