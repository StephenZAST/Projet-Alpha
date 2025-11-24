/**
 * 🧺 Page Services - Présentation complète des services
 */

import React from 'react';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { ServiceGrid } from '@/components/sections/ServiceGrid';
import { CTA } from '@/components/sections/CTA';
import { FAQ } from '@/components/sections/FAQ';

export const metadata = {
  title: 'Nos Services - Alpha Laundry | Laverie & Nettoyage à Sec Premium',
  description: 'Découvrez tous nos services premium : Laverie, Nettoyage à Sec, Repassage, Retouche et bien plus. Qualité garantie avec collecte et livraison gratuites.',
  keywords: 'services blanchisserie, nettoyage à sec, repassage, retouche, pressage',
  openGraph: {
    title: 'Nos Services - Alpha Laundry',
    description: 'Services complètes de nettoyage et d\'entretien de textiles avec expertise professionnelle.',
    type: 'website',
  },
};

export default function ServicesPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <ServiceGrid />
        <FAQ />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
