import express from 'express';
import { isAuthenticated } from '../middleware/auth';
import { NotificationService } from '../services/notifications';
import { User } from '../models/user';
import { Request, Response, NextFunction } from 'express';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = express.Router();
const notificationService = new NotificationService();

router.get('/', isAuthenticated, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    const notifications = await notificationService.getUserNotifications(req.user.id);
    res.json({ notifications });
  } catch (error) {
    next(error);
  }
});

router.patch('/:notificationId/read', isAuthenticated, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    const success = await notificationService.markAsRead(
      req.params.notificationId,
      req.user.id
    );

    if (success) {
      res.json({ message: 'Notification marked as read' });
    } else {
      res.status(400).json({ error: 'Failed to mark notification as read' });
    }
  } catch (error) {
    next(error);
  }
});

export default router;
