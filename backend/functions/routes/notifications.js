const express = require('express');
const admin = require('firebase-admin');
const { NotificationService } = require('../../src/services/notifications');

const router = express.Router();
const notificationService = new NotificationService();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// GET /notifications
router.get('/', async (req, res) => {
  try {
    const notifications = await notificationService.getUserNotifications(req.user.uid);
    res.json({ notifications });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// PATCH /notifications/:notificationId/read
router.patch('/:notificationId/read', async (req, res) => {
  try {
    const success = await notificationService.markAsRead(
        req.params.notificationId,
        req.user.uid,
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

module.exports = router;
