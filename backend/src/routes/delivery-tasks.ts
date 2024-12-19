import express from 'express';
import { isAuthenticated } from '../middleware/auth';
import { deliveryTasksService } from '../services/delivery-tasks';
import { UserRole, User } from '../models/user';
import { requireAdminRolePath } from '../middleware/auth';
import { Request, Response, NextFunction } from 'express';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = express.Router();

router.get('/tasks', isAuthenticated, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    const tasks = await deliveryTasksService.getAvailableTasks(req.user.id);
    res.json({ tasks });
  } catch (error) {
    next(error);
  }
});

router.get('/tasks/area', isAuthenticated, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { latitude, longitude, radius } = req.query;
    const tasks = await deliveryTasksService.getTasksByArea(
      { latitude: Number(latitude), longitude: Number(longitude) },
      Number(radius)
    );
    res.json({ tasks });
  } catch (error) {
    next(error);
  }
});

router.patch('/tasks/:taskId/status', isAuthenticated, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    const { status, notes } = req.body;
    const success = await deliveryTasksService.updateTaskStatus(
      req.params.taskId,
      status,
      req.user.id,
      notes
    );

    if (success) {
      res.json({ message: 'Task status updated successfully' });
    } else {
      res.status(400).json({ error: 'Failed to update task status' });
    }
  } catch (error) {
    next(error);
  }
});

router.post(
  '/tasks',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const task = await deliveryTasksService.createDeliveryTask(req.body);
      res.status(201).json(task);
    } catch (error) {
      next(error);
    }
  }
);

router.put(
  '/tasks/:id',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const taskId = req.params.id;
      const updatedTask = await deliveryTasksService.updateDeliveryTask(taskId, req.body);
      res.status(200).json(updatedTask);
    } catch (error) {
      next(error);
    }
  }
);

router.delete(
  '/tasks/:id',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const taskId = req.params.id;
      await deliveryTasksService.deleteDeliveryTask(taskId);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }
);

export default router;
