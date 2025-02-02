import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';

// Schéma pour la création d'une commande flash
const createFlashOrderSchema = z.object({
  addressId: z.string().uuid('Invalid address ID'),
  notes: z.string().optional()
});

// Schéma pour la complétion d'une commande flash par l'admin
const completeFlashOrderSchema = z.object({
  serviceId: z.string().uuid('Invalid service ID'),
  items: z.array(z.object({
    articleId: z.string().uuid('Invalid article ID'),
    quantity: z.number().positive('Quantity must be positive'),
    unitPrice: z.number().nonnegative('Unit price cannot be negative')
  })),
  serviceTypeId: z.string().uuid('Invalid service type ID').optional(),
  collectionDate: z.string().datetime().optional(),
  deliveryDate: z.string().datetime().optional()
});

export const validateCreateFlashOrder = (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log('[FlashOrderValidator] Validating create flash order request:', req.body);
    createFlashOrderSchema.parse(req.body);
    console.log('[FlashOrderValidator] Validation successful');
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('[FlashOrderValidator] Validation failed:', error.errors);
      return res.status(400).json({
        error: 'Validation failed',
        details: error.errors
      });
    }
    next(error);
  }
};

export const validateCompleteFlashOrder = (req: Request, res: Response, next: NextFunction) => {
  try {
    console.log('[FlashOrderValidator] Validating complete flash order request:', req.body);
    completeFlashOrderSchema.parse(req.body);
    console.log('[FlashOrderValidator] Validation successful');
    next();
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('[FlashOrderValidator] Validation failed:', error.errors);
      return res.status(400).json({
        error: 'Validation failed',
        details: error.errors
      });
    }
    next(error);
  }
};