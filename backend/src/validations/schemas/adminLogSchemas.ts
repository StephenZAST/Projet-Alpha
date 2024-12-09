import { z } from 'zod';

/**
 * Schema for validating the request to get an admin log by ID.
 */
export const getAdminLogByIdSchema = z.object({
  params: z.object({
    id: z.string().refine((value) => {
      // Check if the id is a valid ObjectId (24 hex characters)
      return /^[0-9a-fA-F]{24}$/.test(value);
    }, 'Invalid ObjectId format'),
  }),
});
