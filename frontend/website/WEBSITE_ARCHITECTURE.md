# Architecture Site Vitrine Alpha Laundry - Next.js

## 📁 Structure du Projet

## 🎨 Design System

### Couleurs (inspirées des constants Flutter)
- **Primary**: #2563EB (Bleu signature)
- **Primary Light**: #60A5FA
- **Primary Dark**: #1E40AF
- **Accent**: #06B6D4 (Cyan)
- **Success**: #10B981 (Vert)
- **Warning**: #F59E0B (Ambre)
- **Error**: #EF4444 (Rouge)
- **Background Light**: #F8FAFC
- **Background Dark**: #0F172A
- **Surface Light**: #FFFFFF
- **Surface Dark**: #1E293B

### Typographie
- **Font**: Inter (Premium)
- **Display**: 48px, 800 weight
- **H1**: 32px, 700 weight
- **H2**: 24px, 600 weight
- **H3**: 20px, 600 weight
- **Body**: 16px, 400 weight
- **Small**: 14px, 400 weight

### Espacements
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

### Rayons
- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 20px
- xxl: 24px
- full: 999px

## 🎬 Animations

### Micro-interactions
- **Fade In**: 300ms, easeOut
- **Slide Up**: 400ms, easeOutQuart
- **Scale**: 250ms, easeInOut
- **Hover**: 150ms, easeOut

### Scroll Animations
- **Parallax**: Offset basé sur scroll
- **Reveal**: Éléments apparaissent au scroll
- **Stagger**: Délai progressif entre éléments

## 📱 Breakpoints Responsifs

- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px
- **Large Desktop**: > 1440px

## 🔧 Technologies

- **Framework**: Next.js 14+
- **Styling**: Tailwind CSS + CSS Modules
- **Animations**: Framer Motion
- **Icons**: React Icons
- **Image Optimization**: Next.js Image
- **Form Handling**: React Hook Form
- **Validation**: Zod
- **API Client**: Axios
- **State Management**: React Context / Zustand

## 📊 Pages Principales

1. **Home** - Page d'accueil avec hero, stats, services
2. **Services** - Détail des services avec pricing
3. **Pricing** - Plans tarifaires
4. **Blog** - Articles et actualités
5. **About** - À propos de l'entreprise
6. **Contact** - Formulaire de contact
7. **Landing Pages** - Pages spécifiques pour campagnes

## 🚀 Déploiement

- **Hosting**: Vercel / Netlify
- **Domain**: alphalaundry.com (à configurer)
- **CDN**: Vercel Edge Network
- **Analytics**: Vercel Analytics / Google Analytics

## 📈 Performance

- **Lighthouse Score**: 90+
- **Core Web Vitals**: Optimisés
- **Image Optimization**: WebP, lazy loading
- **Code Splitting**: Automatique avec Next.js
- **Caching**: ISR (Incremental Static Regeneration)

## 🔐 Sécurité

- **HTTPS**: Obligatoire
- **CSP**: Content Security Policy
- **CORS**: Configuré
- **Rate Limiting**: API endpoints
- **Input Validation**: Côté client et serveur

## 📝 Conventions de Code

- **Composants**: PascalCase, fonctionnels
- **Fichiers**: kebab-case
- **Variables**: camelCase
- **Constants**: UPPER_SNAKE_CASE
- **Types**: PascalCase avec préfixe T ou suffixe Type

## 🎯 Objectifs

- ✅ Design premium et moderne
- ✅ Responsive sur tous les appareils
- ✅ Animations fluides et performantes
- ✅ SEO optimisé
- ✅ Accessibilité WCAG AA+
- ✅ Performance Lighthouse 90+
- ✅ Conversion optimisée



## 📁 Structure du Projet actuellement et en detail brute


C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\.next
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\node_modules
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\out
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\public
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\.env.example
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\.env.local
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\.env.production
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\.gitignore
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\APP_LANDING_PAGES_DOCUMENTATION.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\COPYWRITING_IMPROVED.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\DEPLOYMENT_CHECKLIST.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\home_page.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\IMAGES_GUIDE.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\IMAGES_USED.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\INDEX.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\jsconfig.json
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\netlify.toml
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\next-env.d.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\next.config.js
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\package-lock.json
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\package.json
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\README.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\tailwind.config.js
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\tsconfig.json
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\tsconfig.tsbuildinfo
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\WEBSITE_ARCHITECTURE.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\website_code_pattern.md
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\lib
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\styles
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\types
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\sitemap.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\about
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\affiliate-app
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\app
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\blog
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\client-app
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\contact
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\pricing
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\services
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\about\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\about\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\affiliate-app\AffiliateApp.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\affiliate-app\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\affiliate-app\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\app\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\app\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\blog\[slug]
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\blog\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\blog\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\blog\[slug]\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\client-app\ClientApp.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\client-app\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\client-app\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\contact\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\contact\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\pricing\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\pricing\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\services\layout.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\app\(pages)\services\page.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\common
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\layout
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\common\Button.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\common\Button.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\common\GlassCard.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\common\GlassCard.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\layout\Footer.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\layout\Footer.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\layout\Header.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\layout\Header.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\About.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\About.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\AppShowcase.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\AppShowcase.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\BlogArticleDetail.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\BlogArticleDetail.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\BlogListing.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\BlogListing.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\ContactForm.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\ContactForm.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\CTA.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\CTA.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\FAQ.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\FAQ.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Hero.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Hero.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\PricingTable.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\PricingTable.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Problems.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Problems.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\RelatedArticles.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\RelatedArticles.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\ServiceGrid.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\ServiceGrid.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Services.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Services.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Stats.module.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\components\sections\Stats.tsx
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\lib\api-config.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\lib\app-pages-config.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\lib\blog-homepage-config.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\lib\blog-seo-config.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\lib\constants.ts
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\styles\globals.css
C:\Users\HP OMEN\Desktop\Codes\Important\Alpha\frontend\website\src\types\blog.ts