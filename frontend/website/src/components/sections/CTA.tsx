/**
 * 🎯 CTA Section - Appel à l'action
 */

'use client';

import React from 'react';
import Image from 'next/image';
import { Button } from '../common/Button';
import styles from './CTA.module.css';
import { EXTERNAL_LINKS } from '@/lib/constants';

export const CTA: React.FC = () => {
  return (
    <section className={styles.cta}>
      <div className={styles.container}>
        <div className={styles.content}>
          <div className={styles.textContent}>
            <h2 className={styles.title}>
              Améliorez votre expérience client avec notre app
            </h2>
            <p className={styles.description}>
              Notre app est conçue pour vous aider à mieux gérer vos achats et à obtenir le meilleur service. Avec notre app, vous pouvez suivre vos commandes en temps réel, cumuler des points de fidélité et profiter de nombreux avantages, tels que des réductions, des offres spéciales et des cadeaux.
            </p>

            <div className={styles.ctas}>
              <Button
                variant="primary"
                size="large"
                onClick={() => window.location.href = '/client-app'}
              >
                Découvrez l'App
              </Button>
              <Button
                variant="secondary"
                size="large"
                onClick={() => window.location.href = '/affiliate-app'}
              >
                Devenir Partenaire
              </Button>
            </div>
          </div>

          <div className={styles.imageContainer}>
            <Image
              src="/images/app_mockups/client app home page.png"
              alt="Mockup de l'application client Alpha Pressing"
              width={280}
              height={560}
              className={styles.mockupImage}
              priority
            />
          </div>
        </div>

        {/* Éléments de décoration */}
        <div className={styles.decoration1} />
        <div className={styles.decoration2} />
      </div>
    </section>
  );
};
