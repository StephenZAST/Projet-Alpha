"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateWeightPricing = void 0;
const express_validator_1 = require("express-validator");
exports.validateWeightPricing = {
    calculatePrice: [
        (0, express_validator_1.body)('weight')
            .isFloat({ min: 0 })
            .withMessage('Weight must be a positive number'),
        (0, express_validator_1.body)('service_id') // Changed from serviceId to service_id
            .isUUID()
            .withMessage('Valid service ID is required')
    ],
    createPricing: [
        (0, express_validator_1.body)('service_id') // Changed from serviceId to service_id
            .isUUID()
            .withMessage('Valid service ID is required'),
        (0, express_validator_1.body)('price_per_kg')
            .isFloat({ min: 0 })
            .withMessage('Price per kg must be a positive number'),
        (0, express_validator_1.body)('min_weight')
            .optional()
            .isFloat({ min: 0 })
            .withMessage('Min weight must be a positive number'),
        (0, express_validator_1.body)('max_weight')
            .optional()
            .isFloat({ min: 0 })
            .withMessage('Max weight must be a positive number')
    ]
};
