import express from 'express';
import { websocketManager } from '../server';
import { logger } from '../utils/logger';

const router = express.Router();

/**
 * @openapi
 * /api/websocket/clients:
 *   get:
 *     summary: Get number of connected WebSocket clients
 *     tags:
 *       - WebSocket
 *     responses:
 *       200:
 *         description: Number of connected clients
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 connectedClients:
 *                   type: number
 */
router.get('/clients', (req, res) => {
  try {
    const connectedClients = websocketManager.getConnectedClientsCount();
    res.json({ connectedClients });
  } catch (error) {
    logger.error('Error fetching connected clients', error);
    res.status(500).json({ 
      message: 'Erreur lors de la récupération des clients connectés', 
      status: 500 
    });
  }
});

/**
 * @openapi
 * /api/websocket/broadcast:
 *   post:
 *     summary: Broadcast a message to all connected clients
 *     tags:
 *       - WebSocket
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               event:
 *                 type: string
 *               data:
 *                 type: object
 *     responses:
 *       200:
 *         description: Message broadcasted successfully
 *       500:
 *         description: Error broadcasting message
 */
router.post('/broadcast', (req, res) => {
  try {
    const { event, data } = req.body;
    
    if (!event) {
      res.status(400).json({ 
        message: 'Événement requis', 
        status: 400 
      }); // Removed return
    }

    websocketManager.broadcast(event, data);
    res.json({ 
      message: 'Message diffusé avec succès', 
      status: 200 
    }); // Removed return
  } catch (error) {
    logger.error('Error broadcasting message', error);
    res.status(500).json({ 
      message: 'Erreur lors de la diffusion du message', 
      status: 500 
    }); // Removed return
  }
});

export default router;
