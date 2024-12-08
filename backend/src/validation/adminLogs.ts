import Joi from 'joi';
import { AdminAction } from '../models/adminLog';

export const searchAdminLogsSchema = Joi.object({
  adminId: Joi.string().optional(),
  action: Joi.string().valid(...Object.values(AdminAction)).optional(),
  startDate: Joi.date().optional(),
  endDate: Joi.date().min(Joi.ref('startDate')).optional(),
  limit: Joi.number().integer().min(1).optional(),
  skip: Joi.number().integer().min(0).optional()
});
