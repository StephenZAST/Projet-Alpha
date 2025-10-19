# 🎁 Documentation Complète - Types de Récompenses (Rewards System)

**Date de création:** 16 Octobre 2025  
**Version:** 1.0  
**Application:** Alpha Laundry & Pressing  
**Statut:** ✅ Implémentation COMPLÈTE

---

## 📋 Table des Matières

1. [Introduction](#introduction)
2. [Architecture du Système](#architecture-du-système)
3. [Type 1: Réductions (Discount)](#type-1--réductions-discount)
4. [Type 2: Services Gratuits (FreeService)](#type-2--services-gratuits-freeservice)
5. [Type 3: Cadeaux (Gift)](#type-3--cadeaux-gift)
6. [Type 4: Bons d'Achat (Voucher)](#type-4--bons-dachat-voucher)
7. [Configuration Recommandée Initial](#configuration-recommandée-initial)
8. [Implémentation Technique](#implémentation-technique)
9. [Exemples Pratiques](#exemples-pratiques)
10. [Cas d'Usage](#cas-dusage)

---

## 🎯 Introduction

### Qu'est-ce qu'une Récompense?

Une **récompense** est une récompense que les clients fidèles peuvent recevoir en échange de leurs **points de fidélité**.

**Flux simple:**
```
Client accumule points via achats
    ↓
Client voit catalogue de récompenses
    ↓
Client réclame récompense (dépense points)
    ↓
Admin approuve/rejette
    ↓
Client reçoit sa récompense
```

### Types Supportés

Votre système supporte **4 catégories principales** de récompenses:

| Type | Enum | Description | Exemple |
|------|------|-------------|---------|
| 💰 **Réductions** | `DISCOUNT` | Pourcentage ou montant fixe | 10% ou 500 FCFA |
| 🚚 **Services Gratuits** | `FREESERVICE` | Service offert gratuitement | Livraison gratuite |
| 🎀 **Cadeaux** | `GIFT` | Article physique ou produit | Kit d'entretien |
| 🎫 **Bons d'Achat** | `VOUCHER` | Bon valable pendant période | Bon 500 FCFA |

**Référence:** 
- 📁 `backend/prisma/schema.prisma` (model `rewards`)
- 📁 `frontend/mobile/customers_app/lib/core/models/loyalty.dart` (enum `RewardType`)

---

## 🏗️ Architecture du Système

### Modèle de Données (Prisma)

📁 **Référence:** `backend/prisma/schema.prisma`

```prisma
model rewards {
  id               String   @id @default(dbgenerated("gen_random_uuid()"))
  name             String              // Ex: "10% de réduction"
  description      String?             // Description détaillée
  pointsCost       Int                 // Points requis pour réclamer
  type             String              // 'DISCOUNT', 'FREESERVICE', 'GIFT', 'VOUCHER'
  discountValue    Decimal?            // Valeur: 10 (10%) ou 500 (500 FCFA)
  discountType     String?             // 'PERCENTAGE' ou 'FIXED_AMOUNT'
  maxRedemptions   Int?                // Limite globale (null = illimité)
  currentRedemptions Int?              // Nombre de fois déjà utilisée
  isActive         Boolean @default(true)
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt
  reward_claims    reward_claims[]
}

model reward_claims {
  id               String   @id @default(dbgenerated("gen_random_uuid()"))
  userId           String
  rewardId         String
  pointsUsed       Int      // Points dépensés pour cette récompense
  status           String   // 'PENDING', 'APPROVED', 'REJECTED', 'USED'
  createdAt        DateTime @default(now())
  processedAt      DateTime?
  usedAt           DateTime?
  rejectionReason  String?
  users            users    @relation(fields: [userId], references: [id])
  rewards          rewards  @relation(fields: [rewardId], references: [id])
}
```

### Modèle Frontend (Dart)

📁 **Référence:** `frontend/mobile/customers_app/lib/core/models/loyalty.dart`

```dart
enum RewardType {
  discount,      // Réductions
  freeService,   // Services gratuits
  gift,          // Cadeaux
  voucher,       // Bons d'achat
}

class Reward {
  final String id;
  final String name;              // "10% de réduction"
  final String description;       // Description détaillée
  final int pointsRequired;       // Points nécessaires
  final RewardType type;
  final double? discountPercentage;   // Pour DISCOUNT PERCENTAGE
  final double? discountAmount;       // Pour DISCOUNT FIXED_AMOUNT
  final bool isActive;
  final DateTime createdAt;
  
  // Getters utiles
  bool get isAvailable => isActive;
  String get formattedPoints => '${pointsRequired} pts';
  String get displayValue => /* voir sections suivantes */;
}
```

---

## 💰 Type 1 – Réductions (Discount)

### Description

Les réductions permettent aux clients de **recevoir une réduction** (pourcentage ou montant) sur leurs commandes.

### Sous-Types

#### 1.1 Réductions Pourcentage (Percentage)

**Concept:** Une réduction de X% sur le total de la commande

**Exemples:**
- 5% de réduction
- 10% de réduction
- 15% de réduction (services PRESSING uniquement)
- 20% de réduction (services LAVAGE+REPASSAGE)
- 25% de réduction (nouvelle commande)

**Configuration:**
```javascript
{
  id: "reward-001",
  name: "5% de réduction",
  description: "5% de réduction sur votre prochaine commande",
  type: "DISCOUNT",
  discountType: "PERCENTAGE",
  discountValue: 5,
  pointsCost: 100,
  maxRedemptions: null,           // Illimité
  isActive: true,
  createdAt: "2025-01-01T00:00:00Z"
}
```

**Calcul Exemple:**
```
Commande: 10 000 FCFA
Réduction: 5%
Montant réduction: 10 000 × 5% = 500 FCFA
Total après réduction: 9 500 FCFA
```

**Avantages:**
- ✅ Scalable avec le prix de la commande
- ✅ Transparent pour le client
- ✅ Flexible selon service

**Cas d'usage ideal:**
- Récompenses pour clients réguliers
- Incentives de dépense progressive

---

#### 1.2 Réductions Montant Fixe (Fixed Amount)

**Concept:** Une réduction d'un montant exact (ex: 500 FCFA) sur le total

**Exemples:**
- 500 FCFA de réduction
- 1000 FCFA de réduction
- 2000 FCFA de réduction (commande ≥ 10 000 FCFA)
- 5000 FCFA de réduction (gros butin)

**Configuration:**
```javascript
{
  id: "reward-002",
  name: "500 FCFA de réduction",
  description: "500 FCFA de réduction sur votre prochaine commande",
  type: "DISCOUNT",
  discountType: "FIXED_AMOUNT",
  discountValue: 500,
  pointsCost: 150,
  maxRedemptions: 100,            // Limité à 100 utilisations
  isActive: true
}
```

**Calcul Exemple:**
```
Commande: 10 000 FCFA
Réduction: 500 FCFA fixe
Total après réduction: 10 000 - 500 = 9 500 FCFA
```

**Avantages:**
- ✅ Simple et prévisible
- ✅ Facile à contrôler le budget
- ✅ Impact immediat visible

**Cas d'usage ideal:**
- Récompenses pour petites dépenses
- Promotions saisonnières

---

### Stratégie de Tarification

| Niveau | Réduction | Points | Fréquence | Stratégie |
|--------|-----------|--------|-----------|-----------|
| **Bronze** | 5% | 100 | ∞ | Accès facile, fidélité |
| **Silver** | 10% | 200 | 500 max | Clients réguliers |
| **Gold** | 15% | 350 | 200 max | VIP clients |
| **Platinum** | 20% | 500 | 100 max | Top clients |

---

## 🚚 Type 2 – Services Gratuits (FreeService)

### Description

Les services gratuits permettent aux clients de **recevoir des services normalement payants gratuitement**.

### Types de Services Gratuits Disponibles

Votre système supporte les services suivants (référence: `backend/prisma/schema.prisma`):

#### 2.1 Livraison Gratuite

**Concept:** Récompense qui offre une livraison gratuite

**Configuration:**
```javascript
{
  id: "reward-003",
  name: "Livraison gratuite",
  description: "Bénéficiez d'une livraison gratuite sur votre prochaine commande",
  type: "FREESERVICE",
  pointsCost: 250,
  maxRedemptions: null,           // Illimité
  isActive: true,
  metadata: {
    service: "LIVRAISON",         // Référence au service
    value: "FULL"                 // Livraison complète
  }
}
```

**Économie Client:**
```
Frais de livraison normaux: 2 000 FCFA
Avec récompense: 0 FCFA
Économie: 2 000 FCFA
```

**Applicabilité:**
- ✅ Toutes les commandes
- ✅ Aucune restriction de montant
- ✅ Non cumulable avec autres livraisons gratuites

---

#### 2.2 Collecte Gratuite

**Concept:** Récompense qui offre une collecte gratuite (absence de frais de collecte)

**Configuration:**
```javascript
{
  id: "reward-004",
  name: "Collecte gratuite",
  description: "Nos livreurs viennent collecter vos vêtements gratuitement",
  type: "FREESERVICE",
  pointsCost: 250,
  maxRedemptions: null,
  isActive: true,
  metadata: {
    service: "COLLECTE",
    value: "FULL"
  }
}
```

**Note:** Votre système gère COLLECTE comme un service distinct.

---

#### 2.3 Repassage Gratuit

**Concept:** Récompense qui offre le repassage gratuit pour une commande

**Configuration:**
```javascript
{
  id: "reward-005",
  name: "Repassage gratuit",
  description: "Repassage gratuit de 1 article sur votre prochaine commande",
  type: "FREESERVICE",
  pointsCost: 200,
  maxRedemptions: null,
  isActive: true,
  metadata: {
    service: "REPASSAGE",
    quantity: 1,                  // 1 article
    type: "SIMPLE"                // Repassage simple
  }
}
```

**Services de Repassage Disponibles:**
```
- REPASSAGE SIMPLE        (1 article gratuit)
- REPASSAGE DELICATE      (1 article délicat gratuit)
- REPASSAGE VIP           (1 article premium gratuit)
```

---

#### 2.4 Nettoyage à Sec Gratuit

**Concept:** Récompense qui offre un nettoyage à sec gratuit

**Configuration:**
```javascript
{
  id: "reward-006",
  name: "Nettoyage à sec gratuit",
  description: "Nettoyage à sec complet d'1 article",
  type: "FREESERVICE",
  pointsCost: 350,
  maxRedemptions: 100,
  isActive: true,
  metadata: {
    service: "NETTOYAGE_A_SEC",
    quantity: 1,
    standard_price: 5000         // Valeur normale du service
  }
}
```

**Type de Nettoyage:**
```
- Nettoyage à sec STANDARD
- Nettoyage à sec PREMIUM (délicats)
- Nettoyage à sec RUSH (24h)
```

---

#### 2.5 Lavage Gratuit

**Concept:** Récompense qui offre un lavage simple gratuit

**Configuration:**
```javascript
{
  id: "reward-007",
  name: "Lavage simple gratuit",
  description: "Lavage complet d'1 article",
  type: "FREESERVICE",
  pointsCost: 150,
  maxRedemptions: null,
  isActive: true,
  metadata: {
    service: "LAVAGE_SIMPLE",
    quantity: 1
  }
}
```

**Types de Lavage:**
```
- Lavage SIMPLE            (eau)
- Lavage DÉLICAT           (produits spécialisés)
- Lavage + REPASSAGE       (combo)
```

---

#### 2.6 Service Combo Gratuit

**Concept:** Récompense qui offre un combo de services (ex: Lavage + Repassage)

**Configuration:**
```javascript
{
  id: "reward-008",
  name: "Lavage + Repassage gratuit",
  description: "Lavage complet + repassage de 1 article",
  type: "FREESERVICE",
  pointsCost: 400,
  maxRedemptions: 50,
  isActive: true,
  metadata: {
    service: "COMBO_LAVAGE_REPASSAGE",
    quantity: 1,
    standard_price: 8000
  }
}
```

---

### Restrictions et Conditions

**Restrictions Possibles:**
- ✅ Valable 30 jours après rédemption
- ✅ Non cumulable avec autres services gratuits
- ✅ 1 utilisation par commande
- ✅ Non remboursable en points
- ✅ Nécessite commande minimum (optionnel)

---

## 🎀 Type 3 – Cadeaux (Gift)

### Description

Les cadeaux sont des **articles physiques ou produits** offerts aux clients.

### Catégories de Cadeaux

#### 3.1 Cadeaux Produits d'Entretien

**Concept:** Produits pour entretenir les vêtements

**Exemples:**

| Cadeau | Description | Points | Valeur | Limite |
|--------|-------------|--------|--------|--------|
| Kit complet d'entretien | Savon + spray + brosse | 400 | ~3000 FCFA | 50 |
| Spray détachant | Spray anti-taches | 200 | ~2000 FCFA | 100 |
| Savon laine délicate | Savon spécialisé | 150 | ~1500 FCFA | 200 |
| Brosse nettoyante | Brosse vêtements | 100 | ~1000 FCFA | 100 |
| Désodorisant textile | Spray parfumé | 80 | ~800 FCFA | ∞ |

**Configuration Exemple:**
```javascript
{
  id: "reward-009",
  name: "Kit d'entretien complet",
  description: "Savon + Spray détachant + Brosse de nettoyage",
  type: "GIFT",
  pointsCost: 400,
  maxRedemptions: 50,
  isActive: true,
  metadata: {
    category: "CARE_PRODUCTS",
    items: [
      { name: "Savon", type: "SOAP", quantity: 1 },
      { name: "Spray détachant", type: "STAIN_REMOVER", quantity: 1 },
      { name: "Brosse", type: "BRUSH", quantity: 1 }
    ],
    marketValue: 3000,
    partner: "AquaClean"           // Marque partenaire
  }
}
```

---

#### 3.2 Cadeaux Accessoires

**Concept:** Accessoires utiles pour le repassage et l'entretien

**Exemples:**

| Cadeau | Description | Points | Valeur |
|--------|-------------|--------|--------|
| Cintre premium (lot 5) | Cintres de qualité | 150 | ~2500 FCFA |
| Pince à cravate | Accessoire repassage | 100 | ~1500 FCFA |
| Pochette vêtements | Sac de protection | 80 | ~1200 FCFA |
| Housse costume | Protection premium | 200 | ~3500 FCFA |
| Sac rangement tissu | Sac rangement | 120 | ~1800 FCFA |

**Configuration:**
```javascript
{
  id: "reward-010",
  name: "Lot de 5 cintres premium",
  description: "Cintres de qualité supérieure pour préserver vos vêtements",
  type: "GIFT",
  pointsCost: 150,
  maxRedemptions: 100,
  isActive: true,
  metadata: {
    category: "ACCESSORIES",
    quantity: 5,
    model: "Premium Wood Hangers",
    partner: "Acmecorp"
  }
}
```

---

#### 3.3 Cadeaux Parfum/Bien-être

**Concept:** Produits parfum ou bien-être pour la maison/armoire

**Exemples:**

| Cadeau | Description | Points |
|--------|-------------|--------|
| Parfum d'armoire | Parfum pour armoire | 120 |
| Diffuseur textile | Diffuseur pour vêtements | 150 |
| Sachet parfumé (lot 3) | Sachets aromathérapie | 100 |
| Spray textile frais | Spray rafraîchissant | 90 |

---

#### 3.4 Cadeaux Catégories Spéciales

**Concepts Avancés:**

- **Giftcard Partenaire:** Carte cadeau commercant partenaire (500 FCFA)
- **Bon Restaurant:** Partenariat avec restaurants locaux
- **Ticket Cinéma:** Accès à divertissement

---

### Workflow de Livraison de Cadeaux

```
1. Client réclame cadeau
   ↓
2. Admin approuve la réclamation
   ↓
3. Système génère:
   - Code de collecte
   - QR code unique
   - Email avec détails
   ↓
4. Client vient chercher cadeau en magasin
   (OU livreur apporte cadeau)
   ↓
5. Vérification QR code
   ↓
6. Cadeau remis au client
   ↓
7. Status: USED
```

---

## 🎫 Type 4 – Bons d'Achat (Voucher)

### Description

Les bons d'achat sont des **bons valables pendant une période limitée** pour réduire le prix des services.

### Caractéristiques

#### 4.1 Bons Standards

**Concept:** Bon valable X jours sur tous les services (sauf restrictions)

**Exemples:**

| Bon | Valeur | Points | Durée | Cumul | Limite |
|-----|--------|--------|-------|-------|--------|
| Bon 250 FCFA | 250 FCFA | 80 | 30j | Non | ∞ |
| Bon 500 FCFA | 500 FCFA | 150 | 30j | Non | 100 |
| Bon 1000 FCFA | 1000 FCFA | 300 | 30j | Non | 50 |
| Bon 2000 FCFA | 2000 FCFA | 500 | 30j | Non | 25 |
| Bon 5000 FCFA | 5000 FCFA | 1000 | 60j | Non | 10 |

**Configuration:**
```javascript
{
  id: "reward-011",
  name: "Bon 500 FCFA",
  description: "Bon d'achat de 500 FCFA valable 30 jours sur tous les services",
  type: "VOUCHER",
  discountType: "FIXED_AMOUNT",
  discountValue: 500,
  pointsCost: 150,
  maxRedemptions: 100,
  isActive: true,
  metadata: {
    validity_days: 30,
    minimum_purchase: null,       // Aucun minimum
    cumulative: false,            // Non cumulable
    applicable_services: "ALL",   // Tous les services
    code_format: "VOUCHER-####",  // Format du code
    expiry_date: "2025-11-15"
  }
}
```

---

#### 4.2 Bons Restreints

**Concept:** Bon valable uniquement sur certains services

**Exemples:**

| Bon | Service | Valeur | Points | Durée |
|-----|---------|--------|--------|-------|
| Bon PRESSING 300 FCFA | PRESSING uniquement | 300 | 120 | 30j |
| Bon LAVAGE 250 FCFA | LAVAGE uniquement | 250 | 100 | 30j |
| Bon RUSH 250 FCFA | Services EXPRESS | 250 | 100 | 30j |
| Bon LIVRAISON 200 FCFA | Livraison uniquement | 200 | 80 | 30j |

**Configuration:**
```javascript
{
  id: "reward-012",
  name: "Bon PRESSING 300 FCFA",
  description: "Bon de 300 FCFA valable sur services PRESSING uniquement",
  type: "VOUCHER",
  discountType: "FIXED_AMOUNT",
  discountValue: 300,
  pointsCost: 120,
  maxRedemptions: 200,
  isActive: true,
  metadata: {
    validity_days: 30,
    minimum_purchase: 1000,       // Commande ≥ 1000 FCFA
    cumulative: false,
    applicable_services: ["PRESSING"],  // Restriction
    applicable_service_types: ["DRY_CLEANING", "STEAM_PRESSING"]
  }
}
```

---

#### 4.3 Bons Premium (VIP)

**Concept:** Bons exclusifs pour clients VIP/Platinum

**Exemples:**

| Bon | Restrictions | Points | Notes |
|-----|-------------|--------|-------|
| VIP 1000 FCFA | Accès VIP uniquement | 400 | Non remboursable |
| VIP 15% | VIP uniquement | 500 | Cumulable avec offres |
| Bon ANNIVERSAIRE | Clients depuis 1 an+ | 200 | Valable 60j |

**Configuration:**
```javascript
{
  id: "reward-013",
  name: "Bon VIP 1000 FCFA",
  description: "Accès VIP uniquement - 1000 FCFA sur tout service",
  type: "VOUCHER",
  discountType: "FIXED_AMOUNT",
  discountValue: 1000,
  pointsCost: 400,
  maxRedemptions: 50,
  isActive: true,
  metadata: {
    validity_days: 60,
    vip_only: true,               // Exclusif VIP
    minimum_purchase: 5000,
    cumulative: true,             // Peut se cumuler
    tier: "PLATINUM"
  }
}
```

---

### Conditions des Bons

**Restrictions Possibles:**

1. **Minimum d'Achat:**
   - Bon valable à partir de 1000 FCFA d'achats
   - Bon valable à partir de 5000 FCFA (bons premium)

2. **Durée de Validité:**
   - 30 jours pour bons standards
   - 60 jours pour bons VIP
   - Non remboursable après expiration

3. **Cumulativité:**
   - Non cumulable avec autres bons (généralement)
   - Cumulable avec les offres commerciales (optionnel)

4. **Services Applicables:**
   - Tous les services (généralement)
   - Certains services uniquement (restriction)

5. **Restrictions Clients:**
   - Pas plus de 1 bon par commande (généralement)
   - Exclusif VIP (pour bons premium)
   - 1 utilisation par client (généralement)

---

### Génération et Gestion des Codes

**Format des Codes:**
```
Standard:     VOUCHER-XXXX-YYYY    (ex: VOUCHER-5001-A3B7)
VIP:          ALPHA-VIP-XXXX       (ex: ALPHA-VIP-2024)
Spécial:      FIDELITE-MMDD-XXXX   (ex: FIDELITE-1216-5AB9)
```

**Métadonnées:**
```javascript
{
  code: "VOUCHER-5001-A3B7",
  reward_id: "reward-011",
  user_id: "client-123",
  issued_date: "2025-10-16",
  expiry_date: "2025-11-15",
  used_date: null,
  order_id: null,
  is_used: false,
  discount_applied: 0
}
```

---

## 🚀 Configuration Recommandée Initial

### Phase 1: Démarrage (Semaine 1)

**Objectif:** 5 récompenses simples et populaires

```javascript
[
  {
    id: "reward-101",
    name: "5% de réduction",
    type: "DISCOUNT",
    discountType: "PERCENTAGE",
    discountValue: 5,
    pointsCost: 100,
    maxRedemptions: null,
    isActive: true
  },
  {
    id: "reward-102",
    name: "Bon 500 FCFA",
    type: "VOUCHER",
    discountType: "FIXED_AMOUNT",
    discountValue: 500,
    pointsCost: 150,
    maxRedemptions: 100,
    isActive: true
  },
  {
    id: "reward-103",
    name: "Livraison gratuite",
    type: "FREESERVICE",
    pointsCost: 250,
    maxRedemptions: null,
    isActive: true
  },
  {
    id: "reward-104",
    name: "Repassage gratuit",
    type: "FREESERVICE",
    pointsCost: 200,
    maxRedemptions: null,
    isActive: true
  },
  {
    id: "reward-105",
    name: "Spray détachant",
    type: "GIFT",
    pointsCost: 200,
    maxRedemptions: 100,
    isActive: true
  }
]
```

---

### Phase 2: Expansion (Semaine 2-3)

**Objectif:** Ajouter 8-10 récompenses supplémentaires

```javascript
[
  // ... Phase 1 ...
  {
    id: "reward-201",
    name: "10% de réduction",
    type: "DISCOUNT",
    discountType: "PERCENTAGE",
    discountValue: 10,
    pointsCost: 250,
    maxRedemptions: 500,
    isActive: true
  },
  {
    id: "reward-202",
    name: "Bon PRESSING 300 FCFA",
    type: "VOUCHER",
    discountType: "FIXED_AMOUNT",
    discountValue: 300,
    pointsCost: 120,
    maxRedemptions: 200,
    isActive: true
  },
  {
    id: "reward-203",
    name: "Nettoyage à sec gratuit",
    type: "FREESERVICE",
    pointsCost: 350,
    maxRedemptions: 100,
    isActive: true
  },
  {
    id: "reward-204",
    name: "Kit d'entretien complet",
    type: "GIFT",
    pointsCost: 400,
    maxRedemptions: 50,
    isActive: true
  },
  {
    id: "reward-205",
    name: "Bon 1000 FCFA",
    type: "VOUCHER",
    discountType: "FIXED_AMOUNT",
    discountValue: 1000,
    pointsCost: 300,
    maxRedemptions: 50,
    isActive: true
  }
]
```

---

### Phase 3: Optimisation (Semaine 4+)

**Objectif:** Tester et affiner selon données d'utilisation

- Analyser les récompenses les plus demandées
- Ajuster les points requis
- Ajouter récompenses saisonnières
- Créer niveaux VIP exclusifs

---

## 🔧 Implémentation Technique

### 1. Créer une Récompense (Backend)

📁 **Référence:** 
- `backend/src/controllers/loyalty.controller.ts` (line 173)
- `backend/src/services/loyaltyAdmin.service.ts` (line 338)

**Route API:**
```typescript
POST /api/loyalty/admin/rewards
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "name": "10% de réduction",
  "description": "10% de réduction sur votre prochaine commande",
  "type": "DISCOUNT",
  "discountType": "PERCENTAGE",
  "discountValue": 10,
  "pointsCost": 200,
  "maxRedemptions": 500,
  "isActive": true
}
```

**Réponse:**
```json
{
  "success": true,
  "data": {
    "id": "reward-001",
    "name": "10% de réduction",
    "type": "DISCOUNT",
    "pointsCost": 200,
    "maxRedemptions": 500,
    "createdAt": "2025-10-16T10:30:00Z"
  }
}
```

---

### 2. Récupérer les Récompenses (Client)

📁 **Référence:** 
- `frontend/mobile/customers_app/lib/providers/loyalty_provider.dart`
- `frontend/mobile/customers_app/lib/screens/loyalty/rewards_catalog_screen.dart`

**Service Client:**
```dart
// Dans loyalty_provider.dart
Future<void> fetchAvailableRewards() async {
  final response = await _apiService.get('/loyalty/admin/rewards');
  
  if (response.statusCode == 200) {
    _rewards = (response.data['data'] as List)
        .map((r) => Reward.fromJson(r))
        .toList();
    notifyListeners();
  }
}
```

**Affichage:**
```dart
// Dans rewards_catalog_screen.dart
ListView.builder(
  itemCount: _rewards.length,
  itemBuilder: (context, index) {
    final reward = _rewards[index];
    return RewardCard(
      reward: reward,
      onClaim: () => _claimReward(reward.id),
    );
  },
)
```

---

### 3. Réclamer une Récompense (Client)

**Service:**
```dart
Future<void> claimReward(String rewardId) async {
  final response = await _apiService.post(
    '/loyalty/client/claim-reward',
    data: {
      'rewardId': rewardId,
      'userId': currentUserId,
    },
  );
  
  if (response.statusCode == 200) {
    // Pointsautomatiquement déduits
    // reward_claims créé avec status: PENDING
    print('Récompense réclamée!');
  }
}
```

---

### 4. Gérer les Récompenses (Admin)

📁 **Référence:** 
- `frontend/mobile/admin-dashboard/lib/screens/loyalty/components/rewards_management_dialog.dart`
- `frontend/mobile/admin-dashboard/lib/controllers/loyalty_controller.dart`

**Opérations Admin:**
```dart
// Créer
await LoyaltyService.createReward(rewardData);

// Modifier
await LoyaltyService.updateReward(rewardId, updateData);

// Supprimer
await LoyaltyService.deleteReward(rewardId);

// Désactiver
await LoyaltyService.toggleRewardStatus(rewardId, isActive: false);

// Approuver réclamation
await LoyaltyService.approveRewardClaim(claimId);

// Rejeter réclamation
await LoyaltyService.rejectRewardClaim(claimId, reason);

// Marquer comme utilisée
await LoyaltyService.markRewardClaimAsUsed(claimId);
```

---

## 💡 Exemples Pratiques

### Exemple 1: Client Nouveau Gagne ses Premiers Points

```
Scénario: Mohamed s'inscrit + premiere commande

1. Mohamed crée compte
2. Première commande: 2500 FCFA
   → 2500 points gagnés (1 point = 1 FCFA)
   
3. Points totaux: 2500 pts

4. Mohamed voit le catalogue:
   - 5% réduction (100 pts) ✓ accessible
   - Bon 500 FCFA (150 pts) ✓ accessible
   - Livraison gratuite (250 pts) ✓ accessible
   - Kit d'entretien (400 pts) ✓ accessible
   - 10% réduction (200 pts) ✓ accessible
   - Bon 1000 FCFA (300 pts) ✓ accessible
   - Bon 5000 FCFA (1000 pts) ✗ NOT accessible

5. Mohamed réclame: "Bon 500 FCFA"
   → 150 points déduits
   → Points restants: 2350
   → reward_claims.create(status: PENDING)
   → Admin approuve
   → Code généré: VOUCHER-5001-K2M9
   → Email envoyé au client
```

---

### Exemple 2: Client VIP Utilise Points Premium

```
Scénario: Fatima cliente depuis 2 ans, 15 000 points accumulés

1. Fatima voit récompenses VIP:
   - Bon VIP 1000 FCFA (400 pts)
   - Nettoyage complet gratuit (500 pts)
   - Kit premium d'entretien (600 pts)
   - Bon 15% réduction (800 pts)

2. Fatima réclame: "Bon VIP 1000 FCFA"
   → 400 points déduits
   → Points restants: 14600
   
3. Code généré: ALPHA-VIP-2024-F7X3
   Validité: 60 jours
   Minimum d'achat: 5000 FCFA
   
4. Fatima l'utilise sur commande 8000 FCFA:
   Avant: 8000 FCFA
   Réduction: -1000 FCFA
   Total final: 7000 FCFA
   
5. reward_claims.status = USED
```

---

### Exemple 3: Admin Gère Récompenses Limitées

```
Scénario: Admin veut créer récompense limitée

1. Admin crée récompense:
   Nom: "Nettoyage à sec gratuit"
   Type: FREESERVICE
   Points: 350
   Max rédemptions: 100 (limité)
   
2. Clients commencent à réclamer:
   - Claim 1: ✓ Approuvé (99 restantes)
   - Claim 2: ✓ Approuvé (98 restantes)
   - ...
   - Claim 100: ✓ Approuvé (0 restantes)
   
3. Claim 101: ✗ ERREUR "Récompense épuisée"
   
4. Admin désactive: rewards.isActive = false
   
5. Clients ne voient plus la récompense
```

---

### Exemple 4: Saisonnalité - Récompense Spéciale Noël

```
Scénario: Admin crée récompense Noël

1. Admin crée récompense temporaire:
   Nom: "Bon Noël 2500 FCFA"
   Type: VOUCHER
   Valeur: 2500 FCFA
   Points: 600 (prix réduit pour occasion)
   Validité: 45 jours
   Max rédemptions: 500
   
2. Clients voient récompense spéciale
   
3. Après période:
   Admin désactive: isActive = false
   
4. Récompense reste dans l'historique
   mais n'est plus réclamable
```

---

## 📊 Cas d'Usage

### Use Case 1: Client Fidèle

```
👤 Profile: Fatima, cliente depuis 2 ans
💰 Points accumulés: 12,000 pts
🎯 Objectif: Maximiser économies

Stratégie:
1. Attendre récompense 1000 FCFA (300 pts)
2. Utiliser sur commande 6000 FCFA
3. Économie: 1000 FCFA (16.7%)

Ou:

1. Utiliser 10% réduction (250 pts)
2. Sur commande 5000 FCFA
3. Économie: 500 FCFA (10%)

Recommandation: Utiliser Bon 1000 FCFA
```

---

### Use Case 2: Admin Promo Saisonnière

```
🎄 Période: Novembre (avant Noël)

Stratégie Admin:
1. Créer récompense SPÉCIALE:
   - Bon 2000 FCFA (points réduits)
   - Valide 60 jours
   - Max 300 rédemptions
   
2. Promouvoir via email/push
   
3. Résultat attendu:
   - +30% commandes en novembre
   - +500 pts gagnés par client moyen
   - Client satisfait pour cadeaux
```

---

### Use Case 3: Acquisition Nouveaux Clients

```
🆕 Audience: Nouveaux inscrits

Stratégie:
1. BONUS D'INSCRIPTION: +250 pts gratuits
2. Après 1ère commande: +X pts (calculés)
3. Total rapide: 500-1000 pts possibles

4. Récompenses attractives:
   - 5% réduction (100 pts) - facile accès
   - Bon 250 FCFA (80 pts) - très accessible
   
5. Résultat:
   - Nouveau client peut réclamer rapidement
   - Crée habitude d'utilisation
   - Fidélisation progressive
```

---

### Use Case 4: Gestion Inventaire Limité

```
🎁 Cadeau: Kit d'entretien (50 kits disponibles)

Workflow:
1. Admin crée récompense avec maxRedemptions: 50
2. Clients réclament progressivement
3. Système track: currentRedemptions incrementé
4. Après 50 rédemptions: Récompense non accessible
5. Admin peut:
   - Réapprovisionner (réactiver)
   - Supprimer définitivement
   - Remplacer par autre cadeau
```

---

## 📚 Fichiers de Référence

### Backend
```
✅ backend/prisma/schema.prisma              (models rewards, reward_claims)
✅ backend/src/services/loyaltyAdmin.service.ts  (createReward, approveRewardClaim)
✅ backend/src/controllers/loyalty.controller.ts (endpoint management)
✅ backend/src/routes/loyalty.routes.ts      (routes admin)
```

### Frontend Client
```
✅ frontend/mobile/customers_app/lib/core/models/loyalty.dart     (Reward model)
✅ frontend/mobile/customers_app/lib/providers/loyalty_provider.dart  (state mgmt)
✅ frontend/mobile/customers_app/lib/screens/loyalty/rewards_catalog_screen.dart (UI)
```

### Frontend Admin
```
✅ frontend/mobile/admin-dashboard/lib/models/loyalty.dart        (Reward model)
✅ frontend/mobile/admin-dashboard/lib/services/loyalty_service.dart   (API calls)
✅ frontend/mobile/admin-dashboard/lib/screens/loyalty/components/rewards_management_dialog.dart (CRUD UI)
✅ frontend/mobile/admin-dashboard/lib/controllers/loyalty_controller.dart (logic)
```

---

## 🎯 Recommandations Finales

### Pour Démarrage
1. **Commencer simple:** 5 récompenses de base
2. **Tester auprès utilisateurs:** Feedback sur attrait
3. **Analyser données:** Points requis adaptés?
4. **Itérer:** Ajuster points + récompenses

### Pour Croissance
1. **Ajouter variété:** Mix de 4 types
2. **Créer tiers:** Bronze/Silver/Gold
3. **Promotions saisonnières:** Spécialité
4. **VIP exclusif:** Rewards premium

### Pour Optimisation
1. **Tracker conversion:** Récompenses réellement utilisées?
2. **Ajuster prix:** Points requis trop hauts/bas?
3. **Ajouter limites:** Gérer coûts
4. **Notification:** Rappeler récompenses disponibles

---

**Rédigé par:** Assistant d'analyse code  
**Dernier update:** 16 Octobre 2025  
**Pour:** Projet Alpha - Système de Récompenses de Fidélité
