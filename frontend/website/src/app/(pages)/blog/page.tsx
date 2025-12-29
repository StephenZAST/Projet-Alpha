/**
 * 📝 Page Blog - Listing des articles de blog
 * Optimisée pour le SEO avec métadonnées dynamiques
 */

import React from 'react';
import { Metadata } from 'next';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { BlogListing } from '@/components/sections/BlogListing';
import { CTA } from '@/components/sections/CTA';

export const metadata: Metadata = {
  title: 'Blog Alpha Laundry | Conseils Blanchisserie & Nettoyage à Sec',
  description: 'Découvrez nos articles experts sur la blanchisserie, le nettoyage à sec, l\'entretien des vêtements et les meilleures pratiques. Conseils professionnels et astuces pratiques.',
  keywords: 'blog blanchisserie, nettoyage à sec, entretien vêtements, conseils pressing, astuces nettoyage',
  openGraph: {
    title: 'Blog Alpha Laundry | Conseils Blanchisserie & Nettoyage à Sec',
    description: 'Articles experts sur la blanchisserie et le nettoyage à sec. Conseils pratiques et astuces professionnelles.',
    type: 'website',
    url: 'https://alphalaundry.com/blog',
    images: [
      {
        url: 'https://alphalaundry.com/images/blog-og.jpg',
        width: 1200,
        height: 630,
        alt: 'Blog Alpha Laundry'
      }
    ]
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Blog Alpha Laundry',
    description: 'Conseils experts en blanchisserie et nettoyage à sec',
    images: ['https://alphalaundry.com/images/blog-og.jpg']
  },
  alternates: {
    canonical: 'https://alphalaundry.com/blog'
  }
};

export default function BlogPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <BlogListing />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
