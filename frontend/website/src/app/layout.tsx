/**
 * 🎯 Root Layout - Configuration globale
 */

import type { Metadata } from 'next';
import '@/styles/variables.css';
import '@/styles/globals.css';

export const metadata: Metadata = {
  title: 'Alpha Laundry - Blanchisserie & Nettoyage à Sec Premium',
  description: 'Découvrez Alpha Laundry, votre partenaire de confiance pour la blanchisserie, le nettoyage à sec et les services de repassage. Collecte et livraison gratuite.',
  viewport: 'width=device-width, initial-scale=1, maximum-scale=5',
  robots: 'index, follow',
  authors: [{ name: 'Alpha Laundry' }],
  creator: 'Alpha Laundry',
  publisher: 'Alpha Laundry',
  formatDetection: {
    email: false,
    telephone: false,
    address: false,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <head>
        <meta charSet="utf-8" />
        <meta name="theme-color" content="#2563EB" />
        <link rel="icon" href="/favicon.ico" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="manifest" href="/manifest.json" />
      </head>
      <body>
        {children}
      </body>
    </html>
  );
}
