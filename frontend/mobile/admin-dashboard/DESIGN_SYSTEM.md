# Design System – Alpha Admin

## Vision Générale
L'application admin Alpha doit offrir une expérience moderne, fluide et cohérente sur toutes les pages (utilisateurs, articles, services, catégories, commandes, etc.). Le design doit être à la fois professionnel, épuré et agréable à utiliser, avec une forte identité visuelle.

## Principes de Design
- **Cohérence** : Tous les écrans partagent les mêmes composants, couleurs, typographies et comportements.
- **Modernité** : Utilisation de glassmorphism (effet glassy), ombres douces, arrondis, couleurs vibrantes et animations subtiles.
- **Feedback utilisateur** : Les notifications, loaders, et dialogues sont visibles, élégants et informatifs.
- **Accessibilité** : Contrastes suffisants, tailles de texte lisibles, boutons accessibles.

## Composants Clés
- **Header** :
  - Titre de page en gras, espacé, couleur principale.
  - Boutons glassy (ajout, refresh, etc.) alignés à droite.
- **Search Bar** :
  - Fond semi-transparent, bords arrondis, icône de recherche.
  - Animation légère à l’apparition.
- **Boutons** :
  - GlassButton ou AppButton partout (fond glassy, ombre, arrondi, feedback visuel).
  - Couleurs cohérentes avec AppColors (success, error, warning, info).
- **Dialogs** :
  - Fond glassy, arrondi, ombre douce.
  - Transitions douces à l’ouverture/fermeture.
- **Notifications (Snackbars)** :
  - Apparition en haut, fond glassy, icône, texte lisible.
  - Couleur selon le type (success, error, info, warning).
  - **Effet de flux** : Animation d’apparition/disparition fluide, la notification "pousse" le contenu vers le bas à l’apparition et disparaît sans laisser de vide.
  - Disparaît automatiquement après 2-3 secondes.
- **Cards/Listes** :
  - Fond semi-transparent, arrondi, ombre légère.
  - Responsive (s’adapte desktop/tablette/mobile).
- **Loaders** :
  - Circulaires, couleur principale, centrés.

## Couleurs
- Palette définie dans `AppColors` (bleu, vert, rouge, orange, violet, etc.)
- Utilisation systématique des couleurs de statut pour les feedbacks et statuts d’objets.

## Typographie
- Titres en gras, taille adaptée à l’écran.
- Textes secondaires plus discrets.

## Expérience Utilisateur
- Navigation fluide (GetX), transitions douces.
- Feedback immédiat sur chaque action (création, suppression, erreur, etc.).
- Dialogues de confirmation pour les actions destructrices.

## Notifications – Détail du Comportement

### Composant standardisé
Toutes les notifications doivent utiliser le même composant/snackbar, basé sur `Get.rawSnackbar` avec les paramètres suivants :
- **Apparition** : Animation de slide/fade depuis le haut, effet glassy (fond semi-transparent, overlayBlur, arrondi, ombre portée).
- **Leger et rapid Effet de flux** : Le contenu de la page est floutté à l’apparition de la notification, puis se rétablit à la disparition.
- **Disparition** : Animation inverse, sans laisser de vide.
- **Couleur** :
  - Success : vert (`AppColors.success`)
  - Error : rouge (`AppColors.error`)
  - Info : bleu (`AppColors.info`)
  - Warning : orange (`AppColors.warning`)
- **Icône** : Toujours présente, adaptée au type de notification (ex : check_circle pour succès, error_outline pour erreur).
- **Lisibilité** : Texte blanc ou très contrasté, taille suffisante.
- **Durée** : 2 à 3 secondes, puis disparition automatique.
- **Accessibilité** : Dismissible par l’utilisateur.

### API recommandée
Utiliser une méthode utilitaire dans chaque controller/service :
```dart
void _showSuccessSnackbar(String message) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    messageText: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ),
      ],
    ),
    backgroundColor: AppColors.success.withOpacity(0.85),
    borderRadius: 16,
    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: 2),
    boxShadows: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
    isDismissible: true,
    overlayBlur: 2.5,
  );
}
```
Même logique pour `_showErrorSnackbar`, en changeant l’icône et la couleur.

### Exemple d’utilisation
- À chaque action utilisateur (création, suppression, erreur, etc.), appeler la méthode utilitaire correspondante pour afficher la notification.
- Ne jamais utiliser de snackbar ou toast natif Flutter par défaut : toujours passer par ce composant pour garantir la cohérence visuelle.

### À respecter
- Toute nouvelle page ou fonctionnalité doit utiliser ce composant pour les notifications.
- En cas d’évolution du style, modifier ce composant centralisé pour propager le changement partout.

---

**Ce fichier doit servir de référence pour toute évolution du frontend afin de garantir une expérience utilisateur homogène et moderne.**
