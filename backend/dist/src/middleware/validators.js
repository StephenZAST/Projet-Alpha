"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateLocation = exports.validateOrder = exports.validateClaimReward = exports.validateNotificationPreferences = exports.validatePointsRedemption = exports.validateAffiliateCreation = exports.validateLogin = exports.validateRegistration = void 0;
const validators_1 = require("../utils/validators");
const zod_1 = require("zod");
// Schémas de validation
const pointsRedemptionSchema = zod_1.z.object({
    points: zod_1.z.number().positive('Points must be positive'),
    rewardId: zod_1.z.string().uuid('Invalid reward ID')
});
const notificationPreferencesSchema = zod_1.z.object({
    emailNotifications: zod_1.z.boolean(),
    pushNotifications: zod_1.z.boolean(),
    types: zod_1.z.array(zod_1.z.enum(['ORDER_STATUS', 'POINTS_EARNED', 'REFERRAL_BONUS', 'PROMOTIONS']))
});
const claimRewardSchema = zod_1.z.object({
    rewardId: zod_1.z.string().uuid('Invalid reward ID')
});
const validateRegistration = (req, res, next) => {
    const { email, password, firstName, lastName } = req.body;
    if (!email || !password || !firstName || !lastName) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
    }
    if (!(0, validators_1.validateEmail)(email)) {
        res.status(400).json({ error: 'Invalid email format' });
        return;
    }
    if (!(0, validators_1.validatePassword)(password)) {
        res.status(400).json({ error: 'Password must be at least 6 characters' });
        return;
    }
    next();
};
exports.validateRegistration = validateRegistration;
const validateLogin = (req, res, next) => {
    const { email, password } = req.body;
    if (!email || !password) {
        res.status(400).json({ error: 'Email and password are required' });
        return;
    }
    if (!(0, validators_1.validateEmail)(email)) {
        res.status(400).json({ error: 'Invalid email format' });
        return;
    }
    next();
};
exports.validateLogin = validateLogin;
const validateAffiliateCreation = (req, res, next) => {
    const { parentAffiliateCode } = req.body;
    if (parentAffiliateCode && typeof parentAffiliateCode !== 'string') {
        return res.status(400).json({ error: 'Invalid affiliate code format' });
    }
    next();
};
exports.validateAffiliateCreation = validateAffiliateCreation;
const validatePointsRedemption = (req, res, next) => {
    try {
        pointsRedemptionSchema.parse(req.body);
        next();
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            res.status(400).json({
                error: 'Validation failed',
                details: error.errors
            });
        }
        else {
            next(error);
        }
    }
};
exports.validatePointsRedemption = validatePointsRedemption;
const validateNotificationPreferences = (req, res, next) => {
    try {
        notificationPreferencesSchema.parse(req.body);
        next();
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            res.status(400).json({
                error: 'Validation failed',
                details: error.errors
            });
        }
        else {
            next(error);
        }
    }
};
exports.validateNotificationPreferences = validateNotificationPreferences;
const validateClaimReward = (req, res, next) => {
    try {
        claimRewardSchema.parse(req.body);
        next();
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            res.status(400).json({
                error: 'Validation failed',
                details: error.errors
            });
        }
        else {
            next(error);
        }
    }
};
exports.validateClaimReward = validateClaimReward;
const validateOrder = (req, res, next) => {
    console.log('Validating order request:', req.body);
    const { serviceId, addressId, items } = req.body;
    if (!serviceId || !addressId || !items || !Array.isArray(items) || items.length === 0) {
        console.log('Validation failed: Missing required fields or invalid items array');
        return res.status(400).json({ error: 'Missing required fields' });
    }
    // Check if each item has articleId and quantity
    for (const item of items) {
        if (!item.articleId || typeof item.quantity !== 'number' || item.quantity <= 0) {
            console.log('Validation failed: Invalid item format', item);
            return res.status(400).json({ error: 'Invalid item format' });
        }
    }
    console.log('Order validation successful');
    next();
};
exports.validateOrder = validateOrder;
const validateLocation = (req, res, next) => {
    const { location } = req.body;
    if (!location || typeof location.latitude !== 'number' || typeof location.longitude !== 'number') {
        return res.status(400).json({ error: 'Invalid location format' });
    }
    if (location.latitude < -90 || location.latitude > 90 ||
        location.longitude < -180 || location.longitude > 180) {
        return res.status(400).json({ error: 'Invalid coordinates' });
    }
    next();
};
exports.validateLocation = validateLocation;
