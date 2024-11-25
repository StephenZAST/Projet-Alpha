import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { AdminLogController } from '../controllers/adminLogController';

const router = express.Router();
const adminLogController = new AdminLogController();

// Protect all routes
router.use(isAuthenticated);
router.use(requireAdminRole);

// Define route handler functions using async/await
const getLogs = async (req: express.Request, res: express.Response) => {
  await adminLogController.getLogs(req, res);
};
const getLogById = async (req: express.Request<{ id: string }>, res: express.Response) => {
  await adminLogController.getLogById(req, res);
};
const createLog = async (req: express.Request, res: express.Response) => {
  await adminLogController.createLog(req, res);
};
const updateLog = async (req: express.Request<{ id: string }>, res: express.Response) => {
  await adminLogController.updateLog(req, res);
};
const deleteLog = async (req: express.Request<{ id: string }>, res: express.Response) => {
  await adminLogController.deleteLog(req, res);
};

// Routes using route handler functions
router.get('/', getLogs);
router.get('/:id', getLogById);
router.post('/', createLog);
router.put('/:id', updateLog);
router.delete('/:id', deleteLog);

export default router;
