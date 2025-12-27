/**
 * 📚 Blog Cache Manager
 * Gère le cache local des slugs d'articles pour éviter les timeouts API
 * lors du déploiement sur Netlify
 */

import fs from 'fs';
import path from 'path';

const CACHE_DIR = path.join(process.cwd(), '.blog-cache');
const SLUGS_CACHE_FILE = path.join(CACHE_DIR, 'slugs.json');
const CACHE_EXPIRY_MS = 24 * 60 * 60 * 1000; // 24 heures

interface CacheData {
  slugs: string[];
  timestamp: number;
}

/**
 * Initialise le répertoire de cache
 */
function ensureCacheDir(): void {
  if (!fs.existsSync(CACHE_DIR)) {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
  }
}

/**
 * Récupère les slugs du cache local
 */
export function getCachedSlugs(): string[] {
  try {
    if (!fs.existsSync(SLUGS_CACHE_FILE)) {
      return [];
    }

    const data = fs.readFileSync(SLUGS_CACHE_FILE, 'utf-8');
    const cacheData: CacheData = JSON.parse(data);

    // Vérifier si le cache n'a pas expiré
    if (Date.now() - cacheData.timestamp < CACHE_EXPIRY_MS) {
      console.log(`✅ Cache des slugs valide (${cacheData.slugs.length} articles)`);
      return cacheData.slugs;
    }

    console.log('⏰ Cache des slugs expiré');
    return [];
  } catch (error) {
    console.error('Erreur lors de la lecture du cache:', error);
    return [];
  }
}

/**
 * Sauvegarde les slugs dans le cache local
 */
export function cacheSlugs(slugs: string[]): void {
  try {
    ensureCacheDir();

    const cacheData: CacheData = {
      slugs,
      timestamp: Date.now(),
    };

    fs.writeFileSync(SLUGS_CACHE_FILE, JSON.stringify(cacheData, null, 2));
    console.log(`✅ Cache des slugs sauvegardé (${slugs.length} articles)`);
  } catch (error) {
    console.error('Erreur lors de la sauvegarde du cache:', error);
  }
}

/**
 * Récupère les slugs depuis l'API avec fallback sur le cache
 */
export async function getSlugsWithFallback(
  apiUrl: string,
  maxRetries: number = 3
): Promise<string[]> {
  // Essayer de récupérer depuis l'API
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 15000); // 15 secondes

      const response = await fetch(`${apiUrl}/api/blog-articles?limit=100`, {
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        const data = await response.json();
        const slugs = (data.data || []).map((article: any) => article.slug);

        if (slugs.length > 0) {
          cacheSlugs(slugs);
          console.log(`✅ ${slugs.length} slugs récupérés depuis l'API`);
          return slugs;
        }
      }
    } catch (error) {
      console.warn(`⚠️ Tentative ${attempt + 1}/${maxRetries} échouée:`, error);

      if (attempt < maxRetries - 1) {
        const delay = Math.min(1000 * Math.pow(2, attempt), 10000);
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  // Fallback sur le cache local
  const cachedSlugs = getCachedSlugs();
  if (cachedSlugs.length > 0) {
    console.log(`⚠️ API indisponible, utilisation du cache (${cachedSlugs.length} articles)`);
    return cachedSlugs;
  }

  console.warn('❌ Impossible de récupérer les slugs (API + cache indisponibles)');
  return [];
}

/**
 * Nettoie le cache
 */
export function clearCache(): void {
  try {
    if (fs.existsSync(SLUGS_CACHE_FILE)) {
      fs.unlinkSync(SLUGS_CACHE_FILE);
      console.log('✅ Cache nettoyé');
    }
  } catch (error) {
    console.error('Erreur lors du nettoyage du cache:', error);
  }
}
