# 🗂️ Référence Article/Service/Admin/OrderItem

Ce document synthétise la logique de couplage et de tarification entre articles, services, types de service, couples article-service, prix, items de commande, et la gestion Admin.

---

## Section : Admin

### Backend

- **Routes**
  - `src/routes/admin.routes.ts` : Toutes les routes admin (gestion commandes, configuration, dashboard, profil, etc.)
  - Sous-routes : `/admin/subscriptions`, `/admin/orders`, `/admin/settings`, etc.

- **Controllers**
  - `src/controllers/admin.controller.ts` : Logique métier admin (configuration commissions, rewards, création service/article, etc.)
  - `src/controllers/admin/serviceManagement.controller.ts` : Gestion avancée des services.

- **Services**
  - `src/services/admin.service.ts` : Logique métier (CRUD services/articles, dashboard, export, configuration système, etc.)

- **Modèles**
  - `types.ts` : Modèle admin, DTOs pour création/édition, etc.

### Frontend (Mobile Admin Dashboard)

- **Controllers**
  - `lib/controllers/admin_controller.dart` : Logique de gestion du profil admin, dashboard, mise à jour profil, récupération statistiques.

- **Services**
  - `lib/services/admin_service.dart` : Communication avec les endpoints `/admin/profile`, `/admin/statistics`, `/admin/export`, `/admin/settings`.

- **Modèles**
  - `lib/models/admin.dart` : Structure du modèle admin (id, email, nom, rôle, préférences, etc.)

### Schéma d’interaction

- **Dashboard** :  
  - Frontend appelle `AdminService.getDashboardData()` → backend `/admin/statistics` → calcul et retour des stats.
- **Mise à jour profil** :  
  - Frontend appelle `AdminService.updateProfile()` → backend `/admin/profile` → mise à jour en base.
- **Configuration système** :  
  - Frontend appelle `AdminService.updateSystemSettings()` → backend `/admin/settings` → mise à jour des paramètres globaux.

### Conseils de navigation

- Backend : `admin.routes.ts` → `admin.controller.ts` → `admin.service.ts` → modèles/types
- Frontend : `admin_controller.dart` → `admin_service.dart` → UI dashboard/profil

---

## 1. Modèles et Couplage

- **Article** : Un produit (ex : chemise, pantalon)
- **ServiceType** : Type de prestation (ex : Express, Standard)
- **Service** : Prestation spécifique (ex : Nettoyage à sec, Repassage)
- **ArticleService** : Couple article/service, pour gérer les relations et les prix multipliés
- **ArticleServicePrice** : Table centrale de tarification, structure :
  ```typescript
  article_id, service_type_id, service_id, base_price, premium_price, is_available, price_per_kg
  ```
- **OrderItem** : Ligne d'une commande, structure :
  ```typescript
  articleId, serviceId, serviceTypeId, quantity, unitPrice, isPremium, weight
  ```

---

## 2. Fonctionnement de la tarification

- Le prix d'un article dans une commande dépend **strictement** du trio `(article_id, service_type_id, service_id)` dans `article_service_prices`.
- **Ne jamais filtrer uniquement sur `article_id` et `service_type_id`** : il peut exister plusieurs couples pour un même article/serviceType mais avec des services différents.
- Backend : TOUJOURS filtrer sur les trois clés pour récupérer le bon prix.

---

## 3. Création d'une commande

- Le frontend envoie pour chaque item :
  - `articleId`, `serviceTypeId`, `serviceId`, `isPremium`, `quantity`
- Le backend utilise ces clés pour récupérer le prix exact dans `article_service_prices`.
- Le total est calculé en multipliant le prix du couple par la quantité.
- Chaque `OrderItem` reçoit le prix unitaire du couple, jamais le prix de la table `articles` seule.

---

## 4. Endpoints principaux

- **Backend**
  - `/api/articles` : CRUD articles
  - `/api/service-types` : CRUD types de service
  - `/api/article-services/prices` : CRUD prix des couples
  - `/api/order-items` : CRUD items de commande

- **Frontend**
  - Modèles et services Dart pour chaque entité
  - UI de création/édition d'item et gestion des prix

---

## 5. Points d'attention

- Toujours vérifier que le couple existe dans `article_service_prices`.
- Si un prix n'est pas trouvé, le fallback est 1 (à personnaliser selon le besoin métier).
- Le frontend doit afficher le même prix que le backend pour éviter toute confusion utilisateur.

---

## 6. Navigation rapide

- Backend : `articleServicePrice.controller.ts` → `articleServicePrice.service.ts` → Prisma → `types.ts`
- Frontend : `service_type_controller.dart` → `service_type_service.dart` → UI de création/édition d’item

---

> Ce fichier est une référence rapide pour toute évolution ou correction liée à la tarification et au couplage article/service/orderItem.

# Delivery Feature Reference

## Backend

### Main Files
- **Routes:** `backend/src/routes/delivery.routes.ts`
  - Endpoints for delivery operations: pending/assigned/collected orders, status updates, protected by authentication and role-based authorization.
- **Controller:** `backend/src/controllers/delivery.controller.ts`
  - Handles logic for fetching orders (pending, assigned, collected), updating order status, error handling, user authentication.
- **Service:** `backend/src/services/delivery.service.ts`
  - Implements business logic: queries orders by status/user, updates order status, interacts with Prisma ORM.

### Data Model
- Orders, DeliveryUser, OrderStatus, DeliveryProfile (see types/models in backend).
- Statuses: PENDING, COLLECTING, DELIVERED, etc.

### Key Logic
- Delivery users fetch their assigned/pending/collected orders.
- Status updates for orders (PATCH endpoint).
- Role-based access for delivery/admin/super-admin.

## Frontend (Flutter)

### Main Files
- **Screens:**
  - `frontend/mobile/admin-dashboard/lib/screens/delivery/delivery_screen.dart`: Main UI for delivery management (lists, stats, deliverers).
  - Components: deliverers table, delivery list, stats card, filters, update status dialog, etc.
- **Controller:**
  - `frontend/mobile/admin-dashboard/lib/controllers/delivery_controller.dart`: State management, API calls, filtering, stats, map visualization, error handling.
- **Service:**
  - `frontend/mobile/admin-dashboard/lib/services/delivery_service.dart`: API integration for delivery endpoints (get deliverers, orders, update status, stats).
- **Model:**
  - `frontend/mobile/admin-dashboard/lib/models/delivery.dart`: Data structures for DeliveryUser, DeliveryOrder, DeliveryStats, DeliveryProfile, etc.

### UI/UX
- Dashboard for delivery management: lists of orders, deliverers, stats, filters, status update dialogs.
- Map visualization, search/filter, error handling, active/inactive toggles.

## Feature Flow
1. **Order Management:**
   - Backend: `/delivery/pending-orders`, `/delivery/assigned-orders`, `/delivery/:orderId/status` (GET/PATCH), controller/service/model.
   - Frontend: Delivery screens, controller, service, model for displaying and updating orders.
2. **Deliverer Management:**
   - Backend: Role-based access, user model.
   - Frontend: Deliverers table, stats, filters, controller/service/model.
3. **Status Updates:**
   - Backend: PATCH endpoint for order status, controller/service.
   - Frontend: Status update dialog, controller/service/model.
4. **Stats & Visualization:**
   - Backend: Order stats via service/model.
   - Frontend: Stats cards, grids, map visualization, controller/model.

## Notes
- Delivery logic is modularized in backend and mapped to Flutter screens/components/controllers/models for maintainability.
- For details on each endpoint, see backend route/controller/service files and corresponding frontend service/controller/screen/model files.


# Affiliate Feature Reference

## Backend

### Main Files
- **Routes:** `backend/src/routes/affiliate.routes.ts`
  - Defines all affiliate-related endpoints (profile, commissions, withdrawals, referrals, levels, code generation, admin list/stats, withdrawal approval/rejection, status update).
- **Controller:** `backend/src/controllers/affiliate.controller.ts`
  - Handles logic for profile retrieval/update, commission queries, withdrawal requests, referrals, level management, code generation, admin actions.
- **Services:**
  - `backend/src/services/affiliate.service/index.ts`: Main service, delegates to profile, commission, withdrawal services.
  - `backend/src/services/affiliate.service/constants.ts`: Commission rates, margin, referral points, withdrawal limits, levels, distinctions.
  - `backend/src/services/affiliate.service/affiliateWithdrawal.service.ts`: Handles withdrawal requests, approval/rejection, transaction logic.
  - `backend/src/services/affiliate.service/affiliateProfile.service.ts`: Profile creation, update, referral management, code generation.
  - `backend/src/services/affiliate.service/affiliateCommission.service.ts`: Commission calculation, retrieval, transaction management.

### Data Model
- Affiliate profiles, commission transactions, withdrawal requests, referral relationships, distinction levels.
- Statuses: PENDING, APPROVED, REJECTED, ACTIVE, etc.

### Key Logic
- Profile management, commission calculation, withdrawal requests (with limits/cooldown), referral tracking, admin controls for affiliates and withdrawals.

## Frontend (Flutter)

### Main Files
- **Screens:**
  - `frontend/mobile/admin-dashboard/lib/screens/affiliates/affiliate_management_screen.dart`: Main UI for managing affiliates (tabs for list, filters, withdrawals, commission settings).
  - Components: affiliate list, filters, withdrawal requests, commission settings, stats grid, details dialog, etc.
- **Controller:**
  - `frontend/mobile/admin-dashboard/lib/controllers/affiliates_controller.dart`: State management, API calls, pagination, filtering, stats, commissions, withdrawals.
- **Service:**
  - `frontend/mobile/admin-dashboard/lib/services/affiliate_service.dart`: API integration for all affiliate endpoints (list, stats, withdrawals, commissions, status updates).
- **Model:**
  - `frontend/mobile/admin-dashboard/lib/models/affiliate.dart`: Data structures for affiliate profile, status, level, commission, withdrawal, referral, etc.

### UI/UX
- Tabs for managing affiliates, viewing stats, handling withdrawal requests, commission settings.
- Filtering, searching, pagination, status updates, approval/rejection of withdrawals.

## Feature Flow
1. **Affiliate Profile:**
   - Backend: `/affiliate/profile` (GET/PUT), controller/service/model.
   - Frontend: Profile display/edit, model mapping.
2. **Commissions:**
   - Backend: `/affiliate/commissions`, commission service/model.
   - Frontend: Commissions tab, stats, model.
3. **Withdrawals:**
   - Backend: `/affiliate/withdrawal`, approval/rejection endpoints, withdrawal service/model.
   - Frontend: Withdrawal requests tab, approval/rejection UI.
4. **Referrals & Levels:**
   - Backend: `/affiliate/referrals`, `/affiliate/levels`, `/affiliate/current-level`, referral/level logic.
   - Frontend: Referral stats, level display.
5. **Admin Controls:**
   - Backend: `/affiliate/admin/*` endpoints, admin checks, controller/service.
   - Frontend: Admin screens for managing affiliates, withdrawals, stats.

## Notes
- All affiliate logic is modularized in backend services and mapped to Flutter screens/components/controllers/models for maintainability.
- For details on each endpoint, see backend route/controller/service files and corresponding frontend service/controller/screen/model files.


# 📦 Documentation Features - Notification

Ce document synthétise la logique, les fichiers clés et le schéma d'interaction pour la feature Notification du projet Alpha.

---

## Section : Notification

### Backend
- **Routes**
  - `src/routes/notification.routes.ts` : Gestion des notifications (récupération, lecture, suppression, préférences).
  - Endpoints : `/api/notifications`, `/api/notifications/unread`, `/api/notifications/:notificationId/read`, `/api/notifications/:notificationId`, `/api/notifications/mark-all-read`, `/api/notifications/preferences`.
- **Controllers**
  - `src/controllers/notification.controller.ts` : Logique métier (récupération notifications, marquer comme lue, suppression, préférences).
- **Services**
  - `src/services/notification.service.ts` : Logique métier (envoi, création, gestion des règles, templates, préférences, etc.)
- **Modèles**
  - `types.ts` ou `admin_notification` :
    - `Notification`, `NotificationType`, `NotificationPreferences`, etc.
    - Champs principaux : id, userId, type, title, message, data, read, createdAt, updatedAt.

### Frontend (Mobile Admin Dashboard)
- **Écrans**
  - `lib/screens/notifications/notifications_screen.dart` : UI principale de gestion des notifications (liste, stats, filtres).
  - `components/notification_tile.dart`, `notification_stats_grid.dart`, `notification_filters.dart` : Composants spécialisés.
- **Controllers**
  - `lib/controllers/notification_controller.dart` : Logique de gestion des notifications (chargement, filtrage, lecture, actions, navigation).
- **Services**
  - `lib/services/notification_service.dart` : Communication avec les endpoints `/api/notifications`, gestion CRUD, lecture, suppression, préférences.
- **Modèles**
  - `lib/models/admin_notification.dart` : Structure du modèle Notification (id, type, titre, message, priorité, isRead, createdAt, etc.)

### Schéma d’interaction
- **Récupération/affichage** :
  - Frontend appelle `NotificationService.getNotifications()` → backend `/api/notifications` → retour liste paginée.
- **Lecture/suppression** :
  - Frontend appelle `/api/notifications/:notificationId/read` ou `/delete` → backend met à jour ou supprime.
- **Statistiques** :
  - Frontend appelle `/api/notifications/unread` → backend retourne le nombre de notifications non lues.
- **Préférences** :
  - Frontend appelle `/api/notifications/preferences` → backend retourne ou met à jour les préférences utilisateur.

### Conseils de navigation
- Backend : `notification.routes.ts` → `notification.controller.ts` → `notification.service.ts` → modèles/types
- Frontend : `notifications_screen.dart` → `notification_controller.dart` → `notification_service.dart` → UI liste/filtres

---


# 📦 Documentation Features - Subscription

Ce document synthétise la logique, les fichiers clés et le schéma d'interaction pour la feature Subscription du projet Alpha.

---

## Section : Subscription

### Backend
- **Routes**
  - `src/routes/subscription.routes.ts` : CRUD des plans d'abonnement, souscription, annulation, récupération des abonnements actifs et des utilisateurs abonnés.
  - Endpoints : `/api/subscriptions/plans`, `/api/subscriptions/subscribe`, `/api/subscriptions/:subscriptionId/cancel`, `/api/subscriptions/active`, `/api/subscriptions/plans/:planId/users`.
- **Controllers**
  - `src/controllers/subscription.controller.ts` : Logique métier (création plan, souscription, annulation, récupération abonnements/plans/utilisateurs).
- **Services**
  - `src/services/subscription.service.ts` : Logique métier (CRUD plans, gestion des abonnements, notifications, calcul prix centralisé, etc.)
- **Modèles**
  - `types.ts` ou `subscription_plan` :
    - `SubscriptionPlan`, `UserSubscription`, etc.
    - Champs principaux : id, name, description, price, duration_days, max_orders_per_month, max_weight_per_order, is_premium, created_at, updated_at.

### Frontend (Mobile Admin Dashboard)
- **Écrans**
  - `lib/screens/subscriptions/subscription_management_page.dart` : UI principale de gestion des abonnements (tabs plans, utilisateurs abonnés, stats).
  - `lib/screens/subscriptions/subscription_plans_tab.dart`, `subscribed_users_tab.dart`, `components/subscription_stats_grid.dart` : Composants spécialisés.
- **Modèles**
  - `lib/models/subscription_plan.dart` : Structure du modèle SubscriptionPlan (id, name, description, price, durationDays, maxOrdersPerMonth, maxWeightPerOrder, isPremium, createdAt, updatedAt).

### Schéma d’interaction
- **CRUD Plan** :
  - Frontend appelle endpoint `/api/subscriptions/plans` pour récupérer, créer, éditer, supprimer les plans.
- **Souscription/Annulation** :
  - Frontend appelle `/api/subscriptions/subscribe` ou `/api/subscriptions/:subscriptionId/cancel` → backend gère la souscription ou l'annulation.
- **Affichage abonnements actifs/utilisateurs** :
  - Frontend appelle `/api/subscriptions/active` ou `/api/subscriptions/plans/:planId/users` → backend retourne les abonnements ou utilisateurs abonnés.

### Conseils de navigation
- Backend : `subscription.routes.ts` → `subscription.controller.ts` → `subscription.service.ts` → modèles/types
- Frontend : `subscription_management_page.dart` → `subscription_plan.dart` → UI tabs/stats

---


# 📦 Documentation Features - Admin & Offer

Ce document synthétise la logique, les fichiers clés et le schéma d'interaction pour les features Admin et Offer du projet Alpha.

---

## Section : Admin

### Backend
- **Routes**
  - `src/routes/admin.routes.ts` : Toutes les routes admin (gestion commandes, configuration, dashboard, profil, etc.)
  - Sous-routes : `/admin/subscriptions`, `/admin/orders`, `/admin/settings`, etc.
- **Controllers**
  - `src/controllers/admin.controller.ts` : Logique métier admin (configuration commissions, rewards, création service/article, etc.)
  - `src/controllers/admin/serviceManagement.controller.ts` : Gestion avancée des services.
- **Services**
  - `src/services/admin.service.ts` : Logique métier (CRUD services/articles, dashboard, export, configuration système, etc.)
- **Modèles**
  - `types.ts` : Modèle admin, DTOs pour création/édition, etc.

### Frontend (Mobile Admin Dashboard)
- **Controllers**
  - `lib/controllers/admin_controller.dart` : Logique de gestion du profil admin, dashboard, mise à jour profil, récupération statistiques.
- **Services**
  - `lib/services/admin_service.dart` : Communication avec les endpoints `/admin/profile`, `/admin/statistics`, `/admin/export`, `/admin/settings`.
- **Modèles**
  - `lib/models/admin.dart` : Structure du modèle admin (id, email, nom, rôle, préférences, etc.)

### Schéma d’interaction
- **Dashboard** :  
  - Frontend appelle `AdminService.getDashboardData()` → backend `/admin/statistics` → calcul et retour des stats.
- **Mise à jour profil** :  
  - Frontend appelle `AdminService.updateProfile()` → backend `/admin/profile` → mise à jour en base.
- **Configuration système** :  
  - Frontend appelle `AdminService.updateSystemSettings()` → backend `/admin/settings` → mise à jour des paramètres globaux.

### Conseils de navigation
- Backend : `admin.routes.ts` → `admin.controller.ts` → `admin.service.ts` → modèles/types
- Frontend : `admin_controller.dart` → `admin_service.dart` → UI dashboard/profil

---

## Section : Offer

### Backend
- **Routes**
  - `src/routes/offer.routes.ts` : CRUD des offres, souscription, désinscription, gestion des statuts, récupération des abonnés.
  - Endpoints : `/api/offers`, `/api/offers/:offerId/subscribe`, `/api/offers/:offerId/unsubscribe`, `/api/offers/available`, `/api/offers/my-subscriptions`.
- **Controllers**
  - `src/controllers/offer.controller.ts` : Logique métier (création, édition, suppression, souscription, désinscription, récupération abonnés, etc.)
- **Services**
  - `src/services/offer.service.ts` : Logique métier (CRUD, gestion des abonnements, notifications, mapping articles, etc.)
- **Modèles**
  - `src/models/offer.types.ts` :
    - `Offer`, `CreateOfferDTO`, `OfferSubscription`, `OfferUser`, etc.
    - Gestion des types de réduction : `OfferDiscountType` (pourcentage, montant fixe, échange de points).

### Frontend (Mobile Admin Dashboard)
- **Écrans**
  - `lib/screens/offers/offers_screen.dart` : UI principale de gestion des offres (table, stats, filtres, création/édition).
  - `lib/screens/offers/offer_list.dart`, `offer_form.dart`, `components/offer_table.dart`, etc. : Composants spécialisés.
- **Services**
  - `lib/services/offer_service.dart` : Communication avec les endpoints `/api/offers`, gestion CRUD, souscription, désinscription, récupération des offres et abonnements.
- **Modèles**
  - `lib/models/offer.dart` : Structure du modèle Offer (id, nom, description, type de réduction, valeur, dates, articles liés, etc.)

### Schéma d’interaction
- **CRUD Offre** :
  - Frontend appelle `OfferService.getAllOffers()` → backend `/api/offers` → retour liste des offres.
  - Création/édition/suppression via les endpoints `/api/offers`, `/api/offers/:offerId`.
- **Souscription/Désinscription** :
  - Frontend appelle `OfferService.subscribeToOffer()` ou `unsubscribeFromOffer()` → backend `/api/offers/:offerId/subscribe` ou `/unsubscribe` → mise à jour en base.
- **Affichage abonnements** :
  - Frontend appelle `/api/offers/my-subscriptions` → backend retourne les offres souscrites par l’utilisateur.

### Conseils de navigation
- Backend : `offer.routes.ts` → `offer.controller.ts` → `offer.service.ts` → `offer.types.ts`
- Frontend : `offers_screen.dart` → `offer_service.dart` → `offer.dart` → UI table/formulaire

---


