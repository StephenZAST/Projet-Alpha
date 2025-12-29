/**
 * 🧺 Service Grid Section - Services Statiques
 * Utilise les données statiques de constants.ts pour une meilleure performance
 */

'use client';

import React, { useEffect, useState } from 'react';
import styles from './ServiceGrid.module.css';
import { EXTERNAL_LINKS, ADDITIONAL_SERVICES, SERVICES } from '@/lib/constants';

interface Service {
  id: string;
  name: string;
  description: string;
  icon: string;
  features: string[];
}

export const ServiceGrid: React.FC = () => {
  const [isVisible, setIsVisible] = useState(false);

  // Services statiques depuis constants.ts
  const staticServices: Service[] = SERVICES.map((service: any) => ({
    id: service.id,
    name: service.title,
    description: service.description,
    icon: service.icon,
    features: [
      'Technique optimisée',
      'Résultats garantis',
      'Respect des textiles'
    ]
  }));

  // Observer pour animation d'entrée
  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
        }
      },
      { threshold: 0.1 }
    );

    const element = document.getElementById('services-grid-section');
    if (element) observer.observe(element);

    return () => observer.disconnect();
  }, []);

  const handleReserve = () => {
    window.location.href = EXTERNAL_LINKS.clientApp;
  };

  const handleLearnMore = (serviceId: string) => {
    // Scroller vers les détails du service
    const element = document.getElementById(`service-${serviceId}`);
    element?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <section id="services-grid-section" className={styles.servicesSection}>
      <div className={styles.container}>
        {/* En-tête */}
        <div className={styles.header}>
          <div className={styles.superTitle}>Excellence & Confiance</div>
          <h1 className={styles.title}>Nos Services Complets</h1>
          <p className={styles.subtitle}>
            Alpha Laundry offre une gamme complète de services de nettoyage et d'entretien 
            de textiles pour répondre à tous vos besoins. Du linge délicat aux vêtements de 
            travail, nous maîtrisons chaque technique avec expertise et professionnalisme.
          </p>
        </div>

        {/* Grille des services */}
        <div className={styles.grid}>
          {staticServices.map((service, index) => (
            <div
              key={service.id}
              id={`service-${service.id}`}
              className={`${styles.card} ${isVisible ? styles.visible : ''}`}
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className={styles.cardIcon}>{service.icon}</div>
              <h3 className={styles.cardTitle}>{service.name}</h3>
              <p className={styles.cardDescription}>{service.description}</p>

              {/* Features */}
              <ul className={styles.cardFeatures}>
                {service.features.map((feature, i) => (
                  <li key={i} className={styles.cardFeature}>
                    {feature}
                  </li>
                ))}
              </ul>

              {/* CTA Buttons */}
              <div className={styles.cardCta}>
                <button
                  className={styles.cardCtaPrimary}
                  onClick={handleReserve}
                >
                  Réserver
                </button>
                <button
                  className={styles.cardCtaSecondary}
                  onClick={() => handleLearnMore(service.id)}
                >
                  En Savoir Plus
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Services Additionnels */}
        <div className={styles.additionalServices}>
          <h2 className={styles.additionalTitle}>Services Additionnels</h2>
          <div className={styles.additionalGrid}>
            {ADDITIONAL_SERVICES.map((service, index) => (
              <div key={index} className={styles.additionalItem}>
                <div className={styles.additionalItemIcon}>
                  {[
                    '🧴',
                    '✨',
                    '🎯',
                    '🛡️',
                    '👟',
                  ][index % 5]}
                </div>
                <h4 className={styles.additionalItemTitle}>{service.title}</h4>
                <p className={styles.additionalItemDesc}>{service.description}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};
