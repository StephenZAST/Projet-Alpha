/**
 * 💰 Page Pricing - Tarification et Plans
 */

import React from 'react';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { PricingTable } from '@/components/sections/PricingTable';
import { CTA } from '@/components/sections/CTA';
import { FAQ } from '@/components/sections/FAQ';

export const metadata = {
  title: 'Tarification - Alpha Laundry | Prix Transparents & Juste',
  description: 'Consultez nos tarifs transparents et justes pour tous nos services de blanchisserie et nettoyage à sec. Pas de frais cachés, qualité premium à prix compétitifs.',
  keywords: 'tarifs, prix, blanchisserie, nettoyage à sec, services',
  openGraph: {
    title: 'Tarification - Alpha Laundry',
    description: 'Nos tarifs transparents et nos offres spéciales pour les clients réguliers.',
    type: 'website',
  },
};

export default function PricingPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <PricingTable />
        <FAQ />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
