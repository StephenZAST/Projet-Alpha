import { createAdminLog } from './createAdminLog';
import { getAdminLogs } from './getAdminLogs';
import { getAdminLogById } from './getAdminLogById';
import { updateAdminLog } from './updateAdminLog';
import { deleteAdminLog } from './deleteAdminLog';

export {
  createAdminLog,
  getAdminLogs,
  getAdminLogById,
  updateAdminLog,
  deleteAdminLog
};

export const adminLogController = {
  createAdminLog,
  getAdminLogs,
  getAdminLogById,
  updateAdminLog,
  deleteAdminLog
};
