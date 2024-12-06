import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { AdminLogController } from '../controllers/adminLogController';
import { validateRequest } from '../middleware/validateRequest';
import { searchAdminLogsSchema } from '../validation/adminLogs'; 

const router = express.Router();
const adminLogController = new AdminLogController();

// Protect all routes
router.use(isAuthenticated);
router.use(requireAdminRole);

// Define route handler functions using async/await
const getLogs = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.getLogs(req, res); // Pass only req
  } catch (error) {
    next(error);
  }
};

const getLogById = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.getLogById(req, res); // Pass only req
  } catch (error) {
    next(error);
  }
};

// Routes using route handler functions
router.get('/', validateRequest(searchAdminLogsSchema), getLogs);
router.get('/:id', getLogById);

export default router;
