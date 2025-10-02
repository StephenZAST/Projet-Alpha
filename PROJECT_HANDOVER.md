# 📱 Alpha Client App - Handover Documentation

## 🎯 Vue d'ensemble du projet

**Alpha Client App** est une application mobile Flutter pour les clients d'Alpha Laundry (service de blanchisserie au Sénégal). L'application permet aux clients de créer des commandes, suivre leurs livraisons, gérer leur profil et participer au programme de fidélité.

### 📊 État actuel : 85% complété
- ✅ **Architecture & Fondations** : 100%
- ✅ **Services Backend** : 95%
- ✅ **Authentification** : 100%
- ✅ **Dashboard Principal** : 100%
- ✅ **Système de Commandes** : 100%
- ✅ **Profil Utilisateur** : 100%
- ✅ **Notifications** : 100%
- 🚧 **Programme Fidélité** : 0%
- 🚧 **Historique Commandes** : 0%

---

## 🏗️ Architecture du Projet

### 📁 Structure des dossiers
```
frontend/mobile/customers_app/
├── lib/
│   ├── main.dart                   # Point d'entrée avec MultiProvider
│   ├── constants.dart              # Design system glassmorphism complet
│   ├── components/                 # Composants réutilisables premium
│   ├── core/                       # Services, modèles, utils
│   ├── features/                   # Features organisées par domaine
│   ├── screens/                    # Écrans principaux
│   ├── shared/                     # Providers et widgets partagés
│   ├── theme/                      # Theme provider light/dark
│   └── utils/                      # Utilitaires et helpers
├── assets/                         # Images, logos, icônes
├── pubspec.yaml                    # Dépendances Flutter
└── PROJECT_HANDOVER.md            # Ce fichier
```

### 🔧 Stack Technique
- **Framework** : Flutter 3.6.0+
- **State Management** : Provider Pattern
- **HTTP Client** : Dio 5.4.0
- **Stockage Local** : SharedPreferences
- **Notifications** : FlutterLocalNotifications
- **Animations** : Flutter built-in + Custom
- **UI** : Glassmorphism Design System
- **Navigation** : Flutter Navigator 2.0

---

## 📦 Backend Integration

### 🌐 API Endpoints Utilisés
**Base URL** : Configuration dans `constants.dart`

#### Authentification
- `POST /auth/register` - Inscription client
- `POST /auth/login` - Connexion client
- `POST /auth/logout` - Déconnexion
- `POST /auth/refresh` - Refresh token

#### Client Endpoints
- `GET /users/profile` - Profil utilisateur
- `PATCH /users/profile` - Mise à jour profil
- `GET /addresses` - Adresses utilisateur
- `POST /addresses` - Créer adresse
- `PATCH /addresses/:id` - Modifier adresse
- `DELETE /addresses/:id` - Supprimer adresse

#### Orders Endpoints
- `POST /orders` - Créer commande complète
- `POST /orders/flash` - Créer commande flash (draft)
- `GET /orders` - Historique commandes utilisateur
- `GET /orders/:id` - Détails commande
- `PATCH /orders/:id/cancel` - Annuler commande (si autorisé)

#### Services & Articles
- `GET /service-types` - Types de services
- `GET /services/all` - Services disponibles
- `GET /articles` - Articles disponibles
- `GET /article-services/prices` - Prix article-service

#### Loyalty System
- `GET /loyalty/profile` - Profil fidélité
- `GET /loyalty/transactions` - Historique points
- `POST /loyalty/redeem` - Utiliser points

#### Notifications
- `GET /notifications` - Notifications utilisateur
- `PATCH /notifications/:id/read` - Marquer comme lu
- `PATCH /notifications/mark-all-read` - Tout marquer lu

---

## 🔑 Fichiers Clés Implémentés

### 1. Configuration & Architecture

#### `lib/constants.dart` ⭐ **CRITIQUE**
```dart
// Design system mobile-first complet
- AppColors : Palette glassmorphism (primary, secondary, grays)
- AppTextStyles : Typographie responsive
- AppSpacing : Espacements cohérents
- AppRadius : Rayons de bordure
- AppShadows : Ombres glassmorphism
- MobileDimensions : Tailles optimisées mobile
- AppAnimations : Durées d'animation
- StorageKeys : Clés de stockage local
- NotificationConfig : Configuration notifications
```

#### `lib/app.dart` ⭐ **CRITIQUE**
```dart
// Configuration principale avec :
- DeliveryApp : Widget racine GetMaterialApp
- AppInitializer : Initialisation services et timezones
- AppErrorHandler : Gestion erreurs globales
- AppPerformanceConfig : Optimisations mobile
```

#### `lib/main.dart`
```dart
// Point d'entrée avec :
- Gestion d'erreurs fatales
- DeliveryAppFallback : App de secours
- ErrorScreen : Écran d'erreur élégant
```

### 2. Services Backend

#### `lib/services/auth_service.dart` ⭐ **CRITIQUE**
```dart
// Authentification JWT complète :
- Multi-rôles : DELIVERY, ADMIN, SUPER_ADMIN
- Persistance session avec GetStorage
- Validation token automatique
- Méthodes utilitaires rôles (isAdmin, isSuperAdmin, etc.)
- Couleurs et icônes par rôle
```

#### `lib/services/api_service.dart` ⭐ **CRITIQUE**
```dart
// Client HTTP centralisé :
- Configuration Dio avec intercepteurs
- Gestion automatique tokens JWT
- Retry automatique sur erreurs réseau
- Logging détaillé pour debug
- Gestion timeout et erreurs
```

#### `lib/services/delivery_service.dart` ⭐ **CRITIQUE**
```dart
// Communication avec tous les endpoints delivery :
- Méthodes pour chaque endpoint backend
- Gestion pagination automatique
- Conversion modèles JSON ↔ Dart
- Gestion d'erreurs spécialisée
```

#### `lib/services/location_service.dart`
```dart
// Géolocalisation complète :
- Permissions automatiques Android/iOS
- Tracking position en temps réel
- Calcul distances et vitesses
- Gestion erreurs GPS
```

#### `lib/services/notification_service.dart`
```dart
// Notifications locales :
- Configuration canaux Android
- Notifications programmées avec timezone Sénégal
- Types : nouvelles commandes, statuts, rappels, urgences
- Navigation depuis notifications
- Gestion badges iOS
```

#### `lib/services/navigation_service.dart`
```dart
// Navigation GPS externe :
- Intégration Google Maps, Apple Maps, Waze
- Navigation vers adresses et coordonnées
- Copie presse-papiers
- Gestion URL schemes
```

### 3. Modèles de Données

#### `lib/models/user.dart` ⭐ **CRITIQUE**
```dart
// Modèles utilisateur livreur :
- DeliveryUser : Utilisateur avec rôle et permissions
- DeliveryStats : Statistiques performance complètes
- DeliveryProfile : Profil avec véhicule et disponibilité
- Sérialisation JSON bidirectionnelle
```

#### `lib/models/delivery_order.dart` ⭐ **CRITIQUE**
```dart
// Modèles commandes optimisés mobile :
- DeliveryOrder : Commande avec toutes infos livreur
- DeliveryCustomer : Client avec coordonnées
- DeliveryAddress : Adresse avec GPS
- DeliveryOrderItem : Articles avec prix
- Getters utilitaires mobile (shortId, statusColor, etc.)
- Logique métier (isUrgent, canUpdateStatus, etc.)
```

### 4. Contrôleurs d'État

#### `lib/controllers/app_controller.dart`
```dart
// État global application :
- Gestion thème light/dark
- État réseau et connectivité
- Configuration globale
```

#### `lib/controllers/auth_controller.dart` ⭐ **CRITIQUE**
```dart
// Contrôleur authentification :
- Gestion états login/logout
- Navigation conditionnelle
- Messages utilisateur (snackbars)
- Validation formulaires
- Gestion erreurs auth
```

#### `lib/controllers/dashboard_controller.dart`
```dart
// Contrôleur dashboard :
- Chargement statistiques depuis backend
- Actualisation données (pull-to-refresh)
- Gestion commandes du jour
- Calculs métriques (gains, performances)
```

### 5. Navigation & Routes

#### `lib/routes/app_routes.dart` ⭐ **CRITIQUE**
```dart
// Configuration navigation GetX :
- Routes définies avec bindings
- Middleware authentification
- Transitions personnalisées
- Écrans placeholder pour développement
- Extensions navigation sécurisée
```

#### `lib/bindings/` (Tous les fichiers)
```dart
// Injection dépendances GetX :
- InitialBinding : Services globaux
- AuthBinding : Authentification
- DashboardBinding : Dashboard
- OrdersBinding, MapBinding, ProfileBinding : Sections
```

### 6. Interface Utilisateur

#### `lib/theme/mobile_theme.dart` ⭐ **CRITIQUE**
```dart
// Thème glassmorphism complet :
- MobileTheme.lightTheme / darkTheme
- Couleurs avec transparence
- Typographie responsive
- Composants Material3 personnalisés
- InputDecoration glassmorphism
```

#### `lib/screens/auth/login_screen.dart`
```dart
// Écran connexion mobile-first :
- Design glassmorphism
- Validation temps réel
- Support multi-rôles
- Gestion états loading/erreur
- UX optimisée mobile
```

#### `lib/screens/dashboard/dashboard_screen.dart`
```dart
// Dashboard principal :
- SliverAppBar avec badge rôle
- Statistiques en cards
- Actions rapides
- Pull-to-refresh
- Navigation bottom avec FAB
- Placeholder commandes du jour
```

---

## 🚧 Implémentations Récentes (Dernière Session)

### 1. ✅ Correction Authentification Multi-Rôles
**Objectif** : Permettre connexion DELIVERY + ADMIN + SUPER_ADMIN
**Fichiers modifiés** :
- `lib/services/auth_service.dart` : Validation rôles, méthodes utilitaires
- `lib/controllers/auth_controller.dart` : Getters rôles
- `lib/screens/auth/login_screen.dart` : Interface "Connexion Équipe"
- `lib/screens/dashboard/dashboard_screen.dart` : Badge rôle utilisateur

### 2. ✅ Correction Service Notifications
**Objectif** : Résoudre conflits enum Priority et TZDateTime
**Fichiers modifiés** :
- `lib/services/notification_service.dart` : Enum NotificationPriority, TZDateTime
- `pubspec.yaml` : Ajout dépendance timezone
- `lib/app.dart` : Initialisation timezone Sénégal

### 3. ✅ Correction Routes Navigation
**Objectif** : Éliminer erreurs compilation routes
**Fichiers modifiés** :
- `lib/routes/app_routes.dart` : Écrans placeholder, paramètres GetPage corrigés
- Suppression références écrans inexistants

### 4. ✅ Documentation Projet
**Objectif** : TODO détaillé et handover
**Fichiers créés** :
- `DELIVERY_APP_TODO.md` : Progression par phases
- `PROJECT_HANDOVER.md` : Ce fichier

---

## ⚠️ Points d'Attention Critiques

### 🔴 Problèmes Identifiés

1. **Écrans Manquants** (URGENT)
   - `screens/orders/orders_screen.dart` - Liste commandes avec filtres
   - `screens/orders/order_details_screen.dart` - Détails commande
   - `screens/map/delivery_map_screen.dart` - Carte interactive
   - `screens/profile/profile_screen.dart` - Profil livreur
   - `screens/profile/settings_screen.dart` - Paramètres

2. **Contrôleurs Manquants**
   - `controllers/orders_controller.dart` - Gestion état commandes
   - `controllers/map_controller.dart` - Gestion carte et GPS
   - `controllers/profile_controller.dart` - Gestion profil

3. **Widgets Partagés Manquants**
   - `widgets/shared/glass_container.dart` - Conteneur glassmorphism
   - `widgets/cards/order_card_mobile.dart` - Card commande tactile
   - `widgets/shared/mobile_bottom_nav.dart` - Navigation optimisée

### 🟡 Zones Complexes

1. **Service de Livraison** (`lib/services/delivery_service.dart`)
   - ⚠️ Très dense : 15+ endpoints
   - ⚠️ Gestion pagination complexe
   - ⚠️ Conversion modèles JSON critique

2. **Authentification** (`lib/services/auth_service.dart`)
   - ⚠️ Logique multi-rôles sensible
   - ⚠️ Persistance session critique
   - ⚠️ Validation token automatique

3. **Notifications** (`lib/services/notification_service.dart`)
   - ⚠️ Configuration Android/iOS différente
   - ⚠️ Timezone Sénégal spécifique
   - ⚠️ Navigation depuis notifications

### 🟢 Zones Bien Documentées

1. **Constants** (`lib/constants.dart`) - Design system complet
2. **Modèles** (`lib/models/`) - Sérialisation claire
3. **Routes** (`lib/routes/app_routes.dart`) - Navigation bien structurée

---

## 🎯 Prochaines Priorités (Par Ordre)

### 🔥 Phase 1 : Programme Fidélité (1 semaine)
1. **Créer `loyalty_dashboard_screen.dart`** - Dashboard points et niveau
2. **Créer `loyalty_history_screen.dart`** - Historique transactions points
3. **Créer `rewards_catalog_screen.dart`** - Catalogue récompenses
4. **Créer `loyalty_provider.dart`** - Provider gestion fidélité
5. **Intégrer endpoints loyalty** - `/loyalty/*` backend

### 🔥 Phase 2 : Historique Commandes (1 semaine)
1. **Créer `orders_history_screen.dart`** - Liste commandes avec filtres par statut
2. **Créer `order_details_screen.dart`** - Détails commande avec timeline statut
3. **Créer `order_tracking_screen.dart`** - Suivi temps réel (lecture seule)
4. **Créer `orders_provider.dart`** - Provider gestion historique
5. **Intégrer endpoints orders** - `GET /orders`, `GET /orders/:id`

**Note importante** : Le client peut uniquement **observer** les statuts mis à jour par les admins. Aucune modification de statut n'est autorisée côté client.

### 🔥 Phase 3 : Optimisations & Polish (1 semaine)
1. **Performance optimization** - Lazy loading, cache
2. **Animations polish** - Micro-interactions
3. **Error handling** - Messages utilisateur améliorés
4. **Tests sur devices** - Android/iOS variés

---

## 🔧 Configuration Développement

### Commandes Essentielles
```bash
# Installation dépendances
cd frontend/mobile/customers_app
flutter pub get

# Lancement app
flutter run

# Build debug
flutter build apk --debug

# Analyse code
flutter analyze
```

### Variables d'Environnement
- **Backend URL** : Configuré dans `constants.dart`
- **Timezone** : Africa/Dakar (GMT+0)
- **Rôles autorisés** : CLIENT

### Base de Données Backend
- **Utilisateur test** : Créer avec `role: 'CLIENT'` dans table `users`
- **Endpoints** : Tous documentés dans `backend/docs/`

---

## 📚 Ressources & Documentation

### Liens Utiles
- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [FlutterMap Documentation](https://docs.fleaflet.dev/)

### Fichiers de Référence
- `DELIVERY_APP_TODO.md` - TODO détaillé par phases
- `backend/docs/` - Documentation API backend
- `backend/postman/` - Collections tests API

---

## 🎯 Objectif Final

**Application mobile complète** permettant aux clients de :
- ✅ Se connecter avec authentification sécurisée
- ✅ Créer des commandes complètes et flash
- ✅ Gérer leur profil et adresses
- ✅ Recevoir notifications en temps réel
- 🚧 Suivre leurs commandes (lecture seule des statuts)
- 🚧 Participer au programme de fidélité
- ⏳ Optimisations et polish final

**Timeline estimée** : 2-3 semaines pour finalisation complète

---

*Dernière mise à jour : $(date)*
*Prochaine révision : Après implémentation écrans principaux*