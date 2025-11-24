/**
 * 📱 App Showcase Section
 */

'use client';

import React, { useEffect, useState } from 'react';
import styles from './AppShowcase.module.css';
import { EXTERNAL_LINKS } from '@/lib/constants';

const APPS = [
  {
    id: 'client',
    icon: '🧺',
    title: 'Alpha Laundry Client',
    description: 'Commandez, suivez, payez - tout depuis votre téléphone',
    features: [
      'Réserver en 30 secondes',
      'Suivre en temps réel',
      'Payer de manière sécurisée',
      'Cumuler les points',
    ],
    buttons: [
      { label: 'iOS', url: EXTERNAL_LINKS.clientApp },
      { label: 'Android', url: EXTERNAL_LINKS.clientApp },
    ],
  },
  {
    id: 'delivery',
    icon: '🚚',
    title: 'Alpha Laundry Delivery',
    description: 'Gérez vos livraisons efficacement',
    features: [
      'Itinéraires optimisés',
      'GPS en temps réel',
      'Signature électronique',
      'Statistiques de performance',
    ],
    buttons: [
      { label: 'iOS', url: EXTERNAL_LINKS.deliveryApp },
      { label: 'Android', url: EXTERNAL_LINKS.deliveryApp },
    ],
  },
  {
    id: 'admin',
    icon: '📊',
    title: 'Alpha Laundry Admin',
    description: 'Pilotez votre entreprise',
    features: [
      'Tableau de bord en direct',
      'Gestion des commandes',
      'Rapports détaillés',
      'Gestion d\'équipe',
    ],
    buttons: [
      { label: 'Accéder au Tableau', url: EXTERNAL_LINKS.adminApp },
    ],
  },
];

const BENEFITS = [
  {
    icon: '⏱️',
    title: 'Plus Rapide',
    description: 'Commandes en quelques clics',
  },
  {
    icon: '🔒',
    title: 'Plus Sûr',
    description: 'Transactions chiffrées',
  },
  {
    icon: '💰',
    title: 'Plus Rentable',
    description: 'Points et réductions exclusives',
  },
  {
    icon: '📍',
    title: 'Toujours Connecté',
    description: 'Suivi en temps réel',
  },
];

export const AppShowcase: React.FC = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
        }
      },
      { threshold: 0.1 }
    );

    const element = document.getElementById('app-showcase-section');
    if (element) observer.observe(element);

    return () => observer.disconnect();
  }, []);

  const handleAppClick = (url: string) => {
    window.location.href = url;
  };

  return (
    <section id="app-showcase-section" className={styles.appSection}>
      <div className={styles.container}>
        {/* En-tête */}
        <div className={styles.header}>
          <div className={styles.superTitle}>Solutions Digitales</div>
          <h1 className={styles.title}>Découvrez Nos Applications</h1>
          <p className={styles.subtitle}>
            Accédez à Alpha Laundry où que vous soyez, sur tous vos appareils
          </p>
        </div>

        {/* Grille des apps */}
        <div className={styles.appGrid}>
          {APPS.map((app, index) => (
            <div
              key={app.id}
              className={`${styles.appCard} ${isVisible ? '' : ''}`}
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className={styles.appIcon}>{app.icon}</div>
              <h3 className={styles.appTitle}>{app.title}</h3>
              <p className={styles.appDescription}>{app.description}</p>

              <ul className={styles.appFeatures}>
                {app.features.map((feature, i) => (
                  <li key={i} className={styles.appFeature}>
                    {feature}
                  </li>
                ))}
              </ul>

              <div className={styles.appButtons}>
                {app.buttons.map((button, i) => (
                  <button
                    key={i}
                    className={styles.appButtonPrimary}
                    onClick={() => handleAppClick(button.url)}
                  >
                    {button.label}
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Avantages */}
        <div className={styles.benefitsSection}>
          <h2 className={styles.benefitsSectionTitle}>Pourquoi Utiliser Nos Apps?</h2>
          <div className={styles.benefitsGrid}>
            {BENEFITS.map((benefit, index) => (
              <div key={index} className={styles.benefitCard}>
                <div className={styles.benefitIcon}>{benefit.icon}</div>
                <h3 className={styles.benefitTitle}>{benefit.title}</h3>
                <p className={styles.benefitDescription}>{benefit.description}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};
