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
  unitPrice: z.number().nonnegative('Unit price cannot be negative').optional(),
    isPremium: z.boolean()
  })),
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
    console.log('[FlashOrderValidator] Request body:', JSON.stringify(req.body, null, 2));
    
    // Vérifier que les items sont bien un tableau
    if (!Array.isArray(req.body.items)) {
      console.error('[FlashOrderValidator] Items must be an array');
      return res.status(400).json({
        error: 'Validation failed',
        details: 'Items must be an array'
      });
    }

    // Vérifier le format de chaque item
    req.body.items.forEach((item: { articleId: string; quantity: number; unitPrice: number; isPremium: boolean }, index: number) => {
      console.log(`[FlashOrderValidator] Validating item ${index}:`, item);
    });

    completeFlashOrderSchema.parse(req.body);
    
    // Convertir les dates en format ISO
    if (req.body.collectionDate) {
      req.body.collectionDate = new Date(req.body.collectionDate).toISOString();
    }
    if (req.body.deliveryDate) {
      req.body.deliveryDate = new Date(req.body.deliveryDate).toISOString();
    }

    console.log('[FlashOrderValidator] Validation successful');
    next();
  } catch (error) {
    console.error('[FlashOrderValidator] Validation error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        error: 'Validation failed',
        details: error.errors
      });
    }
    next(error);
  }
};