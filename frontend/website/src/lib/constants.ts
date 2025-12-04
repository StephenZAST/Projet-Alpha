/**
 * 🎨 Design System Constants - Alpha Laundry Website
 * Inspiré des constants Flutter pour cohérence globale
 */

// =============================================================================
// 🌈 COULEURS SIGNATURE ALPHA
// =============================================================================

export const COLORS = {
  // Primaires
  primary: '#2563EB',
  primaryLight: '#60A5FA',
  primaryDark: '#1E40AF',

  // Accents
  accent: '#06B6D4',
  accentLight: '#7DD3FC',
  accentDark: '#0369A1',

  // Secondaires
  secondary: '#8B5CF6',
  secondaryLight: '#EDE9FE',
  secondaryDark: '#6D28D9',

  // Statuts
  success: '#10B981',
  successLight: '#D1FAE5',
  successDark: '#065F46',
  warning: '#F59E0B',
  warningLight: '#FEF3C7',
  warningDark: '#B45309',
  error: '#EF4444',
  errorLight: '#FEE2E2',
  errorDark: '#B91C1C',
  info: '#3B82F6',
  infoLight: '#DBEAFE',
  infoDark: '#1D4ED8',

  // Palette Étendue
  violet: '#8B5CF6',
  pink: '#EC4899',
  teal: '#14B8A6',
  orange: '#F97316',
  rose: '#F43F5E',
  lime: '#84CC16',
  cyan: '#06B6D4',

  // Grays
  white: '#FFFFFF',
  gray50: '#F8FAFC',
  gray100: '#F1F5F9',
  gray200: '#E2E8F0',
  gray300: '#CBD5E1',
  gray400: '#94A3B8',
  gray500: '#64748B',
  gray600: '#475569',
  gray700: '#334155',
  gray800: '#1E293B',
  gray900: '#0F172A',

  // Backgrounds
  bgLight: '#F8FAFC',
  bgDark: '#0F172A',
  surfaceLight: '#FFFFFF',
  surfaceDark: '#1E293B',

  // Texte
  textPrimaryLight: '#0F172A',
  textSecondaryLight: '#475569',
  textTertiaryLight: '#94A3B8',
  textPrimaryDark: '#F8FAFC',
  textSecondaryDark: '#CBD5E1',
  textTertiaryDark: '#94A3B8',

  // Glassmorphism
  glassLight: 'rgba(255, 255, 255, 0.95)',
  glassDark: 'rgba(30, 41, 59, 0.9)',
  glassBorder: 'rgba(255, 255, 255, 0.3)',
} as const;

// =============================================================================
// 📏 ESPACEMENTS
// =============================================================================

export const SPACING = {
  xs: '4px',
  sm: '8px',
  md: '16px',
  lg: '24px',
  xl: '32px',
  xxl: '48px',
  xxxl: '64px',
} as const;

// =============================================================================
// 🔘 RAYONS
// =============================================================================

export const RADIUS = {
  xs: '4px',
  sm: '8px',
  md: '12px',
  lg: '16px',
  xl: '20px',
  xxl: '24px',
  full: '999px',
} as const;

// =============================================================================
// 🎬 ANIMATIONS
// =============================================================================

export const ANIMATIONS = {
  durations: {
    instant: '100ms',
    fast: '150ms',
    medium: '250ms',
    slow: '350ms',
    extraSlow: '500ms',
  },
  timings: {
    easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
    easeOut: 'cubic-bezier(0, 0, 0.2, 1)',
    easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
    easeOutQuart: 'cubic-bezier(0.165, 0.84, 0.44, 1)',
    easeOutExpo: 'cubic-bezier(0.16, 1, 0.3, 1)',
  },
} as const;

// =============================================================================
// 📱 BREAKPOINTS
// =============================================================================

export const BREAKPOINTS = {
  mobile: '640px',
  tablet: '1024px',
  desktop: '1440px',
} as const;

export const BREAKPOINTS_PX = {
  mobile: 640,
  tablet: 1024,
  desktop: 1440,
} as const;

// =============================================================================
// 🎯 TYPOGRAPHIE
// =============================================================================

export const TYPOGRAPHY = {
  fontFamily: {
    primary: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
  },
  sizes: {
    display: '48px',
    h1: '32px',
    h2: '24px',
    h3: '20px',
    h4: '18px',
    bodyLarge: '18px',
    bodyMedium: '16px',
    bodySmall: '14px',
    labelLarge: '16px',
    labelMedium: '14px',
    labelSmall: '12px',
    caption: '12px',
  },
  weights: {
    light: 300,
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
    extrabold: 800,
  },
} as const;

// =============================================================================
// 🌐 NAVIGATION
// =============================================================================

export const NAVIGATION = [
  { label: 'Accueil', href: '/' },
  { label: 'Services', href: '/services' },
  { label: 'Tarifs', href: '/pricing' },
  { label: 'Blog', href: '/blog' },
  { label: 'À propos', href: '/about' },
  { label: 'Contact', href: '/contact' },
] as const;

export const MOBILE_NAVIGATION = [
  { label: 'Accueil', href: '/' },
  { label: 'Services', href: '/services' },
  { label: 'Tarifs', href: '/pricing' },
  { label: 'Blog', href: '/blog' },
  { label: 'À propos', href: '/about' },
  { label: 'Contact', href: '/contact' },
  { label: 'Connexion', href: '/login' },
  { label: 'Inscription', href: '/register' },
] as const;

// =============================================================================
// 🔗 LIENS EXTERNES
// =============================================================================

export const EXTERNAL_LINKS = {
  clientApp: 'https://690cfd42ee6cc00008fe21ce--alphalaundryclient.netlify.app/',
  adminApp: 'https://68f95b5655b078000891a633--alphalaundry.netlify.app/',
  deliveryApp: 'https://68fac646f8312f00079c8b17--alphalaundrydelivers.netlify.app/',
  affiliateApp: 'https://68fac0ae8f30bef299f38200--affiliatealpha.netlify.app/',
  phone: '+226 67 80 16 68',
  phone2: '+226 54 69 12 41',
  email: 'contact@alphalaundry.com',
} as const;

// =============================================================================
// 🦸 HERO CAROUSEL SLIDES
// =============================================================================

export const HERO_SLIDES = [
  {
    id: 'slide-1',
    image: '/images/AdobeStock-XIZWwceNjttt.jpg',
    title: 'Blanchisserie Premium Sans Compromis',
    subtitle: 'L\'immense majorité des gens ne sont pas satisfaits des pressings traditionnels. Qualité médiocre, prix exorbitants, mauvais rapport qualité-prix. Nous sommes là pour changer cela.',
    cta1: 'Réserver une Collecte',
    cta2: '+226 67 80 16 68',
    ctaLink: EXTERNAL_LINKS.clientApp,
    ctaPhone: EXTERNAL_LINKS.phone,
  },
  {
    id: 'slide-2',
    image: '/images/grandma_littlegirl_front_washmachine.jpg',
    title: 'Service Haut de Gamme Pour Tous',
    subtitle: 'Nous apportons le maximum de valeur ajoutée à chaque service. Satisfaction garantie, qualité exceptionnelle, prix justes. Votre confiance est notre priorité.',
    cta1: 'Découvrir Nos Services',
    cta2: '+226 67 80 16 68',
    ctaLink: EXTERNAL_LINKS.clientApp,
    ctaPhone: EXTERNAL_LINKS.phone,
  },
] as const;

// =============================================================================
// 📊 STATISTIQUES
// =============================================================================

export const STATS = [
  { value: '500+', label: 'Clients satisfaits' },
  { value: '10+', label: 'Ans d\'expertise' },
  { value: '100%', label: 'Satisfaction garantie' },
] as const;

// =============================================================================
// 🎯 SERVICES
// =============================================================================

export const SERVICES = [
  {
    id: 'laundry',
    title: 'Laverie et Repassage Soigné',
    description: 'Notre laverie utilise les meilleures technologies pour garantir un nettoyage de haute qualité de vos vêtements.',
    icon: '🧺',
    color: 'primary',
  },
  {
    id: 'drycleaning',
    title: 'Nettoyage à sec',
    description: 'Nous offrons un nettoyage à sec rapide et efficace qui élimine les impuretés et les odeurs sans abîmer les tissus.',
    icon: '✨',
    color: 'accent',
  },
  {
    id: 'repair',
    title: 'Retouche et Détachement',
    description: 'Nous réalisons des retouches et des détachements de vêtements de haute qualité.',
    icon: '🔧',
    color: 'secondary',
  },
] as const;

// =============================================================================
// 💎 AVANTAGES SUPPLÉMENTAIRES
// =============================================================================

export const ADDITIONAL_SERVICES = [
  { title: 'Amidonnage', description: 'Pour donner à vos vêtements une forme et un style uniques' },
  { title: 'Teinture', description: 'Pour rendre vos vêtements plus beaux et plus résistants' },
  { title: 'Détachement', description: 'Pour retirer les taches et les impuretés sans endommager les tissus' },
  { title: 'Désodorisation', description: 'Pour éliminer les odeurs et les mauvaises haleines' },
  { title: 'Collecte et livraison gratuit', description: 'Pour vous faciliter la vie' },
] as const;

// =============================================================================
// 🎁 AVANTAGES PRINCIPAUX
// =============================================================================

export const MAIN_ADVANTAGES = [
  {
    title: 'Qualité et Personnalisation',
    description: 'Nous garantissons des produits soigneusement sélectionnés pour préserver l\'intégrité de vos vêtements, tout en vous offrant un service adapté à vos besoins spécifiques.',
    icon: '⭐',
  },
  {
    title: 'Confort et Gain de Temps',
    description: 'Profitez de la commodité de notre service de collecte et de livraison à domicile. Votre linge est soigneusement repassé et prêt à porter, vous permettant de gagner du temps précieux.',
    icon: '⏱️',
  },
  {
    title: 'Tarifs Avantageux et Avantages Exclusifs',
    description: 'Nous garantissons des produits soigneusement sélectionnés pour préserver l\'intégrité de vos vêtements, tout en vous offrant un service adapté à vos besoins spécifiques.',
    icon: '💰',
  },
] as const;

// =============================================================================
// ❓ FAQ
// =============================================================================

export const FAQ = [
  {
    question: 'Quels sont les services que vous proposez ?',
    answer: 'Nous proposons une gamme complète de services pour vous aider à garder vos vêtements propres et en bon état, notamment la laverie, le pressing, la teinture, le teillage, le repassage et des services à valeur ajoutée tels que la location de vêtements de créateurs et l\'emballage cadeau haut de gamme.',
  },
  {
    question: 'Comment puis-je réserver un service ?',
    answer: 'Vous pouvez réserver un service en ligne via notre site web ou en appelant notre ligne directe. Nous sommes également disponibles pour prendre rendez-vous en personne pour discuter de vos besoins.',
  },
  {
    question: 'Quels sont les horaires d\'ouverture ?',
    answer: 'Nous sommes ouverts du lundi au samedi de 9h à 19h et le dimanche de 10h à 18h. Nous sommes fermés les jours fériés.',
  },
  {
    question: 'Comment puis-je savoir si mes vêtements sont prêts ?',
    answer: 'Nous vous informerons par email ou par téléphone lorsque vos vêtements sont prêts à être récupérés.',
  },
  {
    question: 'Puis-je choisir le type de savon et de détergent ?',
    answer: 'Oui, nous proposons différents types de savon et de détergent pour vous permettre de choisir celui qui convient le mieux à vos besoins.',
  },
  {
    question: 'Quels types de vêtements pouvez-vous laver ?',
    answer: 'Nous pouvons laver tous types de vêtements, y compris les vêtements délicats, les vêtements en coton, en laine, en soie, etc.',
  },
] as const;

// =============================================================================
// 🎯 PROBLÈMES RÉSOLUS
// =============================================================================

export const PROBLEMS = [
  {
    title: 'Vêtements abîmés',
    description: 'Taches persistantes, couleurs qui déteignent. Ces problèmes rendent vos vêtements inutilisables, nécessitant des techniques de nettoyage spécifiques.',
    icon: '👕',
  },
  {
    title: 'Délais non respectés',
    description: 'Besoin urgent de récupérer des vêtements en temps voulu ? Les retards peuvent causer des désagréments lors d\'événements importants.',
    icon: '⏰',
  },
  {
    title: 'Qualité médiocre',
    description: 'Vêtements mal repassés, froissés ou mal nettoyés. Un nettoyage de mauvaise qualité compromet l\'apparence de vos vêtements.',
    icon: '❌',
  },
  {
    title: 'Prix exorbitants',
    description: 'Coûts élevés pour une qualité qui ne les justifie pas. Un tarif injustifié peut engendrer frustration et sentiment de gaspillage.',
    icon: '💸',
  },
  {
    title: 'Manque de transparence',
    description: 'Tarifs cachés ou changements de prix inattendus. Une communication claire sur les coûts est essentielle pour éviter les surprises.',
    icon: '🔍',
  },
  {
    title: 'Service client insuffisant',
    description: 'Difficulté à joindre le service, manque de réactivité. Un service client peu réactif devient frustrant en cas de questions urgentes.',
    icon: '📞',
  },
  {
    title: 'Perte d\'articles',
    description: 'Vêtements égarés ou non retrouvés après nettoyage. La perte d\'articles peut engendrer inquiétude et frustration.',
    icon: '🚨',
  },
  {
    title: 'Allergies et irritations',
    description: 'Produits chimiques utilisés provoquant des réactions cutanées. Des produits agressifs peuvent nuire à votre santé et à votre bien-être.',
    icon: '⚠️',
  },
  {
    title: 'Incohérence des résultats',
    description: 'Nettoyages inégaux d\'une fois à l\'autre. Des résultats variables nuisent à la confiance dans le service.',
    icon: '📊',
  },
] as const;
