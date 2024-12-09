import { z } from 'zod';

/**
 * Schema for validating the search query parameters for admin logs.
 */
export const searchAdminLogsSchema = z.object({
  query: z.object({
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).optional(),
    sortBy: z.string().optional(),
    sortOrder: z.enum(['asc', 'desc']).optional(),
    searchTerm: z.string().optional(),
  }),
});
