import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { AdminLogController } from '../controllers/adminLogController';
import { validateRequest } from '../middleware/validateRequest';
import { searchAdminLogsSchema } from '../validation/adminLogs';
import { UserRole } from '../models/user';
import { getAdminLogByIdSchema } from '../validations/schemas/adminLogSchemas';

const router = express.Router();
const adminLogController = new AdminLogController();

// Protect all routes
router.use(isAuthenticated);
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

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
router.get('/:id', validateRequest(getAdminLogByIdSchema), getLogById);

export default router;
