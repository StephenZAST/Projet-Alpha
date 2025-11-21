/**
 * 📧 Page Contact
 */

import React from 'react';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { ContactForm } from '@/components/sections/ContactForm';
import { CTA } from '@/components/sections/CTA';

export const metadata = {
  title: 'Contact - Alpha Laundry | Nous Contacter',
  description: 'Contactez Alpha Laundry pour vos questions, réclamations ou demandes de partenariat. Réponse garantie sous 24h.',
  keywords: 'contact, support, coordonnées, email, téléphone',
  openGraph: {
    title: 'Contact - Alpha Laundry',
    description: 'Nous sommes là pour vous. Contactez-nous maintenant!',
    type: 'website',
  },
};

export default function ContactPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }}>
        <ContactForm />
        <CTA />
      </main>
      <Footer />
    </>
  );
}
