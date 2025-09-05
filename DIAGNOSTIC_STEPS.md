# 🔍 Étapes de Diagnostic - Problème d'Authentification Affiliés

## 🚨 Problème Identifié

**Symptôme** : La page Users fonctionne parfaitement (200), mais la page Affiliates échoue avec des erreurs 401 "Authentication required".

**Observation clé** : Le token semble être présent pour Users mais pas pour Affiliates.

## 🛠️ Outils de Diagnostic Ajoutés

### 1. **Debug Backend** (`auth.middleware.ts`)
- ✅ Ajout de logs détaillés dans le middleware d'authentification
- ✅ Affichage des headers reçus
- ✅ Vérification de la présence du token

### 2. **Debug Frontend** (`api_service.dart`)
- ✅ Ajout de logs détaillés pour chaque requête
- ✅ Vérification de la présence du token avant envoi
- ✅ Affichage des headers envoyés

### 3. **Utilitaires de Debug**
- ✅ `TokenDebug` - Vérification de l'état du token
- ✅ `ApiTestHelper` - Tests automatisés des APIs
- ✅ Debug dans `AffiliatesController`

## 🔬 Tests à Effectuer

### Étape 1: Vérifier les Logs
1. Redémarrer le backend avec les nouveaux logs
2. Naviguer vers Users → vérifier les logs backend/frontend
3. Naviguer vers Affiliates → comparer les logs

### Étape 2: Analyser les Différences
Rechercher dans les logs :
- ✅ `[AuthMiddleware] ✅ Token found:` (backend)
- ✅ `[ApiService] Adding Authorization header` (frontend)
- ❌ `[AuthMiddleware] ❌ No token provided` (backend)
- ❌ `[ApiService] ⚠️ NO TOKEN FOUND` (frontend)

### Étape 3: Tests Manuels
Ajouter temporairement dans `AffiliatesScreen` :
```dart
// Dans le build method, ajouter un bouton de test
ElevatedButton(
  onPressed: () => ApiTestHelper.testAffiliateAPIs(),
  child: Text('Test APIs'),
)
```

## 🎯 Hypothèses à Vérifier

### Hypothèse 1: Token Perdu Entre Navigations
- **Test** : Vérifier si le token existe dans le storage avant les requêtes
- **Outil** : `TokenDebug.logTokenState()`

### Hypothèse 2: Problème de Timing
- **Test** : Délai entre la navigation et les requêtes
- **Solution** : Ajouter un délai avant les requêtes

### Hypothèse 3: Problème d'Intercepteur
- **Test** : L'intercepteur ne s'exécute pas pour certaines requêtes
- **Solution** : Vérifier l'ordre des intercepteurs

### Hypothèse 4: Problème de Route Backend
- **Test** : Les routes affiliés utilisent un middleware différent
- **Solution** : Vérifier la configuration des routes

## 🔧 Solutions Potentielles

### Solution 1: Forcer le Token
```dart
// Dans ApiService, forcer l'ajout du token
options.headers['Authorization'] = 'Bearer ${getToken()}';
```

### Solution 2: Délai de Navigation
```dart
// Dans MenuAppController
await Future.delayed(Duration(milliseconds: 100));
```

### Solution 3: Réinitialiser l'ApiService
```dart
// Recréer l'instance ApiService pour les affiliés
```

### Solution 4: Vérification Synchrone du Token
```dart
// Vérifier le token de manière synchrone avant chaque requête
```

## 📋 Checklist de Diagnostic

- [ ] Logs backend montrent la réception du token pour Users
- [ ] Logs backend montrent l'absence du token pour Affiliates
- [ ] Logs frontend montrent l'envoi du token pour Users
- [ ] Logs frontend montrent l'absence du token pour Affiliates
- [ ] Token existe dans le storage avant les requêtes Affiliates
- [ ] Intercepteur s'exécute pour les requêtes Affiliates
- [ ] Routes backend configurées correctement
- [ ] Middleware d'authentification identique pour toutes les routes admin

## 🚀 Prochaines Étapes

1. **Exécuter les tests** avec les nouveaux logs
2. **Identifier la cause racine** grâce aux logs détaillés
3. **Appliquer la solution appropriée**
4. **Valider le correctif** en testant la navigation Users → Affiliates
5. **Nettoyer les logs de debug** une fois le problème résolu

---

**Status**: 🔍 Diagnostic en cours - Outils mis en place