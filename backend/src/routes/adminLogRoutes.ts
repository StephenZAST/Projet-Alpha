import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { AdminLogController } from '../controllers/adminLogController';
import { validateRequest } from '../middleware/validateRequest';
import { searchAdminLogsSchema } from '../validation/adminLogs'; // Assuming you have a validation schema for admin logs

const router = express.Router();
const adminLogController = new AdminLogController();

// Protect all routes
router.use(isAuthenticated);
router.use(requireAdminRole);

// Define route handler functions using async/await
const getLogs = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const { adminId, action, startDate, endDate, limit, skip } = req.query;

    const logs = await adminLogController.getLogs({
      adminId: adminId as string,
      action: action as string,
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
      limit: Number(limit) || 50,
      skip: Number(skip) || 0
    });

    res.json(logs);
  } catch (error) {
    next(error);
  }
};

const getLogById = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const log = await adminLogController.getLogById(req.params.id);
    res.json(log);
  } catch (error) {
    next(error);
  }
};

// Routes using route handler functions
router.get('/', validateRequest(searchAdminLogsSchema), getLogs); // Apply validation
router.get('/:id', getLogById);

export default router;
