# 🚀 Prochaines Implémentations - Alpha Client App

## 📋 Vue d'Ensemble

Ce document liste les prochaines fonctionnalités à implémenter pour compléter l'application Alpha Client, en suivant l'ordre de priorité et en respectant le design pattern moderne glassmorphism déjà en place.

---

## ✅ Déjà Complété

- [x] Dashboard avec données réelles + cache
- [x] Système d'affichage des services dans les commandes
- [x] Points de fidélité réels
- [x] Navigation complète du dashboard
- [x] OrderCard réutilisable
- [x] Gestion des états (loading, empty, success)

---

## 🎯 Priorité 1 - Fonctionnalités Critiques

### 1. Pull-to-Refresh sur le Dashboard
**Objectif** : Permettre à l'utilisateur de rafraîchir manuellement les données

**Implémentation** :
```dart
// Dans home_page.dart
Widget _buildHomeContent() {
  return RefreshIndicator(
    onRefresh: () async {
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
      final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);
      
      await Future.wait([
        ordersProvider.initialize(forceRefresh: true),
        loyaltyProvider.initialize(forceRefresh: true),
        servicesProvider.initialize(forceRefresh: true),
      ]);
    },
    color: AppColors.primary,
    child: SingleChildScrollView(...),
  );
}
```

**Fichiers à Modifier** :
- `lib/screens/home_page.dart`

**Temps Estimé** : 30 minutes

---

### 2. Gestion des Erreurs Réseau
**Objectif** : Afficher des messages d'erreur élégants en cas de problème réseau

**Implémentation** :
```dart
// Créer un widget ErrorState
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 64, color: AppColors.error),
          SizedBox(height: 16),
          Text('Erreur de connexion', style: AppTextStyles.headlineSmall),
          Text(message, style: AppTextStyles.bodyMedium),
          SizedBox(height: 24),
          PremiumButton(
            text: 'Réessayer',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
```

**Fichiers à Créer** :
- `lib/shared/widgets/error_state_widget.dart`

**Fichiers à Modifier** :
- `lib/screens/home_page.dart`
- `lib/providers/orders_provider.dart`
- `lib/providers/loyalty_provider.dart`
- `lib/providers/services_provider.dart`

**Temps Estimé** : 1 heure

---

### 3. Recherche de Commandes
**Objectif** : Permettre à l'utilisateur de rechercher ses commandes

**Implémentation** :
```dart
// Dans orders_screen.dart
class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Commandes'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une commande...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          final filteredOrders = ordersProvider.orders.where((order) {
            return order.shortOrderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   order.items.any((item) => item.articleName.toLowerCase().contains(_searchQuery.toLowerCase()));
          }).toList();
          
          return ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              return OrderCard(order: filteredOrders[index]);
            },
          );
        },
      ),
    );
  }
}
```

**Fichiers à Modifier** :
- `lib/features/orders/screens/orders_screen.dart`

**Temps Estimé** : 1 heure

---

### 4. Filtres de Commandes
**Objectif** : Filtrer les commandes par statut et date

**Implémentation** :
```dart
// Créer un widget OrderFilters
class OrderFilters extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final DateTimeRange? dateRange;
  final Function(OrderStatus?) onStatusChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filtre par statut
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text('Tous'),
                selected: selectedStatus == null,
                onSelected: (_) => onStatusChanged(null),
              ),
              FilterChip(
                label: Text('En cours'),
                selected: selectedStatus == OrderStatus.processing,
                onSelected: (_) => onStatusChanged(OrderStatus.processing),
              ),
              FilterChip(
                label: Text('Prêt'),
                selected: selectedStatus == OrderStatus.ready,
                onSelected: (_) => onStatusChanged(OrderStatus.ready),
              ),
              FilterChip(
                label: Text('Livré'),
                selected: selectedStatus == OrderStatus.delivered,
                onSelected: (_) => onStatusChanged(OrderStatus.delivered),
              ),
            ],
          ),
          
          // Filtre par date
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text(dateRange == null 
                ? 'Toutes les dates' 
                : '${dateRange!.start.day}/${dateRange!.start.month} - ${dateRange!.end.day}/${dateRange!.end.month}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDateRangeChanged(picked);
              }
            },
          ),
        ],
      ),
    );
  }
}
```

**Fichiers à Créer** :
- `lib/features/orders/widgets/order_filters.dart`

**Fichiers à Modifier** :
- `lib/features/orders/screens/orders_screen.dart`

**Temps Estimé** : 2 heures

---

## 🎯 Priorité 2 - Améliorations UX

### 5. Animations de Transition
**Objectif** : Améliorer les transitions entre les écrans

**Implémentation** :
```dart
// Créer un helper pour les transitions
class AppTransitions {
  static Route<T> slideTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: AppAnimations.medium,
    );
  }
  
  static Route<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: AppAnimations.fast,
    );
  }
}
```

**Fichiers à Créer** :
- `lib/core/utils/app_transitions.dart`

**Fichiers à Modifier** :
- Tous les fichiers avec navigation

**Temps Estimé** : 1 heure

---

### 6. Skeleton Loading Amélioré
**Objectif** : Améliorer les skeletons avec effet shimmer

**Implémentation** :
```dart
// Dans glass_components.dart
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                AppColors.surfaceVariant(context),
                AppColors.surface(context),
                AppColors.surfaceVariant(context),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Fichiers à Modifier** :
- `lib/components/glass_components.dart`
- Remplacer tous les `SkeletonLoader` par `ShimmerLoader`

**Temps Estimé** : 1 heure

---

### 7. Notifications Push
**Objectif** : Implémenter les notifications push pour les mises à jour de commandes

**Implémentation** :
```dart
// Créer un service de notifications push
class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  static Future<void> initialize() async {
    // Demander la permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Obtenir le token
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      
      // Envoyer le token au backend
      await ApiService.updateFCMToken(token);
      
      // Écouter les messages
      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }
  
  static void _handleMessage(RemoteMessage message) {
    // Afficher une notification locale
    debugPrint('Message reçu: ${message.notification?.title}');
  }
  
  static void _handleMessageOpenedApp(RemoteMessage message) {
    // Naviguer vers l'écran approprié
    debugPrint('Notification ouverte: ${message.data}');
  }
}
```

**Packages Requis** :
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0
```

**Fichiers à Créer** :
- `lib/core/services/push_notification_service.dart`

**Fichiers à Modifier** :
- `lib/main.dart` (initialiser le service)
- Backend : Ajouter endpoint pour enregistrer les tokens FCM

**Temps Estimé** : 3 heures

---

## 🎯 Priorité 3 - Fonctionnalités Avancées

### 8. Système de Favoris
**Objectif** : Permettre aux utilisateurs de marquer des articles/services en favoris

**Implémentation** :
```dart
// Créer un provider pour les favoris
class FavoritesProvider extends ChangeNotifier {
  final List<String> _favoriteArticleIds = [];
  final List<String> _favoriteServiceIds = [];
  
  List<String> get favoriteArticleIds => _favoriteArticleIds;
  List<String> get favoriteServiceIds => _favoriteServiceIds;
  
  Future<void> toggleArticleFavorite(String articleId) async {
    if (_favoriteArticleIds.contains(articleId)) {
      _favoriteArticleIds.remove(articleId);
    } else {
      _favoriteArticleIds.add(articleId);
    }
    
    await _saveFavorites();
    notifyListeners();
  }
  
  Future<void> toggleServiceFavorite(String serviceId) async {
    if (_favoriteServiceIds.contains(serviceId)) {
      _favoriteServiceIds.remove(serviceId);
    } else {
      _favoriteServiceIds.add(serviceId);
    }
    
    await _saveFavorites();
    notifyListeners();
  }
  
  Future<void> _saveFavorites() async {
    await StorageService.saveString(
      StorageKeys.favoriteArticles,
      jsonEncode(_favoriteArticleIds),
    );
    await StorageService.saveString(
      StorageKeys.favoriteServices,
      jsonEncode(_favoriteServiceIds),
    );
  }
  
  Future<void> loadFavorites() async {
    final articlesJson = await StorageService.getString(StorageKeys.favoriteArticles);
    final servicesJson = await StorageService.getString(StorageKeys.favoriteServices);
    
    if (articlesJson != null) {
      _favoriteArticleIds.addAll(List<String>.from(jsonDecode(articlesJson)));
    }
    if (servicesJson != null) {
      _favoriteServiceIds.addAll(List<String>.from(jsonDecode(servicesJson)));
    }
    
    notifyListeners();
  }
}
```

**Fichiers à Créer** :
- `lib/providers/favorites_provider.dart`

**Fichiers à Modifier** :
- `lib/main.dart` (ajouter le provider)
- `lib/features/services/widgets/article_card.dart` (ajouter bouton favori)
- `lib/features/services/widgets/service_card.dart` (ajouter bouton favori)

**Temps Estimé** : 2 heures

---

### 9. Statistiques Utilisateur
**Objectif** : Afficher des statistiques sur les commandes de l'utilisateur

**Implémentation** :
```dart
// Créer un écran de statistiques
class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes Statistiques')),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          final stats = _calculateStats(ordersProvider.orders);
          
          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                _buildStatCard(
                  'Total Commandes',
                  '${stats.totalOrders}',
                  Icons.shopping_bag,
                  AppColors.primary,
                ),
                _buildStatCard(
                  'Montant Total',
                  '${stats.totalAmount.toInt().toFormattedString()} FCFA',
                  Icons.attach_money,
                  AppColors.success,
                ),
                _buildStatCard(
                  'Commandes en Cours',
                  '${stats.activeOrders}',
                  Icons.pending,
                  AppColors.warning,
                ),
                _buildStatCard(
                  'Articles Traités',
                  '${stats.totalItems}',
                  Icons.checkroom,
                  AppColors.info,
                ),
                
                SizedBox(height: 32),
                
                // Graphique des commandes par mois
                _buildMonthlyChart(stats.monthlyOrders),
                
                SizedBox(height: 32),
                
                // Articles les plus commandés
                _buildTopArticles(stats.topArticles),
              ],
            ),
          );
        },
      ),
    );
  }
  
  OrderStats _calculateStats(List<Order> orders) {
    // Calculer les statistiques
    return OrderStats(
      totalOrders: orders.length,
      totalAmount: orders.fold(0.0, (sum, order) => sum + order.totalAmount),
      activeOrders: orders.where((o) => o.status != OrderStatus.delivered).length,
      totalItems: orders.fold(0, (sum, order) => sum + order.items.length),
      monthlyOrders: _groupByMonth(orders),
      topArticles: _getTopArticles(orders),
    );
  }
}
```

**Packages Requis** :
```yaml
dependencies:
  fl_chart: ^0.66.0  # Pour les graphiques
```

**Fichiers à Créer** :
- `lib/screens/statistics/statistics_screen.dart`
- `lib/core/models/order_stats.dart`

**Temps Estimé** : 4 heures

---

### 10. Section Promotions Dynamique
**Objectif** : Remplacer la section promotions statique par des données du backend

**Backend** :
```typescript
// Créer un endpoint pour les promotions
router.get('/promotions/active', async (req, res) => {
  const promotions = await prisma.promotions.findMany({
    where: {
      isActive: true,
      startDate: { lte: new Date() },
      endDate: { gte: new Date() },
    },
    orderBy: { priority: 'desc' },
  });
  
  res.json(promotions);
});
```

**Frontend** :
```dart
// Créer un provider pour les promotions
class PromotionsProvider extends ChangeNotifier {
  List<Promotion> _promotions = [];
  bool _isLoading = false;
  
  List<Promotion> get promotions => _promotions;
  bool get isLoading => _isLoading;
  
  Future<void> loadPromotions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.get('/promotions/active');
      _promotions = (response.data as List)
          .map((json) => Promotion.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur chargement promotions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Dans home_page.dart
Widget _buildPromoSection() {
  return Consumer<PromotionsProvider>(
    builder: (context, promotionsProvider, child) {
      if (promotionsProvider.isLoading) {
        return _buildPromoSkeleton();
      }
      
      if (promotionsProvider.promotions.isEmpty) {
        return SizedBox.shrink();
      }
      
      return Column(
        children: promotionsProvider.promotions.map((promo) {
          return _buildPromoCard(promo);
        }).toList(),
      );
    },
  );
}
```

**Fichiers à Créer** :
- `lib/providers/promotions_provider.dart`
- `lib/core/models/promotion.dart`
- Backend : `backend/src/controllers/promotion.controller.ts`
- Backend : `backend/src/routes/promotion.routes.ts`

**Temps Estimé** : 3 heures

---

## 📊 Récapitulatif des Priorités

| Priorité | Fonctionnalité | Temps Estimé | Difficulté |
|----------|----------------|--------------|------------|
| 🔴 P1 | Pull-to-Refresh | 30 min | Facile |
| 🔴 P1 | Gestion Erreurs | 1h | Moyen |
| 🔴 P1 | Recherche Commandes | 1h | Facile |
| 🔴 P1 | Filtres Commandes | 2h | Moyen |
| 🟡 P2 | Animations Transition | 1h | Facile |
| 🟡 P2 | Shimmer Loading | 1h | Facile |
| 🟡 P2 | Notifications Push | 3h | Difficile |
| 🟢 P3 | Système Favoris | 2h | Moyen |
| 🟢 P3 | Statistiques | 4h | Difficile |
| 🟢 P3 | Promotions Dynamiques | 3h | Moyen |

**Total Estimé** : ~18.5 heures

---

## 🛠️ Outils et Packages Recommandés

### Packages Flutter
```yaml
dependencies:
  # Déjà installés
  flutter:
    sdk: flutter
  provider: ^6.1.1
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  
  # À ajouter
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0
  fl_chart: ^0.66.0
  shimmer: ^3.0.0
  pull_to_refresh: ^2.0.0
```

### Outils de Développement
- **Flutter DevTools** : Pour le debugging
- **Postman** : Pour tester les endpoints backend
- **Firebase Console** : Pour gérer les notifications push

---

## 📝 Notes Importantes

### Design Pattern
- Respecter le pattern Provider déjà en place
- Utiliser le design glassmorphism pour tous les nouveaux widgets
- Suivre les conventions de nommage existantes

### Performance
- Toujours implémenter un système de cache
- Utiliser `const` constructors quand possible
- Optimiser les images (compression, lazy loading)

### Tests
- Tester chaque fonctionnalité sur iOS et Android
- Tester en mode clair et sombre
- Tester avec et sans connexion internet

### Backend
- Toutes les modifications backend doivent être testées avec Postman
- Documenter les nouveaux endpoints dans `backend/docs/`
- Vérifier la compatibilité avec les autres apps (admin, livreur, affilié)

---

## 🎯 Ordre d'Implémentation Recommandé

1. **Semaine 1** : Priorité 1 (Pull-to-Refresh, Erreurs, Recherche, Filtres)
2. **Semaine 2** : Priorité 2 (Animations, Shimmer, Notifications)
3. **Semaine 3** : Priorité 3 (Favoris, Statistiques, Promotions)

---

## 📞 Support

Pour toute question :
1. Consulter la documentation existante
2. Vérifier les fichiers `DASHBOARD_*.md`
3. Tester avec le backend en local
4. Vérifier les logs de débogage

**Bonne chance pour les prochaines implémentations ! 🚀**
