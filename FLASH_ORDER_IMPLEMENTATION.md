# ⚡ Flash Order - Implémentation Complète

## 📋 Vue d'ensemble

La feature **Flash Order** permet aux clients de créer une commande en un clic sans avoir à sélectionner manuellement les articles. Le client décrit simplement ses besoins, et l'équipe admin complète ensuite la commande avec les détails.

---

## 🎯 Workflow Utilisateur

### 1. **Accès à la feature**
- **Option 1:** Depuis la **home page**, le client clique sur le bouton **Flash Order** (icône éclair ⚡) dans la carte principale
- **Option 2:** Depuis la **home page**, le client clique sur le **FAB (Floating Action Button)** au centre de la barre de navigation
- Navigation fluide avec animation slide

### 2. **Écran Flash Order**
- **Section d'accueil** : Explication de la feature avec icône et message informatif
- **Champ de notes** : Le client décrit ses besoins (ex: "3 chemises, 2 pantalons, nettoyage à sec")
- **Section "Comment ça marche"** : 3 étapes visuelles expliquant le processus

### 3. **Création de la commande**
- Le client clique sur **"Créer ma commande flash"**
- **Vérification automatique** de l'adresse par défaut
- Si pas d'adresse : Dialog avec navigation vers la gestion des adresses
- Si adresse OK : Création de la commande DRAFT sur le backend

### 4. **Confirmation**
- **Dialog de succès** avec référence de commande
- Message : "Notre équipe va la valider rapidement"
- Retour automatique à la home page

---

## 🏗️ Architecture Technique

### Backend

#### Endpoint existant
```typescript
POST /api/orders/flash
```

**Payload attendu:**
```json
{
  "addressId": "uuid-de-l-adresse",
  "notes": "Description des besoins du client"
}
```

**Réponse:**
```json
{
  "data": {
    "id": "uuid-commande",
    "orderReference": "FLASH-ABC123",
    "status": "DRAFT",
    "userId": "uuid-user",
    "addressId": "uuid-adresse",
    "totalAmount": 0,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

#### Contrôleur
- **Fichier:** `backend/src/controllers/order.controller/flashOrder.controller.ts`
- **Méthode:** `FlashOrderController.createFlashOrder()`
- **Logique:**
  1. Récupère l'userId depuis le token JWT
  2. Crée une commande avec status `DRAFT`
  3. Enregistre les notes dans `order_notes`
  4. Marque la commande comme flash order dans `order_metadata`
  5. Injection automatique du code affilié si disponible

### Frontend

#### Service
**Fichier:** `frontend/mobile/customers_app/lib/core/services/flash_order_service.dart`

**Méthodes principales:**
```dart
// Créer une commande flash
Future<FlashOrderResult> createFlashOrder(FlashOrder flashOrder)

// Récupérer l'adresse par défaut
Future<Map<String, dynamic>?> _getDefaultAddress(String token)
```

**Logique:**
1. Récupère automatiquement l'adresse par défaut de l'utilisateur
2. Prépare le payload avec `addressId` et `notes`
3. Envoie la requête POST au backend
4. Parse la réponse et retourne un `FlashOrderResult`

#### Provider
**Fichier:** `frontend/mobile/customers_app/lib/shared/providers/flash_order_provider.dart`

**État géré:**
- `_currentFlashOrder`: Commande en cours
- `_isLoading`: État de chargement
- `_isCreatingOrder`: État de création
- `_error`: Message d'erreur
- `_lastOrderResult`: Résultat de la dernière commande

**Méthodes:**
```dart
// Initialiser le provider
Future<void> initialize()

// Mettre à jour les notes
void updateNotes(String notes)

// Soumettre la commande
Future<bool> submitFlashOrder()

// Vider la commande
void clearCurrentOrder()
```

#### UI
**Fichier:** `frontend/mobile/customers_app/lib/features/orders/screens/flash_order_screen.dart`

**Composants:**
1. **AppBar** : Titre + bouton retour
2. **Section d'accueil** : Icône flash + explication
3. **Champ de notes** : TextField multi-lignes pour décrire les besoins
4. **Section "Comment ça marche"** : 3 étapes avec icônes
5. **Bottom bar** : Bouton "Créer ma commande flash" toujours visible

**Dialogs:**
- **Adresse requise** : Si pas d'adresse par défaut, avec navigation vers la gestion des adresses
- **Succès** : Confirmation avec référence de commande
- **Erreur** : SnackBar avec message d'erreur

---

## 🎨 Design & UX

### Animations
- **Fade in** : Apparition progressive du contenu
- **Slide in** : Entrée depuis le bas avec courbe easeOutQuart
- **Haptic feedback** : Vibration légère au clic du bouton

### Couleurs
- **Primary** : Bleu signature Alpha (#2563EB)
- **Accent** : Cyan moderne (#06B6D4)
- **Success** : Vert (#10B981)
- **Info** : Bleu info (#3B82F6)
- **Warning** : Ambre (#F59E0B)

### Glassmorphism
- Containers avec effet de verre
- Bordures subtiles
- Ombres douces
- Blur effect

---

## 📊 Flux de Données

```
Client clique "Flash Order"
    ↓
FlashOrderScreen s'ouvre
    ↓
Client décrit ses besoins (optionnel)
    ↓
Client clique "Créer ma commande flash"
    ↓
FlashOrderProvider.submitFlashOrder()
    ↓
FlashOrderService.createFlashOrder()
    ↓
Récupération adresse par défaut
    ↓
POST /api/orders/flash
    ↓
Backend crée commande DRAFT
    ↓
Réponse avec orderReference
    ↓
Dialog de succès
    ↓
Retour à la home page
```

---

## ✅ Checklist d'implémentation

### Backend
- [x] Endpoint POST /api/orders/flash
- [x] Contrôleur FlashOrderController
- [x] Création commande DRAFT
- [x] Enregistrement des notes
- [x] Métadonnées flash order
- [x] Injection code affilié

### Frontend - Service
- [x] FlashOrderService.createFlashOrder()
- [x] Récupération adresse par défaut
- [x] Gestion des erreurs
- [x] Logs de débogage

### Frontend - Provider
- [x] FlashOrderProvider
- [x] Gestion de l'état
- [x] Méthodes CRUD
- [x] Cache et persistance

### Frontend - UI
- [x] FlashOrderScreen
- [x] Section d'accueil
- [x] Champ de notes
- [x] Section "Comment ça marche"
- [x] Bottom bar avec bouton
- [x] Dialog adresse requise
- [x] Dialog de succès
- [x] SnackBar d'erreur
- [x] Animations et transitions
- [x] Navigation vers gestion des adresses

---

## 🚀 Prochaines Améliorations (Optionnelles)

### Phase 2
- [ ] Affichage de l'historique des commandes flash
- [ ] Filtrage des commandes flash dans l'historique
- [ ] Notification push quand l'admin contacte le client
- [ ] Estimation du prix avant création
- [ ] Sélection d'articles suggérés (optionnel)

### Phase 3
- [ ] Templates de commandes flash (commandes récurrentes)
- [ ] Planification de commandes flash
- [ ] Suivi en temps réel du statut
- [ ] Chat avec l'admin pour clarifier les besoins
- [ ] Photos des articles à nettoyer

---

## 🧪 Tests

### Tests Manuels
1. **Création avec adresse** : ✅
   - Ouvrir Flash Order
   - Ajouter des notes
   - Créer la commande
   - Vérifier le dialog de succès

2. **Création sans adresse** : ✅
   - Ouvrir Flash Order sans adresse configurée
   - Cliquer "Créer"
   - Vérifier le dialog d'erreur
   - Cliquer "Configurer"
   - Vérifier la navigation vers AddressManagement

3. **Gestion des erreurs** : ✅
   - Tester avec backend offline
   - Vérifier le SnackBar d'erreur
   - Vérifier les logs de débogage

### Tests Automatisés (À implémenter)
```dart
testWidgets('Flash Order creation success', (tester) async {
  // Setup
  await tester.pumpWidget(MyApp());
  
  // Navigate to Flash Order
  await tester.tap(find.byIcon(Icons.flash_on));
  await tester.pumpAndSettle();
  
  // Enter notes
  await tester.enterText(find.byType(TextField), '3 chemises');
  
  // Create order
  await tester.tap(find.text('Créer ma commande flash'));
  await tester.pumpAndSettle();
  
  // Verify success dialog
  expect(find.text('Commande créée !'), findsOneWidget);
});
```

---

## 📝 Notes Importantes

### Sécurité
- ✅ Authentification JWT requise
- ✅ Validation de l'adresse côté backend
- ✅ Sanitization des notes
- ✅ Rate limiting sur l'endpoint

### Performance
- ✅ Cache de l'adresse par défaut
- ✅ Requêtes optimisées
- ✅ Animations fluides (60 FPS)
- ✅ Lazy loading des données

### Accessibilité
- ✅ Labels sémantiques
- ✅ Contraste des couleurs (WCAG AA)
- ✅ Taille des boutons (min 48x48)
- ✅ Support du mode sombre

---

## 🆘 Troubleshooting

### Problème: "Adresse requise" alors qu'une adresse existe
**Solution:** Vérifier que l'adresse a le flag `isDefault` à `true` dans la base de données.

### Problème: Commande créée mais pas visible dans l'historique
**Solution:** Vérifier que le filtre de statut inclut `DRAFT` dans l'écran Orders.

### Problème: Notes non enregistrées
**Solution:** Vérifier que la table `order_notes` existe et que la relation est correcte.

### Problème: Erreur "Token non trouvé"
**Solution:** Vérifier que l'utilisateur est bien authentifié et que le token est valide.

---

## 📚 Ressources

- **Documentation Backend:** `backend/docs/REFERENCE_ARTICLE_SERVICE.md`
- **Documentation Frontend:** `frontend/mobile/customers_app/files_architecture.md`
- **Design System:** `frontend/mobile/customers_app/lib/constants.dart`
- **Postman Collection:** `backend/postman/flash_orders_test.json`

---

**Dernière mise à jour:** 2024
**Version:** 1.0.0
**Statut:** ✅ Production Ready
