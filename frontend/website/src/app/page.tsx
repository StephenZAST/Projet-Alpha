/**
 * 🏠 Home Page - Page d'accueil principale
 */

import React from 'react';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { Hero } from '@/components/sections/Hero';
import { Stats } from '@/components/sections/Stats';
import { Problems } from '@/components/sections/Problems';
import { Services } from '@/components/sections/Services';
import { FAQ } from '@/components/sections/FAQ';
import { CTA } from '@/components/sections/CTA';

export const metadata = {
  title: 'Alpha Laundry - Blanchisserie & Nettoyage à Sec Premium',
  description: 'Découvrez Alpha Laundry, votre partenaire de confiance pour la blanchisserie, le nettoyage à sec et les services de repassage. Collecte et livraison gratuite.',
  keywords: 'blanchisserie, nettoyage à sec, pressing, repassage, collecte livraison',
  openGraph: {
    title: 'Alpha Laundry - Blanchisserie & Nettoyage à Sec Premium',
    description: 'Votre partenaire de confiance pour vos besoins en blanchisserie et nettoyage à sec.',
    type: 'website',
  },
};

export default function Home() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <Hero />
        <Stats />
        <Problems />
        <Services />
        <FAQ />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
