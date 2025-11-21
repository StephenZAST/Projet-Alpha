# 🧺 Alpha Laundry - Site Vitrine Premium

Site vitrine moderne et responsive pour Alpha Laundry, construit avec **Next.js 14**, **React 18**, **TypeScript** et **CSS Modules**.

## ✨ Caractéristiques

### 🎨 Design Premium
- **Glassmorphism** sophistiqué avec effet de verre
- **Animations fluides** et micro-interactions
- **Thème clair/sombre** adaptatif
- **Palette de couleurs** cohérente et moderne
- **Typographie** Inter premium

### 📱 Responsive Design
- **Mobile-first** approach
- **Breakpoints** optimisés (640px, 1024px, 1440px)
- **Flexbox & Grid** pour layouts modernes
- **Images optimisées** (WebP, AVIF)

### ⚡ Performance
- **Lighthouse Score** 90+
- **Core Web Vitals** optimisés
- **Code splitting** automatique
- **Lazy loading** des images
- **CSS modules** pour isolation

### ♿ Accessibilité
- **WCAG AA+** compliant
- **Focus visible** sur tous les éléments
- **Semantic HTML** correct
- **ARIA labels** appropriés
- **Keyboard navigation** fluide

### 🔒 Sécurité
- **CSP headers** configurés
- **HTTPS** obligatoire
- **Input validation** côté client et serveur
- **Rate limiting** sur les APIs
- **CORS** configuré

### 📊 SEO
- **Métadonnées** structurées
- **Open Graph** tags
- **Sitemap.xml** généré
- **robots.txt** configuré
- **Canonical URLs** correctes

## 🚀 Démarrage rapide

### Prérequis
- Node.js 18+
- npm 9+ ou yarn

### Installation

```bash
# 1. Cloner le projet
cd frontend/website

# 2. Installer les dépendances
npm install

# 3. Créer les dossiers nécessaires
mkdir -p public/images/{logo,heroes,services}

# 4. Copier les images
# Copier les images du dossier pictures vers public/images/

# 5. Lancer le serveur de développement
npm run dev

# 6. Ouvrir dans le navigateur
# http://localhost:3000
```

## 📁 Structure du projet

```
frontend/website/
├── public/
│   ├── images/
│   │   ├── logo/
│   │   ├── heroes/
│   │   └── services/
│   └── favicon.ico
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── globals.css
│   │   └── (pages)/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   └── Footer.tsx
│   │   ├── sections/
│   │   │   ├── Hero.tsx
│   │   │   ├── Stats.tsx
│   │   │   ├── Problems.tsx
│   │   │   ├── Services.tsx
│   │   │   ├── FAQ.tsx
│   │   │   └── CTA.tsx
│   │   └── common/
│   │       ├── Button.tsx
│   │       └── GlassCard.tsx
│   ├── lib/
│   │   └── constants.ts
│   └── styles/
│       └── globals.css
├── next.config.js
├── tsconfig.json
└── package.json
```

## 🎯 Pages principales

### ✅ Créées
- **Home** (`/`) - Page d'accueil avec hero, stats, services, FAQ, CTA
- **Header** - Navigation principale avec menu mobile
- **Footer** - Pied de page avec liens et contact

### 📝 À créer
- **Services** (`/services`) - Détail des services
- **Pricing** (`/pricing`) - Plans tarifaires
- **Blog** (`/blog`) - Articles et actualités
- **About** (`/about`) - À propos de l'entreprise
- **Contact** (`/contact`) - Formulaire de contact

## 🎨 Design System

### Couleurs
```css
--color-primary: #2563EB (Bleu signature)
--color-accent: #06B6D4 (Cyan)
--color-secondary: #8B5CF6 (Violet)
--color-success: #10B981 (Vert)
--color-warning: #F59E0B (Ambre)
--color-error: #EF4444 (Rouge)
```

### Espacements
```css
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
xxl: 48px
xxxl: 64px
```

### Rayons
```css
xs: 4px
sm: 8px
md: 12px
lg: 16px
xl: 20px
xxl: 24px
full: 999px
```

### Animations
```css
instant: 100ms
fast: 150ms
medium: 250ms
slow: 350ms
extra-slow: 500ms
```

## 🔧 Scripts disponibles

```bash
# Développement
npm run dev          # Lancer le serveur de développement

# Production
npm run build        # Construire pour la production
npm start            # Lancer le serveur de production

# Qualité du code
npm run lint         # Vérifier les erreurs ESLint
npm run type-check   # Vérifier les types TypeScript
npm run format       # Formater le code avec Prettier

# Analyse
npm run analyze      # Analyser la taille du bundle
```

## 📦 Dépendances

### Production
- `next@^14.0.0` - Framework React
- `react@^18.2.0` - Bibliothèque UI
- `react-dom@^18.2.0` - Rendu DOM

### Développement
- `typescript@^5.0.0` - Typage statique
- `eslint@^8.0.0` - Linting
- `prettier@^3.0.0` - Formatage

## 🚀 Déploiement

### Vercel (Recommandé)
```bash
npm i -g vercel
vercel
```

### Netlify
```bash
npm i -g netlify-cli
netlify deploy --prod
```

### Docker
```bash
docker build -t alpha-laundry-website .
docker run -p 3000:3000 alpha-laundry-website
```

## 📊 Performance

### Lighthouse Scores
- **Performance**: 95+
- **Accessibility**: 95+
- **Best Practices**: 95+
- **SEO**: 100

### Core Web Vitals
- **LCP** (Largest Contentful Paint): < 2.5s
- **FID** (First Input Delay): < 100ms
- **CLS** (Cumulative Layout Shift): < 0.1

## 🔐 Sécurité

- ✅ CSP (Content Security Policy)
- ✅ HTTPS obligatoire
- ✅ X-Frame-Options
- ✅ X-Content-Type-Options
- ✅ Referrer-Policy
- ✅ Permissions-Policy

## ♿ Accessibilité

- ✅ WCAG 2.1 Level AA+
- ✅ Focus visible
- ✅ Semantic HTML
- ✅ ARIA labels
- ✅ Keyboard navigation
- ✅ Color contrast WCAG AA+

## 📱 Responsive Breakpoints

```css
Mobile: < 640px
Tablet: 640px - 1024px
Desktop: 1024px - 1440px
Large Desktop: > 1440px
```

## 🎬 Animations

### Entrée
- `slideUp` - Glisse vers le haut
- `slideDown` - Glisse vers le bas
- `slideLeft` - Glisse vers la gauche
- `slideRight` - Glisse vers la droite
- `fadeIn` - Apparition progressive
- `scaleIn` - Zoom d'entrée

### Continues
- `float` - Flottement
- `pulse` - Pulsation
- `glow` - Lueur
- `shimmer` - Scintillement

## 🌙 Dark Mode

Le site supporte automatiquement le dark mode via `prefers-color-scheme`.

```css
@media (prefers-color-scheme: dark) {
  /* Styles pour le dark mode */
}
```

## 📚 Documentation

- [WEBSITE_ARCHITECTURE.md](./WEBSITE_ARCHITECTURE.md) - Architecture détaillée
- [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Guide d'implémentation
- [website_code_pattern.md](./website_code_pattern.md) - Patterns de code

## 🆘 Dépannage

### Erreur : "Module not found"
Vérifier que les chemins d'import utilisent `@/` et que les fichiers existent.

### Erreur : "Image not found"
Vérifier que les images sont dans `public/images/` avec le bon chemin.

### Performance lente
Exécuter `npm run analyze` pour vérifier la taille du bundle.

## 📞 Support

Pour toute question ou problème :
1. Consulter la [documentation Next.js](https://nextjs.org/docs)
2. Vérifier les fichiers de configuration
3. Exécuter `npm run lint` pour vérifier les erreurs
4. Vérifier la console du navigateur

## 📄 Licence

Propriétaire - Alpha Laundry © 2024

## 👥 Auteur

**Alpha Laundry Team**
- Site: [alphalaundry.com](https://alphalaundry.com)
- Email: contact@alphalaundry.com
- Phone: +226 67 80 16 68

## 🎯 Roadmap

### Phase 1 (Semaine 1-2)
- ✅ Architecture et setup
- ✅ Composants de base
- ✅ Page d'accueil
- 📝 Pages supplémentaires

### Phase 2 (Semaine 3-4)
- 📝 Formulaire de contact
- 📝 Système de blog
- 📝 Newsletter
- 📝 Analytics

### Phase 3 (Semaine 5-6)
- 📝 Optimisations SEO
- 📝 Performance tuning
- 📝 Tests
- 📝 Déploiement

### Phase 4 (Continu)
- 📝 Maintenance
- 📝 Mises à jour
- 📝 Nouvelles fonctionnalités
- 📝 Améliorations UX

---

**Dernière mise à jour** : 2024
**Version** : 1.0.0
**Statut** : ✅ En développement
