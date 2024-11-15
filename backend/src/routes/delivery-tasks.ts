import express from 'express';
import { authenticateUser } from '../middleware/auth';
import { requireLivreur as requireDriver } from '../middleware/auth';
import { DeliveryTaskService } from '../services/delivery-tasks';

const router = express.Router();
const taskService = new DeliveryTaskService();

router.get('/tasks', authenticateUser, requireDriver, async (req, res) => {
  try {
    const tasks = await taskService.getAvailableTasks(req.user!.uid);
    res.json({ tasks });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

router.get('/tasks/area', authenticateUser, requireDriver, async (req, res) => {
  try {
    const { latitude, longitude, radius } = req.query;
    const tasks = await taskService.getTasksByArea(
      { latitude: Number(latitude), longitude: Number(longitude) },
      Number(radius)
    );
    res.json({ tasks });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch tasks by area' });
  }
});

router.patch('/tasks/:taskId/status', authenticateUser, requireDriver, async (req, res) => {
  try {
    const { status, notes } = req.body;
    const success = await taskService.updateTaskStatus(
      req.params.taskId,
      status,
      req.user!.uid,
      notes
    );
    
    if (success) {
      res.json({ message: 'Task status updated successfully' });
    } else {
      res.status(400).json({ error: 'Failed to update task status' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to update task status' });
  }
});

export default router;
