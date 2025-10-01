# 🚀 Alpha Pressing - Application Client Premium

## 📋 Vue d'Ensemble

Application mobile Flutter premium pour Alpha Pressing, développée avec un design glassmorphism sophistiqué et une expérience utilisateur exceptionnelle. Cette application représente l'excellence du savoir-faire design d'Alpha Pressing.

## ✨ Fonctionnalités Implémentées

### 🔐 Système d'Authentification Complet
- **Connexion** : Interface premium avec validation temps réel
- **Inscription** : Processus multi-étapes avec validation progressive
- **Gestion de session** : Persistance automatique et vérification de token
- **Mot de passe oublié** : Flow de récupération intégré
- **Déconnexion** : Nettoyage sécurisé des données

### 🏠 Dashboard Premium
- **Accueil personnalisé** : Salutation avec nom utilisateur réel
- **Carte bancaire virtuelle** : Style premium avec gradient
- **Services populaires** : Carousel horizontal avec pricing
- **Commandes récentes** : Historique avec statuts visuels
- **Promotions** : Section mise en avant
- **Menu profil** : Bottom sheet avec options utilisateur

### 🎨 Design System Sophistiqué
- **Glassmorphism** : Effets de transparence et blur avancés
- **Thème adaptatif** : Support complet clair/sombre
- **Animations fluides** : Micro-interactions premium
- **Typographie Inter** : Police premium avec hiérarchie claire
- **Couleurs signature** : Palette Alpha Pressing (#2563EB)

### 🏗️ Architecture Technique
- **Provider Pattern** : State management avec Provider
- **Services modulaires** : AuthService, StorageService
- **Modèles de données** : User, Address, PaymentMethod, etc.
- **Persistance locale** : SharedPreferences pour les préférences
- **API Integration** : HTTP client configuré pour le backend

## 📁 Structure du Projet

```
lib/
├── core/
│   ├── models/           # Modèles de données (User, Address, etc.)
│   ├── services/         # Services API (AuthService)
│   └── utils/           # Utilitaires (StorageService)
├── features/
│   └── auth/
│       └── screens/     # Écrans d'authentification
├── shared/
│   ├── providers/       # State management (AuthProvider)
│   └── widgets/         # Composants réutilisables
├── components/          # Composants UI premium (GlassContainer, etc.)
├── theme/              # Gestion des thèmes
├── screens/            # Écrans principaux (HomePage)
├── constants.dart      # Design tokens et constantes
└── main.dart          # Point d'entrée de l'application
```

## 🎯 Prochaines Étapes Recommandées

### Semaine 1-2 : Commandes Flash
1. **Créer le service FlashOrderService**
2. **Implémenter l'écran de commande flash**
3. **Intégrer avec l'endpoint `/api/orders/flash`**
4. **Validation des prérequis (adresse par défaut)**

### Semaine 3-4 : Commande Complète Multi-Step
1. **Service OrderService complet**
2. **Stepper de création de commande**
3. **Intégration pricing avec backend**
4. **Gestion des articles et services**

### Semaine 5-6 : Profil Utilisateur
1. **Écran de profil complet**
2. **Gestion des adresses**
3. **Méthodes de paiement**
4. **Préférences utilisateur**

## 🔧 Installation et Configuration

### Prérequis
- Flutter SDK (>=3.6.0)
- Dart SDK
- Android Studio / VS Code
- Émulateur Android/iOS ou appareil physique

### Installation
```bash
# Cloner le projet
cd frontend/mobile/customers_app

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Configuration Backend
Mettre à jour l'URL du backend dans `lib/constants.dart` :
```dart
class ApiConfig {
  static const String baseUrl = 'https://votre-backend-url.com';
}
```

### Développement local (recommandé)
Pour pointer rapidement l'application vers un backend local ou de test sans modifier le code, utilisez l'option `--dart-define` :

```bash
# Exemple : exécuter l'application Flutter en utilisant un backend local
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000

# Ou pour Android/iOS (émulateur)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

L'option `API_VERSION` est aussi disponible si votre backend expose une version comme `/api/v1` :

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=API_VERSION=v1
```

Cette approche évite les modifications permanentes et facilite les tests en local.

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.1              # State management
  shared_preferences: ^2.2.2    # Persistance locale
  http: ^1.1.0                  # Requêtes HTTP
  flutter_svg: ^2.0.10+1        # Support SVG
```

## 🎨 Design Tokens

### Couleurs Signature
- **Primary** : #2563EB (Bleu Alpha)
- **Accent** : #06B6D4 (Cyan moderne)
- **Success** : #10B981 (Vert service terminé)
- **Warning** : #F59E0B (Ambre en cours)
- **Error** : #EF4444 (Rouge problème)

### Espacements
- **xs** : 4px
- **sm** : 8px
- **md** : 16px
- **lg** : 24px
- **xl** : 32px

### Rayons
- **sm** : 8px
- **md** : 12px
- **lg** : 16px
- **xl** : 20px

## 🔐 Authentification

### Flow Utilisateur
1. **Splash Screen** : Vérification de session existante
2. **Login/Register** : Selon l'état d'authentification
3. **Home** : Redirection après connexion réussie

### Sécurité
- Tokens JWT stockés de manière sécurisée
- Vérification automatique de validité
- Nettoyage automatique en cas d'expiration

## 🎯 Fonctionnalités Backend Intégrées

### Endpoints Utilisés
- `POST /api/auth/login` : Connexion
- `POST /api/auth/register` : Inscription
- `GET /api/auth/verify` : Vérification token
- `POST /api/auth/forgot-password` : Récupération mot de passe

### Modèles de Données
- **User** : Informations utilisateur complètes
- **UserProfile** : Profil étendu avec adresses et préférences
- **Address** : Adresses de livraison/collecte
- **PaymentMethod** : Méthodes de paiement
- **LoyaltyInfo** : Informations de fidélité

## 🚀 Performance

### Optimisations Implémentées
- Lazy loading des images
- Skeleton loading states
- Animations 60 FPS
- Cache intelligent des données
- Memory management optimisé

### Métriques Cibles
- Time to Interactive : < 2s
- First Contentful Paint : < 1s
- App size : < 50MB
- Memory usage : < 200MB

## 🎨 Composants UI Premium

### GlassContainer
Conteneur glassmorphism universel avec blur et transparence.

### PremiumButton
Boutons sophistiqués avec micro-interactions et variants.

### StatusBadge
Badges de statut avec couleurs contextuelles.

### SkeletonLoader
Loading states élégants avec animations shimmer.

## 📱 Responsive Design

### Breakpoints
- **Mobile** : < 768px
- **Tablet** : 768px - 1024px
- **Desktop** : > 1024px

### Adaptations
- Layout flexible selon la taille d'écran
- Typographie responsive
- Espacements adaptatifs

## 🔍 Debugging

### Logs Utiles
```dart
// Activer les logs détaillés
flutter run --verbose

// Logs d'authentification
print('Auth state: ${authProvider.isAuthenticated}');
print('Current user: ${authProvider.currentUser?.fullName}');
```

### Outils de Debug
- Flutter Inspector
- Network Inspector
- Performance Overlay
- Widget Inspector

## 🤝 Contribution

### Standards de Code
- Utiliser les design tokens définis
- Suivre l'architecture Provider
- Documenter les nouvelles fonctionnalités
- Tester sur multiple devices

### Workflow Git
1. Créer une branche feature
2. Développer avec commits atomiques
3. Tester thoroughly
4. Créer une Pull Request
5. Review et merge

## 📞 Support

Pour toute question ou problème :
- Consulter la documentation backend dans `backend/docs/`
- Vérifier les fichiers de référence `REFERENCE_*.md`
- Tester les endpoints avec Postman

---

**Développé avec ❤️ pour Alpha Pressing**
*Excellence & Innovation*