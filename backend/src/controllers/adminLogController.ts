import { createAdminLog } from './adminLogController/createAdminLog';
import { getAdminLogs } from './adminLogController/getAdminLogs';
import { getAdminLogById } from './adminLogController/getAdminLogById';
import { updateAdminLog } from './adminLogController/updateAdminLog';
import { deleteAdminLog } from './adminLogController/deleteAdminLog';

export const adminLogController = {
  createAdminLog,
  getAdminLogs,
  getAdminLogById,
  updateAdminLog,
  deleteAdminLog
};
