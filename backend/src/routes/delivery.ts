import express from 'express';
import { isAuthenticated } from '../middleware/auth';
import { DeliveryService } from '../services/delivery';

const router = express.Router();
const deliveryService = new DeliveryService();

router.get('/timeslots', isAuthenticated, async (req, res) => {
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

router.post('/schedule-pickup', isAuthenticated, async (req, res) => {
  try {
    const { orderId, date, timeSlot, address } = req.body;
    await deliveryService.schedulePickup(
      orderId,
      new Date(date),
      timeSlot,
      address
    );
    res.json({ message: 'Pickup scheduled successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to schedule pickup' });
  }
});

router.post('/update-location', isAuthenticated, async (req, res) => {
  try {
    const { orderId, location, status } = req.body;
    await deliveryService.updateOrderLocation(
      orderId,
      location,
      status
    );
    res.json({ message: 'Location updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update location' });
  }
});

router.get(
  '/tasks',
  isAuthenticated,
  async (req, res) => {
    try {
      const tasks = await deliveryService.getTasks(req.query);
      res.json(tasks);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch tasks' });
    }
  }
);

router.get(
  '/tasks/:id',
  isAuthenticated,
  async (req, res) => {
    try {
      const task = await deliveryService.getTaskById(req.params.id);
      res.json(task);
    } catch (error) {
      res.status(404).json({ error: 'Task not found' });
    }
  }
);

router.post(
  '/tasks',
  isAuthenticated,
  async (req, res) => {
    try {
      const task = await deliveryService.createTask(req.body);
      res.status(201).json(task);
    } catch (error) {
      res.status(400).json({ error: 'Invalid input' });
    }
  }
);

router.put(
  '/tasks/:id',
  isAuthenticated,
  async (req, res) => {
    try {
      const task = await deliveryService.updateTask(req.params.id, req.body);
      res.json(task);
    } catch (error) {
      res.status(404).json({ error: 'Task not found' });
    }
  }
);

router.post(
  '/optimize-tasks', // Renamed endpoint
  isAuthenticated,
  async (req, res) => {
    try {
      const { taskIds, driverId, startLocation, endLocation, maxTasks, considerTraffic } = req.body;
      const route = await deliveryService.optimizeRoute(
        taskIds,
        driverId,
        startLocation,
        endLocation,
        maxTasks,
        considerTraffic
      );
      res.json(route);
    } catch (error) {
      res.status(400).json({ error: 'Invalid input' });
    }
  }
);

router.post(
  '/location',
  isAuthenticated,
  async (req, res) => {
    try {
      await deliveryService.updateLocation(req.body);
      res.json({ message: 'Location updated successfully' });
    } catch (error) {
      if (error instanceof Error) {
        res.status(400).json({ error: error.message });
      } else {
        res.status(400).json({ error: 'Invalid input' });
      }
    }
  });

router.get(
  '/zones',
  isAuthenticated,
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
