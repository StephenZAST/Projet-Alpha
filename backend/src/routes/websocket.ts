// Removed Swagger comments
import express from 'express';
import { websocketManager } from '../server';
import { logger } from '../utils/logger';

const router = express.Router();

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

router.post('/broadcast', (req, res) => {
  try {
    const { event, data } = req.body;
    
    if (!event) {
      res.status(400).json({ 
        message: 'Événement requis', 
        status: 400 
      });
    }

    websocketManager.broadcast(event, data);
    res.json({ 
      message: 'Message diffusé avec succès', 
      status: 200 
    });
  } catch (error) {
    logger.error('Error broadcasting message', error);
    res.status(500).json({ 
      message: 'Erreur lors de la diffusion du message', 
      status: 500 
    });
  }
});

export default router;
