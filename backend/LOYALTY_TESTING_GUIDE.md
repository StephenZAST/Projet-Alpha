# Guide de Test du Système de Fidélité

## 🎯 Objectif
Tester les endpoints du système de fidélité et récompenses pour identifier les problèmes avant d'ajuster le frontend.

## 📋 Prérequis

1. **Base de données** : Vérifier que les tables loyalty existent
2. **Backend** : Serveur démarré sur le port 3001
3. **Admin user** : Un utilisateur admin pour les tests

## 🚀 Étapes de Test

### 1. Démarrer le Backend
```bash
cd backend
npm run dev
```

### 2. Vérifier la Santé du Serveur
```bash
curl http://localhost:3001/api/health
```

### 3. Test Automatisé avec Node.js
```bash
cd backend
node test_loyalty_endpoints.js
```

### 4. Test Manuel avec Postman

#### Importer les Collections
1. Importer `loyalty_system_complete.postman_collection.json`
2. Importer `loyalty_test.postman_environment.json`

#### Séquence de Tests Recommandée

1. **Auth → Admin Login**
   - Vérifier que le token est sauvegardé automatiquement

2. **Admin - Loyalty Points → Get Loyalty Stats**
   - Vérifier la structure de réponse
   - Noter les erreurs éventuelles

3. **Admin - Loyalty Points → Get All Loyalty Points**
   - Vérifier la pagination
   - Noter le format des données

4. **Admin - Rewards → Get All Rewards**
   - Vérifier les récompenses par défaut
   - Noter la structure des données

5. **Admin - Rewards → Create Reward**
   - Tester la création d'une nouvelle récompense
   - Vérifier que l'ID est sauvegardé

6. **Utilities → Calculate Order Points**
   - Tester le calcul de points pour une commande

## 🔍 Points à Vérifier

### Structure des Réponses
- [ ] Format JSON cohérent
- [ ] Champs `success`, `data`, `error`
- [ ] Pagination correcte
- [ ] Gestion des erreurs

### Données Attendues

#### Loyalty Stats
```json
{
  "success": true,
  "data": {
    "totalUsers": number,
    "activeUsers": number,
    "totalPointsDistributed": number,
    "totalPointsRedeemed": number,
    "averagePointsPerUser": number,
    "totalRewardsClaimed": number,
    "pendingClaims": number,
    "pointsBySource": {},
    "redemptionsByType": {}
  }
}
```

#### Loyalty Points
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": "uuid",
        "userId": "uuid",
        "pointsBalance": number,
        "totalEarned": number,
        "createdAt": "date",
        "updatedAt": "date",
        "user": {
          "id": "uuid",
          "firstName": "string",
          "lastName": "string",
          "email": "string"
        }
      }
    ],
    "pagination": {
      "page": number,
      "limit": number,
      "total": number,
      "totalPages": number
    }
  }
}
```

## 🐛 Problèmes Courants à Identifier

### 1. Erreurs de Base de Données
- Tables manquantes
- Contraintes FK non respectées
- Index manquants

### 2. Erreurs de Mapping
- Noms de champs incohérents (camelCase vs snake_case)
- Types de données incorrects
- Relations manquantes

### 3. Erreurs de Logique Métier
- Calculs de points incorrects
- Gestion des transactions
- Validation des données

### 4. Erreurs d'Authentification
- Tokens invalides
- Permissions insuffisantes
- Middleware d'auth défaillant

## 📝 Rapport de Test

Créer un fichier `LOYALTY_TEST_RESULTS.md` avec :

```markdown
# Résultats des Tests - Système de Fidélité

## Date: [DATE]
## Testeur: [NOM]

### ✅ Tests Réussis
- [ ] Server Health Check
- [ ] Admin Login
- [ ] Get Loyalty Stats
- [ ] Get All Loyalty Points
- [ ] Get Point Transactions
- [ ] Get All Rewards
- [ ] Create Reward
- [ ] Calculate Order Points

### ❌ Tests Échou��s
- [ ] [Nom du test] - [Raison de l'échec]

### 🔧 Corrections Nécessaires
1. [Description du problème] → [Solution proposée]
2. [Description du problème] → [Solution proposée]

### 📊 Données de Test Observées
- Nombre d'utilisateurs avec points: X
- Nombre de récompenses: X
- Nombre de transactions: X
```

## 🎯 Prochaines Étapes

Une fois les tests terminés :

1. **Identifier les incohérences** entre backend et frontend
2. **Corriger le backend** si nécessaire (priorité)
3. **Ajuster le frontend** pour s'adapter au backend
4. **Re-tester** l'intégration complète
5. **Documenter** les changements

## 💡 Conseils

- **Ne pas modifier le backend** sans d'abord comprendre l'impact
- **Tester un endpoint à la fois** pour isoler les problèmes
- **Documenter chaque erreur** avec le contexte complet
- **Vérifier les logs du serveur** pour plus de détails