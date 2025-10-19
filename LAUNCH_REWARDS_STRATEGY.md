# 🚀 Stratégie de Lancement - Récompenses Essentielles (MVP)

**Date de création:** 16 Octobre 2025  
**Version:** 1.0  
**Objectif:** Définir les récompenses prioritaires pour le lancement d'Alpha Laundry  
**Statut:** 🎯 Recommandations d'Implémentation

---

## 📋 Table des Matières

1. [Introduction](#introduction)
2. [Analyse du Lancement](#analyse-du-lancement)
3. [Récompenses Essentielles MVP](#récompenses-essentielles-mvp)
4. [Votre Idée: Reward Partenariat](#votre-idée--reward-partenariat)
5. [Catégorisation et Mapping](#catégorisation-et-mapping)
6. [Configuration de Démarrage](#configuration-de-démarrage)
7. [Plan de Rollout](#plan-de-rollout)
8. [KPIs et Monitoring](#kpis-et-monitoring)

---

## 🎯 Introduction

### Contexte du Lancement

Vous lancez **Alpha Laundry** avec un système de fidélité. Les clients n'ont jamais utilisé vos services, donc il faut:

✅ **Attirer** les premiers clients  
✅ **Récompenser** rapidement (accumulation rapide)  
✅ **Fidéliser** avec récompenses variées  
✅ **Maximiser retention** en année 1

### Principe du MVP (Minimum Viable Product)

**Ne pas surcharger** avec 50 récompenses différentes.

**Au lieu de cela:**
- 🎯 **8-10 récompenses** bien pensées
- 💎 **Mix des 4 catégories** (Discount, FreeService, Gift, Voucher)
- 🔄 **Rotation tous les 2-3 mois**
- 📊 **Analyser → Adapter**

---

## 📊 Analyse du Lancement

### Profils de Clients à Conquérir

| Profil | Motivation | Récompense Idéale |
|--------|-----------|-------------------|
| **Budget-conscious** 💰 | Économies max | Réductions % + Vouchers |
| **Service-focused** 🛠️ | Facilité + temps | Services gratuits (livraison) |
| **Experience-seeker** 🎁 | Variété + luxe | Cadeaux + services premium |
| **Eco-conscious** ♻️ | Responsabilité | Produits naturels + écolo |
| **Busy professional** ⏰ | Praticité | Livrais gratuite + speed |

---

## 🏆 Récompenses Essentielles MVP

### Vue d'Ensemble Recommandée

```
🎁 TOTAL: 9 récompenses pour démarrage

Catégories:
├─ 3 DISCOUNT (réductions variées)
├─ 2 FREESERVICE (services populaires)
├─ 2 GIFT (produits + partenariat)
├─ 2 VOUCHER (bons flexibles)
└─ BONUS: 1 récompense partenariat spéciale
```

---

## ✅ Configuration MVP Recommandée

### **REWARD 1 - DISCOUNT: 5% Réduction (Très Accessible)**

**Objectif:** Premiers points rapidement utilisables

```javascript
{
  id: "reward-launch-001",
  name: "5% de réduction",
  description: "5% de réduction sur votre prochaine commande",
  type: "DISCOUNT",
  discountType: "PERCENTAGE",
  discountValue: 5,
  pointsCost: 100,           // Très accessible (1 achat ~2500 FCFA)
  maxRedemptions: null,       // Illimité
  isActive: true,
  icon: "percent",
  badge: "POPULAIRE"
}
```

**Stratégie:**
- Client 1ère commande: 2500 pts → peut utiliser après 100 pts requis
- Encourage retour rapide (2e commande dans la semaine)
- Conversion rapide: ~60% des nouveaux utilisateurs

---

### **REWARD 2 - DISCOUNT: 10% Réduction (Couche Intermédiaire)**

**Objectif:** Récompenser clients un peu plus fidèles

```javascript
{
  id: "reward-launch-002",
  name: "10% de réduction",
  description: "10% de réduction sur votre prochaine commande",
  type: "DISCOUNT",
  discountType: "PERCENTAGE",
  discountValue: 10,
  pointsCost: 250,            // 2 petites commandes
  maxRedemptions: 500,        // Limité pour budget
  isActive: true,
  icon: "percent",
  badge: "RECOMMANDÉ"
}
```

**Stratégie:**
- Après 2-3 commandes, client peut réclamer
- Value intéressant (10%)
- Limite budgétaire: 500 × 10% = 50 commandes = manageable

---

### **REWARD 3 - DISCOUNT: 15% Réduction PRESSING (Service Premium)**

**Objectif:** Promouvoir service premium à marge plus haute

```javascript
{
  id: "reward-launch-003",
  name: "15% réduction services PRESSING",
  description: "15% de réduction exclusivement sur services de pressing",
  type: "DISCOUNT",
  discountType: "PERCENTAGE",
  discountValue: 15,
  pointsCost: 400,
  maxRedemptions: 200,        // Limité
  isActive: true,
  icon: "dry_cleaning",
  badge: "PREMIUM",
  metadata: {
    applicableServices: ["PRESSING", "DRY_CLEANING"],
    minimumPurchase: 3000
  }
}
```

**Stratégie:**
- Cible clients avec paniers plus gros
- Encourage essai des services premium
- Marge business: 15% de pressing > 5% de lavage simple

---

### **REWARD 4 - FREESERVICE: Livraison Gratuite (Très Demandée)**

**Objectif:** Éliminer friction prix (frais livraison)

```javascript
{
  id: "reward-launch-004",
  name: "Livraison gratuite",
  description: "Bénéficiez d'une livraison gratuite sur votre prochaine commande",
  type: "FREESERVICE",
  pointsCost: 200,
  maxRedemptions: null,       // Illimité
  isActive: true,
  icon: "local_shipping",
  badge: "POPULAIRE",
  metadata: {
    serviceType: "DELIVERY",
    estimatedValue: 2000,
    applicableAnywhere: true
  }
}
```

**Stratégie:**
- Les frais livraison = 1ère barrière client
- Récompense très attrayante
- Peu coûteux pour business (livraison interne)
- Conversion haute: ~70%

---

### **REWARD 5 - FREESERVICE: Repassage Gratuit (Utile + Rapide à Appliquer)**

**Objectif:** Service rapide à appliquer (pas de délivery needed)

```javascript
{
  id: "reward-launch-005",
  name: "Repassage gratuit (1 article)",
  description: "Repassage complet gratuit d'1 article de votre choix",
  type: "FREESERVICE",
  pointsCost: 180,
  maxRedemptions: null,
  isActive: true,
  icon: "iron",
  badge: "SIMPLE",
  metadata: {
    serviceType: "PRESSING",
    quantity: 1,
    estimatedValue: 1500,
    easyToImplement: true
  }
}
```

**Stratégie:**
- Admin peut rapidement honorer (ajouter 1 item dans workflow)
- Points accessibles
- Client voit qualité du service

---

### **REWARD 6 - GIFT: Kit d'Entretien (Engagement Long-Terme)**

**Objectif:** Récompense tangible qui fidélise

```javascript
{
  id: "reward-launch-006",
  name: "Kit d'entretien textile",
  description: "Kit complet: savon laine + spray détachant + brosse nettoyage",
  type: "GIFT",
  pointsCost: 350,
  maxRedemptions: 100,        // Limité (coûts)
  isActive: true,
  icon: "card_giftcard",
  badge: "EXCLUSIF",
  metadata: {
    category: "CARE_PRODUCTS",
    estimatedCost: 2500,
    items: [
      "Savon laine délicate",
      "Spray détachant 250ml",
      "Brosse nettoyage"
    ],
    partner: null,             // Votre propre sourcing initial
    collectInStore: true
  }
}
```

**Stratégie:**
- Tangible + utilisable
- Renforce brand (clients utilisent votre kit → pensent à vous)
- Limité: 100 = gérable pour sourcing
- Points raison (milieu du spectre)

---

### **REWARD 7 - GIFT + PARTENARIAT: Bon Commercial Partenaire (VOTRE IDÉE! 🎯)**

**Objectif:** Partenariat gagnant-gagnant

```javascript
{
  id: "reward-launch-007",
  name: "Bon alimentation/centre commercial",
  description: "Bon d'achat 2000 FCFA à utiliser chez nos partenaires",
  type: "VOUCHER",              // ← CATÉGORIE APPROPRIÉE (voir explication)
  discountType: "FIXED_AMOUNT",
  discountValue: 2000,
  pointsCost: 500,
  maxRedemptions: 200,
  isActive: true,
  icon: "card_giftcard",
  badge: "PARTENAIRE",
  metadata: {
    category: "PARTNER_VOUCHER",  // ← Nouvelle sous-catégorie
    partnerType: "COMMERCE_GENERAL",
    partnerName: "À définir",
    voucherValue: 2000,
    validity_days: 60,
    minimumPurchase: null,
    couldBeRedeemed: [
      "Supermarché XYZ",
      "Centre Commercial ABC",
      "Restaurant DEF",
      "Boutique GHI"
    ],
    distribution: "DIGITAL_CODE",  // Code envoyé par email
    codeFormat: "PARTNER-####-XXXX"
  }
}
```

**Pourquoi cette catégorie?** → Voir section suivante

---

### **REWARD 8 - VOUCHER: Bon 500 FCFA (Flexible + Facile)**

**Objectif:** Maximum flexibilité pour client

```javascript
{
  id: "reward-launch-008",
  name: "Bon 500 FCFA",
  description: "Bon d'achat de 500 FCFA à utiliser sur tous les services",
  type: "VOUCHER",
  discountType: "FIXED_AMOUNT",
  discountValue: 500,
  pointsCost: 150,
  maxRedemptions: 200,
  isActive: true,
  icon: "card_giftcard",
  badge: "FLEXIBLE",
  metadata: {
    validity_days: 30,
    minimumPurchase: 1000,
    couldBeCombined: false,
    distribution: "DIGITAL_CODE"
  }
}
```

**Stratégie:**
- Simple et direct
- Client aime avoir choix
- Montant petit = plus accessible
- Minimum d'achat = évite petites commandes

---

### **REWARD 9 - VOUCHER: Bon 1000 FCFA (Premium)**

**Objectif:** Jackpot pour clients plus fidèles

```javascript
{
  id: "reward-launch-009",
  name: "Bon 1000 FCFA",
  description: "Bon d'achat de 1000 FCFA sur tous les services",
  type: "VOUCHER",
  discountType: "FIXED_AMOUNT",
  discountValue: 1000,
  pointsCost: 350,
  maxRedemptions: 100,
  isActive: true,
  icon: "card_giftcard",
  badge: "EXCELLENT",
  metadata: {
    validity_days: 45,
    minimumPurchase: 2000,
    distribution: "DIGITAL_CODE"
  }
}
```

**Stratégie:**
- Perception de valeur élevée
- Points intermédiaires
- Limite stricte: 100 (budget)

---

## 🎯 Votre Idée: Reward Partenariat

### 🔥 EXCELLENTE IDÉE!

Vous proposez:
> "Reward où client peut réclamer un bon utiliser dans commerces/restaurants/centres commerciaux partenaires"

### Catégorisation Technique

**Question:** Dans quelle catégorie mettre ce reward?

**Réponse:** C'est un **VOUCHER** avec une sous-catégorie spéciale: `PARTNER_VOUCHER`

### Pourquoi VOUCHER et pas GIFT?

| Critère | GIFT | VOUCHER | ✅ Votre Reward |
|---------|------|---------|------------------|
| Tangible physique? | Oui | Non | Non (digital code) |
| Delivery nécessaire? | Oui | Non | Non |
| Client l'utilise où? | Chez vous | Partout | Chez partenaires |
| Flexibilité? | Basse | Haute | ⭐ Haute |
| Temps implémentation? | Moyen | Rapide | ⭐ Rapide |
| Coût acquisition? | Élevé | Bas | ⭐ Partagé |

**Conclusion:** **VOUCHER** est plus approprié car:
- ✅ Pas de livraison physique needed
- ✅ Code digital simple
- ✅ Client utilise directement
- ✅ Partenaires gèrent leur côté
- ✅ Flexible pour client

### Structure Technique du VOUCHER Partenariat

```javascript
{
  id: "reward-partner-001",
  name: "Bon partenaire 2000 FCFA",
  description: "Utilisez votre bon dans nos commerces partenaires: Supermarché ABC, Centre Commercial XYZ...",
  type: "VOUCHER",              // ← Catégorie principale
  
  // Champs VOUCHER standards
  discountType: "FIXED_AMOUNT",
  discountValue: 2000,
  pointsCost: 500,
  maxRedemptions: 200,
  isActive: true,
  
  // Métadonnées spécifiques partenariat
  metadata: {
    // Classification
    subCategory: "PARTNER_VOUCHER",
    rewardFamily: "PARTNERSHIP",
    
    // Détails partenariat
    partners: [
      {
        id: "partner-001",
        name: "Supermarché ABC",
        type: "SUPERMARKET",
        location: "Centre-ville",
        acceptMethod: "PHYSICAL_CODE"  // Code QR imprimé
      },
      {
        id: "partner-002",
        name: "Centre Commercial XYZ",
        type: "MALL",
        location: "Quartier Nord",
        acceptMethod: "DIGITAL_CODE"   // Code envoyé par SMS
      },
      {
        id: "partner-003",
        name: "Restaurant DEF",
        type: "FOOD",
        location: "Avenue principale",
        acceptMethod: "BOTH"            // QR ou code
      }
    ],
    
    // Distribution et utilisation
    voucherFormat: "DIGITAL_CODE",
    codePattern: "PART-####-XXXX",
    validity_days: 60,
    minimumPurchase: null,
    maximumDiscount: 2000,
    
    // Gestion technique
    redemptionProcess: "PARTNER_VALIDATES",  // Partenaire valide code
    trackingMethod: "QR_CODE",               // Suivi via QR
    partnerNotification: "AUTO",             // Email auto partenaire
    
    // Business metrics
    costToAlpha: "SHARED",        // Alpha paie % aux partenaires
    marginShare: 70,              // Alpha 70%, Partenaire 30%
    estimatedPartnerCost: 1400,   // Cost pour Alpha
  }
}
```

---

## 📍 Catégorisation et Mapping

### Tableau Récapitulatif

| # | Reward | Catégorie | Type | Points | Limite | Raison |
|---|--------|-----------|------|--------|--------|--------|
| 1 | 5% réduction | DISCOUNT | % | 100 | ∞ | Accessibilité max |
| 2 | 10% réduction | DISCOUNT | % | 250 | 500 | Budget contrôlé |
| 3 | 15% PRESSING | DISCOUNT | % | 400 | 200 | Service premium |
| 4 | Livraison gratuite | FREESERVICE | Service | 200 | ∞ | Frictio baisse |
| 5 | Repassage gratuit | FREESERVICE | Service | 180 | ∞ | Facilité admin |
| 6 | Kit entretien | GIFT | Produit | 350 | 100 | Tangible + brand |
| 7 | **Bon Partenaire** | **VOUCHER** | **Digital** | **500** | **200** | **Votre idée** ⭐ |
| 8 | Bon 500 FCFA | VOUCHER | Fixe | 150 | 200 | Flexibilité |
| 9 | Bon 1000 FCFA | VOUCHER | Fixe | 350 | 100 | Premium |

---

## 🚀 Configuration de Démarrage

### Phase 1: Semaine du Lancement (9 Rewards)

```typescript
// backend/src/data/initial-rewards.ts

export const INITIAL_REWARDS = [
  // DISCOUNT - 3 rewards
  {
    name: "5% de réduction",
    type: "DISCOUNT",
    discountType: "PERCENTAGE",
    discountValue: 5,
    pointsCost: 100,
    maxRedemptions: null,
    isActive: true,
    priority: 1
  },
  {
    name: "10% de réduction",
    type: "DISCOUNT",
    discountType: "PERCENTAGE",
    discountValue: 10,
    pointsCost: 250,
    maxRedemptions: 500,
    isActive: true,
    priority: 2
  },
  {
    name: "15% réduction PRESSING",
    type: "DISCOUNT",
    discountType: "PERCENTAGE",
    discountValue: 15,
    pointsCost: 400,
    maxRedemptions: 200,
    isActive: true,
    priority: 3
  },
  
  // FREESERVICE - 2 rewards
  {
    name: "Livraison gratuite",
    type: "FREESERVICE",
    pointsCost: 200,
    maxRedemptions: null,
    isActive: true,
    priority: 4
  },
  {
    name: "Repassage gratuit (1 article)",
    type: "FREESERVICE",
    pointsCost: 180,
    maxRedemptions: null,
    isActive: true,
    priority: 5
  },
  
  // GIFT - 1 reward (start simple)
  {
    name: "Kit d'entretien textile",
    type: "GIFT",
    pointsCost: 350,
    maxRedemptions: 100,
    isActive: true,
    priority: 6
  },
  
  // VOUCHER - 3 rewards (incl. PARTNER)
  {
    name: "Bon partenaire 2000 FCFA",
    type: "VOUCHER",
    discountType: "FIXED_AMOUNT",
    discountValue: 2000,
    pointsCost: 500,
    maxRedemptions: 200,
    isActive: true,
    metadata: {
      subCategory: "PARTNER_VOUCHER",
      partners: ["Supermarché ABC", "Centre Commercial XYZ"]
    },
    priority: 7
  },
  {
    name: "Bon 500 FCFA",
    type: "VOUCHER",
    discountType: "FIXED_AMOUNT",
    discountValue: 500,
    pointsCost: 150,
    maxRedemptions: 200,
    isActive: true,
    priority: 8
  },
  {
    name: "Bon 1000 FCFA",
    type: "VOUCHER",
    discountType: "FIXED_AMOUNT",
    discountValue: 1000,
    pointsCost: 350,
    maxRedemptions: 100,
    isActive: true,
    priority: 9
  }
];
```

---

### Script SQL de Seed (Prisma)

```typescript
// backend/prisma/seed.ts

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding rewards...');
  
  const rewards = await prisma.rewards.createMany({
    data: [
      // DISCOUNT rewards
      {
        name: "5% de réduction",
        description: "5% de réduction sur votre prochaine commande",
        type: "DISCOUNT",
        discountType: "PERCENTAGE",
        discountValue: new Decimal(5),
        pointsCost: 100,
        maxRedemptions: null,
        isActive: true
      },
      // ... (tous les autres rewards)
    ]
  });
  
  console.log(`✅ Created ${rewards.count} rewards`);
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
```

---

## 📅 Plan de Rollout

### Timeline Recommandée

```
SEMAINE 1: LANCEMENT
├─ 9 Rewards actifs
├─ Marketing email
├─ In-app notifications
└─ Test avec 100 early users

SEMAINE 2-3: MONITORING
├─ Track utilisation
├─ Analyser conversion par reward
├─ Feedback utilisateur
└─ Ajuster points si nécessaire

SEMAINE 4: EXPANSION
├─ Ajouter 2-3 rewards saisonnières
├─ Créer tiers VIP
└─ Promouvoir partenariat

MOIS 2: OPTIMISATION
├─ Analyser full data
├─ Retirer rewards under-utilisés
├─ Augmenter rewards populaires
└─ Négocier plus de partenariats
```

---

## 📊 KPIs et Monitoring

### Métriques à Tracker

**Par Reward:**

```javascript
{
  rewardId: "reward-001",
  name: "5% réduction",
  metrics: {
    // Utilisation
    totalClaimed: 450,           // Nombre de réclamations
    totalRedeemed: 380,          // Effectivement utilisées
    redemptionRate: 84.4,        // % (380/450)
    
    // Business impact
    totalPointsSpent: 45000,     // 450 × 100 pts
    estimatedCostToAlpha: 12500, // 450 × ~27 FCFA (avg 5% sur 5000 FCFA commande)
    averageOrderValue: 5200,     // Commandes avec reward
    
    // Trend
    weeklyGrowth: 15.2,          // %
    trending: "UP",              // Up/Down/Stable
    
    // Demographics
    maleUsers: 35,
    femaleUsers: 415,
    avgAge: 28,
    topCity: "Centre-ville"
  }
}
```

**Global:**

```javascript
{
  globalMetrics: {
    totalRewardsClaimed: 2150,
    totalPointsDistributed: 2500000,
    totalValueGiven: 185000,     // FCFA
    conversionRate: 78.5,        // % rewards claimed per user
    averageRewardsPerUser: 2.3,
    topReward: "5% réduction",
    underPerforming: ["15% PRESSING"],
    budgetRemaining: 315000,
    roi: 2.4                     // Revenue increase vs rewards cost
  }
}
```

### Dashboard Admin

```dart
// frontend/mobile/admin-dashboard/lib/screens/loyalty/components/rewards_analytics.dart

Widget buildRewardsAnalytics() {
  return Column(
    children: [
      // Rewards performance grid
      GridView.count(
        crossAxisCount: 3,
        children: [
          StatsCard(
            title: "Total réclamés",
            value: "2,150",
            trend: "+15%"
          ),
          StatsCard(
            title: "Taux rédemption",
            value: "78.5%",
            trend: "Stable"
          ),
          StatsCard(
            title: "Budget utilisé",
            value: "37%",
            trend: "OK"
          ),
        ],
      ),
      
      // Individual reward performance
      RewardPerformanceTable(
        rewards: allRewards,
        metrics: rewardMetrics
      ),
      
      // Recommendations
      RecommendationsCard(
        topReward: "5% réduction",
        underPerforming: "15% PRESSING",
        suggestions: [
          "Augmenter limite 10% réduction",
          "Réduire points pour 15% PRESSING",
          "Ajouter nouveau GIFT reward"
        ]
      )
    ],
  );
}
```

---

## 💡 Recommandations Finales pour Votre Reward Partenariat

### Avant Lancement

1. **Contacter les Partenaires** ✅
   ```
   Email aux partenaires:
   "Alpha Laundry recherche des commerces partenaires pour 
    récompenses client (Supermarché, Restaurant, Centre Commercial).
    
    Intérêt: Vos clients Alpha = nouveaux clients pour vous!
    Commission: Alpha 70%, Partenaire 30% (split de la valeur)"
   ```

2. **Définir Process**
   - Quels partenaires acceptent?
   - QR code ou code texte?
   - Quelle validité? (30, 60 jours?)
   - Qui valide l'utilisation?

3. **Tester Avec 1 Partenaire**
   ```
   Phase 1: Accord avec 1 supermarché
   ├─ Tester le process
   ├─ Vérifier adoption client
   ├─ Analyser ROI
   └─ Documenter learnings
   
   Phase 2: Expansion à 3-5 partenaires
   ```

4. **Infrastructure Technique**
   ```typescript
   // backend/src/services/partnerVoucher.service.ts
   
   export class PartnerVoucherService {
     // Générer code unique
     async generateVoucherCode(rewardId, userId) {}
     
     // Valider code
     async validateVoucherCode(code) {}
     
     // Enregistrer utilisation
     async markAsRedeemed(code, partnerId, transactionId) {}
     
     // Envoyer notification au partenaire
     async notifyPartner(voucher) {}
   }
   ```

5. **Pricing Strategy**
   ```
   Client réclame: 500 points
   ↓
   Vous payez au partenaire: 2000 × 30% = 600 FCFA
   ↓
   Votre ROI (bénéfice Alpha):
   - Client retention: +20%
   - AOV increase: +15%
   - New partner network: +3 commerces
   ```

### Variantes Possibles

```javascript
// Autre approche: Reward différent par partenaire

Reward 1: "Bon Supermarché ABC 1500 FCFA"
Reward 2: "Bon Restaurant XYZ 2000 FCFA"
Reward 3: "Bon Centre Commercial 2500 FCFA"

Avantage: Plus spécifique, client choisit lieu préféré
Inconvénient: Trop de rewards, confus
```

---

## 📋 Checklist Pré-Lancement

- [ ] 9 rewards configurés en base de données
- [ ] Admin dashboard affiche toutes les rewards
- [ ] Client app affiche catalogue rewards
- [ ] Reward claims workflow testé (claim → approve → use)
- [ ] Points deduction working
- [ ] Email notifications pour réclamations
- [ ] Partenaires contactés et accord signé
- [ ] Voucher codes generation tested
- [ ] Admin analytics dashboard fonctionnel
- [ ] KPI monitoring configured
- [ ] Marketing assets prêts (email, push, landing page)
- [ ] Customer support script prêt

---

## 🎯 Résumé Exécutif

### Pour le Lancement

**9 Rewards Essentielles:**
1. ✅ 5% réduction (100 pts)
2. ✅ 10% réduction (250 pts)
3. ✅ 15% PRESSING (400 pts)
4. ✅ Livraison gratuite (200 pts)
5. ✅ Repassage gratuit (180 pts)
6. ✅ Kit entretien (350 pts)
7. ✅ **Bon Partenaire 2000 FCFA (500 pts)** ← VOTRE IDÉE
8. ✅ Bon 500 FCFA (150 pts)
9. ✅ Bon 1000 FCFA (350 pts)

### Catégorisation de Votre Reward

**Type:** `VOUCHER` (pas GIFT)

**Raison:** Code digital sans livraison physique, utilisable chez tiers

**Avantage:** 
- Flexible pour client
- Simple techniquement
- Partenaires gèrent leur côté
- Partagez le coût

### Budget Estimé Mois 1

```
DISCOUNT rewards:     50 000 FCFA (3 × réductions)
FREESERVICE rewards:  20 000 FCFA (livraison, repassage)
GIFT rewards:         15 000 FCFA (kits = 100 × 150)
VOUCHER rewards:      40 000 FCFA (codes)
─────────────────────────────────
TOTAL MONTH 1:       125 000 FCFA
(~3-4% de revenue si 4M FCFA revenue)
```

**Recommandation:** Budgéter 150-200k FCFA pour mois 1 (marge de sécurité)

---

**Rédigé par:** Assistant d'analyse stratégie  
**Dernier update:** 16 Octobre 2025  
**Pour:** Projet Alpha - Stratégie Lancement Rewards
