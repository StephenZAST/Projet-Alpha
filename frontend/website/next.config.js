/**
 * 🔧 Next.js Configuration
 */

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Optimisation des images
  images: {
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

  // Experimental features
  experimental: {
    optimizePackageImports: ['@/components', '@/lib'],
  },

  // Headers de sécurité
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()',
          },
        ],
      },
    ];
  },

  // Redirects
  async redirects() {
    return [
      {
        source: '/admin',
        destination: 'https://68f95b5655b078000891a633--alphalaundry.netlify.app/',
        permanent: false,
      },
      {
        source: '/affiliate',
        destination: 'https://68fac0ae8f30bef299f38200--affiliatealpha.netlify.app/',
        permanent: false,
      },
      {
        source: '/delivery',
        destination: 'https://68fac646f8312f00079c8b17--alphalaundrydelivers.netlify.app/',
        permanent: false,
      },
    ];
  },

  // Rewrites
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'https://alpha-laundry-backend.onrender.com/api/:path*',
        },
      ],
    };
  },

  // Webpack
  webpack: (config, { isServer }) => {
    config.optimization.minimize = true;
    return config;
  },
};

module.exports = nextConfig;
