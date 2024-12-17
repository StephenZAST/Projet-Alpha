import * as Joi from 'joi';

export const searchAdminLogsSchema = Joi.object({
  // existing schema
});

export const getAdminLogByIdSchema = Joi.object({
  // existing schema
});

export const updateAdminLogSchema = Joi.object({
  action: Joi.string().required(),
  description: Joi.string().required(),
});
