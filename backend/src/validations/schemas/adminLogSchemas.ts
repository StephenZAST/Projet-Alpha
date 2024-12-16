import Joi from 'joi';

/**
 * Schema for validating the request to get an admin log by ID.
 */
const getAdminLogByIdSchema = Joi.object({
  params: Joi.object({
    id: Joi.string().pattern(/^[0-9a-fA-F]{24}$/).message('Invalid ObjectId format').required(),
  }),
});

/**
 * Schema for validating the search query parameters for admin logs.
 */
const searchAdminLogsSchema = Joi.object({
  query: Joi.object({
    page: Joi.number().integer().min(1).optional(),
    limit: Joi.number().integer().min(1).optional(),
    sortBy: Joi.string().optional(),
    sortOrder: Joi.string().valid('asc', 'desc').optional(),
    searchTerm: Joi.string().optional(),
  }),
});

export { getAdminLogByIdSchema, searchAdminLogsSchema };
