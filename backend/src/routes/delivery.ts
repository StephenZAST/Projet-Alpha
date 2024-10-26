import express from 'express';
import { authenticateUser, requireDriver } from '../middleware/auth';
import { DeliveryService } from '../services/delivery';

const router = express.Router();
const deliveryService = new DeliveryService();

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
