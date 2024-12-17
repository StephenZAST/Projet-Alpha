import express, { Router, Request, Response, NextFunction } from 'express';
import { adminLogController } from '../controllers/adminLogController';
import { isAuthenticated } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { searchAdminLogsSchema, getAdminLogByIdSchema, updateAdminLogSchema } from '../validations/schemas/adminLogSchemas';

const router: Router = express.Router();

// Protect all routes
router.use(isAuthenticated as (req: Request, res: Response, next: NextFunction) => void);

// Define route handler functions using async/await
const getLogs = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await adminLogController.getAdminLogs(req, res, next);
  } catch (error) {
    next(error);
  }
};

const getLogById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await adminLogController.getAdminLogById(req, res, next);
  } catch (error) {
    next(error);
  }
};

const createLog = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await adminLogController.createAdminLog(req, res, next);
  } catch (error) {
    next(error);
  }
};

const updateLog = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await adminLogController.updateAdminLog(req, res, next);
  } catch (error) {
    next(error);
  }
};

const deleteLog = async (req: Request, res: Response, next: NextFunction) => {
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
router.put('/:id', validateRequest(updateAdminLogSchema), updateLog);
router.delete('/:id', deleteLog);

export default router;
