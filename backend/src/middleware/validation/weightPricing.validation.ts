import { body } from 'express-validator';

export const validateWeightPricing = {
  calculatePrice: [
    body('weight')
      .isFloat({ min: 0 })
      .withMessage('Weight must be a positive number'),
    body('service_id')  // Changed from serviceId to service_id
      .isUUID()
      .withMessage('Valid service ID is required')
  ],
  
  createPricing: [
    body('service_id')  // Changed from serviceId to service_id
      .isUUID()
      .withMessage('Valid service ID is required'),
    body('price_per_kg')
      .isFloat({ min: 0 })
      .withMessage('Price per kg must be a positive number'),
    body('min_weight')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Min weight must be a positive number'),
    body('max_weight')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Max weight must be a positive number')
  ]
};
