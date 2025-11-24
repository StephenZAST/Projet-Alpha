# 🖼️ Guide des images - Site Vitrine Alpha Laundry

## 📁 Structure des dossiers

```
public/
├── images/
│   ├── logo/
│   │   ├── alphalogo.svg
│   │   ├── alphalogo.png
│   │   └── alphalogo-dark.svg
│   ├── heroes/
│   │   ├── girl_with_clothe_nobackground.png
│   │   ├── guy_ironning.jpg
│   │   ├── girl_holding_iron_clothes.jpg
│   │   ├── girl_move_out_clothes_from_machine.jpg
│   │   ├── girl_openning_machine.jpg
│   │   ├── girl_sitting_near_machine.jpg
│   │   ├── girl_with_clothe_backet.jpg
│   │   ├── girls_holding_clothes_basket.jpg
│   │   ├── grandma_littlegirl_front_washmachine.jpg
│   │   ├── iron_on_clothes.jpg
│   │   ├── ironed_clothes_largepic.jpg
│   │   ├── laundry_machine_and_basket.jpg
│   │   ├── machine_vectorpfull.png
│   │   ├── pic_inside_washmachine.jpg
│   │   ├── Smiling_girl.jpg
│   │   ├── smily_girl_with_bags.jpg
│   │   ├── clothes_ironed_on_wood.jpg
│   │   ├── clothes_ironed_on_wood2.jpg
│   │   ├── clothes.jpg
│   │   ├── gay_giving_clothes_to_girl.jpg
│   │   ├── girl_and_man_holding_clothes_orangeback.jpg
│   │   ├── girl_holding_iron_clothes2.jpg
│   │   ├── girl_with_clothe_redbackground.jpg
│   │   └── clothes_baskettfull_no_background.png
│   ├── services/
│   │   ├── laundry.jpg
│   │   ├── drycleaning.jpg
│   │   └── repair.jpg
│   ├── testimonials/
│   │   ├── client1.jpg
│   │   ├── client2.jpg
│   │   └── client3.jpg
│   ├── team/
│   │   ├── member1.jpg
│   │   ├── member2.jpg
│   │   └── member3.jpg
│   └── icons/
│       ├── check.svg
│       ├── star.svg
│       └── arrow.svg
└── favicon.ico
```

---

## 🎯 Utilisation des images par section

### 1. Hero Section
**Image recommandée**: `girl_with_clothe_nobackground.png`
- Dimensions: 500x500px minimum
- Format: PNG avec transparence
- Utilisation: Image principale du héro
- Placement: Côté droit du texte

**Alternative**: `guy_ironning.jpg`

### 2. Stats Section
**Pas d'images** - Utiliser les icônes emoji

### 3. Problems Section
**Pas d'images** - Utiliser les icônes emoji

### 4. Services Section
**Images recommandées**:
- Laverie: `girl_move_out_clothes_from_machine.jpg`
- Nettoyage à sec: `clothes_ironed_on_wood.jpg`
- Retouche: `girl_holding_iron_clothes.jpg`

**Dimensions**: 400x300px
**Format**: JPG optimisé
**Placement**: Au-dessus du titre

### 5. FAQ Section
**Pas d'images** - Utiliser les icônes emoji

### 6. CTA Section
**Pas d'images** - Utiliser le gradient de fond

### 7. Header
**Logo**: `alphalogo.svg`
- Dimensions: 40x40px
- Format: SVG
- Placement: Côté gauche du header

### 8. Footer
**Logo**: `alphalogo.svg` (optionnel)
- Dimensions: 30x30px
- Format: SVG

---

## 📋 Checklist de copie des images

### Étape 1 : Créer les dossiers
```bash
mkdir -p public/images/{logo,heroes,services,testimonials,team,icons}
```

### Étape 2 : Copier les images du dossier pictures

**Logo**
- [ ] `alphalogo.svg` → `public/images/logo/`
- [ ] `alphalogo.png` → `public/images/logo/`

**Heroes**
- [ ] `girl_with_clothe_nobackground.png` → `public/images/heroes/`
- [ ] `guy_ironning.jpg` → `public/images/heroes/`
- [ ] `girl_holding_iron_clothes.jpg` → `public/images/heroes/`
- [ ] `girl_move_out_clothes_from_machine.jpg` → `public/images/heroes/`
- [ ] `girl_openning_machine.jpg` → `public/images/heroes/`
- [ ] `girl_sitting_near_machine.jpg` → `public/images/heroes/`
- [ ] `girl_with_clothe_backet.jpg` → `public/images/heroes/`
- [ ] `girls_holding_clothes_basket.jpg` → `public/images/heroes/`
- [ ] `grandma_littlegirl_front_washmachine.jpg` → `public/images/heroes/`
- [ ] `iron_on_clothes.jpg` → `public/images/heroes/`
- [ ] `ironed_clothes_largepic.jpg` → `public/images/heroes/`
- [ ] `laundry_machine_and_basket.jpg` → `public/images/heroes/`
- [ ] `machine_vectorpfull.png` → `public/images/heroes/`
- [ ] `pic_inside_washmachine.jpg` → `public/images/heroes/`
- [ ] `Smiling_girl.jpg` → `public/images/heroes/`
- [ ] `smily_girl_with_bags.jpg` → `public/images/heroes/`
- [ ] `clothes_ironed_on_wood.jpg` → `public/images/heroes/`
- [ ] `clothes_ironed_on_wood2.jpg` → `public/images/heroes/`
- [ ] `clothes.jpg` → `public/images/heroes/`
- [ ] `gay_giving_clothes_to_girl.jpg` → `public/images/heroes/`
- [ ] `girl_and_man_holding_clothes_orangeback.jpg` → `public/images/heroes/`
- [ ] `girl_holding_iron_clothes2.jpg` → `public/images/heroes/`
- [ ] `girl_with_clothe_redbackground.jpg` → `public/images/heroes/`
- [ ] `clothes_baskettfull_no_background.png` → `public/images/heroes/`

### Étape 3 : Optimiser les images

```bash
# Installer ImageMagick (optionnel)
# brew install imagemagick (macOS)
# choco install imagemagick (Windows)

# Convertir en WebP
mogrify -format webp public/images/**/*.jpg
mogrify -format webp public/images/**/*.png
```

---

## 🖼️ Optimisation des images

### Formats recommandés
- **Logo**: SVG (scalable)
- **Photos**: WebP (compression optimale)
- **Fallback**: JPG (compatibilité)

### Dimensions recommandées
- **Hero image**: 500x500px
- **Service card**: 400x300px
- **Testimonial**: 100x100px
- **Team member**: 200x200px
- **Logo**: 40x40px

### Compression
```bash
# Utiliser TinyPNG ou ImageOptim
# Réduire la taille sans perte de qualité
# Viser < 100KB par image
```

---

## 🎨 Utilisation dans le code

### Exemple : Hero Section
```tsx
<Image
  src="/images/heroes/girl_with_clothe_nobackground.png"
  alt="Service de blanchisserie Alpha Laundry"
  width={500}
  height={500}
  priority
  className={styles.image}
/>
```

### Exemple : Service Card
```tsx
<Image
  src="/images/heroes/girl_move_out_clothes_from_machine.jpg"
  alt="Service de laverie"
  width={400}
  height={300}
  className={styles.serviceImage}
/>
```

### Exemple : Logo
```tsx
<Image
  src="/images/logo/alphalogo.svg"
  alt="Alpha Laundry"
  width={40}
  height={40}
  priority
/>
```

---

## 📊 Statistiques des images

### Nombre total d'images disponibles
- **Logo**: 2 fichiers
- **Heroes**: 24 fichiers
- **Total**: 26 fichiers

### Taille totale estimée
- **Avant optimisation**: ~50-100 MB
- **Après optimisation**: ~10-20 MB
- **Avec WebP**: ~5-10 MB

---

## 🎯 Prochaines étapes

### Phase 2 : Images supplémentaires
- [ ] Créer des images pour les services
- [ ] Créer des images pour les témoignages
- [ ] Créer des images pour l'équipe
- [ ] Créer des icônes SVG

### Phase 3 : Optimisation
- [ ] Convertir en WebP
- [ ] Compresser les images
- [ ] Ajouter les fallbacks
- [ ] Tester la performance

### Phase 4 : Responsive
- [ ] Créer des versions mobile
- [ ] Créer des versions tablet
- [ ] Créer des versions desktop
- [ ] Utiliser srcset

---

## 🔧 Commandes utiles

### Copier les images
```bash
# Windows
xcopy "frontend\website\pictures\*" "frontend\website\public\images\heroes\" /Y

# macOS/Linux
cp frontend/website/pictures/* frontend/website/public/images/heroes/
```

### Vérifier les images
```bash
# Lister les images
ls -la public/images/

# Vérifier la taille
du -sh public/images/
```

### Optimiser les images
```bash
# Utiliser ImageMagick
mogrify -quality 85 public/images/**/*.jpg

# Utiliser ImageOptim (macOS)
open -a ImageOptim public/images/
```

---

## 📝 Notes importantes

1. **Toujours utiliser Next.js Image** - Pour l'optimisation automatique
2. **Ajouter des alt text** - Pour l'accessibilité
3. **Utiliser les dimensions correctes** - Pour éviter le CLS
4. **Optimiser les images** - Pour la performance
5. **Tester sur tous les appareils** - Pour la responsivité

---

## 🎓 Ressources

- [Next.js Image Optimization](https://nextjs.org/docs/basic-features/image-optimization)
- [Web.dev Image Optimization](https://web.dev/image-optimization/)
- [TinyPNG](https://tinypng.com/)
- [ImageOptim](https://imageoptim.com/)

---

**Dernière mise à jour** : 2024
**Version** : 1.0.0
**Statut** : 📝 À faire
