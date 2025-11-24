# Architecture Site Vitrine Alpha Laundry - Next.js

## 📁 Structure du Projet

```
frontend/website/
├── public/
│   ├── images/
│   │   ├── logo/
│   │   ├── heroes/
│   │   ├── services/
│   │   └── testimonials/
│   └── icons/
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── globals.css
│   │   ├── (pages)/
│   │   │   ├── services/
│   │   │   │   ├── page.tsx
│   │   │   │   └── layout.tsx
│   │   │   ├── pricing/
│   │   │   │   ├── page.tsx
│   │   │   │   └── layout.tsx
│   │   │   ├── blog/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [slug]/
│   │   │   │   └── layout.tsx
│   │   │   ├── about/
│   │   │   │   ├── page.tsx
│   │   │   │   └── layout.tsx
│   │   │   └── contact/
│   │   │       ├── page.tsx
│   │   │       └── layout.tsx
│   │   └── api/
│   │       ├── contact/
│   │       └── newsletter/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Navigation.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── MobileMenu.tsx
│   │   ├── sections/
│   │   │   ├── Hero.tsx
│   │   │   ├── Stats.tsx
│   │   │   ├── Features.tsx
│   │   │   ├── Problems.tsx
│   │   │   ├── Services.tsx
│   │   │   ├── WhyChooseUs.tsx
│   │   │   ├── Advantages.tsx
│   │   │   ├── Pricing.tsx
│   │   │   ├── Testimonials.tsx
│   │   │   ├── Blog.tsx
│   │   │   ├── FAQ.tsx
│   │   │   ├── CTA.tsx
│   │   │   └── Newsletter.tsx
│   │   ├── common/
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── GlassCard.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── Container.tsx
│   │   │   ├── Section.tsx
│   │   │   └── AnimatedElement.tsx
│   │   └── ui/
│   │       ├── Accordion.tsx
│   │       ├── Modal.tsx
│   │       ├─�� Tabs.tsx
│   │       └── Slider.tsx
│   ├── styles/
│   │   ├── globals.css
│   │   ├── variables.css
│   │   ├── animations.css
│   │   ├── glassmorphism.css
│   │   └── responsive.css
│   ├── lib/
│   │   ├── constants.ts
│   │   ├── utils.ts
│   │   ├── animations.ts
│   │   └── api.ts
│   ├── types/
│   │   ├── index.ts
│   │   ├── components.ts
│   │   └── api.ts
│   └── hooks/
│       ├── useIntersectionObserver.ts
│       ├── useScrollAnimation.ts
│       └── useMediaQuery.ts
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
├── package.json
└── WEBSITE_ARCHITECTURE.md
```

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
