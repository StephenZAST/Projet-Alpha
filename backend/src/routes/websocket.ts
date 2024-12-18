import express from 'express';
import { websocketManager } from '../server';
import { logger } from '../utils/logger';
import { AppError, errorCodes } from '../utils/errors';

const router = express.Router();

router.get('/clients', (req, res, next) => {
  try {
    const connectedClients = websocketManager.getConnectedClientsCount();
    res.json({ connectedClients });
  } catch (error) {
    logger.error('Error fetching connected clients', error);
    next(new AppError(500, 'Failed to fetch connected clients', errorCodes.WEBSOCKET_ERROR));
  }
});

router.post('/broadcast', (req, res, next) => {
  try {
    const { event, data } = req.body;
    
    if (!event) {
      return next(new AppError(400, 'Event is required', errorCodes.VALIDATION_ERROR));
    }

    websocketManager.broadcast(event, data);
    res.json({ 
      message: 'Message broadcasted successfully', 
      status: 200 
    });
  } catch (error) {
    logger.error('Error broadcasting message', error);
    next(new AppError(500, 'Failed to broadcast message', errorCodes.WEBSOCKET_ERROR));
  }
});

export default router;
