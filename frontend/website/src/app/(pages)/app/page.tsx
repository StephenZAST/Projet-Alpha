/**
 * 📱 Page Applications
 */

import React from 'react';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { AppShowcase } from '@/components/sections/AppShowcase';
import { CTA } from '@/components/sections/CTA';
import { FAQ } from '@/components/sections/FAQ';

export const metadata = {
  title: 'Applications - Alpha Laundry | Télécharger Nos Apps',
  description: 'Découvrez et téléchargez nos applications client, livreur et admin. Disponibles sur iOS et Android.',
  keywords: 'applications, mobile, iOS, Android, télécharger',
  openGraph: {
    title: 'Applications - Alpha Laundry',
    description: 'Les apps Alpha Laundry pour clients, livreurs et admins.',
    type: 'website',
  },
};

export default function AppPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <AppShowcase />
        <FAQ />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
