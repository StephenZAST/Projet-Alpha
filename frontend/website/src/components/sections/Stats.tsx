/**
 * 📊 Stats Section - Statistiques clés
 */

'use client';

import React, { useEffect, useState } from 'react';
import { GlassCard } from '../common/GlassCard';
import styles from './Stats.module.css';
import { STATS } from '@/lib/constants';

export const Stats: React.FC = () => {
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

    const element = document.getElementById('stats-section');
    if (element) observer.observe(element);

    return () => observer.disconnect();
  }, []);

  return (
    <section id="stats-section" className={styles.stats}>
      <div className={styles.container}>
        <div className={styles.grid}>
          {STATS.map((stat, index) => (
            <GlassCard
              key={stat.label}
              variant="primary"
              className={`${styles.card} ${isVisible ? styles.visible : ''}`}
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className={styles.cardContent}>
                <div className={styles.value}>{stat.value}</div>
                <div className={styles.label}>{stat.label}</div>
              </div>
            </GlassCard>
          ))}
        </div>
      </div>
    </section>
  );
};
