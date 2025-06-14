un système de boutons réutilisables avec un design glassmorphique. Voici la solution étape par étape :

D'abord, créons un nouveau composant bouton glassmorphique :
glass_button.dart
glass_button.dart
Maintenant, modifions le OrderStepper pour utiliser ces nouveaux boutons :
order_stepper.dart
order_stepper.dart
Le nouveau composant GlassButton offre :

Plusieurs variantes de couleurs
Différentes tailles
Option pour les boutons outlined
Support des icônes
Option pour largeur complète
Effet glassmorphique consistant
Animation de clic avec effet ripple
Pour l'utiliser ailleurs dans l'application, vous pouvez simplement l'importer et l'utiliser comme ceci :

Vous pouvez maintenant standardiser tous vos boutons en utilisant ce composant, ce qui assurera une cohérence visuelle dans toute l'application. Pour les filtres de statut et autres boutons similaires, vous pouvez utiliser la variante secondary ou info avec isOutlined: true.


Documentation du Design System


# Design System - Admin Dashboard

## 1. Glassmorphism Theme

### Principes de base
- Effet de verre (translucide)
- Coins arrondis consistants
- Ombres subtiles
- Flou d'arrière-plan
- Bordures légères

### Variables clés
```dart
const glassEffect = {
  blur: 5.0,
  opacity: 0.1,
  borderRadius: 12.0,
  borderOpacity: 0.5,
}


Composants principaux
1. GlassButton
Variantes :
Primary
Secondary
Warning
Success
Error
Info
Tailles :
Small (height: 32px)
Medium (height: 40px)
Large (height: 48px)
États :
Normal
Hover
Pressed
Disabled
2. GlassCard
Utilisé pour les conteneurs
Niveau de transparence ajustable
Bordures subtiles