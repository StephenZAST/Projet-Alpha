# 📦 Dépendances à Ajouter - Alpha Affiliate App

Ce fichier liste les dépendances qui doivent être ajoutées au projet pour le bon fonctionnement de toutes les fonctionnalités.

## 🔧 Dépendances Principales

### Déjà Ajoutées ✅
- `flutter/material.dart` - Framework UI
- `provider` - Gestion d'état
- `shared_preferences` - Stockage local
- `http` - Requêtes HTTP
- `url_launcher` - Ouverture d'URLs externes

### À Ajouter 📋

#### 1. Partage de Contenu
```yaml
share_plus: ^7.2.1
```
**Usage:** Partager le code affilié via les applications natives

#### 2. Copie dans le Presse-papiers
```yaml
flutter/services.dart # Déjà inclus dans Flutter
```
**Usage:** Copier le code affilié dans le presse-papiers

#### 3. Génération de QR Code
```yaml
qr_flutter: ^4.1.0
```
**Usage:** Générer des QR codes pour le code affilié

#### 4. Scanner de QR Code
```yaml
mobile_scanner: ^3.5.6
```
**Usage:** Scanner des QR codes (fonctionnalité future)

#### 5. Notifications Push
```yaml
firebase_messaging: ^14.7.9
firebase_core: ^2.24.2
```
**Usage:** Notifications push pour les mises à jour importantes

#### 6. Analytics
```yaml
firebase_analytics: ^10.7.4
```
**Usage:** Suivi des performances et comportement utilisateur

#### 7. Stockage Sécurisé
```yaml
flutter_secure_storage: ^9.0.0
```
**Usage:** Stockage sécurisé des tokens et données sensibles

#### 8. Formatage des Dates
```yaml
intl: ^0.18.1
```
**Usage:** Formatage des dates et nombres selon la locale

#### 9. Graphiques et Charts
```yaml
fl_chart: ^0.65.0
```
**Usage:** Graphiques pour les statistiques de gains

#### 10. Animations Avancées
```yaml
lottie: ^2.7.0
```
**Usage:** Animations Lottie pour améliorer l'UX

## 🛠️ Configuration Requise

### Android (android/app/build.gradle)
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Cette app utilise la caméra pour scanner les QR codes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette app accède à la galerie pour partager des images</string>
```

### Permissions Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## 🚀 Installation

Pour installer toutes les dépendances :

```bash
flutter pub add share_plus qr_flutter mobile_scanner firebase_messaging firebase_core firebase_analytics flutter_secure_storage intl fl_chart lottie
```

## 📱 Fonctionnalités Activées

### Avec ces dépendances, l'app pourra :
- ✅ Partager le code affilié via WhatsApp, SMS, Email, etc.
- ✅ Copier le code dans le presse-papiers
- ✅ Générer des QR codes pour le partage
- ✅ Recevoir des notifications push
- ✅ Afficher des graphiques de performance
- ✅ Stocker les données de manière sécurisée
- ✅ Formater les dates et nombres correctement
- ✅ Animations fluides et modernes

## 🔄 Mise à Jour du Code

Après installation, mettre à jour :

1. **main.dart** - Initialiser Firebase
2. **constants.dart** - Ajouter les configurations
3. **services/** - Intégrer les nouveaux services
4. **widgets/** - Utiliser les nouveaux composants

## 📋 Priorités d'Implémentation

### Phase 1 (Critique) 🔴
- `share_plus` - Partage du code affilié
- `flutter_secure_storage` - Sécurité des tokens
- `intl` - Formatage des données

### Phase 2 (Important) 🟡
- `firebase_messaging` - Notifications push
- `qr_flutter` - QR codes
- `fl_chart` - Graphiques

### Phase 3 (Nice-to-have) 🟢
- `lottie` - Animations
- `mobile_scanner` - Scanner QR
- `firebase_analytics` - Analytics

## 🧪 Tests

Après ajout des dépendances, tester :
- Partage du code affilié
- Notifications
- Stockage sécurisé
- Formatage des données
- Génération QR codes

---

**Note:** Ce fichier doit être mis à jour à chaque ajout de nouvelle fonctionnalité nécessitant des dépendances externes.