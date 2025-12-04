/**
 * 🔍 Blog SEO Configuration - Mots-clés et stratégie SEO optimisée
 */

export const BLOG_SEO_CONFIG = {
  // Mots-clés principaux par catégorie
  keywords: {
    laundry: [
      'blanchisserie premium',
      'service de blanchisserie',
      'blanchisserie professionnel',
      'laverie haut de gamme',
      'nettoyage de vêtements',
      'service de pressing',
      'repassage professionnel',
      'collecte et livraison',
      'blanchisserie écologique',
      'nettoyage textile'
    ],
    drycleaning: [
      'nettoyage à sec',
      'nettoyage à sec professionnel',
      'pressing',
      'pressing premium',
      'nettoyage à sec écologique',
      'nettoyage vêtements délicats',
      'nettoyage de luxe',
      'service de pressing',
      'nettoyage textile',
      'détachement professionnel'
    ],
    tips: [
      'comment nettoyer les vêtements',
      'astuces nettoyage',
      'enlever les taches',
      'entretien des vêtements',
      'comment laver les vêtements délicats',
      'préserver la couleur des vêtements',
      'séchage des vêtements',
      'repassage des vêtements',
      'nettoyage des tissus nobles',
      'entretien des vêtements de marque'
    ],
    sustainability: [
      'nettoyage écologique',
      'blanchisserie durable',
      'nettoyage respectueux de l\'environnement',
      'produits de nettoyage écologiques',
      'nettoyage sans produits chimiques',
      'blanchisserie verte',
      'nettoyage responsable',
      'textile durable',
      'nettoyage éco-responsable',
      'blanchisserie zéro déchet'
    ]
  },

  // Articles recommandés avec SEO
  recommendedArticles: [
    {
      title: 'Guide Complet du Nettoyage à Sec : Tout ce que vous devez savoir',
      slug: 'guide-nettoyage-sec-complet',
      category: 'drycleaning',
      keywords: ['nettoyage à sec', 'pressing', 'guide complet', 'professionnel'],
      description: 'Découvrez comment fonctionne le nettoyage à sec, ses avantages et comment bien entretenir vos vêtements délicats avec nos experts.',
      readingTime: 8,
      sections: [
        'Qu\'est-ce que le nettoyage à sec ?',
        'Comment fonctionne le nettoyage à sec ?',
        'Quels vêtements nettoyer à sec ?',
        'Avantages du nettoyage à sec',
        'Fréquence recommandée',
        'Conseils d\'entretien'
      ]
    },
    {
      title: 'Comment Enlever les Taches : Guide Expert du Détachement',
      slug: 'guide-enlever-taches-expert',
      category: 'tips',
      keywords: ['enlever taches', 'détachement', 'nettoyage', 'astuces'],
      description: 'Guide complet pour enlever tous types de taches : vin, café, graisse, sang, chocolat. Techniques professionnelles et astuces pratiques.',
      readingTime: 7,
      sections: [
        'Types de taches et solutions',
        'Taches de vin rouge',
        'Taches de café',
        'Taches de graisse',
        'Taches de sang',
        'Taches de chocolat',
        'Quand faire appel à un professionnel'
      ]
    },
    {
      title: 'Entretien des Vêtements de Marque : Préserver la Qualité',
      slug: 'entretien-vetements-marque',
      category: 'tips',
      keywords: ['vêtements de marque', 'entretien', 'luxe', 'préserver'],
      description: 'Comment entretenir vos vêtements de marque pour préserver leur qualité et leur durée de vie. Conseils d\'experts en textile.',
      readingTime: 6,
      sections: [
        'Pourquoi l\'entretien est crucial',
        'Lire les étiquettes de soin',
        'Lavage des vêtements de luxe',
        'Séchage optimal',
        'Repassage sans risque',
        'Stockage approprié',
        'Quand faire appel à un professionnel'
      ]
    },
    {
      title: 'Nettoyage Écologique : Pourquoi c\'est Important pour Vous',
      slug: 'nettoyage-ecologique-important',
      category: 'sustainability',
      keywords: ['nettoyage écologique', 'durable', 'environnement', 'responsable'],
      description: 'Découvrez pourquoi le nettoyage écologique est important pour votre santé et l\'environnement. Les avantages du nettoyage durable.',
      readingTime: 5,
      sections: [
        'Impact environnemental du nettoyage traditionnel',
        'Avantages du nettoyage écologique',
        'Produits écologiques vs chimiques',
        'Santé et bien-être',
        'Durabilité des vêtements',
        'Notre engagement écologique'
      ]
    },
    {
      title: 'Service de Collecte et Livraison Gratuite : Comment ça Marche',
      slug: 'collecte-livraison-gratuite-guide',
      category: 'laundry',
      keywords: ['collecte gratuite', 'livraison', 'service', 'commodité'],
      description: 'Apprenez comment fonctionne notre service de collecte et livraison gratuite. Gain de temps et commodité maximale.',
      readingTime: 4,
      sections: [
        'Comment réserver une collecte',
        'Horaires de collecte',
        'Zones de service',
        'Emballage et transport',
        'Délais de livraison',
        'Tarification transparente'
      ]
    },
    {
      title: 'Repassage Professionnel : Techniques et Astuces',
      slug: 'repassage-professionnel-techniques',
      category: 'tips',
      keywords: ['repassage', 'professionnel', 'techniques', 'astuces'],
      description: 'Maîtrisez l\'art du repassage avec nos techniques professionnelles. Conseils pour un repassage parfait sans abîmer vos vêtements.',
      readingTime: 5,
      sections: [
        'Préparation avant repassage',
        'Température appropriée par tissu',
        'Technique de repassage',
        'Vêtements délicats',
        'Erreurs à éviter',
        'Équipement recommandé'
      ]
    },
    {
      title: 'Entretien des Tissus Nobles : Soie, Laine, Cachemire',
      slug: 'entretien-tissus-nobles',
      category: 'tips',
      keywords: ['tissus nobles', 'soie', 'laine', 'cachemire', 'entretien'],
      description: 'Guide complet pour entretenir les tissus nobles. Conseils spécifiques pour la soie, la laine et le cachemire.',
      readingTime: 6,
      sections: [
        'Caractéristiques des tissus nobles',
        'Entretien de la soie',
        'Entretien de la laine',
        'Entretien du cachemire',
        'Lavage vs nettoyage à sec',
        'Stockage approprié'
      ]
    },
    {
      title: 'Blanchisserie Premium : Qualité et Excellence',
      slug: 'blanchisserie-premium-qualite',
      category: 'laundry',
      keywords: ['blanchisserie premium', 'qualité', 'excellence', 'service'],
      description: 'Découvrez ce qui rend notre blanchisserie premium. Qualité exceptionnelle et service d\'excellence.',
      readingTime: 5,
      sections: [
        'Qu\'est-ce que la blanchisserie premium',
        'Nos standards de qualité',
        'Processus de nettoyage',
        'Contrôle qualité',
        'Satisfaction client',
        'Nos certifications'
      ]
    },
    {
      title: 'Préserver la Couleur de Vos Vêtements : Guide Complet',
      slug: 'preserver-couleur-vetements',
      category: 'tips',
      keywords: ['préserver couleur', 'décoloration', 'vêtements', 'astuces'],
      description: 'Apprenez comment préserver la couleur de vos vêtements. Techniques pour éviter la décoloration et maintenir l\'éclat.',
      readingTime: 5,
      sections: [
        'Causes de la décoloration',
        'Tri des vêtements',
        'Température de lavage',
        'Produits de nettoyage',
        'Séchage approprié',
        'Stockage pour préserver la couleur'
      ]
    },
    {
      title: 'Nettoyage des Vêtements de Sport : Conseils Pratiques',
      slug: 'nettoyage-vetements-sport',
      category: 'tips',
      keywords: ['vêtements de sport', 'nettoyage', 'odeurs', 'durabilité'],
      description: 'Comment nettoyer et entretenir vos vêtements de sport pour prolonger leur durée de vie et éliminer les odeurs.',
      readingTime: 4,
      sections: [
        'Défis du nettoyage sportif',
        'Éliminer les odeurs',
        'Préserver l\'élasticité',
        'Nettoyage des matières techniques',
        'Séchage optimal',
        'Fréquence de nettoyage'
      ]
    }
  ],

  // Stratégie de contenu par mois
  contentCalendar: {
    january: [
      'Résolutions 2024 : Prendre soin de vos vêtements',
      'Guide du nettoyage après les fêtes'
    ],
    february: [
      'Entretien des vêtements d\'hiver',
      'Nettoyage écologique : Pourquoi c\'est important'
    ],
    march: [
      'Préparation du printemps : Rangement d\'hiver',
      'Astuces pour enlever les taches de boue'
    ],
    april: [
      'Nettoyage de printemps : Vos vêtements aussi',
      'Guide du nettoyage à sec'
    ],
    may: [
      'Entretien des vêtements de marque',
      'Préparation de l\'été'
    ],
    june: [
      'Nettoyage des vêtements de plage',
      'Entretien des tissus légers'
    ],
    july: [
      'Conseils pour voyager avec ses vêtements',
      'Nettoyage des vêtements de vacances'
    ],
    august: [
      'Retour de vacances : Nettoyage complet',
      'Préparation de la rentrée'
    ],
    september: [
      'Entretien des vêtements d\'automne',
      'Nettoyage des vêtements de rentrée'
    ],
    october: [
      'Préparation de l\'hiver',
      'Entretien des manteaux et vestes'
    ],
    november: [
      'Nettoyage avant les fêtes',
      'Conseils pour les vêtements de cérémonie'
    ],
    december: [
      'Préparation des fêtes : Vêtements impeccables',
      'Rangement de fin d\'année'
    ]
  },

  // Mots-clés longue traîne (long-tail keywords)
  longTailKeywords: [
    'comment nettoyer les vêtements délicats à la maison',
    'meilleur service de nettoyage à sec près de moi',
    'comment enlever une tache de vin sur un vêtement',
    'entretien des vêtements de marque de luxe',
    'nettoyage écologique vs nettoyage traditionnel',
    'comment préserver la couleur des vêtements noirs',
    'service de collecte et livraison de blanchisserie',
    'comment repassser les vêtements sans les abîmer',
    'entretien des tissus nobles : soie et cachemire',
    'nettoyage des vêtements de sport et odeurs'
  ],

  // Questions fréquentes (FAQ) pour le contenu
  faqTopics: [
    'Quelle est la différence entre le nettoyage à sec et le lavage ?',
    'Combien de fois par an faut-il nettoyer à sec ses vêtements ?',
    'Comment enlever une tache rapidement ?',
    'Quels vêtements ne doivent pas être nettoyés à sec ?',
    'Le nettoyage à sec est-il mauvais pour l\'environnement ?',
    'Comment préserver mes vêtements de marque ?',
    'Quel est le délai de nettoyage ?',
    'Proposez-vous un service de collecte ?',
    'Comment fonctionne votre service de livraison ?',
    'Quels sont vos tarifs ?'
  ],

  // Backlinks internes recommandés
  internalLinks: {
    services: '/services',
    pricing: '/pricing',
    about: '/about',
    contact: '/contact',
    clientApp: '/client-app',
    affiliateApp: '/affiliate-app'
  }
};

/**
 * Fonction pour générer les métadonnées SEO d'un article
 */
export function generateArticleSEO(article: {
  title: string;
  slug: string;
  excerpt: string;
  keywords?: string[];
  category?: string;
}) {
  return {
    title: `${article.title} | Alpha Laundry Blog`,
    description: article.excerpt.substring(0, 160),
    keywords: (article.keywords || []).join(', '),
    canonical: `https://alphalaundry.com/blog/${article.slug}`,
    ogImage: `https://alphalaundry.com/og-images/blog/${article.slug}.jpg`,
    ogType: 'article'
  };
}

/**
 * Fonction pour calculer le temps de lecture
 */
export function calculateReadingTime(content: string): number {
  const wordsPerMinute = 200;
  const words = content.split(/\s+/).length;
  return Math.ceil(words / wordsPerMinute);
}

/**
 * Fonction pour générer un slug à partir du titre
 */
export function generateSlug(title: string): string {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}
