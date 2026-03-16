# Module de Recherche d'Utilisateur par ID - Delivery App

## Vue d'ensemble

Ce module ajoute une fonctionnalité de recherche d'utilisateurs par extrait d'ID UUID dans la Delivery App. Les livreurs peuvent maintenant rechercher rapidement un utilisateur en tapant seulement 4 caractères ou plus de son ID.

Cette implémentation est basée sur le module existant du Dashboard Admin et utilise la même API backend.

## Fonctionnalités

### 1. Recherche par Extrait d'ID
- **Minimum 4 caractères requis** pour lancer la recherche
- Recherche **insensible à la casse** (majuscules/minuscules)
- Recherche **en temps réel** avec suggestions dynamiques
- Limite de **10 résultats** par défaut (configurable jusqu'à 50)

### 2. Exemples de Recherche
Pour un ID complet comme : `06657ef1-2c8e-4033-aeb3-8acb98fe1d1c`

Vous pouvez rechercher avec :
- `2c8e` - Segment du milieu
- `4033` - Segment suivant
- `aeb3` - Segment suivant
- `8acb98fe1d1c` - Segment final
- `06657ef1` - Segment initial
- `657ef1-2c8e` - Combinaison de segments

### 3. Interface Utilisateur
- **Dialog de recherche** avec interface glass design
- **Affichage des résultats** avec :
  - Nom et prénom de l'utilisateur
  - Email
  - Rôle (avec couleur spécifique)
  - ID complet (avec bouton copier)
  - Numéro de téléphone (si disponible)
- **Sélection rapide** : cliquer sur un résultat sélectionne l'utilisateur

## Architecture

### Frontend

#### Service : `UserIdSearchService`
```dart
static Future<List<User>> searchUsersByIdFragment(
  String idFragment, {
  int limit = 10,
}) async
```

**Localisation** : `frontend/mobile/delivery_app/lib/services/user_id_search_service.dart`

**Fonctionnement** :
1. Valide que le fragment a au minimum 4 caractères
2. Appelle l'API backend `/api/users/search-by-id`
3. Mappe les résultats JSON en objets `User`
4. Retourne la liste des utilisateurs trouvés

#### Dialog : `UserIdSearchDialog`
**Localisation** : `frontend/mobile/delivery_app/lib/screens/dashboard/components/user_id_search_dialog.dart`

**Fonctionnalités** :
- Champ de recherche avec validation en temps réel
- Affichage dynamique des suggestions
- Gestion des états (recherche, résultats, erreurs)
- Bouton copier pour l'ID
- Sélection d'un utilisateur

#### Intégration : `DashboardScreen`
**Localisation** : `frontend/mobile/delivery_app/lib/screens/dashboard/dashboard_screen.dart`

**Bouton d'accès** :
- Bouton "Utilisateurs" dans les actions rapides
- Icône : `Icons.fingerprint`
- Couleur : `AppColors.secondary`

## Flux d'Utilisation

1. **Accès au module**
   - Cliquer sur le bouton "Utilisateurs" dans les actions rapides du dashboard

2. **Recherche**
   - Taper au moins 4 caractères de l'ID UUID
   - Les résultats s'affichent automatiquement

3. **Sélection**
   - Cliquer sur un utilisateur dans la liste
   - Le dialog se ferme et un message de confirmation s'affiche

4. **Actions supplémentaires**
   - Copier l'ID complet avec le bouton copier
   - Voir le rôle, email, téléphone

## Respect de l'Architecture Existante

### Design System
- Utilise les constantes de `constants.dart` :
  - Couleurs : `AppColors`
  - Espacement : `AppSpacing`
  - Rayons : `AppRadius`
  - Styles de texte : `AppTextStyles`

### Composants Réutilisables
- `GlassContainer` pour le design glass
- Thème dark/light automatique

### Patterns Utilisés
- **GetX** pour la gestion d'état réactive
- **Service Layer** pour les appels API
- **Dialog Pattern** pour les modales
- **Error Handling** avec snackbars

### Sécurité
- Authentification requise (middleware `authenticateToken`)
- Utilise la même API que le Dashboard Admin
- Validation des paramètres côté frontend

## Performance

### Optimisations
- **Limite de résultats** : Maximum 50 résultats pour éviter les surcharges
- **Validation côté client** : Minimum 4 caractères avant appel API
- **Recherche insensible à la casse** : Utilise l'API backend
- **Pas de pagination** : Résultats limités

## Gestion des Erreurs

### Frontend
- Validation du fragment (minimum 4 caractères)
- Gestion des erreurs réseau avec snackbar
- État "Aucun résultat trouvé"
- État "Recherche en cours"

## Fichiers Créés/Modifiés

### Créés
1. `frontend/mobile/delivery_app/lib/services/user_id_search_service.dart` - Service de recherche
2. `frontend/mobile/delivery_app/lib/screens/dashboard/components/user_id_search_dialog.dart` - Dialog de recherche

### Modifiés
1. `frontend/mobile/delivery_app/lib/screens/dashboard/dashboard_screen.dart` - Intégration du bouton et du dialog
2. `frontend/mobile/delivery_app/lib/delivery_app_architecture.md` - Mise à jour de la documentation

## Utilisation de l'API Backend

Cette implémentation utilise l'API backend existante :

**Route** : `GET /api/users/search-by-id`

**Paramètres** :
- `idFragment` (string, requis) : Extrait de l'ID à rechercher
- `limit` (number, optionnel) : Nombre max de résultats (défaut: 10, max: 50)

**Réponse** :
```json
{
  "success": true,
  "data": [
    {
      "id": "06657ef1-2c8e-4033-aeb3-8acb98fe1d1c",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "phone": "+22651542586",
      "role": "CLIENT",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ],
  "count": 1
}
```

## Améliorations Futures

1. **Historique de recherche** : Mémoriser les dernières recherches
2. **Recherche avancée** : Combiner ID + email + nom
3. **Export des résultats** : Exporter les résultats en CSV
4. **Raccourci clavier** : Ctrl+K pour ouvrir la recherche
5. **Recherche floue** : Implémenter une recherche fuzzy pour plus de flexibilité
6. **Cache** : Mettre en cache les résultats fréquents

## Support et Maintenance

Pour toute question ou problème :
1. Vérifier les logs du frontend : `[UserIdSearchService]`
2. Vérifier la connexion à l'API backend
3. Vérifier les permissions de l'utilisateur (authentification requise)
4. Consulter la documentation du module Dashboard Admin pour plus de détails
