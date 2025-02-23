import express, { Request, Response, NextFunction } from 'express';
import { NotificationController } from '../controllers/notification.controller';
import { authenticateToken } from '../middleware/auth.middleware';
import { validatePaginationParams } from '../utils/pagination';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Protection de toutes les routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Routes pour la gestion des notifications
router.get(
  '/',
  (req: Request, res: Response, next: NextFunction) => {
    req.query = validatePaginationParams(req.query) as any;
    next();
  },
  asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    await NotificationController.getNotifications(req, res);
  })
);
 
router.get('/unread', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await NotificationController.getUnreadCount(req, res);
}));

// Actions sur les notifications individuelles
router.patch('/:notificationId/read', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await NotificationController.markAsRead(req, res);
}));

router.delete('/:notificationId', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await NotificationController.deleteNotification(req, res);
}));

// Actions groupées
router.post('/mark-all-read', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await NotificationController.markAllAsRead(req, res);
}));

// Préférences de notification
router.get('/preferences', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await NotificationController.getPreferences(req, res);
}));

router.put('/preferences', asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
  await NotificationController.updatePreferences(req, res);
}));

export default router; 