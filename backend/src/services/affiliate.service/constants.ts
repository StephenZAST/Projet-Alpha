// Taux de commission pour les filleuls indirects (10%)
export const INDIRECT_COMMISSION_RATE = 0.10;

// Taux de marge bénéficiaire pour le calcul des commissions (40%)
export const PROFIT_MARGIN_RATE = 0.40;

// Points de fidélité accordés pour le parrainage
export const REFERRAL_POINTS = 100;

// Seuil minimum pour les retraits de commission (en FCFA)
export const MIN_WITHDRAWAL_AMOUNT = 25000; // 50€ ≈ 25,000 FCFA

// Intervalle de temps minimum entre deux retraits (en jours)
export const WITHDRAWAL_COOLDOWN_DAYS = 7;

// Niveaux de commission basés sur le nombre de clients affiliés
export const COMMISSION_LEVELS = {
    LEVEL1: {
        name: "Débutant",
        min: 0,
        max: 9, 
        rate: 0.10, // 10%
        description: "10% de commission sur les ventes directes"
    },
    LEVEL2: {
        name: "Intermédiaire",
        min: 10,
        max: 19,
        rate: 0.15, // 15%
        description: "15% de commission sur les ventes directes"
    }, 
    LEVEL3: {
        name: "Expert",
        min: 20,
        max: Infinity,
        rate: 0.20, // 20%
        description: "20% de commission sur les ventes directes"
    }
};

// Descriptions des niveaux de distinction (basés sur les gains totaux)
export const DISTINCTION_LEVELS = {
    BRONZE: {
        name: "Bronze",
        description: "Membre Bronze",
        minEarnings: 0 // 0 FCFA
    },
    SILVER: {
        name: "Argent",
        description: "Membre Argent",
        minEarnings: 500000 // 500,000 FCFA
    },
    GOLD: {
        name: "Or",
        description: "Membre Or",
        minEarnings: 2000000 // 2,000,000 FCFA
    },
    PLATINUM: {
        name: "Platine",
        description: "Membre Platine",
        minEarnings: 5000000 // 5,000,000 FCFA
    },
    DIAMOND: {
        name: "Diamant",
        description: "Membre Diamant",
        minEarnings: 10000000 // 10,000,000 FCFA
    }
};