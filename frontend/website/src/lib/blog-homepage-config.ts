/**
 * 📝 Blog Homepage Configuration - Intégration du blog à la homepage
 */

export const BLOG_HOMEPAGE_CONFIG = {
  // Section Blog sur la homepage
  section: {
    title: 'Derniers Articles du Blog',
    subtitle: 'Conseils experts et astuces pratiques pour prendre soin de vos vêtements',
    cta: {
      text: 'Voir tous les articles',
      href: '/blog'
    }
  },

  // Nombre d'articles à afficher
  articlesPerPage: 3,

  // Configuration du carousel/grid
  display: {
    layout: 'grid', // 'grid' ou 'carousel'
    columns: 3,
    gap: 'var(--spacing-xl)'
  },

  // Catégories à afficher en priorité
  priorityCategories: [
    'Conseils & Astuces',
    'Blanchisserie & Nettoyage',
    'Durabilité'
  ],

  // Mots-clés pour la recherche d'articles
  searchKeywords: [
    'nettoyage',
    'blanchisserie',
    'conseils',
    'astuces',
    'entretien'
  ]
};

/**
 * Configuration pour le bouton Blog dans la navigation
 */
export const BLOG_NAV_CONFIG = {
  label: 'Blog',
  href: '/blog',
  icon: '📝',
  position: 4, // Position dans la navigation (0-indexed)
  
  // Sous-menu optionnel
  submenu: [
    {
      label: 'Tous les articles',
      href: '/blog'
    },
    {
      label: 'Conseils & Astuces',
      href: '/blog?category=tips'
    },
    {
      label: 'Nettoyage à Sec',
      href: '/blog?category=drycleaning'
    },
    {
      label: 'Durabilité',
      href: '/blog?category=sustainability'
    }
  ]
};

/**
 * Configuration pour la section Blog Preview sur la homepage
 */
export const BLOG_PREVIEW_CONFIG = {
  // Titre de la section
  title: 'Découvrez nos Conseils Experts',
  
  // Sous-titre
  subtitle: 'Apprenez comment prendre soin de vos vêtements avec nos articles rédigés par des experts en textile et nettoyage professionnel.',
  
  // Icône de la section
  icon: '📚',
  
  // Couleur de fond
  backgroundColor: 'linear-gradient(135deg, rgba(37, 99, 235, 0.05) 0%, var(--color-bg-light) 100%)',
  
  // Nombre d'articles à afficher
  articlesToShow: 3,
  
  // Afficher les catégories
  showCategories: true,
  
  // Afficher le temps de lecture
  showReadingTime: true,
  
  // Afficher la date
  showDate: true,
  
  // Afficher l'auteur
  showAuthor: false,
  
  // Afficher l'image
  showImage: true,
  
  // Hauteur de l'image
  imageHeight: '200px',
  
  // Afficher le bouton "Lire plus"
  showReadMoreButton: true,
  
  // Texte du bouton "Voir tous"
  viewAllText: 'Voir tous les articles',
  
  // Lien du bouton "Voir tous"
  viewAllLink: '/blog'
};

/**
 * Configuration pour les articles recommandés
 */
export const RECOMMENDED_ARTICLES = [
  {
    id: 'article-1',
    title: 'Guide Complet du Nettoyage à Sec',
    slug: 'guide-nettoyage-sec-complet',
    category: 'Nettoyage à Sec',
    readingTime: 8,
    featured: true,
    priority: 1
  },
  {
    id: 'article-2',
    title: 'Comment Enlever les Taches : Guide Expert',
    slug: 'guide-enlever-taches-expert',
    category: 'Conseils & Astuces',
    readingTime: 7,
    featured: true,
    priority: 2
  },
  {
    id: 'article-3',
    title: 'Entretien des Vêtements de Marque',
    slug: 'entretien-vetements-marque',
    category: 'Conseils & Astuces',
    readingTime: 6,
    featured: true,
    priority: 3
  },
  {
    id: 'article-4',
    title: 'Nettoyage Écologique : Pourquoi c\'est Important',
    slug: 'nettoyage-ecologique-important',
    category: 'Durabilité',
    readingTime: 5,
    featured: false,
    priority: 4
  },
  {
    id: 'article-5',
    title: 'Service de Collecte et Livraison Gratuite',
    slug: 'collecte-livraison-gratuite-guide',
    category: 'Blanchisserie & Nettoyage',
    readingTime: 4,
    featured: false,
    priority: 5
  }
];

/**
 * Configuration pour les CTAs (Call-to-Action) dans les articles
 */
export const ARTICLE_CTAS = {
  // CTA après la lecture d'un article
  afterArticle: {
    title: 'Prêt à essayer notre service ?',
    description: 'Découvrez comment Alpha Laundry peut prendre soin de vos vêtements avec excellence.',
    buttons: [
      {
        text: 'Réserver une collecte',
        href: '/client-app',
        style: 'primary'
      },
      {
        text: 'Voir nos tarifs',
        href: '/pricing',
        style: 'secondary'
      }
    ]
  },

  // CTA dans la sidebar
  sidebar: {
    title: 'Besoin d\'aide ?',
    description: 'Contactez notre équipe d\'experts pour des conseils personnalisés.',
    buttons: [
      {
        text: 'Nous contacter',
        href: '/contact',
        style: 'primary'
      }
    ]
  }
};

/**
 * Configuration pour le partage social
 */
export const SOCIAL_SHARE_CONFIG = {
  platforms: [
    {
      name: 'facebook',
      icon: '👍',
      label: 'Facebook',
      url: 'https://www.facebook.com/sharer/sharer.php?u='
    },
    {
      name: 'twitter',
      icon: '𝕏',
      label: 'Twitter',
      url: 'https://twitter.com/intent/tweet?url='
    },
    {
      name: 'linkedin',
      icon: '💼',
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/sharing/share-offsite/?url='
    },
    {
      name: 'whatsapp',
      icon: '💬',
      label: 'WhatsApp',
      url: 'https://wa.me/?text='
    }
  ],

  // Texte par défaut pour le partage
  defaultText: 'Découvrez cet article intéressant sur Alpha Laundry Blog'
};

/**
 * Configuration pour les newsletters
 */
export const NEWSLETTER_CONFIG = {
  // Titre
  title: 'Recevez nos conseils par email',
  
  // Description
  description: 'Abonnez-vous à notre newsletter pour recevoir nos derniers articles et conseils experts directement dans votre boîte mail.',
  
  // Placeholder du formulaire
  placeholder: 'Votre adresse email',
  
  // Texte du bouton
  buttonText: 'S\'abonner',
  
  // Fréquence
  frequency: 'Chaque semaine',
  
  // Endpoint pour l'inscription
  endpoint: '/api/newsletter/subscribe'
};

/**
 * Configuration pour les commentaires (optionnel)
 */
export const COMMENTS_CONFIG = {
  enabled: false, // À activer si vous utilisez un système de commentaires
  provider: 'disqus', // ou 'utterances', 'giscus', etc.
  config: {
    // Configuration spécifique du provider
  }
};

/**
 * Configuration pour l'analytics
 */
export const BLOG_ANALYTICS_CONFIG = {
  // Événements à tracker
  events: {
    articleView: 'article_view',
    articleShare: 'article_share',
    articleScroll: 'article_scroll',
    articleComment: 'article_comment',
    newsletterSignup: 'newsletter_signup',
    relatedArticleClick: 'related_article_click'
  },

  // Propriétés à tracker
  properties: {
    articleId: 'article_id',
    articleTitle: 'article_title',
    articleCategory: 'article_category',
    readingTime: 'reading_time',
    scrollDepth: 'scroll_depth',
    timeOnPage: 'time_on_page'
  }
};

/**
 * Fonction pour obtenir les articles à afficher sur la homepage
 */
export function getHomepageBlogArticles(articles: any[]) {
  return articles
    .filter(article => article.featured || RECOMMENDED_ARTICLES.some(rec => rec.id === article.id))
    .sort((a, b) => {
      const recA = RECOMMENDED_ARTICLES.find(rec => rec.id === a.id);
      const recB = RECOMMENDED_ARTICLES.find(rec => rec.id === b.id);
      return (recA?.priority || 999) - (recB?.priority || 999);
    })
    .slice(0, BLOG_PREVIEW_CONFIG.articlesToShow);
}

/**
 * Fonction pour générer le lien de partage
 */
export function generateShareLink(platform: string, url: string, title: string) {
  const config = SOCIAL_SHARE_CONFIG.platforms.find(p => p.name === platform);
  if (!config) return '';

  if (platform === 'whatsapp') {
    return `${config.url}${encodeURIComponent(title + ' ' + url)}`;
  }

  return `${config.url}${encodeURIComponent(url)}&text=${encodeURIComponent(title)}`;
}
