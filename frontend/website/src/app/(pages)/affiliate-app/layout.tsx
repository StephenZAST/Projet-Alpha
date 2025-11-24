import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Programme Affiliate | Alpha Pressing - Gagnez de l\'Argent',
  description: 'Rejoignez le programme d\'affiliation Alpha Pressing. Gagnez jusqu\'à 20% de commission sur chaque client référé. Paiements rapides, support dédié.',
  keywords: 'affiliation, programme partenaire, commission, gagner argent, marketing',
  openGraph: {
    title: 'Programme Affiliate | Alpha Pressing',
    description: 'Gagnez de l\'argent en recommandant Alpha Pressing. Commissions élevées, paiements rapides.',
    type: 'website',
    url: 'https://alphalaundry.com/affiliate-app',
    images: [
      {
        url: 'https://alphalaundry.com/images/app_mockups/affiliate home page.png',
        width: 300,
        height: 600,
        alt: 'Programme Affiliate Alpha Pressing',
      },
    ],
  },
};

export default function AffiliateAppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
