# 📋 Plan d'Implémentation - Page Nos Services

## ✅ Ce qui a été fait

### 1. Analyse du Système de Tarification

J'ai analysé le système de tarification basé sur le **trio (article_id, service_type_id, service_id)** :

- **Article** : Produit (chemise, pantalon, etc.)
- **ServiceType** : Type de prestation (par article, par poids)
- **Service** : Prestation spécifique (nettoyage à sec, repassage, etc.)
- **ArticleServicePrice** : Table centrale de tarification avec `base_price`, `premium_price`, `price_per_kg`

### 2. Vérification des Modèles Existants

✅ **Modèles déjà présents** (pas de duplication) :
- `core/models/article.dart` - Modèle Article
- `core/models/service.dart` - Modèle Service
- `core/models/service_type.dart` - Modèle ServiceType

### 3. Création des Services API

✅ **Nouveaux services créés** :

#### `core/services/article_service.dart`
- `getAllArticles()` - GET /api/articles (PUBLIC)
- `getArticleById(id)` - GET /api/articles/:id (PUBLIC)
- `getArticlesByCategory(categoryId)` - GET /api/articles/category/:categoryId (PUBLIC)
- Modèle `ArticleCategory` inclus

#### `core/services/service_service.dart`
- `getAllServices()` - GET /api/services/all (PUBLIC)
- `getAllServiceTypes()` - GET /api/service-types (AUTHENTIFIÉ)
- `getServiceTypeById(id)` - GET /api/service-types/:id (AUTHENTIFIÉ)

#### `core/services/pricing_service.dart`
- `getAllPrices()` - GET /api/article-services/prices (AUTHENTIFIÉ)
- `getArticlePrices(articleId)` - GET /api/article-services/:articleId/prices (AUTHENTIFIÉ)
- `getCouplesForServiceType(serviceTypeId)` - GET /api/article-services/couples (AUTHENTIFIÉ)
- `calculatePrice()` - Calcul local du prix selon le trio
- Modèles `ArticleServicePrice` et `ArticleServiceCouple` inclus

### 4. Création du Provider

✅ **Provider créé** : `providers/services_provider.dart`

**Fonctionnalités** :
- Chargement de toutes les données (articles, services, types, prix)
- Recherche d'articles et services
- Filtrage par catégorie et type
- Calcul de prix avec support premium et poids
- Gestion d'état (loading, error)
- Statistiques

---

## 🔍 Routes Backend Disponibles

### Routes Publiques (sans authentification)
✅ `GET /api/articles` - Liste des articles
✅ `GET /api/articles/:id` - Détail d'un article
✅ `GET /api/articles/category/:categoryId` - Articles par catégorie
✅ `GET /api/services/all` - Liste des services

### Routes Authentifiées (token requis)
🔐 `GET /api/service-types` - Liste des types de service
🔐 `GET /api/service-types/:id` - Détail d'un type
🔐 `GET /api/article-services/prices` - Tous les prix
🔐 `GET /api/article-services/:articleId/prices` - Prix d'un article
🔐 `GET /api/article-services/couples` - Couples article-service

---

## 🎯 Prochaines Étapes

### Étape 1 : Intégrer le Provider dans l'App

Ajouter le `ServicesProvider` dans `main.dart` :

```dart
MultiProvider(
  providers: [
    // ... providers existants
    ChangeNotifierProvider(create: (_) => ServicesProvider()),
  ],
  child: MyApp(),
)
```

### Étape 2 : Implémenter la Page "Nos Services"

Mettre à jour `features/services/screens/services_screen.dart` avec :

#### Section 1 : Hero avec Présentation
- Titre "Excellence Alpha"
- Description des services premium
- Icône signature

#### Section 2 : Types de Service
- Card "Par Article" (tarification fixe)
- Card "Par Poids" (tarification au kg)
- Affichage des caractéristiques

#### Section 3 : Catalogue des Services
- Liste des services disponibles
- Groupés par type
- Avec descriptions

#### Section 4 : Grille des Articles
- Articles organisés par catégorie
- Avec images (si disponibles)
- Prix de base affichés

#### Section 5 : Tableau de Tarification
- Matrice Article × Service
- Prix standard et premium
- Indication "par poids" si applicable

### Étape 3 : Créer les Widgets Réutilisables

#### `features/services/widgets/service_type_card.dart`
- Affichage d'un type de service
- Icône, nom, description
- Caractéristiques (poids, premium)

#### `features/services/widgets/service_card.dart`
- Affichage d'un service
- Nom, description, type
- Badge du type de tarification

#### `features/services/widgets/article_card.dart`
- Affichage d'un article
- Image, nom, catégorie
- Prix de base (si disponible)

#### `features/services/widgets/pricing_table.dart`
- Tableau de tarification
- Lignes = Articles
- Colonnes = Services
- Cellules = Prix

#### `features/services/widgets/service_detail_dialog.dart`
- Dialog avec détails complets
- Liste des articles compatibles
- Grille de prix

### Étape 4 : Améliorer le Stepper de Commande

Mettre à jour les steps existants pour utiliser le `ServicesProvider` :

#### `features/orders/widgets/steps/service_selection_step.dart`
- Charger les services depuis le provider
- Afficher les types de service
- Permettre la sélection

#### `features/orders/widgets/steps/article_selection_step.dart`
- Charger les articles depuis le provider
- Filtrer par catégorie
- Afficher les prix en temps réel
- Support quantité et premium

---

## 💡 Recommandations d'Implémentation

### Design Pattern à Suivre

1. **Glassmorphism** : Utiliser `GlassContainer` pour toutes les cards
2. **Animations** : Ajouter `FadeTransition` et `SlideTransition`
3. **Loading States** : Skeleton loaders pendant le chargement
4. **Error Handling** : Afficher des messages d'erreur clairs
5. **Empty States** : Messages quand aucune donnée

### Structure de la Page Services

```dart
ServicesScreen
├── Hero Section (gradient primary)
├── Service Types Section
│   ├── ServiceTypeCard (Par Article)
│   └── ServiceTypeCard (Par Poids)
├── Services Catalog Section
│   └── ListView de ServiceCard
├── Articles Grid Section
│   └── GridView de ArticleCard
└── Pricing Table Section (optionnel)
    └── PricingTable widget
```

### Gestion des États

```dart
Consumer<ServicesProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return SkeletonLoader();
    if (provider.error != null) return ErrorWidget();
    if (!provider.hasData) return EmptyState();
    return ContentWidget();
  },
)
```

---

## 🚨 Points d'Attention

### 1. Authentification pour Certaines Routes

Les routes suivantes nécessitent un token :
- Types de service
- Prix détaillés
- Couples article-service

**Solution** : 
- Charger ces données après connexion
- Afficher un message "Connectez-vous pour voir les prix" si non authentifié
- Ou utiliser uniquement les routes publiques pour la page "Nos Services"

### 2. Calcul des Prix

Le calcul doit **toujours** utiliser le trio `(article_id, service_type_id, service_id)` :

```dart
final price = await provider.calculatePrice(
  articleId: selectedArticle.id,
  serviceId: selectedService.id,
  serviceTypeId: selectedServiceType.id,
  isPremium: isPremium,
  weight: weight, // si tarification au poids
  quantity: quantity,
);
```

### 3. Fallback si Prix Non Trouvé

Si aucun prix n'est trouvé pour un couple :
- Afficher "Prix sur demande"
- Ou masquer l'option
- Ou afficher un prix par défaut (1 FCFA selon la doc)

### 4. Images des Articles

Les articles peuvent avoir des `imageUrl` :
- Utiliser `Image.network()` avec `errorBuilder`
- Fallback sur une icône si pas d'image
- Placeholder pendant le chargement

---

## 📊 Exemple de Flux Utilisateur

### Page "Nos Services"

1. **Arrivée sur la page**
   - Chargement automatique des données
   - Affichage du skeleton loader
   - Transition fluide vers le contenu

2. **Navigation dans les sections**
   - Scroll vertical fluide
   - Sections bien séparées
   - Animations au scroll

3. **Interaction avec un service**
   - Tap sur une card service
   - Dialog avec détails complets
   - Liste des articles compatibles
   - Grille de prix

4. **Recherche**
   - Barre de recherche en haut
   - Filtrage en temps réel
   - Résultats groupés (services + articles)

5. **Action "Commander"**
   - Bouton CTA sur chaque service/article
   - Navigation vers le stepper de commande
   - Pré-sélection du service/article

---

## 🎨 Mockup Visuel Suggéré

```
┌─────────────────────────────────────┐
│  🏠 Nos Services              🔍    │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  🧺 Excellence Alpha          │ │
│  │  Services premium de pressing │ │
│  │  Découvrez notre gamme...     │ │
│  └───────────────────────────────┘ │
│                                     │
│  Types de Service                   │
│  ┌─────────���┐  ┌──────────┐       │
│  │ 📦 Par   │  │ ⚖️ Par   │       │
│  │ Article  │  │ Poids    │       │
│  │ Fixe     │  │ Variable │       │
│  └──────────┘  └──────────┘       │
│                                     │
│  Services Populaires                │
│  ┌─────────────────────────────┐   │
│  │ 🧼 Nettoyage à Sec          │   │
│  │ Vêtements délicats          │   │
│  │ À partir de 8€              │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 👔 Repassage                │   │
│  │ Finition parfaite           │   │
│  │ À partir de 5€              │   │
│  └─────────────────────────────┘   │
│                                     │
│  Articles                           │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐      │
│  │👔 │ │👖 │ │👗 │ │🧥 │      │
│  │8€ ��� │10€│ │15€│ │25€│      │
│  └────┘ └────┘ └────┘ └────┘      │
│                                     │
└─────────────────────────────────────┘
```

---

## ✅ Checklist Finale

### Avant de commencer l'implémentation

- [x] Modèles vérifiés (pas de duplication)
- [x] Services API créés
- [x] Provider créé
- [x] Routes backend identifiées
- [ ] Provider ajouté dans main.dart
- [ ] Tests des appels API

### Implémentation de la page

- [ ] Hero section
- [ ] Section types de service
- [ ] Section services
- [ ] Section articles
- [ ] Recherche fonctionnelle
- [ ] Détails service (dialog)
- [ ] Gestion des erreurs
- [ ] Loading states
- [ ] Empty states

### Intégration avec le stepper

- [ ] Service selection step
- [ ] Article selection step
- [ ] Calcul prix en temps réel
- [ ] Validation des sélections

---

**Prêt à commencer l'implémentation !** 🚀

Voulez-vous que je commence par :
1. Mettre à jour la page `services_screen.dart` ?
2. Créer les widgets réutilisables ?
3. Intégrer le provider dans main.dart ?
