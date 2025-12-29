/**
 * 🔧 Next.js Configuration - Architecture Hybride SSR + ISR
 * 
 * Cette configuration permet :
 * - Pages statiques pré-générées (SSG) pour Netlify
 * - Pages dynamiques avec ISR pour les articles blog
 * - Fallback automatique pour les articles non pré-générés
 */

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Mode export statique pour Netlify
  // Génère un site statique pur compatible avec Netlify
  output: 'export',
  
  // Optimisation des images
  images: {
    unoptimized: true,
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    minimumCacheTTL: 60 * 60 * 24 * 365, // 1 an
  },

  // Compression
  compress: true,

  // Génération statique avec timeout augmenté
  // Permet plus de temps pour les appels API
  staticPageGenerationTimeout: 300, // 5 minutes

  // Optimisation des polices
  optimizeFonts: true,

  // Configuration pour les variables d'environnement
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com',
  },

  // Optimisation des en-têtes de cache
  onDemandEntries: {
    maxInactiveAge: 60 * 1000, // 60 secondes
    pagesBufferLength: 5,
  },

  // Logging pour le debug
  logging: {
    fetches: {
      fullUrl: true,
    },
  },
};

module.exports = nextConfig;
