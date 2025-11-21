/**
 * 🎯 Problems Section - Problèmes résolus
 */

'use client';

import React, { useEffect, useState } from 'react';
import { GlassCard } from '../common/GlassCard';
import styles from './Problems.module.css';
import { PROBLEMS } from '@/lib/constants';

export const Problems: React.FC = () => {
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

    const element = document.getElementById('problems-section');
    if (element) observer.observe(element);

    return () => observer.disconnect();
  }, []);

  return (
    <section id="problems-section" className={styles.problems}>
      <div className={styles.container}>
        <div className={styles.header}>
          <h2 className={styles.title}>Dites Adieu Aux Soucis Quotidiens De Nettoyage</h2>
        </div>

        <div className={styles.grid}>
          {PROBLEMS.map((problem, index) => (
            <GlassCard
              key={problem.title}
              variant="error"
              className={`${styles.card} ${isVisible ? styles.visible : ''}`}
              style={{ animationDelay: `${index * 50}ms` }}
            >
              <div className={styles.cardContent}>
                <div className={styles.icon}>{problem.icon}</div>
                <h3 className={styles.cardTitle}>{problem.title}</h3>
                <p className={styles.cardDescription}>{problem.description}</p>
              </div>
            </GlassCard>
          ))}
        </div>
      </div>
    </section>
  );
};
