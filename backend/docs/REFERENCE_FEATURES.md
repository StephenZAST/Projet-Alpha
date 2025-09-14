
# 📚 Documentation Progressive - Alpha Laundry

Ce fichier regroupe la documentation de référence pour chaque feature majeure du projet, en reliant les fichiers backend et frontend, leur rôle, et les subtilités d'implémentation. Il est enrichi au fur et à mesure de l'analyse des features.

---

## 1. Authentification / Login (Admin)

### Description
Permet à un administrateur de se connecter à l’espace admin via email et mot de passe. La logique inclut la vérification des identifiants, la gestion du token JWT, la sauvegarde de la session, et la navigation conditionnelle selon le rôle.

### Fichiers Frontend
- **Écrans**
  - `frontend/mobile/admin-dashboard/lib/screens/auth/admin_login_screen.dart` : UI du formulaire de login, gestion des champs email/mot de passe, appel au contrôleur d’authentification.
- **Contrôleurs**
  - `frontend/mobile/admin-dashboard/lib/controllers/auth_controller.dart` : Logique de connexion, gestion de l’état utilisateur, navigation, appel au service d’authentification.
- **Services**
  - `frontend/mobile/admin-dashboard/lib/services/auth_service.dart` : Requête HTTP vers `/auth/admin/login`, gestion du token et de l’utilisateur en local (GetStorage).
- **Modèles**
  - `frontend/mobile/admin-dashboard/lib/models/user.dart` : Structure du modèle utilisateur (id, email, rôle, etc.).
- **Middleware & Routes**
  - `frontend/mobile/admin-dashboard/lib/middleware/auth_middleware.dart` : Vérifie l’état d’authentification avant d’accéder à une route protégée.

### Fichiers Backend
- **Routes**
  - `backend/src/routes/auth.routes.ts` : Définit `/admin/login` (POST), appelle le contrôleur AuthController.
- **Contrôleurs**
  - `backend/src/controllers/auth.controller.ts` : Logique de login : vérifie email/mot de passe, appelle AuthService, génère le token JWT.
- **Services**
  - `backend/src/services/auth.service.ts` : Vérifie l’utilisateur en base (Prisma), compare le mot de passe, génère le token JWT, retourne l’utilisateur et le token.
- **Modèles**
  - `backend/src/models/types.ts` : Structure du modèle utilisateur, type UserRole.

### Rôle de chaque fichier
- **Frontend**
  - `admin_login_screen.dart` : Affiche le formulaire, gère l’UI et les interactions.
  - `auth_controller.dart` : Gère la logique de connexion, l’état utilisateur, la navigation.
  - `auth_service.dart` : Fait la requête HTTP, stocke le token et l’utilisateur.
  - `user.dart` : Définit le modèle utilisateur.
  - `auth_middleware.dart` : Protège les routes, redirige si non authentifié.
- **Backend**
  - `auth.routes.ts` : Route d’API pour le login admin.
  - `auth.controller.ts` : Logique de login, validation, génération du token.
  - `auth.service.ts` : Accès à la base, vérification, génération du token.
  - `types.ts` : Modèle utilisateur et rôles.

### Schéma d’interaction
1. **Frontend** : L’admin saisit email/mot de passe → `auth_controller` appelle `auth_service` → requête POST `/auth/admin/login`.
2. **Backend** : Route `/admin/login` → `AuthController.login` → `AuthService.login` → vérification en base → génération du token → réponse avec user + token.
3. **Frontend** : Stockage du token et de l’utilisateur → navigation vers dashboard si succès.

### Conseils pour la navigation rapide
- Pour comprendre la logique de login, commence par le formulaire (`admin_login_screen.dart`), puis la logique (`auth_controller.dart`), puis le service (`auth_service.dart`).
- Pour le backend, commence par la route (`auth.routes.ts`), puis le contrôleur (`auth.controller.ts`), puis le service (`auth.service.ts`).
- Le modèle utilisateur est défini dans `user.dart` (frontend) et `types.ts` (backend).

---


## 2. Gestion des Utilisateurs (User)

### Description
Permet de gérer les utilisateurs du système (clients, affiliés, admins, livreurs) : création, édition, suppression, affichage des détails, statistiques, filtrage et recherche. La logique inclut la gestion des rôles, des adresses, des statistiques, et l’interaction avec le backend pour toutes les opérations CRUD.

### Fichiers Frontend

- **Écrans**
  - `frontend/mobile/admin-dashboard/lib/screens/users/users_screen.dart`  : Écran principal de gestion des utilisateurs (table, stats, filtres, création, édition, détails).
  - `components/users_table.dart`  : Table d’affichage des utilisateurs.
  - `components/user_create_dialog.dart`  : Dialog de création d’utilisateur.
  - `components/user_edit_dialog.dart`  : Dialog d’édition d’utilisateur.
  - `components/user_details_dialog.dart`  : Dialog d’affichage des détails d’un utilisateur.
  - `components/user_stats_grid.dart`  : Affichage des statistiques utilisateurs.

- **Contrôleurs**
  - `frontend/mobile/admin-dashboard/lib/controllers/users_controller.dart`  : Logique de gestion des utilisateurs : chargement, création, édition, suppression, stats, filtres.

- **Services**
  - `frontend/mobile/admin-dashboard/lib/services/user_service.dart`  : Requêtes HTTP vers `/api/users` pour toutes les opérations CRUD, gestion de la pagination, filtrage, recherche.

- **Modèles**
  - `frontend/mobile/admin-dashboard/lib/models/user.dart`  : Structure du modèle utilisateur (id, email, rôle, prénom, nom, téléphone, etc.).

### Fichiers Backend

- **Routes**
  - `backend/src/routes/user.routes.ts`  : Définit toutes les routes `/api/users` (GET, POST, PUT, DELETE, détails, etc.), protection par token et rôle.

- **Contrôleurs**
  - `backend/src/controllers/user.controller.ts`  : Logique de gestion des utilisateurs : création, édition, suppression, récupération des détails, stats, etc.

- **Services**
  - `backend/src/services/auth.service.ts`  : Création d’utilisateur (register), gestion des rôles, hash du mot de passe.
  - `backend/src/services/user.service.ts`  : (Si présent) Logique métier avancée pour les utilisateurs (recherche, stats, etc.).

- **Modèles**
  - `backend/src/models/types.ts`  : Structure du modèle utilisateur, type UserRole, UserListResponse, UserStats, UserFilters.

### Rôle de chaque fichier

- **Frontend**
  - `users_screen.dart` : UI principale, navigation, gestion des interactions.
  - `users_controller.dart` : Logique métier, gestion d’état, appels aux services.
  - `user_service.dart` : Communication avec l’API backend.
  - `user.dart` : Modèle utilisateur.
  - `users_table.dart`, `user_create_dialog.dart`, `user_edit_dialog.dart`, `user_details_dialog.dart`, `user_stats_grid.dart` : Composants UI spécialisés.

- **Backend**
  - `user.routes.ts` : Définition des endpoints API.
  - `user.controller.ts` : Logique métier, validation, gestion des réponses.
  - `auth.service.ts` : Création d’utilisateur, gestion des rôles.
  - `types.ts` : Modèle utilisateur, types de réponses et filtres.

### Schéma d’interaction

1. **Frontend** : L’utilisateur admin navigue sur l’écran Users → le contrôleur charge la liste via `user_service` → requête GET `/api/users`.
2. **Backend** : Route `/api/users` → `UserController` → récupération en base, filtrage, pagination → réponse avec la liste.
3. **Frontend** : Création/édition/suppression via dialogs → requêtes POST/PUT/DELETE → mise à jour de la liste.
4. **Backend** : Validation, création/modification/suppression en base, réponse avec succès ou erreur.

### Conseils pour la navigation rapide

- Pour comprendre la gestion des utilisateurs, commence par l’écran (`users_screen.dart`), puis le contrôleur (`users_controller.dart`), puis le service (`user_service.dart`).
- Pour le backend, commence par la route (`user.routes.ts`), puis le contrôleur (`user.controller.ts`), puis le service (`auth.service.ts` ou `user.service.ts`).
- Le modèle utilisateur est défini dans `user.dart` (frontend) et `types.ts` (backend).

---

## 3. Gestion des Commandes (Order)

### Description
Permet de gérer les commandes du système : création, édition, suppression, affichage des détails, recherche avancée, filtrage par statut, utilisateur, date, etc. La logique inclut la gestion des items, du statut, du paiement, de l’archivage, et l’interaction avec le backend pour toutes les opérations CRUD et de reporting.

### Fichiers Frontend

- **Écrans**
  - `frontend/mobile/admin-dashboard/lib/screens/orders/orders_screen.dart`  : Écran principal de gestion des commandes (table, filtres, recherche, détails, pagination).
  - `components/orders_table.dart`  : Table d’affichage des commandes.
  - `components/order_details_dialog.dart`  : Dialog d’affichage des détails d’une commande.
  - `components/order_filters.dart`, `components/advanced_search_filter.dart`, `components/orders_header.dart`  : Filtres, header, recherche avancée.

- **Contrôleurs**
  - `frontend/mobile/admin-dashboard/lib/controllers/orders_controller.dart`  : Logique de gestion des commandes : chargement, création, édition, suppression, stats, filtres, sélection, pagination.

- **Services**
  - `frontend/mobile/admin-dashboard/lib/services/order_service.dart`  : Requêtes HTTP vers `/api/orders` pour toutes les opérations CRUD, gestion de la pagination, filtrage, recherche, archivage.

- **Modèles**
  - `frontend/mobile/admin-dashboard/lib/models/order.dart`  : Structure du modèle commande (id, user, items, statut, paiement, etc.).
  - `frontend/mobile/admin-dashboard/lib/models/orders_page_data.dart`  : Structure pour la pagination et les données de page.

### Fichiers Backend

- **Routes**
  - `backend/src/routes/order.routes.ts`  : Définit toutes les routes `/api/orders` (GET, POST, PATCH, DELETE, recherche, détails, archivage, etc.), protection par token et rôle.

- **Contrôleurs**
  - `backend/src/controllers/order.controller/index.ts`  : Logique de gestion des commandes : création, édition, suppression, récupération des détails, stats, etc.
  - `backend/src/controllers/order.controller/orderQuery.controller.ts`  : Logique de recherche, pagination, détails, reporting.

- **Services**
  - `backend/src/services/order.service/orderQuery.service.ts`  : Logique métier avancée pour les commandes (recherche, stats, pagination, reporting).

- **Modèles**
  - `backend/src/models/types.ts`  : Structure du modèle commande, types de réponses et filtres.

### Rôle de chaque fichier

- **Frontend**
  - `orders_screen.dart` : UI principale, navigation, gestion des interactions.
  - `orders_controller.dart` : Logique métier, gestion d’état, appels aux services.
  - `order_service.dart` : Communication avec l’API backend.
  - `order.dart`, `orders_page_data.dart` : Modèles de commande et pagination.
  - `orders_table.dart`, `order_details_dialog.dart`, `order_filters.dart`, `advanced_search_filter.dart`, `orders_header.dart` : Composants UI spécialisés.

- **Backend**
  - `order.routes.ts` : Définition des endpoints API.
  - `order.controller/index.ts` : Logique métier, validation, gestion des réponses.
  - `order.controller/orderQuery.controller.ts` : Recherche, pagination, reporting.
  - `order.service/orderQuery.service.ts` : Logique métier avancée.
  - `types.ts` : Modèle commande, types de réponses et filtres.

### Schéma d’interaction

1. **Frontend** : L’utilisateur admin navigue sur l’écran Orders → le contrôleur charge la liste via `order_service` → requête GET `/api/orders`.
2. **Backend** : Route `/api/orders` → `OrderController` → récupération en base, filtrage, pagination → réponse avec la liste.
3. **Frontend** : Création/édition/suppression via dialogs → requêtes POST/PATCH/DELETE → mise à jour de la liste.
4. **Backend** : Validation, création/modification/suppression en base, réponse avec succès ou erreur.

### Conseils pour la navigation rapide

- Pour comprendre la gestion des commandes, commence par l’écran (`orders_screen.dart`), puis le contrôleur (`orders_controller.dart`), puis le service (`order_service.dart`).
- Pour le backend, commence par la route (`order.routes.ts`), puis le contrôleur (`order.controller/index.ts`), puis le service (`order.service/orderQuery.service.ts`).
- Le modèle commande est défini dans `order.dart` (frontend) et `types.ts` (backend).


---

### Feature: Adresse (Address)

#### **Backend**

- **Controller:**  
  - `src/controllers/address.controller.ts`  
    Handles address-related endpoints, e.g. updating the address of an order (`PATCH /orders/:orderId/address`).  
    - Verifies user permissions and address ownership.
    - Updates the order's address in the database.

- **Service:**  
  - `src/services/address.service.ts`  
    Contains business logic for address management:
    - `getAddressById(addressId)`: Fetches address details.
    - `createAddress(...)`: Creates a new address, manages default address logic.

- **Model/Types:**  
  - `src/models/types.ts`  
    Defines the `Address` interface:
    ```typescript
    ```

#### **Frontend (Mobile Admin Dashboard)**

- **Controller:**  
  - `lib/controllers/address_controller.dart`  
    Manages address state and operations:
    - Loads addresses, handles errors.
    - Calls service methods for CRUD operations.

- **Service:**  
  - `lib/services/address_service.dart`  
    Handles API calls:
    - `getAddresses()`, `getAddressById(id)`, `createAddress(data)`, etc.
    - Communicates with backend `/api/addresses` endpoints.

- **Model:**  
  - `lib/models/address.dart`  
    Dart class representing an address, with fields matching backend model.

#### **Schema of Interaction**

- **Frontend** calls service methods to fetch, create, or update addresses.
- **Service** sends HTTP requests to backend endpoints (`/api/addresses`, `/api/orders/:orderId/address`).
- **Backend Controller** validates requests, checks permissions, and delegates to the service.
- **Backend Service** interacts with the database via Prisma, returns address data.
- **Frontend Controller** updates UI state based on service responses.

#### **Navigation Tips**

- To trace address creation:  
  - Frontend: `address_controller.dart` → `address_service.dart` → `/api/addresses`  
  - Backend: `address.controller.ts` → `address.service.ts` → Prisma

- To trace address update for an order:  
  - Frontend: `address_controller.dart` → `address_service.dart` → `/api/orders/:orderId/address`  
  - Backend: `address.controller.ts` (method: `updateOrderAddress`) → Prisma

---

> Ce fichier sera enrichi à chaque nouvelle feature analysée pour servir de référence complète à toute l’équipe.

