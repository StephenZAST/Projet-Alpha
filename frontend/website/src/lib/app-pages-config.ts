/**
 * 📱 App Pages Configuration
 * Centralized configuration for app landing pages
 * Easy to update without modifying component files
 */

// ============================================================================
// CLIENT APP CONFIGURATION
// ============================================================================

export const CLIENT_APP_CONFIG = {
  // Page metadata
  metadata: {
    title: 'Application Client | Alpha Pressing - Blanchisserie Premium',
    description: 'Découvrez l\'application mobile Alpha Pressing. Commandez, suivez et gérez vos vêtements facilement. Service de collecte gratuit, qualité garantie, prix justes.',
    keywords: 'application mobile, pressing, blanchisserie, collecte gratuit, suivi commande',
  },

  // Hero section
  hero: {
    title: 'Votre Blanchisserie Premium',
    titleHighlight: 'Dans Votre Poche',
    subtitle: 'Commandez, suivez et gérez vos vêtements avec l\'application mobile Alpha Pressing. Service de collecte gratuit, qualité garantie, prix justes.',
    primaryCta: 'Télécharger l\'App',
    secondaryCta: 'Voir la Démo',
    stats: [
      { value: '500+', label: 'Clients actifs' },
      { value: '4.8★', label: 'Note moyenne' },
      { value: '24/7', label: 'Support client' },
    ],
  },

  // Features
  features: [
    {
      title: 'Commandes Faciles',
      description: 'Créez une commande en quelques clics. Sélectionnez vos articles, choisissez le service et confirmez. C\'est aussi simple que ça.',
      icon: '📱',
      items: [
        'Sélection d\'articles intuitive',
        'Calcul de prix en temps réel',
        'Sauvegarde de brouillons',
      ],
    },
    {
      title: 'Suivi en Temps Réel',
      description: 'Suivez votre commande à chaque étape. Collecte, traitement, livraison - vous êtes toujours informé.',
      icon: '📍',
      items: [
        'Notifications instantanées',
        'Localisation GPS du livreur',
        'Historique complet',
      ],
    },
    {
      title: 'Gestion des Adresses',
      description: 'Enregistrez plusieurs adresses de collecte et livraison. Sélectionnez rapidement votre adresse préférée.',
      icon: '📍',
      items: [
        'Adresses sauvegardées',
        'Localisation GPS',
        'Adresse par défaut',
      ],
    },
    {
      title: 'Points de Fidélité',
      description: 'Gagnez des points à chaque commande et convertissez-les en réductions. Plus vous commandez, plus vous économisez.',
      icon: '🎁',
      items: [
        '1 point par 0.1€ dépensé',
        'Récompenses exclusives',
        'Paliers de fidélité',
      ],
    },
    {
      title: 'Collecte Gratuite',
      description: 'Nous venons chercher vos vêtements à domicile. Pas de frais cachés, pas de surprise à la livraison.',
      icon: '⏱️',
      items: [
        'Collecte à domicile',
        'Horaires flexibles',
        'Livraison gratuite',
      ],
    },
    {
      title: 'Support 24/7',
      description: 'Une question ? Un problème ? Notre équipe est toujours disponible pour vous aider rapidement.',
      icon: '📱',
      items: [
        'Chat en direct',
        'Email support',
        'Téléphone',
      ],
    },
  ],

  // How it works
  steps: [
    {
      number: 1,
      title: 'Créer une Commande',
      description: 'Ouvrez l\'app, sélectionnez vos articles et le service désiré. Le prix s\'affiche instantanément.',
    },
    {
      number: 2,
      title: 'Planifier la Collecte',
      description: 'Choisissez votre adresse et l\'heure de collecte. Notre livreur viendra chercher vos vêtements.',
    },
    {
      number: 3,
      title: 'Suivi en Temps Réel',
      description: 'Recevez des notifications à chaque étape. Collecte, traitement, prêt pour livraison.',
    },
    {
      number: 4,
      title: 'Livraison à Domicile',
      description: 'Vos vêtements arrivent impeccables à votre porte. Payez et profitez de votre service premium.',
    },
  ],

  // Benefits
  benefits: [
    { icon: '✨', title: 'Qualité Garantie', description: 'Nettoyage professionnel avec les meilleures techniques' },
    { icon: '💰', title: 'Prix Justes', description: 'Tarification transparente sans frais cachés' },
    { icon: '🚚', title: 'Collecte Gratuite', description: 'Nous venons chercher vos vêtements à domicile' },
    { icon: '⏱️', title: 'Rapide & Fiable', description: 'Délais respectés, service professionnel' },
    { icon: '🎁', title: 'Points de Fidélité', description: 'Gagnez des points et obtenez des réductions' },
    { icon: '📱', title: 'App Intuitive', description: 'Interface simple et facile à utiliser' },
  ],

  // Testimonials
  testimonials: [
    {
      rating: 5,
      text: 'L\'application est super facile à utiliser. J\'ai commandé en 2 minutes et le service était impeccable. Je recommande vivement!',
      author: 'Marie Dupont',
      tenure: 'Client depuis 6 mois',
      avatar: 'M',
    },
    {
      rating: 5,
      text: 'Enfin un service de pressing qui respecte les délais et la qualité. Les points de fidélité sont un vrai plus!',
      author: 'Jean Martin',
      tenure: 'Client depuis 1 an',
      avatar: 'J',
    },
    {
      rating: 5,
      text: 'Le suivi en temps réel est génial. Je sais exactement où est mon livreur et quand il arrive. Service professionnel!',
      author: 'Sophie Bernard',
      tenure: 'Client depuis 3 mois',
      avatar: 'S',
    },
  ],

  // Final CTA
  finalCta: {
    title: 'Prêt à Essayer?',
    subtitle: 'Téléchargez l\'application et bénéficiez d\'une réduction de 10% sur votre première commande',
    primaryCta: 'Télécharger Maintenant',
    secondaryCta: 'En Savoir Plus',
    note: 'Disponible sur iOS et Android • Gratuit • Aucune inscription requise',
  },

  // App store links
  appStores: {
    ios: 'https://apps.apple.com/app/alpha-pressing',
    android: 'https://play.google.com/store/apps/details?id=com.alphapressing.client',
  },
};

// ============================================================================
// AFFILIATE APP CONFIGURATION
// ============================================================================

export const AFFILIATE_APP_CONFIG = {
  // Page metadata
  metadata: {
    title: 'Programme Affiliate | Alpha Pressing - Gagnez de l\'Argent',
    description: 'Rejoignez le programme d\'affiliation Alpha Pressing. Gagnez jusqu\'à 20% de commission sur chaque client référé. Paiements rapides, support dédié.',
    keywords: 'affiliation, programme partenaire, commission, gagner argent, marketing',
  },

  // Hero section
  hero: {
    title: 'Gagnez de l\'Argent',
    titleHighlight: 'En Recommandant',
    subtitle: 'Rejoignez le programme d\'affiliation Alpha Pressing et gagnez des commissions généreuses sur chaque client que vous référez. Pas de limite, pas de plafond.',
    primaryCta: 'Rejoindre le Programme',
    secondaryCta: 'Voir les Détails',
    highlights: [
      {
        icon: '📈',
        title: 'Commissions Élevées',
        description: 'Jusqu\'à 20% de commission par client',
      },
      {
        icon: '👥',
        title: 'Pas de Limite',
        description: 'Gagnez autant que vous le souhaitez',
      },
      {
        icon: '💵',
        title: 'Paiements Rapides',
        description: 'Retraits hebdomadaires ou mensuels',
      },
    ],
  },

  // Commission levels
  commissionLevels: [
    {
      name: 'BRONZE',
      displayName: 'Niveau Bronze',
      commission: '10%',
      minEarnings: '0€',
      description: 'Parfait pour commencer votre parcours d\'affiliation',
      color: '#CD7F32',
    },
    {
      name: 'SILVER',
      displayName: 'Niveau Argent',
      commission: '15%',
      minEarnings: '1000€',
      description: 'Débloquez des avantages exclusifs et un support prioritaire',
      color: '#C0C0C0',
    },
    {
      name: 'GOLD',
      displayName: 'Niveau Or',
      commission: '18%',
      minEarnings: '5000€',
      description: 'Accès VIP, bonus mensuels et support dédié',
      color: '#FFD700',
      featured: true,
    },
    {
      name: 'PLATINUM',
      displayName: 'Niveau Platine',
      commission: '20%',
      minEarnings: '10000€',
      description: 'Statut d\'élite avec avantages exceptionnels',
      color: '#E5E4E2',
    },
  ],

  // Features
  features: [
    {
      title: 'Dashboard Complet',
      description: 'Visualisez vos statistiques en temps réel. Commissions, clients, revenus - tout en un coup d\'œil.',
      icon: '📊',
      items: [
        'Statistiques en temps réel',
        'Graphiques de performance',
        'Historique complet',
      ],
    },
    {
      title: 'Code de Référence Unique',
      description: 'Obtenez un code unique à partager avec vos contacts. Chaque client qui l\'utilise vous rapporte une commission.',
      icon: '🔗',
      items: [
        'Code personnalisé',
        'Lien de partage direct',
        'QR code généré',
      ],
    },
    {
      title: 'Suivi des Clients',
      description: 'Suivez tous vos clients référés. Voyez leurs commandes, leurs dépenses et vos commissions associées.',
      icon: '👥',
      items: [
        'Liste des clients',
        'Historique des commandes',
        'Commissions par client',
      ],
    },
    {
      title: 'Gestion des Retraits',
      description: 'Demandez un retrait quand vous le souhaitez. Paiements rapides et sécurisés directement sur votre compte.',
      icon: '💰',
      items: [
        'Retraits illimités',
        'Paiements sécurisés',
        'Historique des paiements',
      ],
    },
    {
      title: 'Notifications Instantanées',
      description: 'Recevez des notifications pour chaque nouvelle commande de vos clients, chaque commission gagnée et chaque retrait approuvé.',
      icon: '🔔',
      items: [
        'Notifications push',
        'Alertes de commission',
        'Mises à jour de statut',
      ],
    },
    {
      title: 'Support Dédié',
      description: 'Une équipe dédiée pour vous aider. Questions, problèmes, conseils - nous sommes toujours là pour vous.',
      icon: '🎧',
      items: [
        'Chat en direct',
        'Email support',
        'Ressources d\'aide',
      ],
    },
  ],

  // How to earn
  steps: [
    {
      number: 1,
      title: 'Rejoindre le Programme',
      description: 'Inscrivez-vous gratuitement et obtenez votre code de référence unique. Aucune condition, aucun frais.',
    },
    {
      number: 2,
      title: 'Partager Votre Code',
      description: 'Partagez votre code avec vos amis, famille et contacts. Via SMS, email, réseaux sociaux - comme vous le souhaitez.',
    },
    {
      number: 3,
      title: 'Gagner des Commissions',
      description: 'Chaque client qui utilise votre code vous rapporte une commission. Plus ils commandent, plus vous gagnez.',
    },
  ],

  // Earning examples
  earningExamples: [
    {
      title: 'Scénario 1: Débutant',
      clients: 5,
      orderAverage: '50€',
      ordersPerMonth: 2,
      commission: '10%',
      monthlyEarnings: '50€',
    },
    {
      title: 'Scénario 2: Intermédiaire',
      clients: 20,
      orderAverage: '50€',
      ordersPerMonth: 2,
      commission: '15%',
      monthlyEarnings: '300€',
    },
    {
      title: 'Scénario 3: Expert',
      clients: 50,
      orderAverage: '50€',
      ordersPerMonth: 2,
      commission: '18%',
      monthlyEarnings: '900€',
      featured: true,
    },
  ],

  // Benefits
  benefits: [
    { icon: '💎', title: 'Commissions Élevées', description: 'Jusqu\'à 20% de commission par client référé' },
    { icon: '📈', title: 'Croissance Illimitée', description: 'Pas de plafond de commission, gagnez autant que vous le souhaitez' },
    { icon: '🎁', title: 'Bonus Mensuels', description: 'Bonus supplémentaires pour les meilleurs affiliés' },
    { icon: '⚡', title: 'Paiements Rapides', description: 'Retraits hebdomadaires ou mensuels sans délai' },
    { icon: '🤝', title: 'Support Dédié', description: 'Équipe dédiée pour vous aider à réussir' },
    { icon: '🌟', title: 'Outils Marketing', description: 'Ressources et outils pour promouvoir votre code' },
  ],

  // FAQ
  faq: [
    {
      question: 'Combien coûte l\'inscription?',
      answer: 'L\'inscription est complètement gratuite. Aucun frais, aucune condition.',
    },
    {
      question: 'Quand reçois-je mes commissions?',
      answer: 'Les commissions sont calculées en temps réel et vous pouvez les retirer quand vous le souhaitez.',
    },
    {
      question: 'Y a-t-il un minimum de retrait?',
      answer: 'Oui, le minimum de retrait est de 5000 FCFA pour assurer des frais de transaction raisonnables.',
    },
    {
      question: 'Comment puis-je augmenter ma commission?',
      answer: 'Votre commission augmente automatiquement selon votre niveau d\'affiliation basé sur vos gains.',
    },
    {
      question: 'Puis-je créer des sous-affiliés?',
      answer: 'Oui! Vous pouvez créer des sous-affiliés et gagner une commission sur leurs commissions.',
    },
    {
      question: 'Comment puis-je promouvoir mon code?',
      answer: 'Vous pouvez partager votre code via SMS, email, réseaux sociaux ou en personne.',
    },
  ],

  // Final CTA
  finalCta: {
    title: 'Prêt à Commencer?',
    subtitle: 'Rejoignez des centaines d\'affiliés qui gagnent déjà avec Alpha Pressing',
    primaryCta: 'Rejoindre Maintenant',
    secondaryCta: 'Contacter le Support',
    note: 'Gratuit • Pas de frais cachés • Support 24/7',
  },

  // App store links
  appStores: {
    ios: 'https://apps.apple.com/app/alpha-affiliate',
    android: 'https://play.google.com/store/apps/details?id=com.alphapressing.affiliate',
  },

  // Signup link
  signupLink: '/affiliate-signup',
};

// ============================================================================
// SHARED CONFIGURATION
// ============================================================================

export const APP_PAGES_SHARED = {
  // Image paths
  images: {
    clientAppHome: '/images/app_mockups/client app home page.png',
    clientAppAddress: '/images/app_mockups/client app adress screen.png',
    clientAppRecap: '/images/app_mockups/client app order recap screen.png',
    affiliateHome: '/images/app_mockups/affiliate home page.png',
    affiliateCustomer: '/images/app_mockups/Affiliate customer screen.png',
    affiliateLogin: '/images/app_mockups/affiliate login page.png',
  },

  // Animation settings
  animations: {
    duration: {
      fast: 150,
      medium: 250,
      slow: 350,
    },
    timing: {
      easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
      easeOut: 'cubic-bezier(0, 0, 0.2, 1)',
      easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
      easeOutQuart: 'cubic-bezier(0.165, 0.84, 0.44, 1)',
    },
  },

  // Responsive breakpoints
  breakpoints: {
    mobile: 640,
    tablet: 768,
    desktop: 1024,
    large: 1280,
  },
};

// ============================================================================
// EXPORT HELPER FUNCTIONS
// ============================================================================

/**
 * Get client app configuration
 */
export function getClientAppConfig() {
  return CLIENT_APP_CONFIG;
}

/**
 * Get affiliate app configuration
 */
export function getAffiliateAppConfig() {
  return AFFILIATE_APP_CONFIG;
}

/**
 * Get shared configuration
 */
export function getSharedConfig() {
  return APP_PAGES_SHARED;
}

/**
 * Get all app pages configuration
 */
export function getAllAppPagesConfig() {
  return {
    clientApp: CLIENT_APP_CONFIG,
    affiliateApp: AFFILIATE_APP_CONFIG,
    shared: APP_PAGES_SHARED,
  };
}
