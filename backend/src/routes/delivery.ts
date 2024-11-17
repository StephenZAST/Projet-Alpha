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

export default router;
