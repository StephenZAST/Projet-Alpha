/**
 * 🗺️ Sitemap XML - Pour Google et autres moteurs de recherche
 * Génère dynamiquement la liste de toutes les pages et articles
 */

import { MetadataRoute } from 'next';

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com';
const SITE_URL = 'https://alphalaundry.com';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  try {
    // Récupérer tous les articles du blog
    const articlesResponse = await fetch(
      `${BACKEND_URL}/api/blog-articles?limit=1000`,
      { next: { revalidate: 86400 } } // Revalidate daily
    );

    let articles = [];
    if (articlesResponse.ok) {
      const data = await articlesResponse.json();
      articles = data.data || [];
    }

    // Pages statiques
    const staticPages: MetadataRoute.Sitemap = [
      {
        url: `${SITE_URL}`,
        lastModified: new Date(),
        changeFrequency: 'weekly',
        priority: 1.0,
      },
      {
        url: `${SITE_URL}/services`,
        lastModified: new Date(),
        changeFrequency: 'monthly',
        priority: 0.9,
      },
      {
        url: `${SITE_URL}/pricing`,
        lastModified: new Date(),
        changeFrequency: 'weekly',
        priority: 0.9,
      },
      {
        url: `${SITE_URL}/blog`,
        lastModified: new Date(),
        changeFrequency: 'weekly',
        priority: 0.8,
      },
      {
        url: `${SITE_URL}/about`,
        lastModified: new Date(),
        changeFrequency: 'monthly',
        priority: 0.7,
      },
      {
        url: `${SITE_URL}/contact`,
        lastModified: new Date(),
        changeFrequency: 'monthly',
        priority: 0.7,
      },
    ];

    // Articles du blog
    const blogArticles: MetadataRoute.Sitemap = articles.map((article: any) => ({
      url: `${SITE_URL}/blog/${article.slug}`,
      lastModified: article.updated_at || article.created_at || new Date(),
      changeFrequency: 'monthly' as const,
      priority: 0.7,
    }));

    return [...staticPages, ...blogArticles];
  } catch (error) {
    console.error('Error generating sitemap:', error);
    
    // Retourner au moins les pages statiques en cas d'erreur
    return [
      {
        url: `${SITE_URL}`,
        lastModified: new Date(),
        changeFrequency: 'weekly',
        priority: 1.0,
      },
      {
        url: `${SITE_URL}/blog`,
        lastModified: new Date(),
        changeFrequency: 'weekly',
        priority: 0.8,
      },
    ];
  }
}
