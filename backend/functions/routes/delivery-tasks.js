const express = require('express');
const admin = require('firebase-admin');
const { DeliveryTaskService } = require('../../src/services/delivery-tasks');
const { GeoPoint } = require('firebase-admin/firestore');

const router = express.Router();
const taskService = new DeliveryTaskService();

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

// GET /delivery-tasks/tasks
router.get('/tasks', isAuthenticated, async (req, res) => {
  try {
    const tasks = await taskService.getAvailableTasks(req.user.uid);
    res.json({ tasks });
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// GET /delivery-tasks/tasks/area
router.get('/tasks/area', isAuthenticated, async (req, res) => {
  try {
    const { latitude, longitude, radius } = req.query;

    // Validate input data
    if (!latitude || !longitude || !radius) {
      return res.status(400).json({ error: 'Missing required query parameters: latitude, longitude, radius' });
    }

    const tasks = await taskService.getTasksByArea(
        new GeoPoint(Number(latitude), Number(longitude)),
        Number(radius),
    );
    res.json({ tasks });
  } catch (error) {
    console.error('Error fetching tasks by area:', error);
    res.status(500).json({ error: 'Failed to fetch tasks by area' });
  }
});

// PATCH /delivery-tasks/tasks/:taskId/status
router.patch('/tasks/:taskId/status', isAuthenticated, async (req, res) => {
  try {
    const { status, notes } = req.body;

    // Validate input data
    if (!status) {
      return res.status(400).json({ error: 'Missing required field: status' });
    }

    const success = await taskService.updateTaskStatus(
        req.params.taskId,
        status,
        req.user.uid,
        notes,
    );

    if (success) {
      res.json({ message: 'Task status updated successfully' });
    } else {
      res.status(400).json({ error: 'Failed to update task status' });
    }
  } catch (error) {
    console.error('Error updating task status:', error);
    res.status(500).json({ error: 'Failed to update task status' });
  }
});

module.exports = router;
