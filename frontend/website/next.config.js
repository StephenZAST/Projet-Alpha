/**
 * 🔧 Next.js Configuration
 */

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Export statique
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

  // Génération statique
  staticPageGenerationTimeout: 120,

  // Optimisation des polices
  optimizeFonts: true,
};

module.exports = nextConfig;
