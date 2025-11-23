import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Application Client | Alpha Pressing - Blanchisserie Premium',
  description: 'Découvrez l\'application mobile Alpha Pressing. Commandez, suivez et gérez vos vêtements facilement. Service de collecte gratuit, qualité garantie, prix justes.',
  keywords: 'application mobile, pressing, blanchisserie, collecte gratuit, suivi commande',
  openGraph: {
    title: 'Application Client | Alpha Pressing',
    description: 'Votre blanchisserie premium dans votre poche. Commandez en quelques clics.',
    type: 'website',
    url: 'https://alphalaundry.com/client-app',
    images: [
      {
        url: 'https://alphalaundry.com/images/app_mockups/client app home page.png',
        width: 300,
        height: 600,
        alt: 'Application Client Alpha Pressing',
      },
    ],
  },
};

export default function ClientAppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
