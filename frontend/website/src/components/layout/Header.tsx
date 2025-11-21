/**
 * 🎯 Header Component - Navigation principale
 */

'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { Button } from '../common/Button';
import styles from './Header.module.css';
import { NAVIGATION, EXTERNAL_LINKS } from '@/lib/constants';

export const Header: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={`${styles.header} ${isScrolled ? styles.scrolled : ''}`}>
      <div className={styles.container}>
        {/* Logo */}
        <Link href="/" className={styles.logo}>
          <Image
            src="/images/alphalogo.svg"
            alt="Alpha Laundry"
            width={40}
            height={40}
            priority
          />
          <span className={styles.logoText}>Alpha Laundry</span>
        </Link>

        {/* Navigation Desktop */}
        <nav className={styles.nav}>
          {NAVIGATION.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={styles.navLink}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        {/* Boutons d'action */}
        <div className={styles.actions}>
          <Button
            variant="outline"
            size="medium"
            onClick={() => window.location.href = EXTERNAL_LINKS.clientApp}
          >
            Connexion
          </Button>
          <Button
            variant="primary"
            size="medium"
            onClick={() => window.location.href = EXTERNAL_LINKS.clientApp}
          >
            Inscription
          </Button>
        </div>

        {/* Menu Mobile */}
        <button
          className={`${styles.mobileMenuButton} ${isMobileMenuOpen ? styles.open : ''}`}
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          aria-label="Menu"
        >
          <span />
          <span />
          <span />
        </button>
      </div>

      {/* Menu Mobile Dropdown */}
      {isMobileMenuOpen && (
        <div className={styles.mobileMenu}>
          <nav className={styles.mobileNav}>
            {NAVIGATION.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={styles.mobileNavLink}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                {item.label}
              </Link>
            ))}
          </nav>
          <div className={styles.mobileActions}>
            <Button
              variant="outline"
              size="medium"
              fullWidth
              onClick={() => {
                window.location.href = EXTERNAL_LINKS.clientApp;
                setIsMobileMenuOpen(false);
              }}
            >
              Connexion
            </Button>
            <Button
              variant="primary"
              size="medium"
              fullWidth
              onClick={() => {
                window.location.href = EXTERNAL_LINKS.clientApp;
                setIsMobileMenuOpen(false);
              }}
            >
              Inscription
            </Button>
          </div>
        </div>
      )}
    </header>
  );
};
