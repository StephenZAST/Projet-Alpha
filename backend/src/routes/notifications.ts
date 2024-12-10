import express from 'express';
import { isAuthenticated } from '../middleware/auth';
import { NotificationService } from '../services/notifications';

const router = express.Router();
const notificationService = new NotificationService();

router.get('/', isAuthenticated, async (req, res) => {
  try {
    const notifications = await notificationService.getUserNotifications(req.user!.uid);
    res.json({ notifications });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

router.patch('/:notificationId/read', isAuthenticated, async (req, res) => {
  try {
    const success = await notificationService.markAsRead(
      req.params.notificationId,
      req.user!.uid
    );
    
    if (success) {
      res.json({ message: 'Notification marked as read' });
    } else {
      res.status(400).json({ error: 'Failed to mark notification as read' });
    }
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
