/**
 * 📝 Page Article Blog - Article détaillé avec SEO optimisé
 * Architecture Hybride : SSG + ISR + Fallback
 */

import React from 'react';
import { Metadata } from 'next';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { BlogArticleDetail } from '@/components/sections/BlogArticleDetail';
import { RelatedArticles } from '@/components/sections/RelatedArticles';
import { CTA } from '@/components/sections/CTA';

interface BlogArticlePageProps {
  params: {
    slug: string;
  };
}

/**
 * Fonction utilitaire pour les retries avec backoff exponentiel
 * Gère les timeouts du backend Render (plan gratuit)
 */
async function fetchWithRetry(
  url: string,
  maxRetries: number = 3,
  timeout: number = 10000
): Promise<Response | null> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      const response = await fetch(url, {
        signal: controller.signal,
        next: { revalidate: 3600 }, // ISR: revalidate every hour
      });

      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      const isLastAttempt = attempt === maxRetries - 1;
      const delay = Math.min(1000 * Math.pow(2, attempt), 10000); // Backoff exponentiel

      console.warn(
        `Fetch attempt ${attempt + 1}/${maxRetries} failed for ${url}. ${
          isLastAttempt ? 'Giving up.' : `Retrying in ${delay}ms...`
        }`,
        error
      );

      if (!isLastAttempt) {
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  return null;
}

// Fonction pour récupérer les données de l'article avec gestion des erreurs
async function getArticleData(slug: string) {
  try {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com';
    const response = await fetchWithRetry(
      `${apiUrl}/api/blog-articles/slug/${slug}`,
      3, // 3 tentatives
      15000 // 15 secondes de timeout
    );

    if (!response?.ok) {
      console.error(`Failed to fetch article: ${slug}. Status: ${response?.status}`);
      return null;
    }

    const data = await response.json();
    return data.data;
  } catch (error) {
    console.error('Error fetching article:', error);
    return null;
  }
}

// Générer les métadonnées dynamiques
export async function generateMetadata(
  { params }: BlogArticlePageProps
): Promise<Metadata> {
  const article = await getArticleData(params.slug);

  if (!article) {
    return {
      title: 'Article non trouvé | Alpha Laundry',
      description: 'L\'article que vous recherchez n\'existe pas.'
    };
  }

  const canonicalUrl = `https://alphalaundry.com/blog/${params.slug}`;
  const imageUrl = article.featured_image || 'https://alphalaundry.com/images/blog-default.jpg';

  return {
    title: `${article.title} | Alpha Laundry Blog`,
    description: article.seo_description || article.excerpt,
    keywords: article.seo_keywords?.join(', '),
    authors: [{ name: article.author?.name || 'Alpha Laundry' }],
    openGraph: {
      title: article.title,
      description: article.seo_description || article.excerpt,
      type: 'article',
      url: canonicalUrl,
      images: [
        {
          url: imageUrl,
          width: 1200,
          height: 630,
          alt: article.title
        }
      ],
      publishedTime: article.published_at,
      modifiedTime: article.updated_at,
      authors: [article.author?.name || 'Alpha Laundry']
    },
    twitter: {
      card: 'summary_large_image',
      title: article.title,
      description: article.seo_description || article.excerpt,
      images: [imageUrl]
    },
    alternates: {
      canonical: canonicalUrl
    }
  };
}

// Générer les slugs statiques pour les articles populaires
export async function generateStaticParams() {
  try {
    const { getSlugsWithFallback } = await import('@/lib/blogCache');
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com';
    
    const slugs = await getSlugsWithFallback(apiUrl, 3);
    
    return slugs.map((slug: string) => ({
      slug,
    }));
  } catch (error) {
    console.error('Error generating static params:', error);
    return [];
  }
}

export default async function BlogArticlePage({ params }: BlogArticlePageProps) {
  const article = await getArticleData(params.slug);

  if (!article) {
    return (
      <>
        <Header />
        <main style={{ paddingTop: '70px', minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ textAlign: 'center' }}>
            <h1>Article non trouvé</h1>
            <p>L'article que vous recherchez n'existe pas ou a été supprimé.</p>
          </div>
        </main>
        <Footer />
      </>
    );
  }

  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        {/* Article détaillé */}
        <BlogArticleDetail article={article} />

        {/* Articles connexes */}
        <RelatedArticles 
          currentArticleId={article.id}
          category={article.category}
        />

        {/* CTA */}
        <CTA />
      </main>
      <Footer />
    </>
  );
}
