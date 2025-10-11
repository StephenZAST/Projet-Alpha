# 🎨 Analyse des Design Patterns & Workflows - Alpha Customer App

## 📋 Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Architecture Globale](#architecture-globale)
3. [Design System](#design-system)
4. [Patterns de Code](#patterns-de-code)
5. [Workflow Patterns](#workflow-patterns)
6. [Conventions de Nommage](#conventions-de-nommage)
7. [Gestion d'État](#gestion-détat)
8. [Navigation](#navigation)
9. [Bonnes Pratiques](#bonnes-pratiques)

---

## 🎯 Vue d'ensemble

L'application **Alpha Customer App** fait partie d'un écosystème de 4 applications Flutter :
- **Customer App** (cette app) - Pour les clients
- **Admin Dashboard** - Pour les administrateurs
- **Affiliate App** - Pour les affiliés
- **Delivery App** - Pour les livreurs

Toutes ces applications partagent :
- Un backend Node.js/TypeScript commun avec Prisma ORM
- Des API REST communes
- Un design system cohérent basé sur le glassmorphism
- Des patterns de code similaires

---

## 🏗️ Architecture Globale

### Structure des Dossiers

```
lib/
├── components/              # Composants réutilisables (Glass components)
├── core/                    # Couche métier centrale
│   ├── models/             # Modèles de données
│   ├── services/           # Services API
│   └── utils/              # Utilitaires (storage, etc.)
├── features/               # Features organisées par domaine
│   ├── auth/              # Authentification
│   ├── notifications/     # Notifications
│   ├── orders/            # Commandes
│   ├── profile/           # Profil utilisateur
│   └── services/          # Services de pressing
├── providers/             # Providers métier spécifiques
├── screens/               # Écrans principaux
├── shared/                # Ressources partagées
│   ├── providers/        # Providers partagés
│   ├── utils/            # Utilitaires partagés
│   └── widgets/          # Widgets partagés
├── theme/                # Thème et styles
├── constants.dart        # Constantes globales
└── main.dart            # Point d'entrée
```

### Principes Architecturaux

1. **Feature-First Organization** : Organisation par fonctionnalité métier
2. **Separation of Concerns** : Séparation claire entre UI, logique et données
3. **Provider Pattern** : Gestion d'état avec Provider
4. **Service Layer** : Couche de services pour les appels API
5. **Model Layer** : Modèles de données typés et immutables

---

## 🎨 Design System

### 1. Système de Couleurs

Le design system utilise un **système de couleurs adaptatif** avec support complet des thèmes clair/sombre.

#### Couleurs Signature (Invariantes)
```dart
AppColors.primary        // #2563EB - Bleu signature Alpha
AppColors.primaryLight   // #60A5FA - Bleu clair
AppColors.primaryDark    // #1E40AF - Bleu foncé
AppColors.accent         // #06B6D4 - Cyan moderne
AppColors.secondary      // #8B5CF6 - Violet secondaire
```

#### Couleurs de Statut
```dart
AppColors.success        // #10B981 - Vert (service terminé)
AppColors.warning        // #F59E0B - Ambre (en cours)
AppColors.error          // #EF4444 - Rouge (problème)
AppColors.info           // #3B82F6 - Bleu info
```

#### Couleurs Adaptatives (selon le thème)
```dart
AppColors.textPrimary(context)      // Texte principal
AppColors.textSecondary(context)    // Texte secondaire
AppColors.surface(context)          // Surface des cartes
AppColors.background(context)       // Fond d'écran
AppColors.border(context)           // Bordures
```

**Pattern d'utilisation** :
```dart
// ✅ BON - Utilise le contexte pour l'adaptation
Text(
  'Hello',
  style: TextStyle(color: AppColors.textPrimary(context)),
)

// ❌ MAUVAIS - Couleur fixe, ne s'adapte pas au thème
Text(
  'Hello',
  style: TextStyle(color: Colors.black),
)
```

### 2. Typographie

Système de typographie basé sur **Inter** avec hiérarchie claire.

#### Hiérarchie des Titres
```dart
AppTextStyles.display        // 48px, w800 - Titres hero
AppTextStyles.h1            // 32px, w700 - Titres principaux
AppTextStyles.h2            // 24px, w600 - Sous-titres
AppTextStyles.h3            // 20px, w600 - Sections
AppTextStyles.h4            // 18px, w500 - Sous-sections
```

#### Corps de Texte
```dart
AppTextStyles.bodyLarge     // 18px, w400 - Texte important
AppTextStyles.bodyMedium    // 16px, w400 - Texte standard
AppTextStyles.bodySmall     // 14px, w400 - Texte secondaire
```

#### Labels et Boutons
```dart
AppTextStyles.labelLarge    // 16px, w500 - Labels importants
AppTextStyles.labelMedium   // 14px, w500 - Labels standards
AppTextStyles.labelSmall    // 12px, w500 - Labels petits
AppTextStyles.buttonMedium  // 14px, w600 - Texte de boutons
```

**Pattern d'utilisation** :
```dart
// ✅ BON - Utilise les styles prédéfinis avec adaptation
Text(
  'Titre',
  style: AppTextStyles.h2.copyWith(
    color: AppColors.textPrimary(context),
  ),
)
```

### 3. Espacements

Système d'espacement basé sur **8pt grid**.

```dart
AppSpacing.xs      // 4px
AppSpacing.sm      // 8px
AppSpacing.md      // 16px
AppSpacing.lg      // 24px
AppSpacing.xl      // 32px
AppSpacing.xxl     // 48px
AppSpacing.xxxl    // 64px
```

**EdgeInsets prédéfinis** :
```dart
AppSpacing.cardPadding      // EdgeInsets.all(16)
AppSpacing.pagePadding      // EdgeInsets.all(24)
AppSpacing.buttonPadding    // EdgeInsets.symmetric(h: 24, v: 16)
```

### 4. Rayons et Formes

```dart
AppRadius.xs       // 4px
AppRadius.sm       // 8px
AppRadius.md       // 12px
AppRadius.lg       // 16px
AppRadius.xl       // 20px
AppRadius.xxl      // 24px
AppRadius.full     // 999px (cercle)
```

**BorderRadius prédéfinis** :
```dart
AppRadius.cardRadius       // 16px - Pour les cartes
AppRadius.buttonRadius     // 12px - Pour les boutons
AppRadius.inputRadius      // 8px - Pour les inputs
```

### 5. Ombres et Glassmorphism

Le design utilise le **glassmorphism** comme signature visuelle.

```dart
AppShadows.light          // Ombre légère
AppShadows.medium         // Ombre moyenne
AppShadows.heavy          // Ombre forte
AppShadows.glass          // Ombre glass effect
AppShadows.glassPrimary   // Ombre glass avec teinte primaire
```

### 6. Animations

Durées et courbes d'animation standardisées.

```dart
// Durées
AppAnimations.instant      // 100ms
AppAnimations.fast         // 150ms
AppAnimations.medium       // 250ms
AppAnimations.slow         // 350ms
AppAnimations.extraSlow    // 500ms

// Courbes
AppAnimations.slideIn      // Curves.easeOutQuart
AppAnimations.fadeIn       // Curves.easeOut
AppAnimations.buttonPress  // Curves.easeInOut
```

---

## 🔧 Patterns de Code

### 1. Composants Glass (Glassmorphism)

Le **GlassContainer** est le composant de base pour tous les éléments visuels.

```dart
// Pattern de base
GlassContainer(
  padding: AppSpacing.cardPadding,
  margin: AppSpacing.cardMargin,
  child: Column(
    children: [
      // Contenu
    ],
  ),
)

// Avec interaction
GlassContainer(
  onTap: () => _handleTap(),
  isInteractive: true,
  child: // ...
)
```

**Composants dérivés** :
- `PremiumCard` - Carte premium avec glassmorphism
- `PremiumButton` - Bouton avec animations et glassmorphism
- `StatusBadge` - Badge de statut coloré
- `SkeletonLoader` - Skeleton loading animé

### 2. Pattern Provider

Tous les providers suivent le même pattern avec `ChangeNotifier`.

```dart
class MyProvider extends ChangeNotifier {
  // État privé
  bool _isLoading = false;
  String? _error;
  MyData? _data;

  // Getters publics
  bool get isLoading => _isLoading;
  String? get error => _error;
  MyData? get data => _data;

  // Méthodes publiques
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();
    
    try {
      _data = await _service.fetchData();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
```

**Utilisation dans les widgets** :
```dart
// Lecture seule
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.error != null) return ErrorWidget(provider.error!);
    return DataWidget(provider.data);
  },
)

// Accès sans rebuild
final provider = Provider.of<MyProvider>(context, listen: false);
provider.loadData();
```

### 3. Pattern Service

Les services encapsulent les appels API.

```dart
class MyService {
  final ApiService _api = ApiService();

  Future<MyModel> fetchData() async {
    final response = await _api.get('/endpoint');
    
    if (response['success'] == true) {
      return MyModel.fromJson(response['data']);
    } else {
      throw Exception(response['error'] ?? 'Erreur inconnue');
    }
  }

  Future<bool> createData(Map<String, dynamic> data) async {
    final response = await _api.post('/endpoint', data: data);
    return response['success'] == true;
  }
}
```

### 4. Pattern Modèle

Les modèles sont immutables avec factory constructors.

```dart
class MyModel {
  final String id;
  final String name;
  final DateTime createdAt;

  MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // Factory pour JSON
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // CopyWith pour immutabilité
  MyModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return MyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 5. Pattern Écran

Structure standard pour les écrans.

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with TickerProviderStateMixin {
  // Contrôleurs d'animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
          parent: _fadeController,
          curve: AppAnimations.fadeIn,
        ));
    _fadeController.forward();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MyProvider>(context, listen: false);
      provider.loadData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      title: Text(
        'Mon Écran',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return _buildLoadingState();
        if (provider.error != null) return _buildErrorState(provider.error!);
        return _buildContent(provider.data);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: 16),
          Text(error, style: AppTextStyles.bodyMedium),
          SizedBox(height: 24),
          PremiumButton(
            text: 'Réessayer',
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MyData? data) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // Contenu
        ],
      ),
    );
  }
}
```

---

## 🔄 Workflow Patterns

### 1. Workflow de Création de Commande

Le workflow de création de commande suit un **pattern multi-étapes** avec validation.

**Étapes** :
1. **Adresse** - Sélection de l'adresse de livraison
2. **Service** - Choix du type de service (Express, Standard, etc.)
3. **Articles** - Sélection des articles à traiter
4. **Informations** - Dates et options complémentaires
5. **Résumé** - Vérification et confirmation

**Pattern d'implémentation** :
```dart
// Provider pour gérer l'état du workflow
class OrderDraftProvider extends ChangeNotifier {
  int _currentStep = 0;
  OrderDraft _orderDraft = OrderDraft.empty();

  int get currentStep => _currentStep;
  OrderDraft get orderDraft => _orderDraft;

  bool get canGoToNextStep {
    switch (_currentStep) {
      case 0: return _orderDraft.hasAddress;
      case 1: return _orderDraft.hasService;
      case 2: return _orderDraft.hasItems;
      case 3: return _orderDraft.hasRequiredInfo;
      default: return false;
    }
  }

  void nextStep() {
    if (canGoToNextStep && _currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
}

// Écran avec PageView
PageView(
  controller: _pageController,
  onPageChanged: (index) => provider.goToStep(index),
  children: [
    AddressSelectionStep(),
    ServiceSelectionStep(),
    ArticleSelectionStep(),
    OrderInfoStep(),
    OrderSummaryStep(),
  ],
)
```

### 2. Workflow d'Authentification

**Pattern AuthWrapper** :
```dart
class AuthWrapper extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return SplashScreen();
        }
        
        if (authProvider.isAuthenticated) {
          return MainNavigation();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
```

### 3. Workflow de Navigation

**Pattern MainNavigation** avec BottomNavigationBar :
```dart
class MainNavigation extends StatefulWidget {
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomePage(),
    OrdersScreen(),
    ServicesScreen(),
    LoyaltyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.design_services), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Fidélité'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

### 4. Workflow de Gestion d'Erreurs

**Pattern de gestion d'erreurs cohérent** :
```dart
try {
  _setLoading(true);
  _clearError();
  
  final result = await _service.performAction();
  
  if (result.isSuccess) {
    _showSuccessMessage('Action réussie');
  } else {
    _setError(result.error ?? 'Erreur inconnue');
  }
} catch (e) {
  _setError('Erreur: ${e.toString()}');
} finally {
  _setLoading(false);
}
```

---

## 📝 Conventions de Nommage

### 1. Fichiers

```
// Écrans
home_page.dart
create_order_screen.dart
profile_screen.dart

// Widgets
order_card.dart
address_form_dialog.dart
notification_tile.dart

// Providers
auth_provider.dart
order_draft_provider.dart

// Services
auth_service.dart
api_service.dart

// Modèles
user.dart
order.dart
address.dart
```

### 2. Classes

```dart
// Écrans : suffixe Screen ou Page
class HomePage extends StatefulWidget {}
class CreateOrderScreen extends StatefulWidget {}

// Widgets : nom descriptif
class OrderCard extends StatelessWidget {}
class AddressFormDialog extends StatefulWidget {}

// Providers : suffixe Provider
class AuthProvider extends ChangeNotifier {}
class OrderDraftProvider extends ChangeNotifier {}

// Services : suffixe Service
class AuthService {}
class ApiService {}

// Modèles : nom simple
class User {}
class Order {}
class Address {}
```

### 3. Variables et Méthodes

```dart
// Variables privées : préfixe _
bool _isLoading = false;
String? _error;

// Getters publics : pas de préfixe
bool get isLoading => _isLoading;

// Méthodes privées : préfixe _
void _setLoading(bool loading) {}
void _clearError() {}

// Méthodes publiques : pas de préfixe
Future<void> loadData() async {}
void updateProfile(User user) {}

// Handlers : préfixe _handle
void _handleTap() {}
void _handleSubmit() {}

// Builders : préfixe _build
Widget _buildAppBar() {}
Widget _buildBody() {}
```

### 4. Constantes

```dart
// Classes de constantes : PascalCase
class AppColors {}
class AppTextStyles {}
class AppSpacing {}

// Constantes : camelCase
static const Color primary = Color(0xFF2563EB);
static const double cardRadius = 16.0;
```

---

## 🎯 Gestion d'État

### 1. Provider Pattern

L'application utilise **Provider** pour la gestion d'état.

**Providers principaux** :
- `AuthProvider` - Authentification et utilisateur
- `ThemeProvider` - Thème clair/sombre
- `OrderDraftProvider` - Brouillon de commande
- `AddressProvider` - Gestion des adresses
- `NotificationProvider` - Notifications
- `FlashOrderProvider` - Commandes flash
- `UserProfileProvider` - Profil utilisateur

**Initialisation dans main.dart** :
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OrderDraftProvider()),
    // ...
  ],
  child: MyApp(),
)
```

### 2. État Local vs Global

**État Global (Provider)** :
- Authentification
- Thème
- Données utilisateur
- Panier/Brouillon de commande
- Notifications

**État Local (setState)** :
- Animations
- Formulaires
- UI temporaire
- Sélections locales

### 3. Persistance

**StorageService** pour la persistance locale :
```dart
class StorageService {
  static Future<void> saveUser(User user) async {}
  static Future<User?> getUser() async {}
  static Future<void> saveToken(String token) async {}
  static Future<String?> getToken() async {}
  static Future<void> clearUser() async {}
}
```

---

## 🧭 Navigation

### 1. Navigation Déclarative

**Routes nommées** :
```dart
MaterialApp(
  routes: {
    '/home': (context) => HomePage(),
    '/login': (context) => LoginScreen(),
  },
)

// Navigation
Navigator.of(context).pushNamed('/home');
```

### 2. Navigation Impérative

**PageRouteBuilder pour animations personnalisées** :
```dart
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => 
        CreateOrderScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: AppAnimations.slideIn)),
        ),
        child: child,
      );
    },
    transitionDuration: AppAnimations.medium,
  ),
);
```

### 3. Modals et Dialogs

**BottomSheet** :
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: // Contenu
  ),
);
```

**Dialog** :
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.surface(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Text('Titre'),
    content: Text('Message'),
    actions: [
      TextButton(onPressed: () {}, child: Text('Annuler')),
      PremiumButton(text: 'Confirmer', onPressed: () {}),
    ],
  ),
);
```

---

## ✅ Bonnes Pratiques

### 1. Performance

```dart
// ✅ BON - Utilise const pour les widgets statiques
const SizedBox(height: 16)
const Icon(Icons.home)

// ✅ BON - Utilise Consumer pour limiter les rebuilds
Consumer<MyProvider>(
  builder: (context, provider, child) => Text(provider.data),
)

// ✅ BON - Extrait les widgets complexes
Widget _buildComplexWidget() {
  return ComplexWidget();
}

// ❌ MAUVAIS - Rebuild inutile
Provider.of<MyProvider>(context).data
```

### 2. Accessibilité

```dart
// ✅ BON - Utilise Semantics
Semantics(
  label: 'Bouton de connexion',
  button: true,
  child: PremiumButton(text: 'Connexion'),
)

// ✅ BON - Tailles de texte adaptatives
Text(
  'Hello',
  style: AppTextStyles.bodyMedium,
  textScaleFactor: MediaQuery.of(context).textScaleFactor,
)
```

### 3. Responsive Design

```dart
// ✅ BON - Utilise MediaQuery
final width = MediaQuery.of(context).size.width;
final isTablet = width > 600;

// ✅ BON - Utilise LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return TabletLayout();
    }
    return MobileLayout();
  },
)
```

### 4. Gestion des Erreurs

```dart
// ✅ BON - Gestion d'erreurs complète
try {
  await performAction();
} catch (e, stackTrace) {
  debugPrint('Erreur: $e');
  debugPrint(stackTrace.toString());
  _showErrorMessage(e.toString());
}

// ✅ BON - Validation des données
if (data == null || data.isEmpty) {
  throw Exception('Données invalides');
}
```

### 5. Tests

```dart
// ✅ BON - Tests unitaires pour les providers
test('AuthProvider login success', () async {
  final provider = AuthProvider();
  final result = await provider.login('email', 'password');
  expect(result, true);
  expect(provider.isAuthenticated, true);
});

// ✅ BON - Tests de widgets
testWidgets('HomePage displays correctly', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Alpha Pressing'), findsOneWidget);
});
```

---

## 🎨 Exemples de Code Complets

### Exemple 1 : Écran Simple avec Provider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../components/glass_components.dart';
import '../providers/my_provider.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
          parent: _fadeController,
          curve: AppAnimations.fadeIn,
        ));
    _fadeController.forward();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyProvider>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary(context),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Mon Écran',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        return _buildContent(provider.data);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton(
              text: 'Réessayer',
              onPressed: _loadData,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MyData? data) {
    if (data == null) {
      return Center(
        child: Text(
          'Aucune donnée',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Text(
            'Titre',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sous-titre',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 32),

          // Carte principale
          PremiumCard(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.star,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            data.subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PremiumButton(
                  text: 'Action',
                  onPressed: () => _handleAction(),
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction() {
    // Logique d'action
  }
}
```

### Exemple 2 : Widget Réutilisable

```dart
import 'package:flutter/material.dart';
import '../constants.dart';
import '../components/glass_components.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary(context),
              size: 16,
            ),
        ],
      ),
    );
  }
}
```

---

## 📚 Ressources Complémentaires

### Documentation Backend
- `backend/docs/REFERENCE_FEATURES.md` - Documentation des features
- `backend/docs/REFERENCE_ARTICLE_SERVICE.md` - Référence Article/Service
- `backend/docs/roles_permissions.md` - Rôles et permissions

### Fichiers Clés
- `lib/constants.dart` - Toutes les constantes de design
- `lib/theme/theme_provider.dart` - Gestion des thèmes
- `lib/components/glass_components.dart` - Composants glass
- `lib/core/services/api_service.dart` - Service API de base

---

## 🎯 Checklist pour Nouvelles Features

Lors de l'ajout d'une nouvelle feature, suivez cette checklist :

### 1. Structure
- [ ] Créer le dossier dans `features/` ou `screens/`
- [ ] Créer les sous-dossiers `screens/`, `widgets/` si nécessaire
- [ ] Créer le modèle dans `core/models/`
- [ ] Créer le service dans `core/services/`
- [ ] Créer le provider dans `providers/` ou `shared/providers/`

### 2. Design
- [ ] Utiliser les couleurs de `AppColors`
- [ ] Utiliser les styles de `AppTextStyles`
- [ ] Utiliser les espacements de `AppSpacing`
- [ ] Utiliser les rayons de `AppRadius`
- [ ] Utiliser les composants glass (`GlassContainer`, `PremiumCard`, etc.)
- [ ] Ajouter des animations avec `AppAnimations`

### 3. Code
- [ ] Suivre le pattern Provider pour la gestion d'état
- [ ] Suivre le pattern Service pour les appels API
- [ ] Suivre le pattern Modèle pour les données
- [ ] Suivre le pattern Écran pour les UI
- [ ] Ajouter la gestion d'erreurs
- [ ] Ajouter les états de chargement
- [ ] Ajouter les animations d'entrée

### 4. Navigation
- [ ] Ajouter la route si nécessaire
- [ ] Utiliser `PageRouteBuilder` pour les animations
- [ ] Gérer le retour arrière correctement

### 5. Tests
- [ ] Écrire les tests unitaires pour le provider
- [ ] Écrire les tests unitaires pour le service
- [ ] Écrire les tests de widgets si nécessaire

### 6. Documentation
- [ ] Commenter le code complexe
- [ ] Ajouter des docstrings pour les classes publiques
- [ ] Mettre à jour ce document si nécessaire

---

## 🔄 Mise à Jour de ce Document

Ce document doit être mis à jour à chaque fois que :
- Un nouveau pattern est introduit
- Une convention change
- Une nouvelle feature majeure est ajoutée
- Un composant réutilisable est créé

**Dernière mise à jour** : [Date actuelle]
**Version** : 1.0.0
**Auteur** : Équipe Alpha Pressing

---

## 📞 Support

Pour toute question sur les patterns ou le design system :
1. Consultez d'abord ce document
2. Regardez les exemples de code dans l'application
3. Consultez les fichiers de référence backend
4. Contactez l'équipe de développement

---

**Note** : Ce document est un guide vivant. N'hésitez pas à le compléter et à l'améliorer au fur et à mesure de l'évolution du projet.
