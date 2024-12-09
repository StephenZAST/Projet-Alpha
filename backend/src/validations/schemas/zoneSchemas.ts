import { z } from 'zod';

// Schema for creating a new zone
export const createZoneSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name is required'),
    coordinates: z.array(z.number()).length(2, 'Coordinates must be an array of two numbers'),
    isActive: z.boolean({
      required_error: 'isActive is required',
    }),
  }),
});

// Schema for getting all zones with optional filters
export const getAllZonesSchema = z.object({
  query: z.object({
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).optional(),
    name: z.string().optional(),
    isActive: z.string().optional(),
    deliveryPersonId: z.string().optional(),
    location: z.any().optional(), // Assuming location is a GeoJSON object, you might need a more specific schema
  }),
});

// Schema for getting a zone by ID
export const getZoneByIdSchema = z.object({
  params: z.object({
    zoneId: z.string().min(1, 'Zone ID is required'),
  }),
});

// Schema for updating a zone
export const updateZoneSchema = z.object({
  body: z.object({
    name: z.string().min(1).optional(),
    coordinates: z.array(z.number()).length(2).optional(),
    isActive: z.boolean().optional(),
  }),
});

// Schema for deleting a zone
export const deleteZoneSchema = z.object({
  params: z.object({
    zoneId: z.string().min(1, 'Zone ID is required'),
  }),
});

// Schema for assigning a delivery person to a zone
export const assignDeliveryPersonSchema = z.object({
  params: z.object({
    zoneId: z.string().min(1, 'Zone ID is required'),
  }),
  body: z.object({
    deliveryPersonId: z.string().min(1, 'Delivery person ID is required'),
  }),
});

// Schema for getting zone statistics
export const getZoneStatsSchema = z.object({
  params: z.object({
    zoneId: z.string().min(1, 'Zone ID is required'),
  }),
  query: z.object({
    startDate: z.string().optional(),
    endDate: z.string().optional(),
  }),
});
