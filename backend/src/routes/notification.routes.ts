import express, { Request, Response, NextFunction } from 'express';
import { NotificationController } from '../controllers/notification.controller';
import { NotificationCleanupService } from '../services/notificationCleanup.service';
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

// 🗑️ Supprimer toutes les notifications lues de l'utilisateur
router.delete('/user/read-notifications', asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.id;
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  
  const deleted = await NotificationCleanupService.deleteReadNotifications(userId);
  res.json({ 
    success: true, 
    message: `${deleted} notifications lues supprimées`,
    deleted 
  });
}));

// 📊 Obtenir les statistiques de notifications
router.get('/stats/overview', asyncHandler(async (req: Request, res: Response) => {
  const stats = await NotificationCleanupService.getNotificationStats();
  res.json({ success: true, data: stats });
}));

// 📊 Obtenir les notifications à supprimer (sans les supprimer)
router.get('/stats/to-delete', asyncHandler(async (req: Request, res: Response) => {
  const toDelete = await NotificationCleanupService.getNotificationsToDelete();
  res.json({ 
    success: true, 
    message: 'Notifications à supprimer',
    data: toDelete 
  });
}));

// 🗑️ Forcer le nettoyage manuel (Admin only)
router.post('/admin/cleanup', asyncHandler(async (req: Request, res: Response) => {
  const userRole = req.user?.role;
  if (userRole !== 'ADMIN' && userRole !== 'SUPER_ADMIN') {
    return res.status(403).json({ error: 'Forbidden - Admin only' });
  }
  
  const result = await NotificationCleanupService.cleanupOldNotifications();
  res.json({ 
    success: true, 
    message: 'Nettoyage manuel exécuté',
    data: result 
  });
}));

// 🧹 Nettoyer les notifications d'un utilisateur spécifique (Admin only)
router.post('/admin/cleanup/:userId', asyncHandler(async (req: Request, res: Response) => {
  const userRole = req.user?.role;
  if (userRole !== 'ADMIN' && userRole !== 'SUPER_ADMIN') {
    return res.status(403).json({ error: 'Forbidden - Admin only' });
  }
  
  const { userId } = req.params;
  const deleted = await NotificationCleanupService.cleanupUserNotifications(userId);
  res.json({ 
    success: true, 
    message: `${deleted} notifications supprimées pour l'utilisateur ${userId}`,
    deleted 
  });
}));

export default router; 