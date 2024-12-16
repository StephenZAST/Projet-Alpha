import Joi from 'joi';

/**
 * Schema for validating the search query parameters for admin logs.
 */
export const searchAdminLogsSchema = Joi.object({
  query: Joi.object({
    page: Joi.number().integer().min(1).optional(),
    limit: Joi.number().integer().min(1).optional(),
    sortBy: Joi.string().optional(),
    sortOrder: Joi.string().valid('asc', 'desc').optional(),
    searchTerm: Joi.string().optional(),
  }),
});
