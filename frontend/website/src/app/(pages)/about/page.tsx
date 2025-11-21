/**
 * 🏢 Page À Propos
 */

import React from 'react';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { About } from '@/components/sections/About';
import { CTA } from '@/components/sections/CTA';

export const metadata = {
  title: 'À Propos - Alpha Laundry | Notre Histoire et Nos Valeurs',
  description: 'Découvrez l\'histoire d\'Alpha Laundry, notre mission, nos valeurs et notre engagement envers l\'excellence et la durabilité.',
  keywords: 'à propos, histoire, valeurs, mission, Alpha Laundry',
  openGraph: {
    title: 'À Propos - Alpha Laundry',
    description: 'L\'histoire d\'Alpha Laundry : passion, excellence et engagement.',
    type: 'website',
  },
};

export default function AboutPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <About />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
