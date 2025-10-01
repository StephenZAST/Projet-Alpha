## Documentation API - Module Affiliés

Ce document décrit les endpoints, schémas de données, règles d'authentification et comportements métiers pour le module "Affiliés" de l'API Projet-Alpha.

Fichier(s) sources analysés (extraits) :
- `src/routes/affiliate.routes.ts`
- `src/controllers/affiliate.controller.ts`
- `src/services/affiliate.service/index.ts`
- `src/services/affiliate.service/affiliateProfile.service.ts`
- `src/services/affiliate.service/affiliateCommission.service.ts`
- `src/services/affiliate.service/affiliateWithdrawal.service.ts`
- `src/services/affiliate.service/constants.ts`

---

## Principes généraux

- Tous les endpoints exposés sous `/api/affiliate`.
- Les routes utilisateurs classiques exigent un token JWT (middleware `authMiddleware` ou `authenticateToken`).
- Les routes d'administration exigent un token et un rôle `ADMIN` ou `SUPER_ADMIN` (vérification via `req.user.role`).
- Pagination commune : query params `page` (défaut 1) et `limit` (défaut 10). Les réponses paginées retournent un objet `pagination` contenant `total`, `currentPage`, `limit`, `totalPages`.
- Constantes importantes (voir `constants.ts`) :
  - `INDIRECT_COMMISSION_RATE = 2` (% pour filleuls indirects)
  - `PROFIT_MARGIN_RATE = 0.40` (40% utilisé pour calculs internes)
  - `MIN_WITHDRAWAL_AMOUNT = 5000` (FCFA)
  - `WITHDRAWAL_COOLDOWN_DAYS = 7`
  - `COMMISSION_LEVELS` (BRONZE/SILVER/GOLD/PLATINUM)

---

## Endpoints publics / Affiché par fonctionnalité

Nota : routes listées avec la méthode HTTP, chemin complet relatif à `/api/affiliate`, autorisation requise et résumé du comportement.

### 1) Profil affilié

- GET /profile
  - Auth : oui (token)
  - Controller : `AffiliateController.getProfile`
  - Description : retourne le profil affilié de l'utilisateur courant ainsi que ses dernières transactions (max 5).
  - Response (succès) :
    {
      success: true,
      data: {
        id, userId, affiliateCode, commissionBalance, totalEarned, monthlyEarnings, isActive, status, levelId, totalReferrals,
        transactionsCount, recentTransactions: [ { id, orderId, amount, status, created_at, ... } ]
      }
    }

- PUT /profile
  - Auth : oui
  - Controller : `AffiliateController.updateProfile`
  - Body : champs modifiables (ex : phone, notificationPreferences, paramètres de profil). Voir service `AffiliateProfileService.updateAffiliateProfile`.
  - Response : profil mis à jour.

### 2) Commissions et retraits (utilisateur)

- GET /commissions
  - Auth : oui
  - Controller : `AffiliateController.getCommissions`
  - Query params : `page`, `limit` (pagination)
  - Description : liste des transactions de commissions pour l'affilié (commande liées + retrait éventuels). Utilise `AffiliateCommissionService.getCommissions`.
  - Response : objet `{ data: [...], pagination: {...} }`.

- POST /withdrawal
  - Auth : oui
  - Controller : `AffiliateController.requestWithdrawal`
  - Body : `{ amount: number, ... }` (montant en FCFA)
  - Règles métier :
    - Montant minimal `MIN_WITHDRAWAL_AMOUNT` (5000 FCFA).
    - Vérification du solde `commission_balance` de l'affilié.
    - Vérification d'état `is_active` et `status === 'ACTIVE'`.
    - Respect d'un cooldown (`WITHDRAWAL_COOLDOWN_DAYS`) si implémenté côté service.
  - Comportement : création d'une transaction de retrait dans `commission_transactions` (commande `order_id` = null pour retraits). Déduction du solde dans une transaction atomique.
  - Notifications : envoie d'une notification type `WITHDRAWAL_REQUESTED` à l'utilisateur.
  - Response : la transaction de retrait créée.

### 3) Parrainage / Références

- GET /referrals
  - Auth : oui
  - Controller : `AffiliateController.getReferrals`
  - Description : retourne les profils des filleuls directs d'un affilié. Utilise `AffiliateProfileService.getReferralsByAffiliateId`.

### 4) Niveaux et taux

- GET /levels
  - Auth : non
  - Controller : `AffiliateController.getLevels`
  - Description : retourne la liste des niveaux de commission (`affiliate_levels`) et des informations additionnelles (`indirectCommission`, `profitMargin`).

- GET /current-level
  - Auth : oui
  - Controller : `AffiliateController.getCurrentLevel`
  - Description : calcul ou récupération du niveau courant d'un affilié selon ses gains ou referrals.

### 5) Génération de code affilié

- POST /generate-code
  - Auth : oui
  - Controller : `AffiliateController.generateAffiliateCode`
  - Description : génère un code affilié unique (format utilisé dans `AffiliateService.generateCode()` : préfixe `AFF-<timestamp36>-<rand>`).

### 6) Enregistrement client avec code affilié

- POST /register-with-code
  - Auth : non
  - Controller : `AffiliateController.createCustomerWithAffiliateCode`
  - Body : `{ email, password, firstName, lastName, affiliateCode, phone? }`
  - Description : crée un utilisateur client en liant le code affilié fourni. Utilise `AffiliateService.createCustomerWithAffiliateCode`.

---

## Endpoints administrateur (requièrent rôle ADMIN/SUPER_ADMIN)

- GET /admin/list
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.getAllAffiliates`
  - Query params : `page`, `limit`, `status`, `query` (recherche par email, nom ou code)
  - Response : `{ data: [affiliates], pagination }`

- GET /admin/stats
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.getAffiliateStats`
  - Description : statistiques globales liées aux affiliés (nombre, totaux commissions, retrait en attente, top affiliates, ...).

- GET /admin/withdrawals/pending
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.getPendingWithdrawals`
  - Description : liste des retraits en attente.

- GET /admin/withdrawals
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.getWithdrawals`
  - Query params : `page`, `limit`, `status?`.

- PATCH /admin/withdrawals/:withdrawalId/reject
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.rejectWithdrawal`
  - Body : `{ reason?: string }` (optionnel)
  - Comportement : remettre le montant au solde de l'affilié, enregistre un motif, notifie l'affilié.

- PATCH /admin/withdrawals/:withdrawalId/approve
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.approveWithdrawal`
  - Comportement : marque la transaction comme APPROVED, déclenche éventuellement l'envoi réel (hors scope) et notifie l'affilié.

- PATCH /admin/affiliates/:affiliateId/status
  - Auth : oui + rôle ADMIN/SUPER_ADMIN
  - Controller : `AffiliateController.updateAffiliateStatus`
  - Body : `{ status: 'ACTIVE'|'PENDING'|'SUSPENDED'|..., isActive: boolean }`
  - Comportement : met à jour `affiliate_profiles.status` et `is_active`, notifie l'utilisateur.

---

## Schémas de données (extraits)

Les services interagissent principalement avec les tables Prisma suivantes : `affiliate_profiles`, `commission_transactions`, `affiliate_levels`, `users`, `orders`.

Exemple : AffiliateProfile (forme exposée par les services)
{
  id: string,
  userId: string,
  affiliateCode: string,
  parent_affiliate_id?: string,
  commission_rate: number,
  commissionBalance: number,
  totalEarned: number,
  monthlyEarnings: number,
  isActive: boolean,
  status: string,
  levelId?: string,
  totalReferrals: number,
  createdAt: Date,
  updatedAt: Date,
  user?: { id, email, firstName, lastName, phone }
}

Exemple : CommissionTransaction / Withdrawal record
{
  id: string,
  orderId?: string | null, // null pour les retraits
  affiliate_id: string,
  amount: number,
  status: 'PENDING'|'APPROVED'|'REJECTED',
  created_at: Date,
  updated_at: Date,
  affiliate_profiles?: { ... },
  orders?: { id, totalAmount, createdAt }
}

---

## Authentification & Autorisation

- Token JWT attendu par `authenticateToken` / `authMiddleware`.
- Payload du token (à la connexion) contient : `{ id, role, email }` (voir `AuthController.generateToken`).
- Cookies : token peut être envoyé en cookie `token` (httpOnly) lors du login. Les endpoints utilisent probablement header `Authorization: Bearer <token>`.
- Rôles : `CLIENT`, `ADMIN`, `SUPER_ADMIN`, `AFFILIATE` (présent implicitement dans le code). Les routes admin vérifient `req.user.role`.

---

## Exemples d'appels (JSON)

- Demande de retrait (utilisateur)

Request:
POST /api/affiliate/withdrawal
Headers: Authorization: Bearer <token>
Body:
{
  "amount": 10000
}

Réponse (succès):
{
  "success": true,
  "data": {
    "id": "withdraw-123",
    "amount": 10000,
    "status": "PENDING",
    "created_at": "2025-10-01T...Z"
  }
}

- Récupérer niveaux (public)

GET /api/affiliate/levels

Réponse:
{
  "data": {
    "levels": [ { id, name, minEarnings, commissionRate, description, createdAt } ... ],
    "additionalInfo": { indirectCommission: { rate, description }, profitMargin: { rate, description } }
  }
}

---

## Erreurs courantes et codes HTTP

- 400 Bad Request : paramètres manquants ou invalides (ex : montant retrait inférieur au minimum).
- 401 Unauthorized : token manquant ou invalide.
- 403 Forbidden : accès admin requis ou action interdite (ex : utilisateur non admin tentant d'accéder aux routes `/admin/*`).
- 404 Not Found : ressource introuvable (affilié, retrait ...).
- 409 Conflict : email déjà existant lors de la création d'un utilisateur/affilié.
- 500 Internal Server Error : erreurs inattendues côté serveur.

---

## Contrat minimal attendu des services (résumé)

- Inputs/Outputs (exemples) :
  - AffiliateService.getProfile(userId) -> AffiliateProfile | null
  - AffiliateCommissionService.getCommissions(affiliateId, page, limit) -> { data: CommissionTransaction[], pagination }
  - AffiliateCommissionService.requestWithdrawal(affiliateId, amount) -> WithdrawalTransaction
  - AffiliateProfileService.createAffiliate(dto) -> AffiliateProfile

- Modes d'erreur : lances d'Exceptions (try/catch dans controllers renvoie 500), erreurs métier retournent des réponses 4xx.

## Cas limites à couvrir

- Tentative de retrait supérieur au solde disponible.
- Tentative de retrait en dessous du minimum.
- Tentative d'actions admin sans le rôle requis.
- Création d'affilié avec un parent inexistant ou code déjà utilisé.
- Concurrency : deux retraits simultanés sur le même solde (usage des transactions Prisma dans les services pour protéger ces cas).

---

## Recommandations / Prochaines étapes

1. Générer une spec OpenAPI (Swagger) à partir de cette doc afin d'obtenir des exemples types et permettre la génération automatique des SDKs.
2. Ajouter des tests unitaires & d'intégration pour :
   - Processus de retrait (happy path, solde insuffisant, montant trop bas).
   - Calcul des taux de commission et promotions de niveau.
   - Endpoints admin (approve/reject withdrawal).
3. Ajouter des middlewares de validation (ex : `Joi`/`zod`) pour valider strictement request bodies des endpoints critiques.
4. Documenter le format exact des notifications envoyées (types, payload) et lister les codes de notification dans un fichier central.

---

Si tu veux, je peux :
- générer automatiquement une spec OpenAPI/Swagger basée sur ces endpoints ;
- créer des exemples Postman / collection pour tester rapidement ;
- ajouter des validations (`zod` ou `joi`) sur les controllers listés.

Indique laquelle de ces options tu veux que j'implémente en priorité.
