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
exports.AffiliateProfileService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../../models/types");
const notification_service_1 = require("../notification.service");
const codeGenerator_1 = require("../../utils/codeGenerator");
const prisma = new client_1.PrismaClient();
class AffiliateProfileService {
    static createProfile(data) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const profile = yield prisma.affiliate_profiles.create({
                data: {
                    userId: data.userId,
                    affiliate_code: data.affiliateCode,
                    parent_affiliate_id: data.parent_affiliate_id,
                    commission_rate: 10,
                    commission_balance: 0,
                    total_earned: 0,
                    monthly_earnings: 0,
                    is_active: true,
                    status: 'PENDING', // Typage explicite pour status
                    created_at: new Date(),
                    updated_at: new Date()
                }
            });
            return {
                id: profile.id,
                userId: profile.userId,
                affiliateCode: profile.affiliate_code,
                parent_affiliate_id: profile.parent_affiliate_id || undefined,
                commission_rate: Number(profile.commission_rate),
                commissionBalance: Number(profile.commission_balance),
                totalEarned: Number(profile.total_earned),
                monthlyEarnings: Number(profile.monthly_earnings),
                isActive: (_a = profile.is_active) !== null && _a !== void 0 ? _a : false,
                status: profile.status, // Le type sera maintenant compatible
                levelId: profile.level_id || undefined,
                totalReferrals: profile.total_referrals || 0,
                createdAt: profile.created_at || new Date(),
                updatedAt: profile.updated_at || new Date()
            };
        });
    }
    static updateProfile(id, data) {
        return __awaiter(this, void 0, void 0, function* () {
            const profile = yield prisma.affiliate_profiles.update({
                where: { id },
                data: {
                    commission_rate: data.commission_rate,
                    is_active: data.isActive,
                    status: data.status || 'PENDING',
                    updated_at: new Date()
                }
            });
            return this.formatProfile(profile);
        });
    }
    static formatProfile(profile) {
        return {
            id: profile.id,
            userId: profile.userId,
            affiliateCode: profile.affiliate_code,
            parent_affiliate_id: profile.parent_affiliate_id || undefined,
            commission_rate: Number(profile.commission_rate),
            commissionBalance: Number(profile.commission_balance),
            totalEarned: Number(profile.total_earned),
            monthlyEarnings: Number(profile.monthly_earnings),
            isActive: profile.is_active,
            status: profile.status || 'PENDING',
            levelId: profile.level_id || undefined,
            totalReferrals: profile.total_referrals || 0,
            createdAt: profile.created_at,
            updatedAt: profile.updated_at
        };
    }
    static createAffiliate(data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Vérifier si l'utilisateur existe déjà comme affilié
                const existingProfile = yield prisma.affiliate_profiles.findUnique({
                    where: { userId: data.userId }
                });
                if (existingProfile) {
                    throw new Error('User already has an affiliate profile');
                }
                // Vérifier le code du parrain si fourni
                let parentId;
                if (data.parentAffiliateCode) {
                    const parentProfile = yield prisma.affiliate_profiles.findFirst({
                        where: {
                            affiliate_code: data.parentAffiliateCode,
                            is_active: true,
                            status: 'ACTIVE'
                        }
                    });
                    if (!parentProfile) {
                        throw new Error('Invalid parent affiliate code');
                    }
                    parentId = parentProfile.id;
                }
                // Générer un code unique
                const affiliateCode = yield (0, codeGenerator_1.generateAffiliateCode)();
                // Créer le profil affilié
                const profile = yield prisma.affiliate_profiles.create({
                    data: {
                        userId: data.userId,
                        affiliate_code: affiliateCode,
                        parent_affiliate_id: parentId,
                        commission_balance: new client_1.Prisma.Decimal(0),
                        total_earned: new client_1.Prisma.Decimal(0),
                        commission_rate: new client_1.Prisma.Decimal(10),
                        is_active: true,
                        total_referrals: 0,
                        monthly_earnings: new client_1.Prisma.Decimal(0),
                        status: 'PENDING',
                        created_at: new Date(),
                        updated_at: new Date()
                    },
                    include: {
                        users: true,
                        affiliate_levels: true
                    }
                });
                // Notification aux administrateurs
                const admins = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['ADMIN', 'SUPER_ADMIN']
                        }
                    }
                });
                yield Promise.all(admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.AFFILIATE_STATUS_UPDATED, {
                    title: 'Nouvelle demande d\'affiliation',
                    message: `Un nouvel affilié attend votre validation`,
                    data: { affiliateId: profile.id }
                })));
                return {
                    id: profile.id,
                    userId: profile.userId,
                    affiliateCode: profile.affiliate_code,
                    parent_affiliate_id: profile.parent_affiliate_id || undefined,
                    commissionBalance: Number(profile.commission_balance),
                    totalEarned: Number(profile.total_earned),
                    createdAt: profile.created_at || new Date(),
                    updatedAt: profile.updated_at || new Date(),
                    commission_rate: Number(profile.commission_rate),
                    status: profile.status || 'PENDING',
                    isActive: profile.is_active || false,
                    totalReferrals: profile.total_referrals || 0,
                    monthlyEarnings: Number(profile.monthly_earnings),
                    levelId: profile.level_id || undefined,
                    level: profile.affiliate_levels ? {
                        id: profile.affiliate_levels.id,
                        name: profile.affiliate_levels.name,
                        minEarnings: Number(profile.affiliate_levels.minEarnings),
                        commissionRate: Number(profile.affiliate_levels.commissionRate),
                        createdAt: profile.affiliate_levels.created_at || new Date(),
                        updatedAt: profile.affiliate_levels.updated_at || new Date()
                    } : undefined
                };
            }
            catch (error) {
                console.error('[AffiliateProfileService] Create affiliate error:', error);
                throw error;
            }
        });
    }
    static getAffiliateProfile(identifier_1) {
        return __awaiter(this, arguments, void 0, function* (identifier, byId = false) {
            try {
                console.log('[AffiliateProfileService] Getting profile for:', { identifier, byId });
                const where = byId
                    ? { id: identifier }
                    : { userId: identifier };
                console.log('[AffiliateProfileService] Query where:', where);
                const profile = yield prisma.affiliate_profiles.findUnique({
                    where,
                    include: {
                        affiliate_levels: true,
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
                console.log('[AffiliateProfileService] Found profile:', profile ? 'YES' : 'NO');
                if (!profile)
                    return null;
                // Formatage cohérent avec les autres méthodes
                const formattedProfile = {
                    id: profile.id,
                    userId: profile.userId,
                    affiliateCode: profile.affiliate_code,
                    parent_affiliate_id: profile.parent_affiliate_id || undefined,
                    commissionBalance: Number(profile.commission_balance),
                    totalEarned: Number(profile.total_earned),
                    createdAt: profile.created_at || new Date(),
                    updatedAt: profile.updated_at || new Date(),
                    commission_rate: Number(profile.commission_rate),
                    status: profile.status || 'PENDING',
                    isActive: profile.is_active || false,
                    totalReferrals: profile.total_referrals || 0,
                    monthlyEarnings: Number(profile.monthly_earnings),
                    levelId: profile.level_id || undefined,
                    // Ajouter les informations utilisateur si disponibles
                    user: profile.users ? {
                        id: profile.users.id,
                        email: profile.users.email,
                        firstName: profile.users.first_name,
                        lastName: profile.users.last_name,
                        phone: profile.users.phone || undefined
                    } : undefined,
                    // Ajouter les informations de niveau si disponibles
                    level: profile.affiliate_levels ? {
                        id: profile.affiliate_levels.id,
                        name: profile.affiliate_levels.name,
                        minEarnings: Number(profile.affiliate_levels.minEarnings),
                        commissionRate: Number(profile.affiliate_levels.commissionRate),
                        createdAt: profile.affiliate_levels.created_at || new Date(),
                        updatedAt: profile.affiliate_levels.updated_at || new Date()
                    } : undefined
                };
                console.log('[AffiliateProfileService] Returning formatted profile:', {
                    id: formattedProfile.id,
                    userId: formattedProfile.userId,
                    affiliateCode: formattedProfile.affiliateCode
                });
                return formattedProfile;
            }
            catch (error) {
                console.error('[AffiliateProfileService] Get affiliate profile error:', error);
                throw error;
            }
        });
    }
    static updateAffiliateProfile(affiliateId, data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const affiliate = yield prisma.affiliate_profiles.update({
                    where: { id: affiliateId },
                    data: {
                        commission_rate: data.commission_rate ? new client_1.Prisma.Decimal(data.commission_rate) : undefined,
                        is_active: data.isActive,
                        status: data.status,
                        level_id: data.levelId,
                        updated_at: new Date()
                    },
                    include: {
                        affiliate_levels: true,
                        users: true
                    }
                });
                if (data.status) {
                    yield notification_service_1.NotificationService.sendNotification(affiliate.userId, types_1.NotificationType.AFFILIATE_STATUS_UPDATED, {
                        title: 'Statut d\'affiliation mis à jour',
                        message: `Votre statut d'affiliation est maintenant: ${data.status}`,
                        data: { newStatus: data.status }
                    });
                }
                return {
                    id: affiliate.id,
                    userId: affiliate.userId,
                    affiliateCode: affiliate.affiliate_code,
                    parent_affiliate_id: affiliate.parent_affiliate_id || undefined,
                    commissionBalance: Number(affiliate.commission_balance),
                    totalEarned: Number(affiliate.total_earned),
                    createdAt: affiliate.created_at || new Date(),
                    updatedAt: affiliate.updated_at || new Date(),
                    commission_rate: Number(affiliate.commission_rate),
                    status: affiliate.status || 'PENDING',
                    isActive: affiliate.is_active || false,
                    totalReferrals: affiliate.total_referrals || 0,
                    monthlyEarnings: Number(affiliate.monthly_earnings),
                    levelId: affiliate.level_id || undefined,
                    level: affiliate.affiliate_levels ? {
                        id: affiliate.affiliate_levels.id,
                        name: affiliate.affiliate_levels.name,
                        minEarnings: Number(affiliate.affiliate_levels.minEarnings),
                        commissionRate: Number(affiliate.affiliate_levels.commissionRate),
                        createdAt: affiliate.affiliate_levels.created_at || new Date(),
                        updatedAt: affiliate.affiliate_levels.updated_at || new Date()
                    } : undefined
                };
            }
            catch (error) {
                console.error('[AffiliateProfileService] Update profile error:', error);
                throw error;
            }
        });
    }
    static getAllAffiliates() {
        return __awaiter(this, arguments, void 0, function* (page = 1, limit = 10, statusFilter) {
            try {
                const where = statusFilter ? { status: statusFilter } : {};
                const skip = (page - 1) * limit;
                const [affiliates, total] = yield Promise.all([
                    prisma.affiliate_profiles.findMany({
                        skip,
                        take: limit,
                        where,
                        orderBy: {
                            created_at: 'desc'
                        },
                        include: {
                            affiliate_levels: true,
                            users: true
                        }
                    }),
                    prisma.affiliate_profiles.count({ where })
                ]);
                return {
                    affiliates: affiliates.map(affiliate => ({
                        id: affiliate.id,
                        userId: affiliate.userId,
                        affiliateCode: affiliate.affiliate_code,
                        parentAffiliateId: affiliate.parent_affiliate_id || undefined,
                        commissionBalance: Number(affiliate.commission_balance),
                        totalEarned: Number(affiliate.total_earned),
                        createdAt: affiliate.created_at || new Date(),
                        updatedAt: affiliate.updated_at || new Date(),
                        commission_rate: Number(affiliate.commission_rate),
                        status: affiliate.status || 'PENDING',
                        isActive: affiliate.is_active || false,
                        totalReferrals: affiliate.total_referrals || 0,
                        monthlyEarnings: Number(affiliate.monthly_earnings),
                        levelId: affiliate.level_id || undefined,
                        level: affiliate.affiliate_levels ? {
                            id: affiliate.affiliate_levels.id,
                            name: affiliate.affiliate_levels.name,
                            minEarnings: Number(affiliate.affiliate_levels.minEarnings),
                            commissionRate: Number(affiliate.affiliate_levels.commissionRate),
                            createdAt: affiliate.affiliate_levels.created_at || new Date(),
                            updatedAt: affiliate.affiliate_levels.updated_at || new Date()
                        } : undefined
                    })),
                    total,
                    pages: Math.ceil(total / limit)
                };
            }
            catch (error) {
                console.error('[AffiliateProfileService] Get all affiliates error:', error);
                throw error;
            }
        });
    }
    static getReferralsByAffiliateId(affiliateId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const referrals = yield prisma.affiliate_profiles.findMany({
                    where: {
                        parent_affiliate_id: affiliateId
                    },
                    include: {
                        users: true,
                        affiliate_levels: true
                    }
                });
                return referrals.map(referral => ({
                    id: referral.id,
                    userId: referral.userId,
                    affiliateCode: referral.affiliate_code,
                    parentAffiliateId: referral.parent_affiliate_id || undefined,
                    commissionBalance: Number(referral.commission_balance),
                    totalEarned: Number(referral.total_earned),
                    createdAt: referral.created_at || new Date(),
                    updatedAt: referral.updated_at || new Date(),
                    commission_rate: Number(referral.commission_rate),
                    status: referral.status || 'PENDING',
                    isActive: referral.is_active || false,
                    totalReferrals: referral.total_referrals || 0,
                    monthlyEarnings: Number(referral.monthly_earnings),
                    levelId: referral.level_id || undefined,
                    level: referral.affiliate_levels ? {
                        id: referral.affiliate_levels.id,
                        name: referral.affiliate_levels.name,
                        minEarnings: Number(referral.affiliate_levels.minEarnings),
                        commissionRate: Number(referral.affiliate_levels.commissionRate),
                        createdAt: referral.affiliate_levels.created_at || new Date(),
                        updatedAt: referral.affiliate_levels.updated_at || new Date()
                    } : undefined
                }));
            }
            catch (error) {
                console.error('[AffiliateProfileService] Get referrals error:', error);
                throw error;
            }
        });
    }
}
exports.AffiliateProfileService = AffiliateProfileService;
