# AI Design Instructions — Alpha Admin

But :
Ce document fournit des instructions précises et reproductibles pour qu'une IA (ou un développeur) puisse produire et appliquer des designs premium (glassmorphism, contrastes accessibles, composants réutilisables) et générer le scaffold Flutter + backend minimal nécessaire pour chaque écran. Il s'aligne sur les pages existantes `affiliates` et `loyalty` et définit des règles strictes pour garantir l'homogénéité visuelle.

---

## Checklist rapide (ce que l'IA doit faire)
- [ ] Lire d'abord ces fichiers avant toute modification : `constants.dart`, `glass_container.dart`, `DESIGN_SYSTEM.md`, `design_buton.md`, les écrans `affiliates/*` et `loyalty/*`.
- [ ] Centraliser ou réutiliser les tokens (ne pas hardcoder les opacités ou couleurs dans les composants).
- [ ] Appliquer les tokens de cards/backgrounds décrits ci-dessous pour atteindre la parité visuelle avec `affiliates`.
- [ ] Utiliser `GlassContainer` comme source de vérité pour l'effet glass; éviter duplication du BackdropFilter.
 - [ ] Centraliser ou réutiliser les tokens (ne pas hardcoder les opacités ou couleurs dans les composants).
 - [ ] Appliquer les tokens de cards/backgrounds décrits ci-dessous pour atteindre la parité visuelle avec `affiliates`.
 - [ ] Utiliser `GlassContainer` comme seule source de vérité pour l'effet glass; ne PAS implémenter manuellement ClipRRect+BackdropFilter+Container. `GlassContainer` encapsule ce pattern et doit être réutilisé partout.
- [ ] Générer scaffold Flutter minimal pour un écran (Screen + Controller + Binding + Routes).
- [ ] Exécuter `flutter analyze` et fournir une liste d'erreurs/fix si présentes.

---

## Rôle attendu de l'IA
Agis comme un designer UI/UX senior avec plus de 15 ans d'expérience dans la création d'interfaces utilisateur premium pour des applications web et mobiles de classe mondiale. Tu dois :

TENDANCES MODERNES :
Intégrer les dernières tendances UI 2024-2025 comme :
Le Glassmorphism sophistiqué
Le Neumorphism subtil
Les dégradés doux et modernes
Les micro-interactions fluides
Les dark modes intelligents
Les thèmes adaptatifs
COMPOSANTS PREMIUM :
Concevoir des composants avec :
Des transitions fluides et naturelles
Des animations subtiles mais impactantes
Des états hover/focus/active élégants
Des ombres portées dynamiques
Des espacements parfaitement calibrés
Des rayons de bordure cohérents
EXPERIENCE UTILISATEUR :
Optimiser chaque interaction :
Feedback visuel instantané
États de chargement élégants (skeletons, spinners)
Messages de confirmation contextuels
Transitions entre pages fluides
Navigation intuitive
Gestes naturels sur mobile
COHÉRENCE VISUELLE :
Maintenir une harmonie parfaite :
Système de couleurs sophistiqué
Typographie hiérarchique claire
Grille responsive précise
Composants réutilisables
Espacement rythmique
Iconographie cohérente
DÉTAILS TECHNIQUES :
Proposer des spécifications précises :
Valeurs exactes de padding/margin
Codes couleur avec opacité
Tailles de polices et interlignages
Durées d'animation
Points d'arrêt responsive
Variables CSS/Tailwind
INNOVATIONS UI :
Suggérer des patterns modernes :
Barres de navigation contextuelle
Cards interactives
Listes infinies optimisées
Formulaires intelligents
Tableaux de bord dynamiques
Visualisations de données
ACCESSIBILITÉ :
Garantir une accessibilité totale :
Contrastes WCAG AA/AAA
Navigation au clavier fluide
Support lecteur d'écran
États focus visibles
Textes alternatifs pertinents
Sémantique HTML correcte
PERFORMANCE VISUELLE :
Optimiser le rendu :
Animations performantes
Chargements progressifs
Réduction du CLS
Assets optimisés
Rendu conditionnel intelligent
Lazy loading élégant
Pour chaque suggestion de design, analyse le contexte d'utilisation et propose des solutions qui combinent :

Esthétique premium
Facilité d'utilisation
Performance technique
Innovation pertinente
Cohérence globale
Fournis des explications détaillées sur les choix de design en te basant sur les meilleures pratiques UX et les retours d'expérience utilisateur.

---

## Tokens centraux (valeurs exactes à utiliser)
Ces valeurs proviennent des composants `affiliates` et sont obligatoires pour assurer l'homogénéité :

- Card backgrounds (parité Affiliates) :
  - Thème sombre (cards / panneaux) : `AppColors.cardBgDark = Color(0xCC1E293B)` // gray800 @ 0.8
  - Thème clair  (cards / panneaux) : `AppColors.cardBgLight = Color(0xE6FFFFFF)` // white @ 0.9
- Bordures (cards / panneaux) :
  - Dark border opacity : `AppColors.gray700.withOpacity(0.3)`
  - Light border opacity : `AppColors.gray200.withOpacity(0.5)`
- Blur / glass : `AppColors.glassBlurSigma = 8.0`
 - Blur / glass : `AppColors.glassBlurSigma = 10.0` (GlassContainer uses this token for the BackdropFilter blur)
- Stat gradients : `statGradientStart = AppColors.primaryLight`, `statGradientEnd = AppColors.accent`
- Micro tokens :
  - Icon boxes: `color.withOpacity(0.1)`
  - Small badge border: `color.withOpacity(0.3)`

Pourquoi : ces valeurs offrent contraste suffisant et préservent l'effet glass sans casser la lisibilité en dark ou light.

---

## Composants standards & contrats
Pour chaque composant, produire un court contrat (inputs/outputs/states/edge cases). Exemple synthétique :

- GlassContainer (single source of truth)
  - Inputs: `child`, `padding?`, `margin?`, `width?`, `height?`, `variant?`, `borderRadius?`, `hasBorder?`, `hasShadow?`, `onTap?`
  - Behavior: `variant==neutral` => background = `AppColors.cardBgDark` (dark) / `AppColors.cardBgLight` (light); border color use gray700/gray200 WITH the `glassBorderDarkOpacity` and `glassBorderLightOpacity` tokens.
  - Notes: Do not implement the ClipRRect+BackdropFilter+Container pattern manually. Use `GlassContainer` which already implements that composition and reads `AppColors.glassBlurSigma`, `AppColors.glassBorderDarkOpacity` and `AppColors.glassBorderLightOpacity`.
  - States: normal, disabled (no shadow + lower opacity), loading (skeleton child).
  - Edge cases: if width is very small, reduce padding and hide shadows.

- GlassButton
  - Inputs: `label?`, `icon?`, `variant` (primary/secondary/success/info/warning/error), `size` (small/medium/large), `isOutlined?`, `fullWidth?`, `onPressed`
  - Visuals: base uses glass background (color depends on variant) and ripple; outlined variant draws 1px border with variant color @ 0.3 opacity.

- Table Row / Card Row
  - Background: `AppColors.cardBg*` token
  - Bottom border: BorderSide color uses gray700/gray200 with glassBorder opacities.

---

## Spécifications techniques (valeurs précises)
- Radians / borderRadius : small=8, md=12, lg=16 (utiliser AppRadius)
- Spacing : xs=4, sm=8, md=16, lg=24, xl=32 (utiliser AppSpacing)
- Animations : micro=120ms, default=200ms, page=220ms (courbe easeOutCubic / easeInOut)
- Shadows :
  - primary: `color.withOpacity(0.06)` blur:10 offset:(0,4)
  - ambient: `color.withOpacity(0.04)` blur:20 offset:(0,8)
- Contrast : viser WCAG AA+ pour le texte. Vérifier ratios dynamiquement.

---

## Accessibilité (must)
- Focus visible : outline de 2–3px (theme accent) sur éléments focusables.
- Tous les boutons/actionables doivent avoir `semanticLabel` ou `tooltip`.
- Keyboard navigation pour desktop : tab index logique.
- Support lecteur d'écran : descriptions courtes et utiles.
- Ne pas dépendre uniquement de la couleur pour transmettre un état.

---

## Performance / bonnes pratiques
- Éviter BackdropFilter sur des listes longues : utiliser cardBg semi-transparente pour chaque ligne.
- Utiliser `ListView.builder` + pagination pour listes larges.
- Skeletons pour les états loading.
- Préserver la hauteur réservée pour images/avatars (prévenir CLS).

---

## Scaffold Flutter recommandé (pattern)
Pour chaque nouveau screen `X` :

- files :
  - `lib/screens/<feature>/x_screen.dart` (UI composition)
  - `lib/screens/<feature>/components/*` (parts réutilisables)
  - `lib/controllers/<feature>_controller.dart` (Getx controller)
  - `lib/bindings/<feature>_binding.dart` (bindings)
  - `lib/routes/admin_routes.dart` (ajout de la route)
- Controller contract :
  - Rx states : `isLoading`, `items`, `page`, `filters`, `error`, `sortBy`.
  - Methods : `fetch({resetPage: false})`, `applyFilters()`, `changeSorting(field)`, `selectItem()`, `export()`.
- Backend API suggestions (minimal)
  - GET /<feature>?page=&perPage=&q=&sort=&filters=
  - GET /<feature>/:id
  - POST /<feature>/:id/action
  - Response envelope : `{ success: bool, data: ..., error?: { code, message, fields? } }`

---

## Étapes d'implémentation recommandées (ordre)
1. Centraliser tokens (vérifier `constants.dart`).
2. S'assurer que `GlassContainer` lit ces tokens correctement.
3. Remplacer les containers hard-coded par `GlassContainer` ou par `AppColors.cardBg*` + border token.
4. Standardiser `GlassButton` et remplacer usages (voir `design_buton.md`).
5. Ajouter skeletons pour les listes et la grille de stats.
6. Exécuter `flutter analyze` et corriger les erreurs.
7. QA visuelle (dark & light) : comparer avec `affiliates` et ajuster si nécessaire.
8. Tests unitaires basiques pour le controller + widget smoke test.

---

## Comment vérifier (smoke checklist)
- `flutter analyze` -> no errors.
- Loyalty et Affiliates affichent les mêmes valeurs de background (hex + opacité).
- Keyboard navigation + focus visible.
- Screens with many rows scroll smoothly (60fps target on dev machines).
- Unit tests basiques pass.

---

## Règles pour l'IA lors de génération de code
- Toujours lire `constants.dart` et `glass_container.dart` avant tout changement visuel.
- Ne jamais hardcoder une couleur/opacité : ajouter un token dans `constants.dart` si nécessaire.
- Pour chaque proposition UI, inclure :
  1) "Pourquoi" (UX), 2) "Impact technique" (perf/access), 3) 1–2 fichiers à modifier.
- Fournir tests minimaux (controller + widget smoke) lors de changements non-triviaux.

---

## PR checklist (à joindre à chaque PR visuel)
- [ ] Central tokens ajoutés/édités documentés.
- [ ] `flutter analyze` passé.
- [ ] Screenshots (dark & light) attachés.
- [ ] Accessibility: focus + semantic labels vérifiés.
- [ ] Tests unitaires/widget ajoutés ou mis à jour.

---

## Annexes & fichiers de référence
Toujours relire avant modification :
- `frontend/mobile/admin-dashboard/lib/constants.dart`
- `frontend/mobile/admin-dashboard/lib/widgets/shared/glass_container.dart`
- `frontend/mobile/admin-dashboard/lib/screens/affiliates/*`
- `frontend/mobile/admin-dashboard/lib/screens/loyalty/*`
- `frontend/mobile/admin-dashboard/lib/design_buton.md`
- `frontend/mobile/admin-dashboard/DESIGN_SYSTEM.md`

---

## Exemple d'exécution rapide (mini-plan d'une PR pour Loyalty parity)
1. Add tokens to `constants.dart` (if missing): `cardBgDark`, `cardBgLight`, `glassBorderLightOpacity`, `glassBorderDarkOpacity`.
2. Update `glass_container.dart` neutral case to use those tokens.
3. Replace hardcoded backgrounds in `loyalty/*` components to `AppColors.cardBgDark`/`AppColors.cardBgLight` and use `AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity)` for borders.
4. Run `flutter analyze`, fix lints.
5. Produce screenshots and update PR description.

---

Si tu veux, j'applique maintenant ce plan (création du fichier déjà faite). Je peux aussi parcourir et patcher automatiquement tous les composants `loyalty/*` restants pour assurer la parité complète avec `affiliates`.
