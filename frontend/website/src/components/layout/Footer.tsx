/**
 * 🔗 Footer Component
 */

'use client';

import React from 'react';
import Link from 'next/link';
import styles from './Footer.module.css';
import { EXTERNAL_LINKS } from '@/lib/constants';

export const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className={styles.footer}>
      <div className={styles.container}>
        {/* Contenu principal */}
        <div className={styles.content}>
          {/* Colonne 1 - À propos */}
          <div className={styles.column}>
            <h4 className={styles.columnTitle}>À propos de nous</h4>
            <ul className={styles.links}>
              <li>
                <Link href="/about">Notre histoire</Link>
              </li>
              <li>
                <Link href="/about">Notre équipe</Link>
              </li>
              <li>
                <Link href="/contact">Nous contacter</Link>
              </li>
            </ul>
          </div>

          {/* Colonne 2 - Services */}
          <div className={styles.column}>
            <h4 className={styles.columnTitle}>Nos services</h4>
            <ul className={styles.links}>
              <li>
                <Link href="/services">Laverie</Link>
              </li>
              <li>
                <Link href="/services">Pressing</Link>
              </li>
              <li>
                <Link href="/services">Repassage</Link>
              </li>
              <li>
                <Link href="/services">Services à valeur ajoutée</Link>
              </li>
            </ul>
          </div>

          {/* Colonne 3 - Offres */}
          <div className={styles.column}>
            <h4 className={styles.columnTitle}>Nos offres</h4>
            <ul className={styles.links}>
              <li>
                <Link href="/pricing">Prix</Link>
              </li>
              <li>
                <Link href="/pricing">Réductions et offres spéciales</Link>
              </li>
              <li>
                <Link href="/pricing">Points de fidélité</Link>
              </li>
            </ul>
          </div>

          {/* Colonne 4 - Applications */}
          <div className={styles.column}>
            <h4 className={styles.columnTitle}>Nos applications</h4>
            <ul className={styles.links}>
              <li>
                <Link href="/client-app">Application Client</Link>
              </li>
              <li>
                <Link href="/affiliate-app">Programme Affiliate</Link>
              </li>
            </ul>
          </div>

          {/* Colonne 5 - Contact */}
          <div className={styles.column}>
            <h4 className={styles.columnTitle}>Appelez écrivez nous</h4>
            <div className={styles.contact}>
              <a href={`tel:${EXTERNAL_LINKS.phone}`} className={styles.phone}>
                {EXTERNAL_LINKS.phone}
              </a>
              <a href={`mailto:${EXTERNAL_LINKS.email}`} className={styles.email}>
                {EXTERNAL_LINKS.email}
              </a>
            </div>
            <div className={styles.socialLinks}>
              <a href="#" aria-label="Facebook" className={styles.socialLink}>
                f
              </a>
              <a href="#" aria-label="Twitter" className={styles.socialLink}>
                𝕏
              </a>
              <a href="#" aria-label="Instagram" className={styles.socialLink}>
                📷
              </a>
              <a href="#" aria-label="LinkedIn" className={styles.socialLink}>
                in
              </a>
            </div>
          </div>
        </div>

        {/* Séparateur */}
        <div className={styles.divider} />

        {/* Bas du footer */}
        <div className={styles.bottom}>
          <p className={styles.copyright}>
            © {currentYear} Alpha Laundry. Tous droits réservés.
          </p>
          <div className={styles.bottomLinks}>
            <Link href="/privacy">Politique de confidentialité</Link>
            <Link href="/terms">Conditions d'utilisation</Link>
            <Link href="/cookies">Gestion des cookies</Link>
          </div>
        </div>
      </div>
    </footer>
  );
};
