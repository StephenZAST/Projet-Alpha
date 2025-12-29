#!/usr/bin/env node

/**
 * 🔨 Build Script Optimisé
 * Prépare le cache des slugs avant le build Next.js
 * Cela évite les timeouts lors du déploiement sur Netlify
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const CACHE_DIR = path.join(process.cwd(), '.blog-cache');
const SLUGS_CACHE_FILE = path.join(CACHE_DIR, 'slugs.json');
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com';

/**
 * Crée le répertoire de cache
 */
function ensureCacheDir() {
  if (!fs.existsSync(CACHE_DIR)) {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
  }
}

/**
 * Récupère les slugs depuis l'API
 */
function fetchSlugs() {
  return new Promise((resolve, reject) => {
    const url = `${API_URL}/api/blog-articles?limit=100`;
    console.log(`📡 Récupération des slugs depuis: ${url}`);

    const request = https.get(url, { timeout: 30000 }, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          if (res.statusCode === 200) {
            const json = JSON.parse(data);
            const slugs = (json.data || []).map((article) => article.slug);
            console.log(`✅ ${slugs.length} slugs récupérés`);
            resolve(slugs);
          } else {
            console.warn(`⚠️ API retourné le statut ${res.statusCode}`);
            resolve([]);
          }
        } catch (error) {
          console.error('❌ Erreur lors du parsing JSON:', error.message);
          resolve([]);
        }
      });
    });

    request.on('timeout', () => {
      request.destroy();
      console.warn('⏱️ Timeout lors de la récupération des slugs');
      reject(new Error('Timeout'));
    });

    request.on('error', (error) => {
      console.warn(`⚠️ Erreur réseau: ${error.message}`);
      reject(error);
    });
  });
}

/**
 * Sauvegarde les slugs dans le cache
 */
function cacheSlugs(slugs) {
  try {
    ensureCacheDir();
    const cacheData = {
      slugs,
      timestamp: Date.now(),
    };
    fs.writeFileSync(SLUGS_CACHE_FILE, JSON.stringify(cacheData, null, 2));
    console.log(`✅ Cache sauvegardé: ${SLUGS_CACHE_FILE}`);
  } catch (error) {
    console.error('❌ Erreur lors de la sauvegarde du cache:', error.message);
  }
}

/**
 * Récupère les slugs du cache existant
 */
function getCachedSlugs() {
  try {
    if (fs.existsSync(SLUGS_CACHE_FILE)) {
      const data = fs.readFileSync(SLUGS_CACHE_FILE, 'utf-8');
      const cacheData = JSON.parse(data);
      return cacheData.slugs || [];
    }
  } catch (error) {
    console.error('❌ Erreur lors de la lecture du cache:', error.message);
  }
  return [];
}

/**
 * Fonction principale
 */
async function main() {
  console.log('🚀 Préparation du build...\n');

  try {
    const slugs = await fetchSlugs();
    if (slugs.length > 0) {
      cacheSlugs(slugs);
    } else {
      console.log('⚠️ Aucun slug récupéré, utilisation du cache existant');
      const cachedSlugs = getCachedSlugs();
      if (cachedSlugs.length > 0) {
        console.log(`✅ Cache existant trouvé: ${cachedSlugs.length} articles`);
      } else {
        console.warn('⚠️ Aucun cache disponible - le build continuera sans pré-génération');
      }
    }
  } catch (error) {
    console.warn(`⚠️ Impossible de récupérer les slugs: ${error.message}`);
    const cachedSlugs = getCachedSlugs();
    if (cachedSlugs.length > 0) {
      console.log(`✅ Utilisation du cache existant: ${cachedSlugs.length} articles`);
    } else {
      console.warn('⚠️ Le build continuera sans cache');
    }
  }

  console.log('\n✅ Préparation terminée\n');
}

main().catch((error) => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
