"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AffiliateController = void 0;
const client_1 = require("@prisma/client");
const index_1 = require("../services/affiliate.service/index");
const pagination_1 = require("../utils/pagination");
const constants_1 = require("../services/affiliate.service/constants");
const prisma = new client_1.PrismaClient();
class AffiliateController {
    static getProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                console.log('[AffiliateController] getProfile called for user:', (_a = req.user) === null || _a === void 0 ? void 0 : _a.id);
                const userId = (_b = req.user) === null || _b === void 0 ? void 0 : _b.id;
                if (!userId) {
                    console.log('[AffiliateController] No userId found in request');
                    return res.status(401).json({ error: 'Unauthorized' });
                }
                console.log('[AffiliateController] Fetching profile for userId:', userId);
                const profile = yield index_1.AffiliateService.getProfile(userId);
                if (!profile) {
                    console.log('[AffiliateController] No profile found for userId:', userId);
                    return res.status(404).json({
                        error: 'Profile not found',
                        message: 'No affiliate profile exists for this user. Please create one first.'
                    });
                }
                console.log('[AffiliateController] Profile found, fetching recent transactions');
                // Récupérer les transactions récentes de manière sécurisée
                let recentTransactions = [];
                try {
                    recentTransactions = yield prisma.commission_transactions.findMany({
                        where: { affiliate_id: profile.id },
                        orderBy: { created_at: 'desc' },
                        take: 5,
                        select: {
                            id: true,
                            affiliate_id: true,
                            amount: true,
                            status: true,
                            created_at: true,
                            updated_at: true,
                            order_id: true
                        }
                    });
                    console.log('[AffiliateController] Found', recentTransactions.length, 'recent transactions');
                }
                catch (transactionError) {
                    console.warn('[AffiliateController] Error fetching transactions:', transactionError);
                    // Continue sans les transactions si erreur
                }
                const responseData = Object.assign(Object.assign({}, profile), { transactionsCount: (recentTransactions === null || recentTransactions === void 0 ? void 0 : recentTransactions.length) || 0, recentTransactions: recentTransactions.map(t => (Object.assign(Object.assign({}, t), { amount: Number(t.amount) }))) });
                console.log('[AffiliateController] Sending response with profile data');
                res.json({
                    success: true,
                    data: responseData
                });
            }
            catch (error) {
                console.error('[AffiliateController] getProfile error:', error);
                res.status(500).json({
                    error: error.message || 'Internal server error',
                    details: process.env.NODE_ENV === 'development' ? error.stack : undefined
                });
            }
        });
    }
    static createProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                // Vérifier si l'utilisateur a le rôle AFFILIATE
                if (((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'AFFILIATE') {
                    return res.status(403).json({ error: 'Only users with AFFILIATE role can create affiliate profile' });
                }
                // Vérifier si un profil existe déjà
                const existingProfile = yield index_1.AffiliateService.getProfile(userId);
                if (existingProfile) {
                    return res.status(409).json({ error: 'Affiliate profile already exists' });
                }
                // Créer le profil affilié
                const profile = yield index_1.AffiliateService.createAffiliate({
                    userId: userId,
                    parentAffiliateCode: undefined // Pas de parrain pour l'auto-création
                });
                res.json({
                    success: true,
                    data: profile
                });
            }
            catch (error) {
                console.error('Create profile error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getLevels(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const levels = yield prisma.affiliate_levels.findMany({
                    orderBy: {
                        minEarnings: 'asc'
                    }
                });
                const formattedLevels = levels.map(level => ({
                    id: level.id,
                    name: level.name,
                    minEarnings: Number(level.minEarnings),
                    commissionRate: Number(level.commissionRate),
                    description: `${level.commissionRate}% de commission sur les ventes directes`,
                    createdAt: level.created_at,
                    updatedAt: level.updated_at
                }));
                const additionalInfo = {
                    indirectCommission: {
                        rate: constants_1.INDIRECT_COMMISSION_RATE * 100,
                        description: `${constants_1.INDIRECT_COMMISSION_RATE * 100}% de commission sur les ventes des filleuls directs`
                    },
                    profitMargin: {
                        rate: constants_1.PROFIT_MARGIN_RATE * 100,
                        description: `Le bénéfice net est calculé comme ${constants_1.PROFIT_MARGIN_RATE * 100}% du prix total`
                    }
                };
                res.json({
                    data: {
                        levels: formattedLevels,
                        additionalInfo
                    }
                });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c, _d, _e, _f, _g, _h;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const { phone, notificationPreferences } = req.body;
                const preferences = {
                    email: (_b = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.email) !== null && _b !== void 0 ? _b : true,
                    push: (_c = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.push) !== null && _c !== void 0 ? _c : true,
                    sms: (_d = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.sms) !== null && _d !== void 0 ? _d : false,
                    order_updates: (_e = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.order_updates) !== null && _e !== void 0 ? _e : true,
                    promotions: (_f = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.promotions) !== null && _f !== void 0 ? _f : true,
                    payments: (_g = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.payments) !== null && _g !== void 0 ? _g : true,
                    loyalty: (_h = notificationPreferences === null || notificationPreferences === void 0 ? void 0 : notificationPreferences.loyalty) !== null && _h !== void 0 ? _h : true
                };
                // Mise à jour du profil affilié avec le type correct
                const profile = yield index_1.AffiliateService.updateProfile(userId, {
                    notificationPreferences: preferences
                });
                // Recherche des préférences existantes
                const existingPrefs = yield prisma.notification_preferences.findFirst({
                    where: { userId: userId }
                });
                // Mise à jour ou création des préférences
                if (existingPrefs) {
                    yield prisma.notification_preferences.update({
                        where: { id: existingPrefs.id },
                        data: preferences
                    });
                }
                else {
                    yield prisma.notification_preferences.create({
                        data: Object.assign(Object.assign({}, preferences), { userId: userId })
                    });
                }
                res.json({ success: true, data: profile });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getCommissions(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const { page = 1, limit = 10 } = req.query;
                const commissions = yield index_1.AffiliateService.getCommissions(userId, Number(page), Number(limit));
                res.json({
                    success: true,
                    data: commissions.data.map(c => (Object.assign(Object.assign({}, c), { amount: Number(c.amount) }))),
                    pagination: commissions.pagination
                });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static requestWithdrawal(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const { amount } = req.body;
                if (!amount || amount <= 0) {
                    return res.status(400).json({ error: 'Invalid amount' });
                }
                if (typeof amount !== 'number') {
                    return res.status(400).json({ error: 'Amount must be a number' });
                }
                const profile = yield prisma.affiliate_profiles.findUnique({
                    where: {
                        userId: userId
                    },
                    select: {
                        id: true
                    }
                });
                if (!profile) {
                    return res.status(404).json({ error: 'Affiliate profile not found' });
                }
                const result = yield index_1.AffiliateWithdrawalService.requestWithdrawal(profile.id, amount);
                res.json({
                    data: {
                        id: result.id,
                        amount: Math.abs(result.amount.toNumber()),
                        status: result.status,
                        createdAt: result.created_at
                    }
                });
            }
            catch (error) {
                console.error('Withdrawal request error:', error);
                res.status(error.message.includes('not found') ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
    static getWithdrawals(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                if (((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) !== 'ADMIN' && ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'SUPER_ADMIN') {
                    return res.status(403).json({ error: 'Forbidden' });
                }
                const pagination = (0, pagination_1.validatePaginationParams)(req.query);
                const { status } = req.query;
                const withdrawals = yield index_1.AffiliateWithdrawalService.getWithdrawals(pagination, status);
                res.json(withdrawals);
            }
            catch (error) {
                console.error('Get withdrawals error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getPendingWithdrawals(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                if (((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) !== 'ADMIN' && ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'SUPER_ADMIN') {
                    return res.status(403).json({ error: 'Forbidden' });
                }
                const pagination = (0, pagination_1.validatePaginationParams)(req.query);
                const withdrawals = yield index_1.AffiliateWithdrawalService.getWithdrawals(pagination, 'PENDING');
                res.json(withdrawals);
            }
            catch (error) {
                console.error('Get pending withdrawals error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static rejectWithdrawal(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                if (((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) !== 'ADMIN' && ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'SUPER_ADMIN') {
                    return res.status(403).json({ error: 'Forbidden' });
                }
                const { withdrawalId } = req.params;
                const { reason } = req.body;
                if (!reason) {
                    return res.status(400).json({
                        error: 'Reason is required for rejection'
                    });
                }
                const result = yield index_1.AffiliateWithdrawalService.rejectWithdrawal(withdrawalId, reason);
                res.json({ data: result });
            }
            catch (error) {
                console.error('Reject withdrawal error:', error);
                res.status(error.message.includes('not found') ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
    static approveWithdrawal(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                if (((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) !== 'ADMIN' && ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'SUPER_ADMIN') {
                    return res.status(403).json({ error: 'Forbidden' });
                }
                const { withdrawalId } = req.params;
                const result = yield index_1.AffiliateWithdrawalService.approveWithdrawal(withdrawalId);
                res.json({ data: result });
            }
            catch (error) {
                console.error('Approve withdrawal error:', error);
                res.status(error.message.includes('not found') ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
    static getAllAffiliates(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const pagination = (0, pagination_1.validatePaginationParams)(req.query);
                const { status, query } = req.query;
                const affiliates = yield index_1.AffiliateService.getAllAffiliates(pagination, {
                    status: status,
                    query: query,
                });
                res.json({ data: affiliates });
            }
            catch (error) {
                console.error('Get all affiliates error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAffiliateStats(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                if (((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) !== 'ADMIN' && ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) !== 'SUPER_ADMIN') {
                    return res.status(403).json({ error: 'Forbidden' });
                }
                const stats = yield index_1.AffiliateService.getAffiliateStats();
                res.json({ data: stats });
            }
            catch (error) {
                console.error('Get affiliate stats error:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateAffiliateStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { affiliateId } = req.params;
                const { status, isActive } = req.body;
                if (!status || typeof isActive !== 'boolean') {
                    return res.status(400).json({
                        error: 'Status and isActive are required',
                        required: { status: 'string', isActive: 'boolean' },
                        received: { status, isActive }
                    });
                }
                const result = yield index_1.AffiliateService.updateAffiliateStatus(affiliateId, status, isActive);
                res.json({ data: result });
            }
            catch (error) {
                console.error('Update affiliate status error:', error);
                res.status(error.message.includes('not found') ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
    static generateAffiliateCode(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const affiliateCode = yield index_1.AffiliateService.generateCode(userId);
                res.json({ success: true, data: { affiliateCode } });
            }
            catch (error) {
                // Gestion d'erreur explicite pour code déjà existant
                if (error.message && error.message.includes('already exists')) {
                    return res.status(409).json({ error: 'Affiliate code already exists for this user', code: 'AFFILIATE_CODE_EXISTS' });
                }
                if (error.message && error.message.includes('not found')) {
                    return res.status(404).json({ error: 'Affiliate profile not found', code: 'AFFILIATE_PROFILE_NOT_FOUND' });
                }
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getReferrals(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const referrals = yield index_1.AffiliateService.getReferrals(userId);
                res.json({ data: referrals });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getCurrentLevel(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const level = yield index_1.AffiliateService.getCurrentLevel(userId);
                res.json({ success: true, data: level });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static createCustomerWithAffiliateCode(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { email, password, firstName, lastName, phone, affiliateCode } = req.body;
                if (!affiliateCode || typeof affiliateCode !== 'string' || affiliateCode.includes('+')) {
                    return res.status(400).json({
                        error: 'Invalid affiliate code format',
                        received: affiliateCode,
                        hint: 'Affiliate code should not be a phone number'
                    });
                }
                if (!email || !password || !firstName || !lastName || !affiliateCode) {
                    return res.status(400).json({
                        error: 'Missing required fields',
                        required: ['email', 'password', 'firstName', 'lastName', 'affiliateCode'],
                        received: { email, firstName, lastName, affiliateCode: !!affiliateCode }
                    });
                }
                const result = yield index_1.AffiliateService.createCustomerWithAffiliateCode(email, password, firstName, lastName, affiliateCode, phone);
                res.json({ data: result });
            }
            catch (error) {
                console.error('Create customer error:', error);
                res.status(error.message === 'Affiliate code not found' ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
}
exports.AffiliateController = AffiliateController;
