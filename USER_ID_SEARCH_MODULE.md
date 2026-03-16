# Module de Recherche d'Utilisateur par ID

## Vue d'ensemble

Ce module ajoute une fonctionnalité de recherche d'utilisateurs par extrait d'ID UUID dans la page de gestion des utilisateurs. Les administrateurs peuvent maintenant rechercher rapidement un utilisateur en tapant seulement 4 caractères ou plus de son ID.

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
- **Sélection rapide** : cliquer sur un résultat affiche les détails de l'utilisateur

## Architecture

### Backend

#### Service : `AuthService.searchUsersByIdFragment()`
```typescript
static async searchUsersByIdFragment(
  idFragment: string,
  limit: number = 10
): Promise<User[]>
```

**Localisation** : `backend/src/services/auth.service.ts`

**Fonctionnement** :
1. Valide que le fragment a au minimum 4 caractères
2. Convertit en minuscules pour la recherche insensible à la casse
3. Utilise Prisma pour rechercher les IDs contenant le fragment
4. Retourne jusqu'à `limit` résultats (max 50)

#### Route : `GET /api/users/search-by-id`
```typescript
router.get(
  '/search-by-id',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(async (req, res) => {
    const { idFragment, limit = 10 } = req.query;
    // Validation et appel du service
  })
);
```

**Localisation** : `backend/src/routes/user.routes.ts`

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

### Frontend

#### Service : `UserIdSearchService`
```dart
static Future<List<User>> searchUsersByIdFragment(
  String idFragment, {
  int limit = 10,
}) async
```

**Localisation** : `frontend/mobile/admin-dashboard/lib/services/user_id_search_service.dart`

**Fonctionnement** :
1. Valide que le fragment a au minimum 4 caractères
2. Appelle l'API backend
3. Mappe les résultats JSON en objets `User`
4. Retourne la liste des utilisateurs trouvés

#### Dialog : `UserIdSearchDialog`
**Localisation** : `frontend/mobile/admin-dashboard/lib/screens/users/components/user_id_search_dialog.dart`

**Fonctionnalités** :
- Champ de recherche avec validation en temps réel
- Affichage dynamique des suggestions
- Gestion des états (recherche, résultats, erreurs)
- Bouton copier pour l'ID
- Sélection d'un utilisateur pour voir ses détails

#### Intégration : `UsersScreen`
**Localisation** : `frontend/mobile/admin-dashboard/lib/screens/users/users_screen.dart`

**Bouton d'accès** :
- Bouton "Rechercher par ID" dans le header
- Icône : `Icons.fingerprint`
- Variante : `GlassButtonVariant.secondary`

## Flux d'Utilisation

1. **Accès au module**
   - Cliquer sur le bouton "Rechercher par ID" dans la page de gestion des utilisateurs

2. **Recherche**
   - Taper au moins 4 caractères de l'ID UUID
   - Les résultats s'affichent automatiquement

3. **Sélection**
   - Cliquer sur un utilisateur dans la liste
   - Le dialog se ferme et les détails de l'utilisateur s'affichent

4. **Actions supplémentaires**
   - Copier l'ID complet avec le bouton copier
   - Voir le rôle, email, téléphone
   - Accéder aux détails complets de l'utilisateur

## Respect de l'Architecture Existante

### Design System
- Utilise les constantes de `constants.dart` :
  - Couleurs : `AppColors`
  - Espacement : `AppSpacing`
  - Rayons : `AppRadius`
  - Styles de texte : `AppTextStyles`

### Composants Réutilisables
- `GlassContainer` pour le design glass
- `GlassButton` pour les boutons
- Thème dark/light automatique

### Patterns Utilisés
- **GetX** pour la gestion d'état réactive
- **Service Layer** pour les appels API
- **Dialog Pattern** pour les modales
- **Error Handling** avec snackbars

### Sécurité
- Authentification requise (middleware `authenticateToken`)
- Autorisation : seuls ADMIN et SUPER_ADMIN
- Validation des paramètres côté backend et frontend

## Performance

### Optimisations
- **Limite de résultats** : Maximum 50 résultats pour éviter les surcharges
- **Validation côté client** : Minimum 4 caractères avant appel API
- **Recherche insensible à la casse** : Utilise `mode: 'insensitive'` de Prisma
- **Pagination** : Pas de pagination pour cette recherche (résultats limités)

### Requête Prisma
```typescript
const users = await prisma.users.findMany({
  where: {
    id: {
      contains: fragment,
      mode: 'insensitive'
    }
  },
  take: limit,
  orderBy: { created_at: 'desc' }
});
```

## Gestion des Erreurs

### Frontend
- Validation du fragment (minimum 4 caractères)
- Gestion des erreurs réseau avec snackbar
- État "Aucun résultat trouvé"
- État "Recherche en cours"

### Backend
- Validation du fragment requis
- Validation de la longueur minimale
- Gestion des erreurs Prisma
- Réponse d'erreur structurée

## Fichiers Modifiés/Créés

### Créés
1. `backend/src/services/auth.service.ts` - Méthode `searchUsersByIdFragment()`
2. `frontend/mobile/admin-dashboard/lib/services/user_id_search_service.dart` - Service de recherche
3. `frontend/mobile/admin-dashboard/lib/screens/users/components/user_id_search_dialog.dart` - Dialog de recherche

### Modifiés
1. `backend/src/routes/user.routes.ts` - Route `/search-by-id`
2. `frontend/mobile/admin-dashboard/lib/screens/users/users_screen.dart` - Intégration du bouton et du dialog

## Tests Recommandés

### Backend
```bash
# Test avec 4 caractères
GET /api/users/search-by-id?idFragment=2c8e

# Test avec plus de caractères
GET /api/users/search-by-id?idFragment=06657ef1-2c8e

# Test avec limite personnalisée
GET /api/users/search-by-id?idFragment=2c8e&limit=5

# Test avec fragment invalide (< 4 caractères)
GET /api/users/search-by-id?idFragment=2c8
# Réponse : 400 Bad Request
```

### Frontend
1. Ouvrir le dialog de recherche
2. Taper moins de 4 caractères → Pas de recherche
3. Taper 4 caractères → Affichage des résultats
4. Cliquer sur un résultat → Affichage des détails
5. Copier l'ID → Vérifier le clipboard

## Améliorations Futures

1. **Historique de recherche** : Mémoriser les dernières recherches
2. **Recherche avancée** : Combiner ID + email + nom
3. **Export des résultats** : Exporter les résultats en CSV
4. **Raccourci clavier** : Ctrl+K pour ouvrir la recherche
5. **Recherche floue** : Implémenter une recherche fuzzy pour plus de flexibilité
6. **Cache** : Mettre en cache les résultats fréquents

## Support et Maintenance

Pour toute question ou problème :
1. Vérifier les logs du backend : `[AuthService] searchUsersByIdFragment`
2. Vérifier les logs du frontend : `[UserIdSearchService]`
3. Vérifier la connexion à la base de données
4. Vérifier les permissions de l'utilisateur (ADMIN/SUPER_ADMIN)
