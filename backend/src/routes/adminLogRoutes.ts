import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { adminLogController } from '../controllers/adminLogController';
import { validateRequest } from '../middleware/validateRequest';
import { searchAdminLogsSchema, getAdminLogByIdSchema } from '../validations/schemas/adminLogSchemas';
import { UserRole } from '../models/user';

const router = express.Router();

// Protect all routes
router.use(isAuthenticated);
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

// Define route handler functions using async/await
const getLogs = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.getAdminLogs(req, res, next);
  } catch (error) {
    next(error);
  }
};

const getLogById = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.getAdminLogById(req, res, next);
  } catch (error) {
    next(error);
  }
};

const createLog = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.createAdminLog(req, res, next);
  } catch (error) {
    next(error);
  }
};

const updateLog = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.updateAdminLog(req, res, next);
  } catch (error) {
    next(error);
  }
};

const deleteLog = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    await adminLogController.deleteAdminLog(req, res, next);
  } catch (error) {
    next(error);
  }
};

// Routes using route handler functions
router.get('/', validateRequest(searchAdminLogsSchema), getLogs);
router.get('/:id', validateRequest(getAdminLogByIdSchema), getLogById);
router.post('/', createLog);
router.put('/:id', updateLog);
router.delete('/:id', deleteLog);

export default router;
