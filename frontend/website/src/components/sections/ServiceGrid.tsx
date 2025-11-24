/**
 * 🧺 Service Grid Section - Services Détaillées avec données dynamiques
 */

'use client';

import React, { useEffect, useState } from 'react';
import styles from './ServiceGrid.module.css';
import { EXTERNAL_LINKS, ADDITIONAL_SERVICES } from '@/lib/constants';

interface Service {
  id: string;
  name: string;
  description: string;
  icon: string;
  features: string[];
}

export const ServiceGrid: React.FC = () => {
  const [services, setServices] = useState<Service[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isVisible, setIsVisible] = useState(false);

  // URL Render du backend
  const RENDER_BACKEND_URL = 'https://alpha-laundry-backend.onrender.com';

  // Fonction de retry avec délai exponentiel
  const fetchWithRetry = async (url: string, maxRetries = 3): Promise<Response> => {
    let lastError: Error | null = null;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 8000);

        const response = await fetch(url, { signal: controller.signal });
        clearTimeout(timeoutId);

        if (response.ok) {
          return response;
        }

        if (response.status === 503 || response.status === 502) {
          throw new Error(`Serveur indisponible (${response.status})`);
        }

        return response;
      } catch (error) {
        lastError = error as Error;
        console.warn(`Tentative ${attempt}/${maxRetries} échouée:`, lastError.message);

        if (attempt < maxRetries) {
          const delay = Math.pow(2, attempt) * 1000;
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    throw lastError || new Error('Échec après plusieurs tentatives');
  };

  // Récupérer les services du backend avec retry
  useEffect(() => {
    const fetchServices = async () => {
      try {
        setIsLoading(true);
        const url = `${RENDER_BACKEND_URL}/api/services/all`;
        console.log('🔄 Récupération des services depuis:', url);
        
        const response = await fetchWithRetry(url, 3);
        
        if (!response.ok) {
          throw new Error(`Erreur HTTP ${response.status}`);
        }

        const data = await response.json();
        
        // Debug: Afficher la structure complète
        console.log('📦 Réponse brute services:', data);
        
        const servicesData = Array.isArray(data) ? data : data.data || [];
        console.log('📊 Nombre total de services reçus:', servicesData.length);
        
        if (servicesData.length > 0) {
          console.log('🔍 Structure du 1er service:', servicesData[0]);
          console.log('🏷️ Clés disponibles:', Object.keys(servicesData[0]));
        }
        
        const mappedServices: Service[] = servicesData.map((service: any) => {
          const mapped = {
            id: service.id || service._id,
            name: service.name || service.serviceName || 'Service',
            description: service.description || 'Service de nettoyage professionnel',
            icon: service.icon || '🧺',
            features: service.features || [
              'Technique optimisée',
              'Résultats garantis',
              'Respect des textiles'
            ]
          };
          
          if (Object.keys(servicesData).indexOf(servicesData[0]) === 0) {
            console.log('🎯 1er service mappé:', mapped);
          }
          
          return mapped;
        });

        if (mappedServices.length > 0) {
          setServices(mappedServices);
          console.log('✅ Services récupérés depuis API:', mappedServices.length, 'services');
        } else {
          throw new Error('Aucun service retourné');
        }
      } catch (error) {
        console.error('❌ Erreur API:', error);
        console.log('📦 Utilisation des services de fallback');
        // Fallback avec les services constants si l'API échoue
        const fallbackServices: Service[] = [
          {
            id: 'laundry',
            name: 'Laverie et Repassage Soigné',
            description: 'Notre laverie utilise les meilleures technologies pour garantir un nettoyage de haute qualité de vos vêtements.',
            icon: '🧺',
            features: [
              'Traitement délicat des tissus',
              'Détachement naturel',
              'Repassage professionnel'
            ]
          },
          {
            id: 'drycleaning',
            name: 'Nettoyage à Sec',
            description: 'Nous offrons un nettoyage à sec rapide et efficace qui élimine les impuretés et les odeurs sans abîmer les tissus.',
            icon: '✨',
            features: [
              'Produits premium',
              'Résultats impeccables',
              'Délai 24h garanti'
            ]
          },
          {
            id: 'repair',
            name: 'Retouche et Détachement',
            description: 'Nous réalisons des retouches et des détachements de vêtements de haute qualité avec expertise.',
            icon: '🔧',
            features: [
              'Réparation expertisée',
              'Détachement spécialisé',
              'Couture invisible'
            ]
          }
        ];
        setServices(fallbackServices);
      } finally {
        setIsLoading(false);
      }
    };

    fetchServices();
  }, []);

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

  const handleReserve = (serviceId: string) => {
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
        {isLoading ? (
          <div className={styles.grid}>
            {[1, 2, 3].map((i) => (
              <div key={i} className={styles.card} style={{ opacity: 0.5 }}>
                <div style={{ height: '100px', background: '#e0e0e0', borderRadius: '8px' }} />
              </div>
            ))}
          </div>
        ) : (
          <div className={styles.grid}>
            {services.map((service, index) => (
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
                    onClick={() => handleReserve(service.id)}
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
        )}

        {/* Services Additionnels */}
        {!isLoading && (
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
        )}
      </div>
    </section>
  );
};
