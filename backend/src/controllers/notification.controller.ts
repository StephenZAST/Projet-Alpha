import { Request, Response } from 'express';
import { NotificationService } from '../services/notification.service';

export class NotificationController {
  static async getNotifications(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;

      const result = await NotificationService.getUserNotifications(userId, page, limit);
      res.json(result);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getUnreadCount(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const count = await NotificationService.getUnreadCount(userId);
      res.json({ count });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }  

  static async markAsRead(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const { notificationId } = req.params;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      await NotificationService.markAsRead(userId, notificationId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async markAllAsRead(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      await NotificationService.markAllAsRead(userId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteNotification(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const { notificationId } = req.params;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      await NotificationService.deleteNotification(userId, notificationId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getPreferences(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const preferences = await NotificationService.getNotificationPreferences(userId);
      res.json({ data: preferences });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updatePreferences(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const preferences = await NotificationService.updateNotificationPreferences(
        userId,
        req.body
      );
      res.json({ data: preferences });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
