# 📊 Analyse Complète - Création de Commande

## 🎯 Objectif
Remplacer les données mockées par les vraies APIs pour rendre la création de commande complète 100% fonctionnelle.

---

## 🔍 État Actuel (Données Mockées)

### Frontend - `order_draft_provider.dart`

#### ❌ Données Mockées Identifiées:

1. **Types de Service** (`_loadServiceTypes()`)
   ```dart
   // MOCK - Ligne ~90
   _serviceTypes = [
     ServiceType(id: 'standard', name: 'Standard', ...),
     ServiceType(id: 'express', name: 'Express 24h', ...),
     ServiceType(id: 'weight', name: 'Au poids', ...),
   ];
   ```

2. **Services** (`_loadServicesByType()`)
   ```dart
   // MOCK - Ligne ~120
   _services = [
     Service(id: 'nettoyage-sec', name: 'Nettoyage à sec', ...),
     Service(id: 'repassage', name: 'Repassage', ...),
     Service(id: 'retouches', name: 'Retouches', ...),
   ];
   ```

3. **Articles** (`_loadArticles()`)
   ```dart
   // MOCK - Ligne ~150
   _articles = [
     Article(id: 'chemise', name: 'Chemise', ...),
     Article(id: 'pantalon', name: 'Pantalon', ...),
     Article(id: 'costume', name: 'Costume', ...),
     Article(id: 'robe', name: 'Robe', ...),
   ];
   ```

4. **Prix des Articles** (`_getArticlePrice()`)
   ```dart
   // MOCK - Ligne ~280
   final basePrices = {
     'chemise': 8.0,
     'pantalon': 10.0,
     'costume': 25.0,
     'robe': 15.0,
   };
   ```

5. **Soumission de Commande** (`submitOrder()`)
   ```dart
   // MOCK - Ligne ~340
   await Future.delayed(const Duration(seconds: 2)); // Simulation
   ```

#### ✅ Données Réelles Déjà Implémentées:

1. **Adresses** (`_loadAddresses()`)
   ```dart
   // ✅ RÉEL - Utilise AddressService
   final addressList = await AddressService().getAllAddresses();
   ```

---

## 🏗️ Architecture Backend (APIs Disponibles)

### 1. **Types de Service**
**Endpoint:** `GET /api/service-types`
- **Fichier:** `backend/src/routes/serviceType.routes.ts`
- **Contrôleur:** `backend/src/controllers/serviceType.controller.ts`
- **Modèle:** `service_types` table

**Réponse attendue:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Standard",
      "description": "Service standard",
      "pricingType": "FIXED",
      "requiresWeight": false,
      "supportsPremium": true,
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 2. **Services**
**Endpoint:** `GET /api/services`
- **Fichier:** `backend/src/routes/service.routes.ts`
- **Contrôleur:** `backend/src/controllers/service.controller.ts`
- **Modèle:** `services` table

**Query params:**
- `serviceTypeId` (optionnel) - Filtrer par type de service
- `isActive=true` - Seulement les services actifs

**Réponse attendue:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Nettoyage à sec",
      "description": "Nettoyage professionnel",
      "serviceTypeId": "uuid",
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 3. **Articles**
**Endpoint:** `GET /api/articles`
- **Fichier:** `backend/src/routes/article.routes.ts`
- **Contrôleur:** `backend/src/controllers/article.controller.ts`
- **Modèle:** `articles` table

**Query params:**
- `isActive=true` - Seulement les articles actifs
- `categoryId` (optionnel) - Filtrer par catégorie

**Réponse attendue:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Chemise",
      "description": "Chemise homme/femme",
      "categoryId": "uuid",
      "basePrice": 8.0,
      "premiumPrice": 12.0,
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 4. **Prix des Couples Article-Service**
**Endpoint:** `GET /api/article-services/prices`
- **Fichier:** `backend/src/routes/articleService.routes.ts`
- **Contrôleur:** `backend/src/controllers/articleServicePrice.controller.ts`
- **Modèle:** `article_service_prices` table

**⚠️ IMPORTANT:** Filtrer sur le **TRIO** `(article_id, service_type_id, service_id)`

**Query params:**
- `articleId` - ID de l'article
- `serviceTypeId` - ID du type de service
- `serviceId` - ID du service

**Réponse attendue:**
```json
{
  "data": [
    {
      "id": "uuid",
      "article_id": "uuid",
      "service_type_id": "uuid",
      "service_id": "uuid",
      "base_price": 8.0,
      "premium_price": 12.0,
      "is_available": true,
      "price_per_kg": null
    }
  ]
}
```

### 5. **Création de Commande**
**Endpoint:** `POST /api/orders`
- **Fichier:** `backend/src/routes/order.routes.ts`
- **Contrôleur:** `backend/src/controllers/order.controller/orderCreate.controller.ts`

**Payload attendu:**
```json
{
  "serviceId": "uuid",
  "serviceTypeId": "uuid",
  "addressId": "uuid",
  "items": [
    {
      "articleId": "uuid",
      "quantity": 2,
      "isPremium": false
    }
  ],
  "paymentMethod": "CASH",
  "collectionDate": "2024-01-15T10:00:00Z",
  "deliveryDate": "2024-01-17T10:00:00Z",
  "note": "Instructions spéciales",
  "affiliateCode": "CODE123",
  "isRecurring": false,
  "recurrenceType": null
}
```

**Réponse:**
```json
{
  "data": {
    "order": {
      "id": "uuid",
      "userId": "uuid",
      "status": "PENDING",
      "totalAmount": 50.0,
      "items": [...],
      "note": "Instructions spéciales"
    },
    "pricing": {
      "subtotal": 50.0,
      "discount": 0,
      "total": 50.0
    },
    "rewards": {
      "pointsEarned": 50,
      "currentBalance": 150
    }
  }
}
```

### 6. **Calcul du Total**
**Endpoint:** `POST /api/orders/calculate-total`
- **Contrôleur:** `OrderCreateController.calculateTotal()`

**Payload:**
```json
{
  "items": [
    {
      "articleId": "uuid",
      "serviceId": "uuid",
      "serviceTypeId": "uuid",
      "quantity": 2,
      "unitPrice": 8.0,
      "isPremium": false
    }
  ],
  "appliedOfferIds": ["uuid"]
}
```

**Réponse:**
```json
{
  "data": {
    "subtotal": 16.0,
    "discount": 2.0,
    "total": 14.0
  }
}
```

---

## 📝 Plan d'Implémentation

### Phase 1: Créer les Services Frontend ✅

#### 1.1 Service Types Service
**Fichier:** `frontend/mobile/customers_app/lib/core/services/service_type_service.dart`

```dart
class ServiceTypeService {
  final ApiService _api = ApiService();

  Future<List<ServiceType>> getAllServiceTypes() async {
    final response = await _api.get('/service-types', queryParameters: {'isActive': 'true'});
    final data = response['data'] as List;
    return data.map((json) => ServiceType.fromJson(json)).toList();
  }
}
```

#### 1.2 Service Service (Services)
**Fichier:** `frontend/mobile/customers_app/lib/core/services/service_service.dart`

```dart
class ServiceService {
  final ApiService _api = ApiService();

  Future<List<Service>> getServicesByType(String serviceTypeId) async {
    final response = await _api.get('/services', queryParameters: {
      'serviceTypeId': serviceTypeId,
      'isActive': 'true'
    });
    final data = response['data'] as List;
    return data.map((json) => Service.fromJson(json)).toList();
  }
}
```

#### 1.3 Article Service
**Fichier:** `frontend/mobile/customers_app/lib/core/services/article_service.dart`

```dart
class ArticleService {
  final ApiService _api = ApiService();

  Future<List<Article>> getAllArticles() async {
    final response = await _api.get('/articles', queryParameters: {'isActive': 'true'});
    final data = response['data'] as List;
    return data.map((json) => Article.fromJson(json)).toList();
  }
}
```

#### 1.4 Pricing Service
**Fichier:** `frontend/mobile/customers_app/lib/core/services/pricing_service.dart`

```dart
class PricingService {
  final ApiService _api = ApiService();

  /// Récupérer le prix d'un couple article-service
  Future<ArticleServicePrice?> getPrice({
    required String articleId,
    required String serviceTypeId,
    required String serviceId,
  }) async {
    final response = await _api.get('/article-services/prices', queryParameters: {
      'articleId': articleId,
      'serviceTypeId': serviceTypeId,
      'serviceId': serviceId,
    });
    
    final data = response['data'] as List;
    if (data.isEmpty) return null;
    
    return ArticleServicePrice.fromJson(data.first);
  }

  /// Calculer le total d'une commande
  Future<OrderPricing> calculateTotal({
    required List<OrderItemRequest> items,
    List<String>? appliedOfferIds,
  }) async {
    final response = await _api.post('/orders/calculate-total', data: {
      'items': items.map((item) => item.toJson()).toList(),
      if (appliedOfferIds != null) 'appliedOfferIds': appliedOfferIds,
    });
    
    return OrderPricing.fromJson(response['data']);
  }
}
```

### Phase 2: Mettre à Jour le Provider ✅

**Fichier:** `frontend/mobile/customers_app/lib/shared/providers/order_draft_provider.dart`

**Modifications:**

1. **Remplacer `_loadServiceTypes()`**
```dart
Future<void> _loadServiceTypes() async {
  try {
    _serviceTypes = await ServiceTypeService().getAllServiceTypes();
    notifyListeners();
  } catch (e) {
    throw Exception('Erreur lors du chargement des types de service: ${e.toString()}');
  }
}
```

2. **Remplacer `_loadServicesByType()`**
```dart
Future<void> _loadServicesByType(String serviceTypeId) async {
  try {
    _services = await ServiceService().getServicesByType(serviceTypeId);
    notifyListeners();
  } catch (e) {
    throw Exception('Erreur lors du chargement des services: ${e.toString()}');
  }
}
```

3. **Remplacer `_loadArticles()`**
```dart
Future<void> _loadArticles() async {
  try {
    _articles = await ArticleService().getAllArticles();
    notifyListeners();
  } catch (e) {
    throw Exception('Erreur lors du chargement des articles: ${e.toString()}');
  }
}
```

4. **Remplacer `_getArticlePrice()`**
```dart
Future<double> _getArticlePrice(String articleId, bool isPremium) async {
  if (_selectedService == null || _selectedServiceType == null) {
    return 0.0;
  }

  try {
    final price = await PricingService().getPrice(
      articleId: articleId,
      serviceTypeId: _selectedServiceType!.id,
      serviceId: _selectedService!.id,
    );

    if (price == null) return 0.0;

    return isPremium ? price.premiumPrice : price.basePrice;
  } catch (e) {
    debugPrint('Erreur récupération prix: $e');
    return 0.0;
  }
}
```

5. **Remplacer `submitOrder()`**
```dart
Future<bool> submitOrder(BuildContext context) async {
  if (!_orderDraft.isValid) {
    _setError('Commande invalide');
    return false;
  }

  _setSubmitting(true);

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Créer le payload pour l'API
    final request = CreateOrderRequest(
      serviceTypeId: _selectedServiceType!.id,
      serviceId: _selectedService!.id,
      addressId: _selectedAddress!.id,
      items: _orderDraft.items.map((item) => OrderItemRequest(
        articleId: item.articleId,
        serviceId: _selectedService!.id,
        serviceTypeId: _selectedServiceType!.id,
        quantity: item.quantity,
        isPremium: item.isPremium,
        weight: item.weight,
      )).toList(),
      note: _orderDraft.notes,
      paymentMethod: _orderDraft.paymentMethod ?? 'CASH',
      collectionDate: _orderDraft.collectionDate,
      deliveryDate: _orderDraft.deliveryDate,
      affiliateCode: _orderDraft.affiliateCode,
      isRecurring: _orderDraft.isRecurring,
      recurrenceType: _orderDraft.recurrenceType,
    );

    // Appeler l'API
    final order = await OrderService().createOrder(request);

    // Réinitialiser le draft après succès
    reset();

    NotificationUtils.showSuccess(
      context,
      'Commande créée avec succès ! Référence: ${order.shortOrderId}',
    );

    return true;
  } catch (e) {
    _setError('Erreur lors de la création: ${e.toString()}');
    NotificationUtils.showError(
      context,
      'Erreur lors de la création: ${e.toString()}',
    );
    return false;
  } finally {
    _setSubmitting(false);
  }
}
```

### Phase 3: Créer les Modèles Manquants ✅

#### 3.1 ArticleServicePrice Model
**Fichier:** `frontend/mobile/customers_app/lib/core/models/article_service_price.dart`

```dart
class ArticleServicePrice {
  final String id;
  final String articleId;
  final String serviceTypeId;
  final String serviceId;
  final double basePrice;
  final double premiumPrice;
  final bool isAvailable;
  final double? pricePerKg;

  ArticleServicePrice({
    required this.id,
    required this.articleId,
    required this.serviceTypeId,
    required this.serviceId,
    required this.basePrice,
    required this.premiumPrice,
    required this.isAvailable,
    this.pricePerKg,
  });

  factory ArticleServicePrice.fromJson(Map<String, dynamic> json) {
    return ArticleServicePrice(
      id: json['id'],
      articleId: json['article_id'],
      serviceTypeId: json['service_type_id'],
      serviceId: json['service_id'],
      basePrice: (json['base_price'] ?? 0).toDouble(),
      premiumPrice: (json['premium_price'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      pricePerKg: json['price_per_kg'] != null 
          ? (json['price_per_kg'] as num).toDouble() 
          : null,
    );
  }
}
```

#### 3.2 OrderPricing Model
**Fichier:** `frontend/mobile/customers_app/lib/core/models/order_pricing.dart`

```dart
class OrderPricing {
  final double subtotal;
  final double discount;
  final double total;

  OrderPricing({
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory OrderPricing.fromJson(Map<String, dynamic> json) {
    return OrderPricing(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}
```

---

## 🎯 Ordre d'Implémentation Recommandé

1. ✅ **Créer les modèles** (`ArticleServicePrice`, `OrderPricing`)
2. ✅ **Créer les services** (`ServiceTypeService`, `ServiceService`, `ArticleService`, `PricingService`)
3. ✅ **Mettre à jour le provider** (remplacer les méthodes mockées)
4. ✅ **Tester chaque étape** du workflow
5. ✅ **Gérer les erreurs** et les cas limites

---

## ⚠️ Points d'Attention

### 1. **Trio Article-Service-ServiceType**
Le prix DOIT être récupéré avec les 3 IDs:
```dart
final price = await PricingService().getPrice(
  articleId: articleId,
  serviceTypeId: serviceTypeId,  // ⚠️ OBLIGATOIRE
  serviceId: serviceId,           // ⚠️ OBLIGATOIRE
);
```

### 2. **Gestion Asynchrone**
Les prix sont maintenant récupérés de manière asynchrone. Il faut:
- Afficher un loader pendant le chargement
- Gérer les erreurs réseau
- Mettre en cache les prix récupérés

### 3. **Validation**
Avant de soumettre la commande, vérifier:
- ✅ Adresse sélectionnée
- ✅ Service sélectionné
- ✅ ServiceType sélectionné
- ✅ Au moins 1 article
- ✅ Tous les prix sont disponibles

### 4. **Performance**
- Charger les types de service au démarrage
- Charger les services uniquement quand un type est sélectionné
- Charger les articles uniquement quand un service est sélectionné
- Mettre en cache les prix récupérés

---

## 🧪 Tests à Effectuer

1. ✅ Chargement des types de service
2. ✅ Sélection d'un type de service → Chargement des services
3. ✅ Sélection d'un service → Chargement des articles
4. ✅ Ajout d'un article → Récupération du prix
5. ✅ Calcul du total avec plusieurs articles
6. ✅ Création de la commande complète
7. ✅ Gestion des erreurs réseau
8. ✅ Gestion des cas où aucun prix n'est trouvé

---

## 📚 Références

- **Backend Docs:** `backend/docs/REFERENCE_ARTICLE_SERVICE.md`
- **Backend Routes:** `backend/src/routes/order.routes.ts`
- **Backend Controller:** `backend/src/controllers/order.controller/orderCreate.controller.ts`
- **Frontend Service:** `frontend/mobile/customers_app/lib/core/services/order_service.dart`
- **Frontend Provider:** `frontend/mobile/customers_app/lib/shared/providers/order_draft_provider.dart`

---

**Statut:** 📝 Document d'analyse - Prêt pour implémentation
**Prochaine étape:** Créer les services frontend et mettre à jour le provider
