"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateOfferValidation = exports.createOfferValidation = void 0;
const express_validator_1 = require("express-validator");
exports.createOfferValidation = [
    (0, express_validator_1.body)('name')
        .trim()
        .notEmpty()
        .withMessage('Name is required')
        .isLength({ max: 255 })
        .withMessage('Name must be less than 255 characters'),
    (0, express_validator_1.body)('description')
        .optional()
        .trim()
        .isLength({ max: 1000 })
        .withMessage('Description must be less than 1000 characters'),
    (0, express_validator_1.body)('discountType')
        .isIn(['PERCENTAGE', 'FIXED_AMOUNT', 'POINTS_EXCHANGE'])
        .withMessage('Invalid discount type'),
    (0, express_validator_1.body)('discountValue')
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
    (0, express_validator_1.body)('minPurchaseAmount')
        .optional()
        .isNumeric()
        .withMessage('Minimum purchase amount must be a number')
        .custom(value => {
        if (value < 0) {
            throw new Error('Minimum purchase amount cannot be negative');
        }
        return true;
    }),
    (0, express_validator_1.body)('maxDiscountAmount')
        .optional()
        .isNumeric()
        .withMessage('Maximum discount amount must be a number')
        .custom(value => {
        if (value < 0) {
            throw new Error('Maximum discount amount cannot be negative');
        }
        return true;
    }),
    (0, express_validator_1.body)('pointsRequired')
        .optional()
        .isInt({ min: 0 })
        .withMessage('Points required must be a positive integer'),
    (0, express_validator_1.body)('isCumulative')
        .optional()
        .isBoolean()
        .withMessage('isCumulative must be a boolean'),
    (0, express_validator_1.body)('startDate')
        .optional()
        .isISO8601()
        .withMessage('Start date must be a valid date'),
    (0, express_validator_1.body)('endDate')
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
exports.updateOfferValidation = [
    ...exports.createOfferValidation,
    (0, express_validator_1.body)().custom(body => {
        if (Object.keys(body).length === 0) {
            throw new Error('At least one field must be provided for update');
        }
        return true;
    })
];
