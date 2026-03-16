# 🧪 Guide de Test Local - Delivery App

## 📋 Vue d'ensemble

Ce guide explique comment tester la **Delivery App** avec le backend local au lieu du serveur Render en production.

## 🚀 Prérequis

1. **Backend local en cours d'exécution**
   - Le serveur backend doit tourner sur `http://localhost:3001`
   - Vérifiez que le backend est démarré avant de lancer l'app

2. **Flutter installé**
   - Version récente de Flutter
   - Chrome ou un navigateur compatible pour le test web

## 🔧 Configuration

### Option 1: Test avec Backend Local (Recommandé pour le développement)

```bash
# Lancer l'app avec le backend local
flutter run -d chrome -v --dart-define=USE_LOCAL=true
```

**Cela va:**
- ✅ Connecter l'app au backend local (`http://localhost:3001/api`)
- ✅ Afficher `🔴 LOCAL (localhost:3001)` au démarrage
- ✅ Permettre de tester les changements backend en temps réel

### Option 2: Test avec Backend Production (Render)

```bash
# Lancer l'app avec le backend Render
flutter run -d chrome -v
```

**Cela va:**
- ✅ Connecter l'app au backend Render (`https://alpha-laundry-backend.onrender.com/api`)
- ✅ Afficher `🟢 PRODUCTION (Render)` au démarrage
- ✅ Tester avec les données en production

## 📊 Vérification de la Configuration

Au démarrage de l'app, vous verrez dans la console:

```
═══════════════════════════════════════════════════════════
🌐 API Configuration
═══════════════════════════════════════════════════════════
Mode: 🔴 LOCAL (localhost:3001)
Base URL: http://localhost:3001/api
═══════════════════════════════════════════════════════════
```

ou

```
═══════════════════════════════════════════════════════════
🌐 API Configuration
═══════════════════════════════════════════════════════════
Mode: 🟢 PRODUCTION (Render)
Base URL: https://alpha-laundry-backend.onrender.com/api
═══════════════════════════════════════════════════════════
```

## 🧪 Cas d'Usage

### Tester une nouvelle fonctionnalité backend

1. Modifiez le backend localement
2. Lancez le backend local: `npm run dev` (ou votre commande)
3. Lancez l'app avec: `flutter run -d chrome -v --dart-define=USE_LOCAL=true`
4. Testez la fonctionnalité
5. Vérifiez les logs dans la console

### Tester avec les données en production

1. Lancez l'app avec: `flutter run -d chrome -v`
2. L'app se connectera au backend Render
3. Vous aurez accès aux données réelles

## 🐛 Déboguer les Erreurs API

### Erreur: "Connection refused" ou "Failed to connect"

**Cause:** Le backend local n'est pas en cours d'exécution

**Solution:**
```bash
# Vérifiez que le backend tourne sur le port 3001
# Dans le dossier backend:
npm run dev
```

### Erreur: "404 Not Found"

**Cause:** La route n'existe pas ou le chemin est incorrect

**Solution:**
- Vérifiez que la route existe dans le backend
- Vérifiez le chemin dans le service (ex: `/users/search-by-id`)
- Consultez les logs du backend pour plus de détails

### Erreur: "401 Unauthorized"

**Cause:** Le token d'authentification est manquant ou expiré

**Solution:**
- Connectez-vous d'abord à l'app
- Vérifiez que le token est stocké correctement
- Vérifiez que le backend accepte le token

## 📝 Fichiers Modifiés

- `lib/constants.dart` - Configuration API avec support LOCAL/PRODUCTION
- `lib/main.dart` - Affichage de la configuration au démarrage

## 🔗 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Dart Environment Variables](https://dart.dev/guides/environment-declarations)
- [Dio HTTP Client](https://pub.dev/packages/dio)

## 💡 Conseils

1. **Utilisez toujours le mode LOCAL pour le développement**
   - Plus rapide
   - Pas de latence réseau
   - Facile à déboguer

2. **Testez en PRODUCTION avant de déployer**
   - Vérifiez que tout fonctionne avec le vrai backend
   - Testez avec les vraies données

3. **Gardez les logs activés**
   - Utilisez `-v` pour les logs verbeux
   - Consultez la console pour les erreurs API

## 🚀 Déploiement

Quand vous êtes prêt à déployer:

1. Assurez-vous que le backend est déployé sur Render
2. Lancez l'app sans le flag `--dart-define=USE_LOCAL=true`
3. L'app utilisera automatiquement le backend Render
