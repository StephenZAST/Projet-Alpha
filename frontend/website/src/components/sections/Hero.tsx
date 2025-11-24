/**
 * 🦸 Hero Section - Carousel Premium avec Images Larges
 * Alternance fluide entre slides avec animations ease
 */

'use client';

import React, { useEffect, useState, useCallback, useRef } from 'react';
import Image from 'next/image';
import { Button } from '../common/Button';
import styles from './Hero.module.css';
import { HERO_SLIDES, EXTERNAL_LINKS } from '@/lib/constants';

export const Hero: React.FC = () => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [isAutoPlay, setIsAutoPlay] = useState(true);
  const [isMounted, setIsMounted] = useState(false);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Navigation vers le slide suivant
  const nextSlide = useCallback(() => {
    setCurrentSlide((prev) => (prev + 1) % HERO_SLIDES.length);
    setIsAutoPlay(false);
  }, []);

  // Navigation vers le slide précédent
  const prevSlide = useCallback(() => {
    setCurrentSlide((prev) => (prev - 1 + HERO_SLIDES.length) % HERO_SLIDES.length);
    setIsAutoPlay(false);
  }, []);

  // Aller à un slide spécifique
  const goToSlide = useCallback((index: number) => {
    setCurrentSlide(index);
    setIsAutoPlay(false);
  }, []);

  // Montage du composant
  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Auto-play des slides
  useEffect(() => {
    if (!isAutoPlay || !isMounted) return;

    // Nettoyer l'intervalle précédent
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    intervalRef.current = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % HERO_SLIDES.length);
    }, 6000); // Change slide toutes les 6 secondes

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [isAutoPlay, isMounted]);

  // Reprendre auto-play après 10 secondes d'inactivité
  useEffect(() => {
    if (isAutoPlay || !isMounted) return;

    // Nettoyer le timeout précédent
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    timeoutRef.current = setTimeout(() => {
      setIsAutoPlay(true);
    }, 10000);

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [isAutoPlay, isMounted]);

  // Cleanup au démontage
  useEffect(() => {
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, []);

  if (!isMounted) {
    return null;
  }

  const slide = HERO_SLIDES[currentSlide];

  return (
    <section className={styles.hero}>
      <div className={styles.carousel}>
        <div className={styles.slides}>
          {HERO_SLIDES.map((s, index) => (
            <div
              key={s.id}
              className={`${styles.slide} ${
                index === currentSlide ? styles.active : ''
              } ${index < currentSlide ? styles.prev : ''}`}
            >
              {/* Background Image */}
              <div className={styles.slideBackground}>
                <Image
                  src={s.image}
                  alt={s.title}
                  fill
                  className={styles.slideImage}
                  priority={index === 0}
                  quality={85}
                />
              </div>

              {/* Overlay Gradient */}
              <div className={styles.slideOverlay} />

              {/* Contenu Texte */}
              <div className={styles.slideContent}>
                <h1 className={styles.slideTitle}>{s.title}</h1>
                <p className={styles.slideSubtitle}>{s.subtitle}</p>

                <div className={styles.slideCtas}>
                  <Button
                    variant="primary"
                    size="large"
                    onClick={() => (window.location.href = s.ctaLink)}
                  >
                    {s.cta1}
                  </Button>
                  <Button
                    variant="outline"
                    size="large"
                    onClick={() => (window.location.href = `tel:${s.ctaPhone}`)}
                    icon="📞"
                    iconPosition="left"
                  >
                    {s.cta2}
                  </Button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Carousel Controls */}
        <div className={styles.controls}>
          {/* Navigation Buttons */}
          <button
            className={styles.navButton}
            onClick={prevSlide}
            aria-label="Slide précédent"
            title="Slide précédent"
          >
            ←
          </button>

          {/* Dots Indicators */}
          <div className={styles.dots}>
            {HERO_SLIDES.map((_, index) => (
              <button
                key={index}
                className={`${styles.dot} ${
                  index === currentSlide ? styles.active : ''
                }`}
                onClick={() => goToSlide(index)}
                aria-label={`Aller au slide ${index + 1}`}
                title={`Slide ${index + 1}`}
              />
            ))}
          </div>

          {/* Navigation Buttons */}
          <button
            className={styles.navButton}
            onClick={nextSlide}
            aria-label="Slide suivant"
            title="Slide suivant"
          >
            →
          </button>
        </div>
      </div>
    </section>
  );
};
