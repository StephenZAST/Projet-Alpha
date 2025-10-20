"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateCompleteFlashOrder = exports.validateCreateFlashOrder = void 0;
const zod_1 = require("zod");
// Schéma pour la création d'une commande flash
const createFlashOrderSchema = zod_1.z.object({
    addressId: zod_1.z.string().uuid('Invalid address ID'),
    notes: zod_1.z.string().optional()
});
// Schéma pour la complétion d'une commande flash par l'admin
const completeFlashOrderSchema = zod_1.z.object({
    serviceId: zod_1.z.string().uuid('Invalid service ID'),
    items: zod_1.z.array(zod_1.z.object({
        articleId: zod_1.z.string().uuid('Invalid article ID'),
        quantity: zod_1.z.number().positive('Quantity must be positive'),
        unitPrice: zod_1.z.number().nonnegative('Unit price cannot be negative').optional(),
        isPremium: zod_1.z.boolean()
    })),
    collectionDate: zod_1.z.string().datetime().optional(),
    deliveryDate: zod_1.z.string().datetime().optional()
});
const validateCreateFlashOrder = (req, res, next) => {
    try {
        console.log('[FlashOrderValidator] Validating create flash order request:', req.body);
        createFlashOrderSchema.parse(req.body);
        console.log('[FlashOrderValidator] Validation successful');
        next();
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            console.error('[FlashOrderValidator] Validation failed:', error.errors);
            return res.status(400).json({
                error: 'Validation failed',
                details: error.errors
            });
        }
        next(error);
    }
};
exports.validateCreateFlashOrder = validateCreateFlashOrder;
const validateCompleteFlashOrder = (req, res, next) => {
    try {
        console.log('[FlashOrderValidator] Request body:', JSON.stringify(req.body, null, 2));
        // Log type et valeur des dates
        console.log('[FlashOrderValidator] Type collectionDate:', typeof req.body.collectionDate, req.body.collectionDate);
        console.log('[FlashOrderValidator] Type deliveryDate:', typeof req.body.deliveryDate, req.body.deliveryDate);
        // Vérifier que les items sont bien un tableau
        if (!Array.isArray(req.body.items)) {
            console.error('[FlashOrderValidator] Items must be an array');
            return res.status(400).json({
                error: 'Validation failed',
                details: 'Items must be an array'
            });
        }
        // Vérifier le format de chaque item
        req.body.items.forEach((item, index) => {
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
    }
    catch (error) {
        console.error('[FlashOrderValidator] Validation error:', error);
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                error: 'Validation failed',
                details: error.errors
            });
        }
        next(error);
    }
};
exports.validateCompleteFlashOrder = validateCompleteFlashOrder;
