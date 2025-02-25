import { body } from 'express-validator'; 

export const createOfferValidation = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Name is required')
    .isLength({ max: 255 })
    .withMessage('Name must be less than 255 characters'),

  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must be less than 1000 characters'),

  body('discountType')
    .isIn(['PERCENTAGE', 'FIXED_AMOUNT', 'POINTS_EXCHANGE'])
    .withMessage('Invalid discount type'),

  body('discountValue')
    .isNumeric()
    .withMessage('Discount value must be a number')
    .custom((value, { req }) => {
      if (req.body.discountType === 'PERCENTAGE' && (value < 0 || value > 100)) {
        throw new Error('Percentage discount must be between 0 and 100');
      }
      if (value < 0) {
        throw new Error('Discount value cannot be negative');
      }
      return true;
    }),

  body('minPurchaseAmount')
    .optional()
    .isNumeric()
    .withMessage('Minimum purchase amount must be a number')
    .custom(value => {
      if (value < 0) {
        throw new Error('Minimum purchase amount cannot be negative');
      }
      return true;
    }),

  body('maxDiscountAmount')
    .optional()
    .isNumeric()
    .withMessage('Maximum discount amount must be a number')
    .custom(value => {
      if (value < 0) {
        throw new Error('Maximum discount amount cannot be negative');
      }
      return true;
    }),

  body('pointsRequired')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Points required must be a positive integer'),

  body('isCumulative')
    .optional()
    .isBoolean()
    .withMessage('isCumulative must be a boolean'),

  body('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),

  body('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date')
    .custom((value, { req }) => {
      if (req.body.startDate && new Date(value) <= new Date(req.body.startDate)) {
        throw new Error('End date must be after start date');
      }
      return true;
    })
];

export const updateOfferValidation = [
  ...createOfferValidation,
  body().custom(body => {
    if (Object.keys(body).length === 0) {
      throw new Error('At least one field must be provided for update');
    }
    return true;
  })
];
