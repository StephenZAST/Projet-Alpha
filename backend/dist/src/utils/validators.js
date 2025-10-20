"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateLogin = exports.validateRegistration = exports.ensureValidDate = exports.validateUserStats = exports.validateUUID = exports.validatePhone = exports.validatePassword = exports.validateEmail = void 0;
const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};
exports.validateEmail = validateEmail;
const validatePassword = (password) => {
    return password.length >= 6;
};
exports.validatePassword = validatePassword;
const validatePhone = (phone) => {
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    return phoneRegex.test(phone);
};
exports.validatePhone = validatePhone;
const validateUUID = (uuid) => {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
};
exports.validateUUID = validateUUID;
const validateUserStats = (stats) => {
    return {
        total: Number(stats.total) || 0,
        clientCount: Number(stats.clientCount) || 0,
        affiliateCount: Number(stats.affiliateCount) || 0,
        adminCount: Number(stats.adminCount) || 0,
        activeToday: Number(stats.activeToday) || 0,
        newThisWeek: Number(stats.newThisWeek) || 0,
        byRole: stats.byRole || {}
    };
};
exports.validateUserStats = validateUserStats;
const ensureValidDate = (date) => {
    if (!date)
        return new Date();
    return new Date(date);
};
exports.ensureValidDate = ensureValidDate;
const validateRegistration = (req, res, next) => {
    const { email, password, firstName, lastName, phone } = req.body;
    // Validation des données
    if (!email || !password || !firstName || !lastName) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
    }
    if (!(0, exports.validateEmail)(email)) {
        res.status(400).json({ error: 'Invalid email format' });
        return;
    }
    if (!(0, exports.validatePassword)(password)) {
        res.status(400).json({ error: 'Password must be at least 6 characters' });
        return;
    }
    if (phone && !(0, exports.validatePhone)(phone)) {
        res.status(400).json({ error: 'Invalid phone number format' });
        return;
    }
    next();
};
exports.validateRegistration = validateRegistration;
const validateLogin = (req, res, next) => {
    const { email, password } = req.body;
    // Validation des données
    if (!email || !password) {
        res.status(400).json({ error: 'Email and password are required' });
        return;
    }
    if (!(0, exports.validateEmail)(email)) {
        res.status(400).json({ error: 'Invalid email format' });
        return;
    }
    next();
};
exports.validateLogin = validateLogin;
