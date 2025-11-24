/**
 * 🧺 Services Section - Présentation des services
 */

'use client';

import React, { useEffect, useState } from 'react';
import { GlassCard } from '../common/GlassCard';
import { Button } from '../common/Button';
import styles from './Services.module.css';
import { SERVICES } from '@/lib/constants';

export const Services: React.FC = () => {
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

    const element = document.getElementById('services-section');
    if (element) observer.observe(element);

    return () => observer.disconnect();
  }, []);

  return (
    <section id="services-section" className={styles.services}>
      <div className={styles.container}>
        <div className={styles.header}>
          <h2 className={styles.title}>Découvrez nos services</h2>
          <p className={styles.subtitle}>
            Avec notre gamme complète de services, nous vous proposons une solution pour toutes vos nécessités en matière de linge. De la laverie à la retouche, nos services sont conçus pour répondre à vos besoins et à votre style de vie.
          </p>
        </div>

        <div className={styles.grid}>
          {SERVICES.map((service, index) => (
            <GlassCard
              key={service.id}
              variant="primary"
              className={`${styles.card} ${isVisible ? styles.visible : ''}`}
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className={styles.cardContent}>
                <div className={styles.icon}>{service.icon}</div>
                <h3 className={styles.cardTitle}>{service.title}</h3>
                <p className={styles.cardDescription}>{service.description}</p>
                <Button variant="outline" size="small">
                  En savoir plus
                </Button>
              </div>
            </GlassCard>
          ))}
        </div>
      </div>
    </section>
  );
};
