/**
 * 🔧 API Configuration - Configuration centralisée des appels API
 */

/**
 * URL de base du backend
 */
export const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com';

/**
 * Endpoints du blog
 */
export const BLOG_ENDPOINTS = {
  // Articles
  articles: `${BACKEND_URL}/api/blog-articles`,
  articleBySlug: (slug: string) => `${BACKEND_URL}/api/blog-articles/slug/${slug}`,
  articleById: (id: string) => `${BACKEND_URL}/api/blog-articles/${id}`,
  
  // Catégories
  categories: `${BACKEND_URL}/api/blog-categories`,
  categoryById: (id: string) => `${BACKEND_URL}/api/blog-categories/${id}`,
  
  // Génération (admin)
  generateArticles: `${BACKEND_URL}/api/blog-generator/generate`,
  publishArticle: (id: string) => `${BACKEND_URL}/api/blog-generator/${id}/publish`,
  pendingArticles: `${BACKEND_URL}/api/blog-generator/pending`,
  generatorStats: `${BACKEND_URL}/api/blog-generator/stats`,
  seedArticles: `${BACKEND_URL}/api/blog-generator/seed`,
  
  // Queue (admin)
  queueGenerate: `${BACKEND_URL}/api/blog-queue/generate`,
  queueStats: `${BACKEND_URL}/api/blog-queue/stats`,
  queueJobs: `${BACKEND_URL}/api/blog-queue/jobs`,
  queueJobStatus: (jobId: string) => `${BACKEND_URL}/api/blog-queue/jobs/${jobId}`,
  queueCleanup: `${BACKEND_URL}/api/blog-queue/cleanup`,
};

/**
 * Options de fetch par défaut
 */
export const DEFAULT_FETCH_OPTIONS: RequestInit = {
  headers: {
    'Content-Type': 'application/json',
  },
};

/**
 * Fonction helper pour construire les paramètres de requête
 */
export function buildQueryParams(params: Record<string, any>): string {
  const searchParams = new URLSearchParams();
  
  Object.entries(params).forEach(([key, value]) => {
    if (value !== null && value !== undefined && value !== '') {
      searchParams.append(key, String(value));
    }
  });
  
  return searchParams.toString();
}

/**
 * Fonction helper pour les appels API avec gestion d'erreurs
 */
export async function fetchAPI<T>(
  url: string,
  options: RequestInit = {}
): Promise<{ data: T | null; error: string | null }> {
  try {
    const response = await fetch(url, {
      ...DEFAULT_FETCH_OPTIONS,
      ...options,
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    return { data, error: null };
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    console.error('API Error:', errorMessage);
    return { data: null, error: errorMessage };
  }
}
