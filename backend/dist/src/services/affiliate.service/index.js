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
exports.AffiliateWithdrawalService = exports.AffiliateCommissionService = exports.AffiliateProfileService = exports.AffiliateService = void 0;
const client_1 = require("@prisma/client");
const affiliateProfile_service_1 = require("./affiliateProfile.service");
Object.defineProperty(exports, "AffiliateProfileService", { enumerable: true, get: function () { return affiliateProfile_service_1.AffiliateProfileService; } });
const affiliateCommission_service_1 = require("./affiliateCommission.service");
Object.defineProperty(exports, "AffiliateCommissionService", { enumerable: true, get: function () { return affiliateCommission_service_1.AffiliateCommissionService; } });
const affiliateWithdrawal_service_1 = require("./affiliateWithdrawal.service");
Object.defineProperty(exports, "AffiliateWithdrawalService", { enumerable: true, get: function () { return affiliateWithdrawal_service_1.AffiliateWithdrawalService; } });
const prisma = new client_1.PrismaClient();
class AffiliateService {
    // Profile Management
    static getProfile(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                console.log('[AffiliateService] Getting profile for userId:', userId);
                const profile = yield affiliateProfile_service_1.AffiliateProfileService.getAffiliateProfile(userId);
                console.log('[AffiliateService] Profile retrieved:', profile ? 'SUCCESS' : 'NOT_FOUND');
                return profile;
            }
            catch (error) {
                console.error('[AffiliateService] Error getting profile:', error);
                throw error;
            }
        });
    }
    static getReferrals(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                console.log('[AffiliateService] Getting referrals for userId:', userId);
                // D'abord récupérer le profil affilié pour obtenir l'affiliateId
                const profile = yield affiliateProfile_service_1.AffiliateProfileService.getAffiliateProfile(userId);
                if (!profile) {
                    throw new Error('Affiliate profile not found');
                }
                console.log('[AffiliateService] Found affiliate profile:', profile.id);
                // Maintenant récupérer les référencements avec l'affiliateId
                return yield affiliateProfile_service_1.AffiliateProfileService.getReferralsByAffiliateId(profile.id);
            }
            catch (error) {
                console.error('[AffiliateService] Error getting referrals:', error);
                throw error;
            }
        });
    }
    // Commission Management
    static getCommissions(userId_1) {
        return __awaiter(this, arguments, void 0, function* (userId, page = 1, limit = 10) {
            try {
                console.log('[AffiliateService] Getting commissions for userId:', userId);
                // D'abord récupérer le profil affilié pour obtenir l'affiliateId
                const profile = yield affiliateProfile_service_1.AffiliateProfileService.getAffiliateProfile(userId);
                if (!profile) {
                    throw new Error('Affiliate profile not found');
                }
                console.log('[AffiliateService] Found affiliate profile:', profile.id);
                // Maintenant récupérer les commissions avec l'affiliateId
                return yield affiliateCommission_service_1.AffiliateCommissionService.getCommissions(profile.id, page, limit);
            }
            catch (error) {
                console.error('[AffiliateService] Error getting commissions:', error);
                throw error;
            }
        });
    }
    static getAllAffiliates(pagination, filters) {
        return __awaiter(this, void 0, void 0, function* () {
            const { page = 1, limit = 10 } = pagination;
            const skip = (page - 1) * limit;
            try {
                // Construction du filtre
                const whereConditions = {};
                if (filters.status) {
                    whereConditions.status = filters.status;
                }
                if (filters.query) {
                    whereConditions.OR = [
                        {
                            users: {
                                email: {
                                    contains: filters.query,
                                    mode: 'insensitive'
                                }
                            }
                        },
                        {
                            users: {
                                first_name: {
                                    contains: filters.query,
                                    mode: 'insensitive'
                                }
                            }
                        },
                        {
                            users: {
                                last_name: {
                                    contains: filters.query,
                                    mode: 'insensitive'
                                }
                            }
                        },
                        {
                            affiliate_code: {
                                contains: filters.query,
                                mode: 'insensitive'
                            }
                        }
                    ];
                }
                const [affiliates, total] = yield Promise.all([
                    prisma.affiliate_profiles.findMany({
                        skip,
                        take: limit,
                        where: whereConditions,
                        include: {
                            users: {
                                select: {
                                    id: true,
                                    email: true,
                                    first_name: true,
                                    last_name: true,
                                    phone: true
                                }
                            }
                        },
                        orderBy: {
                            created_at: 'desc'
                        }
                    }),
                    prisma.affiliate_profiles.count({ where: whereConditions })
                ]);
                // Log le résultat brut pour debug
                console.log('[AffiliateService] Affiliates raw:', JSON.stringify(affiliates, null, 2));
                // Mapping correct du champ 'user'
                const mappedAffiliates = affiliates.map(affiliate => (Object.assign(Object.assign({}, affiliate), { user: affiliate.users ? {
                        id: affiliate.users.id,
                        email: affiliate.users.email,
                        firstName: affiliate.users.first_name,
                        lastName: affiliate.users.last_name,
                        phone: affiliate.users.phone
                    } : null })));
                return {
                    data: mappedAffiliates,
                    pagination: {
                        total,
                        currentPage: page,
                        limit,
                        totalPages: Math.ceil(total / limit)
                    }
                };
            }
            catch (error) {
                console.error('[AffiliateService] Get all affiliates error:', error);
                throw error;
            }
        });
    }
    static updateAffiliateStatus(affiliateId, status, isActive) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const updatedAffiliate = yield prisma.affiliate_profiles.update({
                    where: { id: affiliateId },
                    data: {
                        status: status,
                        is_active: isActive,
                        updated_at: new Date()
                    },
                    include: {
                        users: {
                            select: {
                                id: true,
                                email: true,
                                first_name: true,
                                last_name: true,
                                phone: true
                            }
                        }
                    }
                });
                return Object.assign(Object.assign({}, updatedAffiliate), { user: updatedAffiliate.users ? {
                        id: updatedAffiliate.users.id,
                        email: updatedAffiliate.users.email,
                        firstName: updatedAffiliate.users.first_name,
                        lastName: updatedAffiliate.users.last_name,
                        phone: updatedAffiliate.users.phone
                    } : null });
            }
            catch (error) {
                console.error('[AffiliateService] Update affiliate status error:', error);
                throw error;
            }
        });
    }
    static createCustomerWithAffiliateCode(email, password, firstName, lastName, affiliateCode, phone) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const affiliate = yield prisma.affiliate_profiles.findUnique({
                    where: { affiliate_code: affiliateCode }
                });
                if (!affiliate) {
                    throw new Error('Affiliate code not found');
                }
                const user = yield prisma.users.create({
                    data: {
                        email,
                        password,
                        first_name: firstName,
                        last_name: lastName,
                        phone,
                        role: 'CLIENT',
                        referral_code: affiliateCode
                    }
                });
                return Object.assign(Object.assign({}, user), { firstName: user.first_name, lastName: user.last_name });
            }
            catch (error) {
                console.error('[AffiliateService] Create customer with affiliate code error:', error);
                throw error;
            }
        });
    }
    static generateCode(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            // Vérifier si l'utilisateur a déjà un code affilié
            const profile = yield prisma.affiliate_profiles.findUnique({
                where: { userId }
            });
            if (!profile) {
                throw new Error("Affiliate profile not found for this user");
            }
            if (profile.affiliate_code) {
                // Un code existe déjà, on refuse la régénération
                throw new Error("Affiliate code already exists and cannot be regenerated");
            }
            // Générer un nouveau code unique
            const prefix = 'AFF';
            const timestamp = Date.now().toString(36);
            const randomStr = Math.random().toString(36).substring(2, 6);
            const newCode = `${prefix}-${timestamp}-${randomStr}`.toUpperCase();
            // Enregistrer le code dans le profil affilié
            yield prisma.affiliate_profiles.update({
                where: { userId },
                data: { affiliate_code: newCode }
            });
            return newCode;
        });
    }
    static getCurrentLevel(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            // Implémentation de la récupération du niveau
        });
    }
    static getAffiliateStats() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const [totalAffiliates, activeAffiliates, pendingAffiliates, suspendedAffiliates, totalCommissions, monthlyCommissions, totalReferrals] = yield Promise.all([
                    // Total des affiliés
                    prisma.affiliate_profiles.count(),
                    // Affiliés actifs
                    prisma.affiliate_profiles.count({
                        where: { status: 'ACTIVE' }
                    }),
                    // Affiliés en attente
                    prisma.affiliate_profiles.count({
                        where: { status: 'PENDING' }
                    }),
                    // Affiliés suspendus
                    prisma.affiliate_profiles.count({
                        where: { status: 'SUSPENDED' }
                    }),
                    // Total des commissions
                    prisma.commission_transactions.aggregate({
                        _sum: { amount: true },
                        where: { status: 'PAID' }
                    }),
                    // Commissions du mois
                    prisma.commission_transactions.aggregate({
                        _sum: { amount: true },
                        where: {
                            status: 'PAID',
                            created_at: {
                                gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
                            }
                        }
                    }),
                    // Total des référencements
                    prisma.affiliate_profiles.aggregate({
                        _sum: { total_referrals: true }
                    })
                ]);
                // Calcul du taux moyen de commission
                const averageCommissionRate = yield prisma.affiliate_profiles.aggregate({
                    _avg: { commission_rate: true }
                });
                return {
                    totalAffiliates,
                    activeAffiliates,
                    pendingAffiliates,
                    suspendedAffiliates,
                    totalCommissions: Number(totalCommissions._sum.amount || 0),
                    monthlyCommissions: Number(monthlyCommissions._sum.amount || 0),
                    averageCommissionRate: Number(averageCommissionRate._avg.commission_rate || 0),
                    totalReferrals: Number(totalReferrals._sum.total_referrals || 0)
                };
            }
            catch (error) {
                console.error('[AffiliateService] Get affiliate stats error:', error);
                throw error;
            }
        });
    }
    static updateProfileSettings(userId, data) {
        return __awaiter(this, void 0, void 0, function* () {
            // Implémentation de la mise à jour du profil
        });
    }
}
exports.AffiliateService = AffiliateService;
AffiliateService.updateProfile = affiliateProfile_service_1.AffiliateProfileService.updateAffiliateProfile;
AffiliateService.createAffiliate = affiliateProfile_service_1.AffiliateProfileService.createAffiliate;
AffiliateService.calculateCommissionRate = affiliateCommission_service_1.AffiliateCommissionService.calculateCommissionRate;
AffiliateService.processNewCommission = affiliateCommission_service_1.AffiliateCommissionService.processNewCommission;
// Withdrawal Management
AffiliateService.requestWithdrawal = affiliateWithdrawal_service_1.AffiliateWithdrawalService.requestWithdrawal;
AffiliateService.getWithdrawals = affiliateWithdrawal_service_1.AffiliateWithdrawalService.getWithdrawals;
AffiliateService.approveWithdrawal = affiliateWithdrawal_service_1.AffiliateWithdrawalService.approveWithdrawal;
AffiliateService.rejectWithdrawal = affiliateWithdrawal_service_1.AffiliateWithdrawalService.rejectWithdrawal;
