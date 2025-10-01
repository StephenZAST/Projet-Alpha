# 🏗️ Architecture & Workflow - Alpha Client App

## 🚨 INSTRUCTIONS OBLIGATOIRES POUR L'IA IMPLÉMENTATRICE

### ⚠️ LECTURE BACKEND OBLIGATOIRE
**AVANT TOUTE IMPLÉMENTATION DE FEATURE**, vous DEVEZ :

1. **Consulter les fichiers de référence backend** :
   - `backend/docs/REFERENCE_ARTICLE_SERVICE.md`
   - `backend/docs/REFERENCE_FEATURES.md`

2. **Identifier la feature correspondante** dans ces fichiers

3. **Lire les endpoints spécifiques** et la logique métier

4. **Comprendre les modèles de données** et les types

5. **Vérifier les contraintes** et règles business

### 📋 Processus d'Implémentation Obligatoire
```
Feature Request → Consulter REFERENCE_*.md → Identifier Backend Logic → Implémenter Frontend → Tester Integration
```

**JAMAIS d'implémentation sans cette validation préalable !**

---

## 📋 Analyse Backend et Features Disponibles

### Authentifi**Quick Actions Grid**
   - [ ] **Nouvelle Commande** (primary action) - Commande complète avec stepper
   - [ ] **Commande Flash** (secondary action) - Commande rapide en un clic
   - [ ] Suivi Commandes (tertiary)
   - [ ] Catalogue Services (quaternary)
   - [ ] Support Contact (quintary)
   - [ ] Glassmorphism cards avec hover effectsation & Gestion Utilisateur
- **Inscription/Connexion** : Registration, login, profile management
- **Profil** : Update profile, change password, preferences
- **Sécurité** : Token-based auth, password reset

### Gestion des Commandes
- **Création** : Multi-step order creation avec articles/services
- **Suivi** : Real-time status tracking, order history
- **Modification** : Edit order details, cancel orders
- **Paiement** : Payment integration, pricing calculation

### Système de Services
- **Catalogue** : Browse services, categories, pricing
- **Articles** : Clothing types, service compatibility
- **Tarification** : Dynamic pricing, premium options

### Système d'Affiliation
- **Programme** : Become affiliate, referral tracking
- **Commissions** : Earn and track commissions
- **Withdrawals** : Request and manage payouts

### Programme de Fidélité
- **Points** : Earn and spend loyalty points
- **Récompenses** : Redeem rewards, special offers
- **Niveaux** : Tier-based benefits

### Notifications
- **Push** : Real-time order updates
- **Préférences** : Notification settings
- **Historique** : Notification history

### Livraison
- **Zones** : Delivery area coverage
- **Suivi** : Real-time delivery tracking
- **Planification** : Schedule pickup/delivery

---

## 🎯 Architecture de l'Application Client

### Structure Générale
```
lib/
├── core/
│   ├── constants/        # Design tokens, colors, typography
│   ├── theme/           # Theme provider, light/dark modes
│   ├── utils/           # Helpers, formatters, validators
│   └── services/        # API services, local storage
├── features/
│   ├── auth/            # Authentication flow
│   ├── home/            # Dashboard, welcome screen
│   ├── orders/          # Order management (normal + flash)
│   ├── services/        # Service catalog
│   ├── profile/         # User profile management
│   ├── loyalty/         # Loyalty program
│   ├── notifications/   # Notification center
│   └── delivery/        # Delivery tracking
├── shared/
│   ├── widgets/         # Reusable UI components
│   ├── models/          # Data models
│   └── providers/       # State management
└── main.dart           # App entry point
```

---

## 🚀 Workflow Utilisateur Optimisé

### 1. Onboarding & Authentification

#### Flow d'Inscription
```
Splash Screen → Welcome → Registration → Email Verification → Profile Setup → Home
```

**Écrans Requis :**
- `SplashScreen` : Logo Alpha avec animation
- `WelcomeScreen` : Introduction au service avec benefits
- `RegistrationScreen` : Form multi-step avec validation temps réel
- `EmailVerificationScreen` : Code verification avec resend
- `ProfileSetupScreen` : Photo, preferences, **adresse de livraison par défaut obligatoire**
- `OnboardingCompleteScreen` : Welcome message, quick tour

**Features UX :**
- Animation fluide entre étapes
- Progress indicator elegant
- Validation inline avec feedback
- Skip options pour informations optionnelles (sauf adresse)
- Auto-save draft information
- **Validation obligatoire de l'adresse de livraison pour commandes flash**

#### Flow de Connexion
```
Login Screen → Biometric/PIN → Home
```

**Écrans Requis :**
- `LoginScreen` : Email/password avec biometric option
- `ForgotPasswordScreen` : Email recovery avec countdown
- `BiometricAuthScreen` : Face ID/Touch ID/PIN setup

---

### 2. Dashboard Principal (Home)

#### Composants Principaux
```
AppBar avec logo + notifications + profile
  ↓
Hero Section : Greeting + Quick Stats
  ↓
Quick Actions : Nouvelle commande, Suivi, Services
  ↓
Recent Orders : 3 dernières commandes avec status
  ↓
Services Populaires : Grid des services tendance
  ↓
Promotions : Carousel des offres actives
  ↓
Loyalty Status : Points, niveau, prochaine récompense
```

**Features UX :**
- Skeleton loading pour chaque section
- Pull-to-refresh global
- Quick actions avec haptic feedback
- Real-time status updates
- Personalization basée sur l'historique

---

### 3. Création de Commande (Multi-Step)

### 🛍️ Commande Complète Multi-Step
**Priorité : CRITIQUE**

#### Flow Optimisé
```
Service Selection → Article Selection → Pickup Details → Delivery Details → Summary → Payment → Confirmation
```

**Étape 1 : Service Selection**
- Grid/List des services avec filtres
- Preview pricing pour chaque service
- Popular/Recommended tags
- Quick select pour services fréquents

**Étape 2 : Article Selection**
- Catalog interactif par catégorie
- Quantity picker avec counter animations
- Real-time price calculation
- Add/remove avec micro-animations

**Étape 3 : Pickup Details**
- Address selector (saved addresses + new)
- Date/time picker avec availability
- Special instructions text area
- Contact preference toggle

**Étape 4 : Delivery Details**
- Address selector (peut être différente du pickup)
- Delivery window selection
- Express/Standard options
- Packaging preferences

**Étape 5 : Summary & Review**
- Itemized pricing breakdown
- Edit buttons pour chaque section
- Terms & conditions checkbox
- Estimated completion time

**Étape 6 : Payment**
- Payment method selection
- Secure payment processing
- Success/error handling
- Receipt generation

**Features UX :**
- Progress bar sticky en haut
- Back navigation avec sauvegarde
- Real-time price updates
- Validation progressive
- Error handling elegant

---

### ⚡ Commande Flash (One-Click Order)
**Priorité : HAUTE**

#### Concept
Commande rapide en un clic utilisant les préférences et adresse par défaut de l'utilisateur, créant un draft que l'admin complétera.

#### Flow Simplifié
```
Quick Selection → Confirmation → Draft Created → Admin Completion
```

**Quick Selection Screen :**
- Services populaires en grid rapide
- Quantités par défaut ou dernière commande
- Preview pricing estimé
- **Utilise automatiquement l'adresse par défaut**

**Confirmation Rapide :**
- Résumé des éléments sélectionnés
- Adresse de pickup/delivery (par défaut)
- Estimation de prix approximative
- Notes optionnelles rapides

**Draft Creation :**
- Statut "DRAFT" en backend
- Informations partielles sauvegardées
- Notification à l'équipe admin
- Confirmation à l'utilisateur avec référence

**Admin Completion (Backend App) :**
- Les admins reçoivent la draft order
- Complètent les détails manquants
- Calculent le prix final exact
- Contactent le client pour validation
- Finalisent la commande

#### Prérequis Obligatoires
- **Adresse par défaut configurée** (pickup + delivery)
- **Méthode de paiement par défaut** (optionnel)
- **Préférences de service** sauvegardées

#### Backend Integration
- Endpoint : `POST /api/orders/flash`
- Payload minimal requis
- Création avec statut DRAFT
- Workflow admin pour completion

**Features UX :**
- Bouton "Commande Flash" proéminent sur dashboard
- Animation rapide de confirmation
- Feedback immédiat sur création draft
- Suivi du statut draft → completed

---

### 4. Suivi des Commandes

#### Interface de Suivi
```
Orders List → Order Details → Real-time Tracking
```

**Orders List Screen :**
- Filtres par status (Active, Completed, Cancelled)
- Search bar avec suggestions
- Sort options (Date, Status, Price)
- Infinite scroll avec pagination
- Empty states élégants

**Order Details Screen :**
- Timeline visuelle du status
- Photo gallery des articles
- Contact delivery option
- Modify/cancel actions
- Share order details

**Real-time Tracking :**
- Map integration pour delivery
- Live status updates
- Estimated time calculations
- Push notifications intégrées

---

### 5. Catalogue de Services

#### Organisation
```
Categories → Services → Service Details → Add to Order
```

**Categories Screen :**
- Visual grid avec icônes
- Search et filtres avancés
- Popular services highlight
- Price range indicators

**Service Details :**
- Photo gallery avec zoom
- Pricing matrix détaillée
- Reviews et ratings
- FAQ section
- Add to cart/order directly

---

### 6. Profil Utilisateur

#### Sections Principales
```
Profile Info → Order History → Addresses → Payment Methods → Preferences → Support
```

**Profile Management :**
- Photo upload avec crop
- Edit inline information
- Password change modal
- Account deletion option

**Order History :**
- Chronological list avec search
- Reorder functionality
- Export history option
- Favorite services tracking

**Address Book :**
- CRUD operations pour addresses
- Map integration pour selection
- Default address management
- Validation et geocoding

---

### 7. Programme de Fidélité

#### Features
- Points balance avec visual progress
- Rewards catalog avec preview
- Transaction history
- Tier progression visualization
- Exclusive offers pour membres

---

### 8. Programme d'Affiliation

#### Dashboard Affilié
- Commission tracking avec charts
- Referral link management
- Performance analytics
- Withdrawal requests
- Marketing materials access

---

### 9. Centre de Notifications

#### Gestion
- Categorized notifications (Orders, Promotions, System)
- Mark as read/unread
- Notification preferences
- Push notification toggle
- History avec search

---

## 🎨 Composants UI Signature

### Navigation
- **Bottom Navigation** : Home, Orders, Services, Profile
- **Floating Action Button** : Quick order creation
- **App Bar** : Contextuel selon la page

### Cards & Containers
- **GlassContainer** : Base pour tous les containers
- **ServiceCard** : Services avec pricing preview
- **OrderCard** : Commandes avec status timeline
- **PromoCard** : Promotions avec countdown timers

### Buttons & Actions
- **PremiumButton** : Primary actions avec variants
- **IconButton** : Secondary actions avec tooltips
- **StatusBadge** : Status indicators avec animations

### Forms & Inputs
- **PremiumTextField** : Inputs avec validation inline
- **QuantityPicker** : Counter avec animations
- **DateTimePicker** : Native pickers avec customization
- **AddressPicker** : Map integration avec search

### Loading & Empty States
- **SkeletonLoader** : Pour chaque type de content
- **EmptyState** : Illustrations avec call-to-action
- **LoadingOverlay** : Progress indicators contextuels

---

## 📊 State Management

### Provider Architecture
```dart
├── AppProvider (Global app state)
├── AuthProvider (User authentication)
├── OrderProvider (Order management)
├── ServiceProvider (Services catalog)
├── NotificationProvider (Notifications)
└── ThemeProvider (UI theme management)
```

### Data Flow
```
UI Widget → Provider → Service → API → Database
    ↓         ↑        ↑       ↑       ↑
  State    Notify   Cache   HTTP   Persistence
```

---

## 🔄 API Integration

### Service Layer
```dart
class ApiService {
  // Base HTTP client configuration
  // Token management et refresh
  // Error handling global
  // Request/response interceptors
}

class AuthService extends ApiService {
  // Login, register, logout
  // Token storage et validation
  // Biometric integration
}

class OrderService extends ApiService {
  // Order CRUD operations
  // Real-time status updates
  // Price calculations
}
```

### Offline Support
- Cache strategy pour données critiques
- Sync mechanism pour actions offline
- Conflict resolution pour données modifiées
- Graceful degradation d'expérience

---

## 📱 Performance & Optimization

### Image Management
- Lazy loading avec placeholders
- Compression automatique
- Cache strategy avec expiration
- Progressive loading pour galleries

### Memory Management
- Proper disposal des controllers
- Image cache cleanup
- Provider lifecycle management
- Memory leak prevention

### Network Optimization
- Request batching pour efficiency
- Retry logic avec exponential backoff
- Connection state awareness
- Data compression

---

## 🧪 Testing Strategy

### Unit Tests
- Business logic validation
- Service layer testing
- State management verification
- Utility functions coverage

### Widget Tests
- UI component behavior
- User interaction simulation
- State change validation
- Accessibility compliance

### Integration Tests
- Complete user workflows
- API integration validation
- Performance benchmarking
- Cross-platform compatibility

---

## 🚀 Deployment Pipeline

### Build Configuration
```
Development → Staging → Production
     ↓           ↓         ↓
   Debug     Profile   Release
```

### Quality Gates
- Code review requirements
- Automated testing passage
- Performance benchmarks
- Accessibility audit
- Security scan validation

---

Cette architecture garantit une expérience utilisateur exceptionnelle tout en maintenant la performance, la maintenabilité et l'évolutivité de l'application.