/**
 * 📱 Client App Landing Page
 * Page de présentation de l'application mobile client Alpha Pressing
 * Explique les fonctionnalités, avantages et comment utiliser l'app
 */

'use client';

import React from 'react';
import Image from 'next/image';
import { FiCheck, FiSmartphone, FiMapPin, FiClock, FiAward, FiExternalLink } from 'react-icons/fi';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { EXTERNAL_LINKS } from '@/lib/constants';
import styles from './ClientApp.module.css';

export default function ClientAppPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }} className={styles.container}>
      {/* ============================================================================
          HERO SECTION - Présentation de l'app
          ============================================================================ */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <div className={styles.heroText}>
            <h1 className={styles.heroTitle}>
              Votre Blanchisserie Premium
              <span className={styles.highlight}> Dans Votre Poche</span>
            </h1>
            <p className={styles.heroSubtitle}>
              Commandez, suivez et gérez vos vêtements avec l'application mobile Alpha Pressing.
              Service de collecte gratuit, qualité garantie, prix justes.
            </p>
            
            <div className={styles.ctaButtons}>
              <a href={EXTERNAL_LINKS.clientApp} target="_blank" rel="noopener noreferrer" className={styles.primaryButton} style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: '10px' }}>
                <FiExternalLink size={20} />
                Lancer l'App Web
              </a>
            </div>
            <p className={styles.appAvailabilityNote}>
              📱 Les applications iOS et Android seront bientôt disponibles sur l'App Store et Google Play.
              Pour le moment, utilisez la version web qui fonctionne parfaitement sur tous les appareils!
            </p>

            <div className={styles.stats}>
              <div className={styles.stat}>
                <span className={styles.statNumber}>500+</span>
                <span className={styles.statLabel}>Clients actifs</span>
              </div>
              <div className={styles.stat}>
                <span className={styles.statNumber}>4.8★</span>
                <span className={styles.statLabel}>Note moyenne</span>
              </div>
              <div className={styles.stat}>
                <span className={styles.statNumber}>24/7</span>
                <span className={styles.statLabel}>Support client</span>
              </div>
            </div>
          </div>

          <div className={styles.heroImage}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/client app home page dual.png"
                alt="Écran d'accueil de l'app client"
                width={300}
                height={600}
                priority
                className={styles.phoneImage}
              />
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================================
          FEATURES SECTION - Fonctionnalités principales
          ============================================================================ */}
      <section className={styles.features}>
        <div className={styles.sectionHeader}>
          <h2>Fonctionnalités Principales</h2>
          <p>Tout ce dont vous avez besoin pour gérer vos vêtements facilement</p>
        </div>

        <div className={styles.featuresGrid}>
          {/* Feature 1: Commandes faciles */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>
              <FiSmartphone size={32} />
            </div>
            <h3>Commandes Faciles</h3>
            <p>
              Créez une commande en quelques clics. Sélectionnez vos articles, 
              choisissez le service et confirmez. C'est aussi simple que ça.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Sélection d'articles intuitive</li>
              <li><FiCheck size={18} /> Calcul de prix en temps réel</li>
              <li><FiCheck size={18} /> Sauvegarde de brouillons</li>
            </ul>
          </div>

          {/* Feature 2: Suivi en temps réel */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>
              <FiMapPin size={32} />
            </div>
            <h3>Suivi en Temps Réel</h3>
            <p>
              Suivez votre commande à chaque étape. Collecte, traitement, 
              livraison - vous êtes toujours informé.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Notifications instantanées</li>
              <li><FiCheck size={18} /> Localisation GPS du livreur</li>
              <li><FiCheck size={18} /> Historique complet</li>
            </ul>
          </div>

          {/* Feature 3: Gestion des adresses */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>
              <FiMapPin size={32} />
            </div>
            <h3>Gestion des Adresses</h3>
            <p>
              Enregistrez plusieurs adresses de collecte et livraison. 
              Sélectionnez rapidement votre adresse préférée.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Adresses sauvegardées</li>
              <li><FiCheck size={18} /> Localisation GPS</li>
              <li><FiCheck size={18} /> Adresse par défaut</li>
            </ul>
          </div>

          {/* Feature 4: Points de fidélité */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>
              <FiAward size={32} />
            </div>
            <h3>Points de Fidélité</h3>
            <p>
              Gagnez des points à chaque commande et convertissez-les en réductions. 
              Plus vous commandez, plus vous économisez.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> 1 point par 0.1€ dépensé</li>
              <li><FiCheck size={18} /> Récompenses exclusives</li>
              <li><FiCheck size={18} /> Paliers de fidélité</li>
            </ul>
          </div>

          {/* Feature 5: Collecte gratuite */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>
              <FiClock size={32} />
            </div>
            <h3>Collecte Gratuite</h3>
            <p>
              Nous venons chercher vos vêtements à domicile. Pas de frais cachés, 
              pas de surprise à la livraison.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Collecte à domicile</li>
              <li><FiCheck size={18} /> Horaires flexibles</li>
              <li><FiCheck size={18} /> Livraison gratuite</li>
            </ul>
          </div>

          {/* Feature 6: Support 24/7 */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>
              <FiSmartphone size={32} />
            </div>
            <h3>Support 24/7</h3>
            <p>
              Une question ? Un problème ? Notre équipe est toujours disponible 
              pour vous aider rapidement.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Chat en direct</li>
              <li><FiCheck size={18} /> Email support</li>
              <li><FiCheck size={18} /> Téléphone</li>
            </ul>
          </div>
        </div>
      </section>

      {/* ============================================================================
          SCREENSHOTS SECTION - Galerie des écrans
          ============================================================================ */}
      <section className={styles.screenshots}>
        <div className={styles.sectionHeader}>
          <h2>Découvrez l'Interface</h2>
          <p>Une expérience utilisateur fluide et intuitive</p>
        </div>

        <div className={styles.screenshotsGrid}>
          <div className={styles.screenshotItem}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/client app home simple screen.png"
                alt="Écran d'accueil"
                width={280}
                height={560}
                className={styles.screenshot}
              />
            </div>
            <h4>Accueil</h4>
            <p>Accès rapide à vos commandes et services</p>
          </div>

          <div className={styles.screenshotItem}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/client app adress screen.png"
                alt="Gestion des adresses"
                width={280}
                height={560}
                className={styles.screenshot}
              />
            </div>
            <h4>Adresses</h4>
            <p>Gérez vos adresses de collecte et livraison</p>
          </div>

          <div className={styles.screenshotItem}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/client app order recap screen.png"
                alt="Récapitulatif de commande"
                width={280}
                height={560}
                className={styles.screenshot}
              />
            </div>
            <h4>Récapitulatif</h4>
            <p>Vérifiez les détails avant de confirmer</p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          HOW IT WORKS SECTION - Comment ça marche
          ============================================================================ */}
      <section className={styles.howItWorks}>
        <div className={styles.sectionHeader}>
          <h2>Comment Ça Marche</h2>
          <p>4 étapes simples pour un service impeccable</p>
        </div>

        <div className={styles.stepsContainer}>
          <div className={styles.step}>
            <div className={styles.stepNumber}>1</div>
            <h3>Créer une Commande</h3>
            <p>
              Ouvrez l'app, sélectionnez vos articles et le service désiré. 
              Le prix s'affiche instantanément.
            </p>
          </div>

          <div className={styles.stepArrow}>→</div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>2</div>
            <h3>Planifier la Collecte</h3>
            <p>
              Choisissez votre adresse et l'heure de collecte. 
              Notre livreur viendra chercher vos vêtements.
            </p>
          </div>

          <div className={styles.stepArrow}>→</div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>3</div>
            <h3>Suivi en Temps Réel</h3>
            <p>
              Recevez des notifications à chaque étape. 
              Collecte, traitement, prêt pour livraison.
            </p>
          </div>

          <div className={styles.stepArrow}>→</div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>4</div>
            <h3>Livraison à Domicile</h3>
            <p>
              Vos vêtements arrivent impeccables à votre porte. 
              Payez et profitez de votre service premium.
            </p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          BENEFITS SECTION - Avantages
          ============================================================================ */}
      <section className={styles.benefits}>
        <div className={styles.sectionHeader}>
          <h2>Pourquoi Choisir Alpha Pressing</h2>
          <p>Les avantages qui font la différence</p>
        </div>

        <div className={styles.benefitsGrid}>
          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>✨</div>
            <h3>Qualité Garantie</h3>
            <p>Nettoyage professionnel avec les meilleures techniques</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>💰</div>
            <h3>Prix Justes</h3>
            <p>Tarification transparente sans frais cachés</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>🚚</div>
            <h3>Collecte Gratuite</h3>
            <p>Nous venons chercher vos vêtements à domicile</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>⏱️</div>
            <h3>Rapide & Fiable</h3>
            <p>Délais respectés, service professionnel</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>🎁</div>
            <h3>Points de Fidélité</h3>
            <p>Gagnez des points et obtenez des réductions</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>📱</div>
            <h3>App Intuitive</h3>
            <p>Interface simple et facile à utiliser</p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          TESTIMONIALS SECTION - Témoignages
          ============================================================================ */}
      <section className={styles.testimonials}>
        <div className={styles.sectionHeader}>
          <h2>Ce Que Disent Nos Clients</h2>
          <p>Des avis authentiques de nos utilisateurs satisfaits</p>
        </div>

        <div className={styles.testimonialsGrid}>
          <div className={styles.testimonialCard}>
            <div className={styles.stars}>★★★★★</div>
            <p>
              "L'application est super facile à utiliser. J'ai commandé en 2 minutes 
              et le service était impeccable. Je recommande vivement!"
            </p>
            <div className={styles.testimonialAuthor}>
              <div className={styles.avatar}>M</div>
              <div>
                <strong>Marie Dupont</strong>
                <span>Client depuis 6 mois</span>
              </div>
            </div>
          </div>

          <div className={styles.testimonialCard}>
            <div className={styles.stars}>★★★★★</div>
            <p>
              "Enfin un service de pressing qui respecte les délais et la qualité. 
              Les points de fidélité sont un vrai plus!"
            </p>
            <div className={styles.testimonialAuthor}>
              <div className={styles.avatar}>J</div>
              <div>
                <strong>Jean Martin</strong>
                <span>Client depuis 1 an</span>
              </div>
            </div>
          </div>

          <div className={styles.testimonialCard}>
            <div className={styles.stars}>★★★★★</div>
            <p>
              "Le suivi en temps réel est génial. Je sais exactement où est mon 
              livreur et quand il arrive. Service professionnel!"
            </p>
            <div className={styles.testimonialAuthor}>
              <div className={styles.avatar}>S</div>
              <div>
                <strong>Sophie Bernard</strong>
                <span>Client depuis 3 mois</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================================
          CTA SECTION - Appel à l'action final
          ============================================================================ */}
      <section className={styles.finalCta}>
        <h2>Prêt à Essayer?</h2>
        <p>Commencez dès maintenant avec la version web et bénéficiez d'une réduction de 10% sur votre première commande</p>
        
        <a href={EXTERNAL_LINKS.clientApp} target="_blank" rel="noopener noreferrer" className={styles.primaryButton} style={{ textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: '10px', marginTop: '24px' }}>
          <FiExternalLink size={20} />
          Accéder à l'App
        </a>

        <p className={styles.ctaNote}>
          ✓ Pas d'installation requise • Fonctionne sur tous les appareils • Les nouveaux clients créent un compte, les clients existants se connectent
        </p>
      </section>
      </main>
      <Footer />
    </>
  );
}
