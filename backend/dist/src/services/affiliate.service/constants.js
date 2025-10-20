"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DISTINCTION_LEVELS = exports.COMMISSION_LEVELS = exports.WITHDRAWAL_COOLDOWN_DAYS = exports.MIN_WITHDRAWAL_AMOUNT = exports.REFERRAL_POINTS = exports.PROFIT_MARGIN_RATE = exports.INDIRECT_COMMISSION_RATE = void 0;
// Taux de commission pour les filleuls indirects (2%)
exports.INDIRECT_COMMISSION_RATE = 2; // 2% pour les commissions indirectes
// Taux de marge bénéficiaire pour le calcul des commissions (40%)
exports.PROFIT_MARGIN_RATE = 0.40;
// Points de fidélité accordés pour le parrainage
exports.REFERRAL_POINTS = 100;
// Seuil minimum pour les retraits de commission (en FCFA)
exports.MIN_WITHDRAWAL_AMOUNT = 5000; // 5000 FCFA minimum
// Intervalle de temps minimum entre deux retraits (en jours)
exports.WITHDRAWAL_COOLDOWN_DAYS = 7;
// Niveaux de commission basés sur le nombre de clients affiliés
exports.COMMISSION_LEVELS = {
    BRONZE: {
        minEarnings: 0,
        commissionRate: 10
    },
    SILVER: {
        minEarnings: 100000,
        commissionRate: 12
    },
    GOLD: {
        minEarnings: 500000,
        commissionRate: 15
    },
    PLATINUM: {
        minEarnings: 1000000,
        commissionRate: 18
    }
};
// Descriptions des niveaux de distinction (basés sur les gains totaux)
exports.DISTINCTION_LEVELS = {
    NEW: {
        minReferrals: 0,
        badge: '🆕'
    },
    RISING: {
        minReferrals: 5,
        badge: '⭐'
    },
    EXPERT: {
        minReferrals: 20,
        badge: '🌟'
    },
    MASTER: {
        minReferrals: 50,
        badge: '👑'
    }
};
