import express from 'express';
import { authenticateUser, requireRole, requireOwnership, validateOneClickOrder } from '../middleware/auth';
import { UserRole } from '../models/user';
import { OrderStatus, OrderType } from '../models/order';
import { createOrder, getOrdersByUser, updateOrderStatus } from '../services/orders';

const router = express.Router();

// Middleware d'authentification pour toutes les routes
router.use(authenticateUser);

// Route pour créer une commande one-click
router.post('/one-click', validateOneClickOrder, async (req, res) => {
  try {
    const userId = req.user!.uid!;
    const order = await createOrder({ ...req.body, type: OrderType.ONE_CLICK });
    if (order) {
      res.status(201).json({ message: 'One-click order created', order });
    } else {
      res.status(400).json({ error: 'Failed to create one-click order' });
    }
  } catch (error) {
    console.error('Error creating one-click order:', error);
    res.status(500).json({ error: 'Failed to create one-click order' });
  }
});

// Route pour obtenir les commandes d'un utilisateur
router.get('/user/:userId', requireOwnership(req => req.params.userId), async (req, res) => {
  try {
    const userId = req.params.userId;
    const orders = await getOrdersByUser(userId);
    res.status(200).json({ orders });
  } catch (error) {
    console.error('Error fetching user orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Route pour les secrétaires pour détailler une commande
router.put('/:orderId/detail', requireRole([UserRole.SECRETAIRE, UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const orderId = req.params.orderId;
    const orderDetails = req.body;
    // Logique pour mettre à jour les détails de la commande
    res.status(200).json({ message: 'Order details updated' });
  } catch (error) {
    console.error('Error updating order details:', error);
    res.status(500).json({ error: 'Failed to update order details' });
  }
});

// Route pour les livreurs pour mettre à jour le statut de collecte/livraison
router.put('/:orderId/status', requireRole([UserRole.LIVREUR, UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const orderId = req.params.orderId;
    const { status } = req.body;
    await updateOrderStatus(orderId, status);
    res.status(200).json({ message: 'Order status updated' });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

// Route pour obtenir les commandes par zone pour les livreurs
router.get('/zone/:zoneId', requireRole([UserRole.LIVREUR, UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const zoneId = req.params.zoneId;
    // Logique pour récupérer les commandes d'une zone
    res.status(200).json({ orders: [] });
  } catch (error) {
    console.error('Error fetching zone orders:', error);
    res.status(500).json({ error: 'Failed to fetch zone orders' });
  }
});

// Route pour obtenir l'itinéraire optimisé pour un livreur
router.get('/delivery-route/:deliveryId', requireRole([UserRole.LIVREUR, UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const deliveryId = req.params.deliveryId;
    // Logique pour calculer l'itinéraire optimisé
    res.status(200).json({ route: [] });
  } catch (error) {
    console.error('Error calculating delivery route:', error);
    res.status(500).json({ error: 'Failed to calculate delivery route' });
  }
});

// Route pour les superviseurs pour voir toutes les commandes
router.get('/all', requireRole([UserRole.SUPERVISEUR, UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const { status, startDate, endDate } = req.query;
    // Logique pour récupérer toutes les commandes avec filtres
    res.status(200).json({ orders: [] });
  } catch (error) {
    console.error('Error fetching all orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Route pour créer une commande
router.post('/', async (req, res) => {
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

export default router;