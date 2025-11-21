/**
 * 🏢 About Section
 */

'use client';

import React from 'react';
import styles from './About.module.css';

const VALUES = [
  {
    icon: '⭐',
    title: 'Excellence',
    description: 'Chaque détail compte dans notre service',
  },
  {
    icon: '🤝',
    title: 'Intégrité',
    description: 'Transparence totale, toujours',
  },
  {
    icon: '🚀',
    title: 'Innovation',
    description: 'Technologie & méthodes modernes',
  },
  {
    icon: '🌍',
    title: 'Durabilité',
    description: 'Respectueux de l\'environnement',
  },
  {
    icon: '❤️',
    title: 'Bienveillance',
    description: 'Traiter les clients comme des amis',
  },
  {
    icon: '🛡️',
    title: 'Fiabilité',
    description: 'Vous pouvez compter sur nous',
  },
];

const STATS = [
  { number: '10+', label: 'Ans d\'Expérience' },
  { number: '500+', label: 'Clients Satisfaits' },
  { number: '99.5%', label: 'Satisfaction' },
  { number: '50+', label: 'Employés' },
];

export const About: React.FC = () => {
  return (
    <section className={styles.aboutSection}>
      <div className={styles.container}>
        {/* Hero */}
        <div className={styles.hero}>
          <h1 className={styles.heroTitle}>L'Histoire d'Alpha Laundry</h1>
          <p className={styles.heroSubtitle}>
            Plus qu'une blanchisserie. Une passion pour l'excellence.
          </p>
        </div>

        {/* Story */}
        <div className={styles.storySection}>
          <h2 className={styles.storyTitle}>Comment Tout A Commencé</h2>
          <div className={styles.storyContent}>
            <p>
              Alpha Laundry a été fondée avec une vision simple : "transformer l'expérience du 
              nettoyage au Burkina Faso". Ce qui a commencé par un petit magasin est devenu 
              l'une des blanchisseries les plus modernes de la région.
            </p>
            <p>
              Aujourd'hui, nous servons des milliers de clients satisfaits - des familles 
              occupées aux entreprises dynamiques - parce que nous avons toujours mis la qualité 
              et la satisfaction en premier.
            </p>
            <p>
              Notre mission reste inchangée : vous offrir un service qui dépasse vos attentes, 
              avec des résultats impeccables et une équipe dévouée à votre satisfaction.
            </p>
          </div>
        </div>

        {/* Values */}
        <div className={styles.valuesSection}>
          <h2 className={styles.valuesSectionTitle}>Ce qui Nous Définit</h2>
          <div className={styles.valuesGrid}>
            {VALUES.map((value, index) => (
              <div key={index} className={styles.valueCard}>
                <div className={styles.valueIcon}>{value.icon}</div>
                <h3 className={styles.valueTitle}>{value.title}</h3>
                <p className={styles.valueDescription}>{value.description}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Stats */}
        <div className={styles.statsSection}>
          <div className={styles.statsGrid}>
            {STATS.map((stat, index) => (
              <div key={index} className={styles.statItem}>
                <div className={styles.statNumber}>{stat.number}</div>
                <div className={styles.statLabel}>{stat.label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Environment */}
        <div className={styles.environmentSection}>
          <h2 className={styles.environmentTitle}>
            <span>🌍</span>
            Notre Responsabilité Écologique
          </h2>
          <p className={styles.environmentContent}>
            Nous croyons qu'un bon nettoyage ne doit pas coûter cher à la planète. C'est pourquoi 
            nous utilisons 100% de produits écologiques et recyclables, et avons réduit notre 
            consommation d'eau de 40% au cours des 3 dernières années.
          </p>
          <p className={styles.environmentContent}>
            Chaque commande traitée chez Alpha Laundry est traitée avec soin pour l'environnement. 
            Nous envisageons d'être "carbone neutre" d'ici 2030.
          </p>
        </div>
      </div>
    </section>
  );
};
