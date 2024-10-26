import express from 'express';
import { createOrder, getOrdersByUser, updateOrderStatus } from '../services/orders';
import { authenticateUser } from '../middleware/auth';

const router = express.Router();

router.post('/', authenticateUser, async (req, res) => {
  try {
    const order = await createOrder(req.body);
    if (order) {
      res.status(201).json({ message: 'Order created successfully', order });
    } else {
      res.status(400).json({ error: 'Failed to create order' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/user/:userId', authenticateUser, async (req, res) => {
  try {
    const orders = await getOrdersByUser(req.params.userId);
    res.status(200).json({ orders });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;