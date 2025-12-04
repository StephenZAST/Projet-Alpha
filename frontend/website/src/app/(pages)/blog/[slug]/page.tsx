/**
 * 📝 Page Article Blog - Article détaillé avec SEO optimisé
 */

import React from 'react';
import { Metadata, ResolvingMetadata } from 'next';
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

// Fonction pour récupérer les données de l'article
async function getArticleData(slug: string) {
  try {
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com'}/api/blog-articles/slug/${slug}`,
      { 
        next: { revalidate: 3600 } // ISR: revalidate every hour
      }
    );

    if (!response.ok) {
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
  { params }: BlogArticlePageProps,
  parent: ResolvingMetadata
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
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com'}/api/blog-articles?limit=50`,
      { next: { revalidate: 86400 } } // Revalidate daily
    );

    if (!response.ok) {
      return [];
    }

    const data = await response.json();
    return (data.data || []).map((article: any) => ({
      slug: article.slug
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
