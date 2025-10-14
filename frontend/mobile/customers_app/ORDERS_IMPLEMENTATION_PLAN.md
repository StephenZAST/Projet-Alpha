# 📦 Plan d'Implémentation - Page Commandes Client

## 🎯 Objectif
Créer une page de gestion des commandes moderne, fluide et synchronisée avec le backend, incluant :
- Historique des commandes (normales + draft)
- Détails de commande
- Suivi en temps réel
- Commandes récentes sur le dashboard
- Système de cache optimisé

---

## 📊 Analyse Backend

### Endpoints Disponibles

#### **Commandes Normales**
- `GET /api/orders/my-orders` - Liste des commandes de l'utilisateur
- `GET /api/orders/:orderId` - Détails d'une commande
- `GET /api/orders/by-id/:orderId` - Recherche par ID
- `GET /api/orders/recent?limit=5` - Commandes récentes
- `POST /api/orders` - Créer une commande normale
- `PATCH /api/orders/:orderId` - Modifier une commande
- `PATCH /api/orders/:orderId/status` - Changer le statut

#### **Commandes Flash (Draft)**
- `POST /api/orders/flash` - Créer une commande draft
- `GET /api/orders/flash/draft` - Liste des drafts (ADMIN)
- `PATCH /api/orders/flash/:orderId/complete` - Compléter un draft (ADMIN)

### Statuts de Commande (Workflow)
```
DRAFT → PENDING → COLLECTING → COLLECTED → PROCESSING → READY → DELIVERING → DELIVERED
                                                                              ↓
                                                                          CANCELLED
```

### Structure de Données

**Order:**
- Informations de base (id, userId, shortId, dates)
- Statuts (status, paymentStatus)
- Montants (subtotal, discount, deliveryFee, tax, total)
- Adresses (pickup, delivery)
- Paiement (method, isPaid)
- Récurrence (isRecurring, recurrenceType, nextDate)
- Items (liste d'OrderItem)

**OrderItem:**
- Article (articleId, articleName)
- Service (serviceId, serviceName, serviceTypeName)
- Quantité, prix unitaire, premium, poids

---

## 🎨 Design Pattern & Architecture

### 1. **Provider Pattern avec Cache**
```dart
OrdersProvider extends ChangeNotifier {
  // Cache Management (5 min)
  DateTime? _lastFetch;
  bool _isInitialized = false;
  
  // Data
  List<Order> _orders = [];
  Order? _selectedOrder;
  
  // Filters
  OrderStatus? _filterStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
}
```

### 2. **Service Layer**
```dart
OrderService {
  // GET
  Future<List<Order>> getMyOrders({filters, pagination})
  Future<Order> getOrderById(String id)
  Future<List<Order>> getRecentOrders(int limit)
  
  // POST
  Future<Order> createOrder(CreateOrderRequest)
  Future<Order> createFlashOrder(CreateFlashOrderRequest)
  
  // PATCH
  Future<Order> updateOrder(String id, UpdateOrderRequest)
  Future<Order> cancelOrder(String id)
}
```

### 3. **UI Components**

#### **OrdersScreen** (Page principale)
- AppBar avec titre + filtres
- Tabs: Toutes | En cours | Livrées | Annulées
- Liste des commandes (ListView.builder)
- Pull-to-refresh
- Pagination infinie
- Floating Action Button (Nouvelle commande)

#### **OrderCard** (Widget réutilisable)
- Header: ID court + Statut badge
- Body: Articles (max 3 visibles) + "et X autres"
- Footer: Total + Date + Bouton "Détails"
- Indicateur de paiement
- Icône de récurrence si applicable

#### **OrderDetailsScreen** (Détails complets)
- Header: ID + Statut + Timeline
- Section Informations
- Section Articles (liste complète)
- Section Paiement
- Section Adresses
- Section Actions (Annuler, Renouveler, Contacter)

#### **OrderTimeline** (Suivi visuel)
- Stepper vertical avec étapes
- Dates pour chaque étape complétée
- Estimation pour étapes futures
- Animations de progression

---

## 🔄 Workflow Utilisateur

### Scénario 1: Commande Normale
1. User clique "Nouvelle commande"
2. Sélection service type
3. Sélection articles + services
4. Choix adresse
5. Choix paiement
6. Confirmation
7. Création via `POST /api/orders`
8. Redirection vers détails

### Scénario 2: Commande Flash (Draft)
1. User clique "Commande rapide"
2. Confirmation adresse par défaut
3. Création via `POST /api/orders/flash`
4. Status = DRAFT
5. Admin complète la commande
6. User reçoit notification
7. Status → PENDING

### Scénario 3: Consultation Historique
1. User ouvre page Commandes
2. Provider charge depuis cache (si valide)
3. Sinon, appel `GET /api/orders/my-orders`
4. Affichage avec filtres
5. Pagination au scroll
6. Pull-to-refresh pour actualiser

---

## 📱 Intégration Dashboard

### Section "Commandes Récentes"
```dart
RecentOrdersWidget {
  - Appel: GET /api/orders/recent?limit=5
  - Cache: 2 minutes
  - Affichage: 5 dernières commandes
  - Bouton "Voir tout" → OrdersScreen
  - Mini cards avec statut + total
}
```

---

## 🚀 Plan d'Implémentation (Étapes)

### Phase 1: Service & Provider ✅
1. Créer `OrderService` avec tous les endpoints
2. Créer `OrdersProvider` avec cache (5 min)
3. Méthodes: initialize, loadOrders, getOrderById, refresh
4. Filtres: status, dates, pagination

### Phase 2: UI - Liste des Commandes
1. Créer `OrdersScreen` avec tabs
2. Créer `OrderCard` widget
3. Implémenter filtres
4. Implémenter pagination
5. Pull-to-refresh

### Phase 3: UI - Détails de Commande
1. Créer `OrderDetailsScreen`
2. Créer `OrderTimeline` widget
3. Sections: Info, Articles, Paiement, Adresses
4. Actions: Annuler, Renouveler

### Phase 4: Dashboard Integration
1. Créer `RecentOrdersWidget`
2. Intégrer dans `HomePage`
3. Navigation vers `OrdersScreen`

### Phase 5: Commande Flash
1. Créer `FlashOrderDialog`
2. Intégration dans `OrdersScreen`
3. Gestion du workflow draft

---

## 🎨 Design System

### Couleurs par Statut
- DRAFT: Gris clair
- PENDING: Orange (warning)
- COLLECTING: Bleu (info)
- COLLECTED: Bleu foncé (primary)
- PROCESSING: Violet (accent)
- READY: Vert clair (secondary)
- DELIVERING: Bleu (info)
- DELIVERED: Vert (success)
- CANCELLED: Rouge (error)

### Typographie
- Titre: 18px, Bold
- ID: 14px, Medium, Monospace
- Statut: 12px, Bold, Uppercase
- Prix: 16px, Bold
- Dates: 12px, Regular

### Spacing
- Card padding: 16px
- Card margin: 12px
- Section spacing: 24px
- Item spacing: 8px

---

## 🔧 Optimisations

### Cache Strategy
- Orders list: 5 minutes
- Order details: 3 minutes
- Recent orders: 2 minutes
- Invalidation après création/modification

### Performance
- Pagination: 20 items par page
- Lazy loading des images
- Skeleton loaders
- Debounce sur recherche (500ms)

### UX
- Animations de transition
- Feedback visuel immédiat
- Messages d'erreur clairs
- États vides avec illustrations

---

## 📋 Checklist

### Backend (Déjà fait ✅)
- [x] Endpoints commandes normales
- [x] Endpoints commandes flash
- [x] Filtres et pagination
- [x] Statuts et workflow
- [x] Modèles de données

### Frontend (À faire)
- [ ] OrderService complet
- [ ] OrdersProvider avec cache
- [ ] OrdersScreen (liste)
- [ ] OrderCard widget
- [ ] OrderDetailsScreen
- [ ] OrderTimeline widget
- [ ] RecentOrdersWidget
- [ ] FlashOrderDialog
- [ ] Tests et optimisations

---

## 🎯 Prochaines Étapes

1. **Maintenant**: Créer OrderService
2. **Ensuite**: Créer OrdersProvider avec cache
3. **Puis**: UI OrdersScreen
4. **Enfin**: Intégration Dashboard

**Prêt à commencer l'implémentation ! 🚀**
