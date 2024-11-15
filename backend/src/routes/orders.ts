import express from 'express';
import { authenticateUser, requireRole, requireOwnership, validateOneClickOrder } from '../middleware/auth';
import { UserRole } from '../models/user';
import { OrderStatus, OrderType } from '../models/order';
import { createOrder, getOrdersByUser, updateOrderStatus } from '../services/orders';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Orders
 *   description: Gestion des commandes
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Order:
 *       type: object
 *       required:
 *         - userId
 *         - type
 *         - serviceType
 *         - items
 *         - pickupAddress
 *         - deliveryAddress
 *       properties:
 *         userId:
 *           type: string
 *           description: ID de l'utilisateur
 *         type:
 *           type: string
 *           enum: [STANDARD, ONE_CLICK]
 *           description: Type de commande
 *         serviceType:
 *           type: string
 *           enum: [PRESSING, REPASSAGE, NETTOYAGE]
 *           description: Type de service
 *         items:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               itemType:
 *                 type: string
 *               quantity:
 *                 type: number
 *               notes:
 *                 type: string
 *         pickupAddress:
 *           type: string
 *         deliveryAddress:
 *           type: string
 *         status:
 *           type: string
 *           enum: [PENDING, ACCEPTED, PICKED_UP, IN_PROGRESS, READY, DELIVERING, DELIVERED]
 *         scheduledPickupTime:
 *           type: string
 *           format: date-time
 *         scheduledDeliveryTime:
 *           type: string
 *           format: date-time
 */

// Middleware d'authentification pour toutes les routes
router.use(authenticateUser);

/**
 * @swagger
 * /api/orders/one-click:
 *   post:
 *     summary: Créer une nouvelle commande one-click
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Order'
 *     responses:
 *       201:
 *         description: Commande one-click créée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Order'
 *       400:
 *         description: Données invalides
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders/user/{userId}:
 *   get:
 *     summary: Obtenir les commandes d'un utilisateur
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         schema:
 *           type: string
 *         required: true
 *         description: ID de l'utilisateur
 *     responses:
 *       200:
 *         description: Liste des commandes de l'utilisateur
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Order'
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders/{orderId}/detail:
 *   put:
 *     summary: Mettre à jour les détails d'une commande
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: orderId
 *         schema:
 *           type: string
 *         required: true
 *         description: ID de la commande
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               details:
 *                 type: string
 *     responses:
 *       200:
 *         description: Détails mis à jour avec succès
 *       400:
 *         description: Données invalides
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders/{orderId}/status:
 *   put:
 *     summary: Mettre à jour le statut d'une commande
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: orderId
 *         schema:
 *           type: string
 *         required: true
 *         description: ID de la commande
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [PENDING, ACCEPTED, PICKED_UP, IN_PROGRESS, READY, DELIVERING, DELIVERED]
 *     responses:
 *       200:
 *         description: Statut mis à jour avec succès
 *       400:
 *         description: Données invalides
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders/zone/{zoneId}:
 *   get:
 *     summary: Obtenir les commandes par zone pour les livreurs
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: zoneId
 *         schema:
 *           type: string
 *         required: true
 *         description: ID de la zone
 *     responses:
 *       200:
 *         description: Liste des commandes de la zone
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Order'
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders/delivery-route/{deliveryId}:
 *   get:
 *     summary: Obtenir l'itinéraire optimisé pour un livreur
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: deliveryId
 *         schema:
 *           type: string
 *         required: true
 *         description: ID de la livraison
 *     responses:
 *       200:
 *         description: Itinéraire optimisé
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 route:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       lat:
 *                         type: number
 *                       lng:
 *                         type: number
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders/all:
 *   get:
 *     summary: Obtenir toutes les commandes pour les superviseurs
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *         description: Filtrer par statut
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Date de début
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: Date de fin
 *     responses:
 *       200:
 *         description: Liste des commandes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Order'
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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

/**
 * @swagger
 * /api/orders:
 *   post:
 *     summary: Créer une nouvelle commande
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Order'
 *     responses:
 *       201:
 *         description: Commande créée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Order'
 *       400:
 *         description: Données invalides
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       401:
 *         description: Non autorisé
 *       500:
 *         description: Erreur serveur
 */
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