"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const client_1 = require("@prisma/client"); // Ajout de l'import Prisma
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const email_service_1 = require("./email.service");
const uuid_1 = require("uuid");
const jwt = __importStar(require("jsonwebtoken"));
const JWT_SECRET = process.env.JWT_SECRET;
const blacklistedTokens = new Set();
const prisma = new client_1.PrismaClient();
class AuthService {
    static register(email_1, password_1, firstName_1, lastName_1, phone_1, affiliateCode_1) {
        return __awaiter(this, arguments, void 0, function* (email, password, firstName, lastName, phone, affiliateCode, role = 'CLIENT') {
            try {
                // Création simple de l'utilisateur, le trigger s'occupera des loyalty_points
                const user = yield prisma.users.create({
                    data: {
                        id: (0, uuid_1.v4)(),
                        email,
                        password: yield bcryptjs_1.default.hash(password, 10),
                        first_name: firstName,
                        last_name: lastName,
                        phone,
                        role: role,
                        referral_code: affiliateCode,
                        created_at: new Date(),
                        updated_at: new Date(),
                        // Créer uniquement les préférences de notification
                        notification_preferences: {
                            create: {
                                id: (0, uuid_1.v4)(),
                                email: true,
                                push: true,
                                sms: false,
                                order_updates: true,
                                promotions: true,
                                payments: true,
                                loyalty: true,
                                created_at: new Date(),
                                updated_at: new Date()
                            }
                        }
                    }
                });
                return {
                    id: user.id,
                    email: user.email,
                    password: user.password,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    phone: user.phone || undefined,
                    role: user.role || 'CLIENT',
                    referralCode: user.referral_code || undefined,
                    createdAt: user.created_at || new Date(),
                    updatedAt: user.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('Register error:', error);
                if (error instanceof client_1.Prisma.PrismaClientKnownRequestError) {
                    console.error('Prisma error details:', {
                        code: error.code,
                        meta: error.meta,
                        message: error.message
                    });
                }
                throw error;
            }
        });
    }
    static login(email, password) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findFirst({
                where: { email }
            });
            if (!user) {
                throw new Error('Invalid email or password');
            }
            const isPasswordValid = yield bcryptjs_1.default.compare(password, user.password);
            if (!isPasswordValid) {
                throw new Error('Invalid email or password');
            }
            const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, {
                expiresIn: '168h',
            });
            return {
                user: {
                    id: user.id,
                    email: user.email,
                    password: user.password,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    phone: user.phone || undefined,
                    role: user.role || 'CLIENT',
                    referralCode: user.referral_code || undefined,
                    createdAt: user.created_at || new Date(),
                    updatedAt: user.updated_at || new Date()
                },
                token
            };
        });
    }
    static invalidateToken(token) {
        return __awaiter(this, void 0, void 0, function* () {
            blacklistedTokens.add(token);
        });
    }
    static isTokenBlacklisted(token) {
        return blacklistedTokens.has(token);
    }
    static getCurrentUser(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findUnique({
                where: { id: userId },
                include: {
                    addresses: true
                }
            });
            if (!user)
                throw new Error('User not found');
            return user;
        });
    }
    static createAffiliate(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.update({
                where: { id: userId },
                data: { role: 'AFFILIATE' }
            });
            const affiliateCode = Math.random().toString(36).substr(2, 9).toUpperCase();
            try {
                yield prisma.affiliate_profiles.create({
                    data: {
                        userId: userId,
                        affiliate_code: affiliateCode,
                        parent_affiliate_id: null,
                        commission_balance: 0,
                        total_earned: 0,
                        monthly_earnings: 0,
                        total_referrals: 0,
                        commission_rate: 10.00,
                        status: 'PENDING',
                        is_active: true,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                yield prisma.users.update({
                    where: { id: userId },
                    data: { role: 'CLIENT' }
                });
                throw error;
            }
            return {
                id: user.id,
                email: user.email,
                password: user.password,
                firstName: user.first_name,
                lastName: user.last_name,
                phone: user.phone || undefined,
                role: user.role || 'CLIENT',
                referralCode: user.referral_code || undefined,
                createdAt: user.created_at || new Date(),
                updatedAt: user.updated_at || new Date()
            };
        });
    }
    static createAdmin(email, password, firstName, lastName, phone) {
        return __awaiter(this, void 0, void 0, function* () {
            const hashedPassword = yield bcryptjs_1.default.hash(password, 10);
            const dbUser = {
                id: (0, uuid_1.v4)(),
                email,
                password: hashedPassword,
                first_name: firstName,
                last_name: lastName,
                phone,
                role: 'ADMIN',
                created_at: new Date(),
                updated_at: new Date()
            };
            const data = yield prisma.users.create({
                data: {
                    id: dbUser.id,
                    email: dbUser.email,
                    password: dbUser.password,
                    first_name: dbUser.first_name,
                    last_name: dbUser.last_name,
                    phone: dbUser.phone,
                    role: dbUser.role,
                    created_at: dbUser.created_at,
                    updated_at: dbUser.updated_at
                }
            });
            return {
                id: data.id,
                email: data.email,
                password: data.password,
                firstName: data.first_name,
                lastName: data.last_name,
                phone: data.phone,
                role: data.role,
                createdAt: data.created_at,
                updatedAt: data.updated_at
            };
        });
    }
    static updateProfile(userId, email, firstName, lastName, phone) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.users.update({
                where: { id: userId },
                data: { email, first_name: firstName, last_name: lastName, phone, updated_at: new Date() }
            });
            return {
                id: data.id,
                email: data.email,
                password: data.password,
                firstName: data.first_name,
                lastName: data.last_name,
                phone: data.phone || undefined,
                role: data.role || 'CLIENT',
                referralCode: data.referral_code || undefined,
                createdAt: data.created_at || new Date(),
                updatedAt: data.updated_at || new Date()
            };
        });
    }
    static changePassword(userId, currentPassword, newPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findUnique({
                where: { id: userId }
            });
            if (!user)
                throw new Error('User not found');
            const isPasswordValid = yield bcryptjs_1.default.compare(currentPassword, user.password);
            if (!isPasswordValid) {
                throw new Error('Invalid current password');
            }
            const hashedNewPassword = yield bcryptjs_1.default.hash(newPassword, 10);
            const data = yield prisma.users.update({
                where: { id: userId },
                data: { password: hashedNewPassword, updated_at: new Date() }
            });
            return {
                id: data.id,
                email: data.email,
                password: data.password,
                firstName: data.first_name,
                lastName: data.last_name,
                phone: data.phone || undefined,
                role: data.role || 'CLIENT',
                referralCode: data.referral_code || undefined,
                createdAt: data.created_at || new Date(),
                updatedAt: data.updated_at || new Date()
            };
        });
    }
    static deleteAccount(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.users.delete({
                where: { id: userId }
            });
        });
    }
    static deleteUser(targetUserId, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findUnique({
                where: { id: targetUserId }
            });
            if (!user)
                throw new Error('User not found');
            if (user.role === 'SUPER_ADMIN' && userId !== targetUserId) {
                throw new Error('Super Admin can only delete their own account');
            }
            // Supprimer les préférences de notification liées à l'utilisateur
            yield prisma.notification_preferences.deleteMany({
                where: { userId: targetUserId }
            });
            // Ajouter ici d'autres suppressions de dépendances si besoin (adresses, commandes, etc.)
            yield prisma.users.delete({
                where: { id: targetUserId }
            });
        });
    }
    static updateUser(targetUserId, email, firstName, lastName, phone, role, currentUser) {
        return __awaiter(this, void 0, void 0, function* () {
            // Vérification des permissions pour la modification du rôle
            if (role) {
                if (!currentUser) {
                    throw new Error('Permission denied: utilisateur non authentifié');
                }
                // Récupérer l'utilisateur cible
                const targetUser = yield prisma.users.findUnique({ where: { id: targetUserId } });
                if (!targetUser)
                    throw new Error('User not found');
                const targetRole = targetUser.role;
                const currentRole = currentUser.role;
                // Seul un SUPER_ADMIN peut modifier le rôle d'un SUPER_ADMIN
                if (targetRole === 'SUPER_ADMIN' && currentRole !== 'SUPER_ADMIN') {
                    throw new Error('Permission denied: seul un SUPER_ADMIN peut modifier un SUPER_ADMIN');
                }
                // Un ADMIN ne peut pas modifier le rôle d'un autre ADMIN
                if (targetRole === 'ADMIN' && currentRole !== 'SUPER_ADMIN') {
                    throw new Error('Permission denied: seul un SUPER_ADMIN peut modifier un ADMIN');
                }
                // Seuls ADMIN et SUPER_ADMIN peuvent modifier les rôles
                if (!['ADMIN', 'SUPER_ADMIN'].includes(currentRole)) {
                    throw new Error('Permission denied: seuls les ADMIN ou SUPER_ADMIN peuvent modifier les rôles');
                }
            }
            const data = yield prisma.users.update({
                where: { id: targetUserId },
                data: { email, first_name: firstName, last_name: lastName, phone, role: role, updated_at: new Date() }
            });
            return {
                id: data.id,
                email: data.email,
                password: data.password,
                firstName: data.first_name,
                lastName: data.last_name,
                phone: data.phone || undefined,
                role: data.role || 'CLIENT',
                referralCode: data.referral_code || undefined,
                createdAt: data.created_at || new Date(),
                updatedAt: data.updated_at || new Date()
            };
        });
    }
    static registerAffiliate(email, password, firstName, lastName, phone, parentAffiliateCode) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const user = yield prisma.users.create({
                    data: {
                        id: (0, uuid_1.v4)(),
                        email,
                        password: yield bcryptjs_1.default.hash(password, 10),
                        first_name: firstName,
                        last_name: lastName,
                        phone,
                        role: 'AFFILIATE',
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                const affiliateCode = Math.random().toString(36).substr(2, 9).toUpperCase();
                const affiliateProfile = yield prisma.affiliate_profiles.create({
                    data: {
                        userId: user.id,
                        affiliate_code: affiliateCode,
                        parent_affiliate_id: null,
                        commission_balance: 0,
                        total_earned: 0
                    }
                });
                const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '168h' });
                return {
                    user: {
                        id: user.id,
                        email: user.email,
                        password: user.password,
                        firstName: user.first_name,
                        lastName: user.last_name,
                        phone: user.phone || undefined,
                        role: user.role || 'CLIENT',
                        referralCode: user.referral_code || undefined,
                        createdAt: user.created_at || new Date(),
                        updatedAt: user.updated_at || new Date()
                    },
                    token,
                    affiliateProfile: {
                        id: affiliateProfile.id,
                        userId: affiliateProfile.userId,
                        affiliateCode: affiliateProfile.affiliate_code,
                        commission_rate: Number(affiliateProfile.commission_rate || 10),
                        commissionBalance: Number(affiliateProfile.commission_balance || 0),
                        totalEarned: Number(affiliateProfile.total_earned || 0),
                        status: affiliateProfile.status || 'PENDING',
                        isActive: affiliateProfile.is_active || true,
                        totalReferrals: affiliateProfile.total_referrals || 0,
                        monthlyEarnings: Number(affiliateProfile.monthly_earnings || 0),
                        levelId: (_a = affiliateProfile.level_id) !== null && _a !== void 0 ? _a : undefined,
                        createdAt: affiliateProfile.created_at || new Date(),
                        updatedAt: affiliateProfile.updated_at || new Date()
                    }
                };
            }
            catch (error) {
                throw error;
            }
        });
    }
    static resetPassword(email) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const user = yield prisma.users.findFirst({
                    where: { email }
                });
                if (!user) {
                    throw new Error('User not found');
                }
                const code = this.generateVerificationCode();
                const expirationTime = new Date(Date.now() + 15 * 60 * 1000);
                yield prisma.reset_codes.create({
                    data: {
                        userId: user.id,
                        email: email,
                        code: code,
                        expires_at: expirationTime,
                        used: false,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                try {
                    yield (0, email_service_1.sendEmail)(email, code);
                    console.log('Reset code email sent successfully to:', email);
                }
                catch (emailError) {
                    console.error('Email sending error:', emailError);
                    throw new Error('Failed to send reset code email');
                }
            }
            catch (error) {
                console.error('Reset password process error:', error);
                throw error;
            }
        });
    }
    static generateVerificationCode() {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }
    static storeVerificationCode(email, code) {
        return __awaiter(this, void 0, void 0, function* () {
            const expirationTime = new Date();
            expirationTime.setMinutes(expirationTime.getMinutes() + 15);
            const user = yield prisma.users.findFirst({
                where: { email }
            });
            if (!user) {
                throw new Error('User not found');
            }
            const data = yield prisma.reset_codes.create({
                data: {
                    userId: user.id,
                    email,
                    code,
                    expires_at: expirationTime,
                    used: false
                }
            });
            return { data };
        });
    }
    static sendVerificationEmail(email, code) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, email_service_1.sendEmail)(email, code);
                return true;
            }
            catch (error) {
                console.error('Error sending email:', error);
                throw new Error('Failed to send verification email');
            }
        });
    }
    static validateResetCode(email, code) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const resetCode = yield prisma.reset_codes.findFirst({
                    where: {
                        email,
                        code,
                        used: false,
                        expires_at: {
                            gt: new Date()
                        }
                    },
                    orderBy: {
                        created_at: 'desc'
                    }
                });
                if (!resetCode) {
                    return false;
                }
                return true;
            }
            catch (error) {
                console.error('Reset code validation error:', error);
                return false;
            }
        });
    }
    static verifyCodeAndResetPassword(email, code, newPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const resetCode = yield prisma.reset_codes.findFirst({
                    where: {
                        email,
                        code,
                        used: false,
                        expires_at: {
                            gt: new Date()
                        }
                    }
                });
                if (!resetCode) {
                    throw new Error('Invalid or expired reset code');
                }
                const hashedPassword = yield bcryptjs_1.default.hash(newPassword, 10);
                yield prisma.users.findFirst({
                    where: { email }
                }).then(user => {
                    if (!user)
                        throw new Error('User not found');
                    return prisma.users.update({
                        where: { id: user.id },
                        data: {
                            password: hashedPassword,
                            updated_at: new Date()
                        }
                    });
                });
                const testVerification = yield bcryptjs_1.default.compare(newPassword, hashedPassword);
                if (!testVerification) {
                    throw new Error('Password verification failed');
                }
                yield prisma.reset_codes.update({
                    where: { id: resetCode.id },
                    data: {
                        used: true,
                        updated_at: new Date()
                    }
                });
                console.log('Password reset completed successfully');
            }
            catch (error) {
                console.error('Password reset failed:', error);
                throw error;
            }
        });
    }
    static getAllUsers() {
        return __awaiter(this, arguments, void 0, function* ({ page = 1, limit = 10, filters = {} } = {}) {
            try {
                // Limiter le nombre d'éléments par page à 100 max
                const safeLimit = Math.min(Math.max(limit, 1), 100);
                // Compter le nombre total d'utilisateurs correspondant aux filtres
                const where = {};
                if (filters.role) {
                    where.role = filters.role.toUpperCase();
                }
                if (filters.searchQuery) {
                    where.OR = [
                        { first_name: { contains: filters.searchQuery, mode: 'insensitive' } },
                        { last_name: { contains: filters.searchQuery, mode: 'insensitive' } },
                        { email: { contains: filters.searchQuery, mode: 'insensitive' } },
                    ];
                }
                if (filters.startDate) {
                    where.created_at = Object.assign(Object.assign({}, (where.created_at || {})), { gte: filters.startDate });
                }
                if (filters.endDate) {
                    where.created_at = Object.assign(Object.assign({}, (where.created_at || {})), { lte: filters.endDate });
                }
                const count = yield prisma.users.count({ where });
                const totalPages = Math.max(1, Math.ceil(count / safeLimit));
                // Corriger la page demandée si hors plage
                const safePage = Math.max(1, Math.min(page, totalPages));
                const skip = (safePage - 1) * safeLimit;
                const data = count === 0 ? [] : yield prisma.users.findMany({
                    where,
                    skip,
                    take: safeLimit,
                    orderBy: { created_at: 'desc' },
                });
                // Logging détaillé
                console.log('[getAllUsers] page:', safePage, 'limit:', safeLimit, 'total:', count, 'totalPages:', totalPages, 'filters:', filters);
                return {
                    data: data.map(user => ({
                        id: user.id,
                        email: user.email,
                        firstName: user.first_name,
                        lastName: user.last_name,
                        phone: user.phone,
                        role: user.role,
                        password: user.password,
                        createdAt: user.created_at,
                        updatedAt: user.updated_at
                    })),
                    pagination: {
                        total: count,
                        page: safePage,
                        limit: safeLimit,
                        totalPages: totalPages
                    }
                };
            }
            catch (error) {
                console.error('Error in getAllUsers:', error);
                throw error;
            }
        });
    }
    static getUserStats() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const rawStats = yield prisma.users.findMany({
                    select: {
                        role: true
                    }
                });
                const stats = {
                    total: 0,
                    clientCount: 0,
                    affiliateCount: 0,
                    adminCount: 0,
                    activeToday: 0,
                    newThisWeek: 0,
                    byRole: {}
                };
                rawStats.forEach((user) => {
                    stats.total++;
                    const role = user.role.toLowerCase();
                    stats.byRole[role] = (stats.byRole[role] || 0) + 1;
                    switch (user.role) {
                        case 'CLIENT':
                            stats.clientCount++;
                            break;
                        case 'AFFILIATE':
                            stats.affiliateCount++;
                            break;
                        case 'ADMIN':
                        case 'SUPER_ADMIN':
                            stats.adminCount++;
                            break;
                    }
                });
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const weekAgo = new Date(today);
                weekAgo.setDate(weekAgo.getDate() - 7);
                const activeCount = yield prisma.users.count({
                    where: {
                        created_at: {
                            gte: today
                        }
                    }
                });
                const newUsersCount = yield prisma.users.count({
                    where: {
                        created_at: {
                            gte: weekAgo
                        }
                    }
                });
                stats.activeToday = activeCount;
                stats.newThisWeek = newUsersCount;
                return stats;
            }
            catch (error) {
                console.error('Error in getUserStats:', error);
                throw error;
            }
        });
    }
    static getUserNotifications(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.notifications.findMany({
                where: { userId: userId },
                orderBy: {
                    created_at: 'desc'
                }
            });
            return data;
        });
    }
    static updateNotificationPreferences(userId, preferences) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c, _d, _e, _f, _g, _h;
            const existingPrefs = yield prisma.notification_preferences.findFirst({
                where: { userId: userId }
            });
            yield prisma.notification_preferences.upsert({
                where: { id: (_a = existingPrefs === null || existingPrefs === void 0 ? void 0 : existingPrefs.id) !== null && _a !== void 0 ? _a : (0, uuid_1.v4)() },
                update: {
                    email: preferences.email,
                    push: preferences.push,
                    sms: preferences.sms,
                    order_updates: preferences.orderUpdates,
                    promotions: preferences.promotions,
                    payments: preferences.payments,
                    loyalty: preferences.loyalty,
                    updated_at: new Date()
                },
                create: {
                    id: (0, uuid_1.v4)(),
                    userId: userId,
                    email: (_b = preferences.email) !== null && _b !== void 0 ? _b : true,
                    push: (_c = preferences.push) !== null && _c !== void 0 ? _c : true,
                    sms: (_d = preferences.sms) !== null && _d !== void 0 ? _d : false,
                    order_updates: (_e = preferences.orderUpdates) !== null && _e !== void 0 ? _e : true,
                    promotions: (_f = preferences.promotions) !== null && _f !== void 0 ? _f : true,
                    payments: (_g = preferences.payments) !== null && _g !== void 0 ? _g : true,
                    loyalty: (_h = preferences.loyalty) !== null && _h !== void 0 ? _h : true,
                    updated_at: new Date()
                }
            });
            return true;
        });
    }
    static getUserAddresses(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.addresses.findMany({
                where: { userId: userId }
            });
            return data;
        });
    }
    static getUserLoyaltyPoints(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.loyalty_points.findUnique({
                where: { userId: userId }
            });
            return data;
        });
    }
    static logUserActivity(activity) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Utilisation de $executeRaw pour une insertion directe
                yield prisma.$executeRaw `
            INSERT INTO user_activity_logs (
                id, 
                userId, 
                action, 
                details, 
                ip_address, 
                user_agent, 
                created_at
            ) VALUES (
                ${(0, uuid_1.v4)()}, 
                ${activity.userId}, 
                ${activity.action}, 
                ${activity.details || {}}, 
                ${activity.ipAddress}, 
                ${activity.userAgent}, 
                ${new Date()}
            )
        `;
            }
            catch (error) {
                console.error('Error logging user activity:', error);
                // Log l'erreur mais ne la propage pas pour ne pas interrompre le flux principal
                console.log('Activity details:', activity);
            }
        });
    }
    // Nouvelle méthode spécifique pour la création d'utilisateur par l'admin
    static createUserByAdmin(adminId, userData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Vérifier que l'admin existe
                const admin = yield prisma.users.findUnique({
                    where: { id: adminId }
                });
                if (!admin || (admin.role !== 'ADMIN' && admin.role !== 'SUPER_ADMIN')) {
                    throw new Error('Unauthorized admin access');
                }
                // Vérifier si l'email existe déjà
                const existingUser = yield prisma.users.findFirst({
                    where: { email: userData.email }
                });
                if (existingUser) {
                    throw new Error('Email already exists');
                }
                // Hasher le mot de passe
                const hashedPassword = yield bcryptjs_1.default.hash(userData.password, 10);
                // Créer l'utilisateur avec transaction
                return yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                    const user = yield tx.users.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            email: userData.email,
                            password: hashedPassword,
                            first_name: userData.first_name,
                            last_name: userData.last_name,
                            phone: userData.phone,
                            role: 'CLIENT',
                            created_at: new Date(),
                            updated_at: new Date()
                        }
                    });
                    yield tx.loyalty_points.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            pointsBalance: 0,
                            totalEarned: 0,
                            createdAt: new Date(),
                            updatedAt: new Date(),
                            users: {
                                connect: {
                                    id: user.id
                                }
                            }
                        }
                    });
                    yield tx.notification_preferences.create({
                        data: {
                            id: (0, uuid_1.v4)(),
                            email: true,
                            push: true,
                            sms: false,
                            order_updates: true,
                            promotions: true,
                            payments: true,
                            loyalty: true,
                            created_at: new Date(),
                            updated_at: new Date(),
                            users: {
                                connect: {
                                    id: user.id
                                }
                            }
                        }
                    });
                    return user;
                }));
            }
            catch (error) {
                console.error('[AuthService] Create user by admin error:', error);
                throw error;
            }
        });
    }
    static adminResetUserPassword(userId, newPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findUnique({ where: { id: userId } });
            if (!user)
                throw new Error('User not found');
            const hashedPassword = yield bcryptjs_1.default.hash(newPassword, 10);
            const updated = yield prisma.users.update({
                where: { id: userId },
                data: { password: hashedPassword, updated_at: new Date() }
            });
            return {
                id: updated.id,
                email: updated.email,
                password: updated.password,
                firstName: updated.first_name,
                lastName: updated.last_name,
                phone: updated.phone || undefined,
                role: updated.role || 'CLIENT',
                referralCode: updated.referral_code || undefined,
                createdAt: updated.created_at || new Date(),
                updatedAt: updated.updated_at || new Date()
            };
        });
    }
    /**
     * Recherche paginée et filtrée d'utilisateurs par rôle, recherche, etc.
     * @param params { role, query, filter, page, limit }
     * @returns { data, pagination }
     */
    static searchUsers(_a) {
        return __awaiter(this, arguments, void 0, function* ({ role = 'all', query = '', filter = 'all', page = 1, limit = 10 }) {
            // Sécuriser les paramètres
            const safeLimit = Math.max(1, Math.min(limit, 100));
            let safePage = Math.max(1, page);
            const where = {};
            // Filtrage par rôle (CLIENT, AFFILIATE, ADMIN, LIVREUR, ALL)
            if (role && role.toUpperCase() !== 'ALL') {
                where.role = role.toUpperCase();
            }
            // Recherche par champ
            const search = query.trim();
            if (search) {
                switch (filter) {
                    case 'name':
                        where.OR = [
                            { first_name: { contains: search, mode: 'insensitive' } },
                            { last_name: { contains: search, mode: 'insensitive' } }
                        ];
                        break;
                    case 'email':
                        where.email = { contains: search, mode: 'insensitive' };
                        break;
                    case 'phone':
                        where.phone = { contains: search, mode: 'insensitive' };
                        break;
                    case 'all':
                    default:
                        where.OR = [
                            { first_name: { contains: search, mode: 'insensitive' } },
                            { last_name: { contains: search, mode: 'insensitive' } },
                            { email: { contains: search, mode: 'insensitive' } },
                            { phone: { contains: search, mode: 'insensitive' } }
                        ];
                        break;
                }
            }
            // Compter le total filtré
            const total = yield prisma.users.count({ where });
            const totalPages = Math.max(1, Math.ceil(total / safeLimit));
            safePage = Math.min(safePage, totalPages);
            const skip = (safePage - 1) * safeLimit;
            // Récupérer la page filtrée
            const data = total === 0 ? [] : yield prisma.users.findMany({
                where,
                skip,
                take: safeLimit,
                orderBy: { created_at: 'desc' },
            });
            return {
                data: data.map(user => ({
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    phone: user.phone,
                    role: user.role,
                    password: user.password,
                    createdAt: user.created_at,
                    updatedAt: user.updated_at
                })),
                pagination: {
                    total,
                    currentPage: safePage,
                    limit: safeLimit,
                    totalPages
                }
            };
        });
    }
    /**
     * Récupère un utilisateur par son ID (pour l'API GET /api/users/:id)
     */
    static getUserById(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findUnique({ where: { id: userId } });
            if (!user)
                return null;
            return {
                id: user.id,
                email: user.email,
                password: user.password,
                firstName: user.first_name,
                lastName: user.last_name,
                phone: user.phone || undefined,
                role: user.role || 'CLIENT',
                referralCode: user.referral_code || undefined,
                createdAt: user.created_at || new Date(),
                updatedAt: user.updated_at || new Date()
            };
        });
    }
}
exports.AuthService = AuthService;
