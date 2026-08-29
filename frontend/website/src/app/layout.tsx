/**
 * 🎯 Root Layout - Configuration globale
 */

import type { Metadata, Viewport } from 'next';
import '@/styles/globals.css';

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
};

export const metadata: Metadata = {
  title: 'Alpha Laundry - Blanchisserie & Nettoyage à Sec Premium',
  description: 'Découvrez Alpha Laundry, votre partenaire de confiance pour la blanchisserie, le nettoyage à sec et les services de repassage. Collecte et livraison gratuite.',
  robots: 'index, follow',
  authors: [{ name: 'Alpha Laundry' }],
  creator: 'Alpha Laundry',
  publisher: 'Alpha Laundry',
  formatDetection: {
    email: false,
    telephone: false,
    address: false,
  },
  // ajout Open Graph siteName et url — Next injectera les balises OG appropriées
  openGraph: {
    title: 'Alpha Laundry - Blanchisserie & Nettoyage à Sec Premium',
    description: 'Découvrez Alpha Laundry, votre partenaire de confiance pour la blanchisserie et nettoyage à sec.',
    type: 'website',
    siteName: 'Alpha Laundry',
    url: 'https://alpha-laundry.it.com',
  },
};

const websiteLd = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Alpha Laundry",
  "alternateName": "Alpha Laundry - Blanchisserie & Nettoyage à Sec Premium",
  "url": "https://alpha-laundry.it.com/"
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
        
        {/* Favicones - Meilleure pratique moderne */}
        <link rel="icon" type="image/svg+xml" href="/images/alphalogo.svg" />
        <link rel="alternate icon" href="/favicon.ico" />
        <link rel="apple-touch-icon" href="/images/alphalogo.png" />
        <link rel="manifest" href="/manifest.json" />
        
        {/* Meta pour PWA */}
        <meta name="msapplication-TileColor" content="#2563EB" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />

        {/* Explicit Open Graph site name + url (sécurise le signal pour Google) */}
        <meta property="og:site_name" content="Alpha Laundry" />
        <meta property="og:url" content="https://alpha-laundry.it.com" />

        {/* WebSite structured data (JSON-LD) */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteLd) }}
        />
      </head>
      <body>
        {children}
      </body>
    </html>
  );
}
