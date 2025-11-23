/**
 * 🤝 Affiliate App Landing Page
 * Page de présentation de l'application mobile affiliate Alpha Pressing
 * Explique le programme d'affiliation, les commissions et comment gagner
 */

'use client';

import React from 'react';
import Image from 'next/image';
import { FiDownload, FiCheck, FiArrowRight, FiTrendingUp, FiUsers, FiAward, FiDollarSign, FiExternalLink } from 'react-icons/fi';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { EXTERNAL_LINKS } from '@/lib/constants';
import styles from './AffiliateApp.module.css';

export default function AffiliateAppPage() {
  return (
    <>
      <Header />
      <main style={{ paddingTop: '70px' }} className={styles.container}>
      {/* ============================================================================
          HERO SECTION - Présentation du programme d'affiliation
          ============================================================================ */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <div className={styles.heroText}>
            <h1 className={styles.heroTitle}>
              Gagnez de l'Argent
              <span className={styles.highlight}> En Recommandant</span>
            </h1>
            <p className={styles.heroSubtitle}>
              Rejoignez le programme d'affiliation Alpha Pressing et gagnez des commissions 
              généreuses sur chaque client que vous référez. Pas de limite, pas de plafond.
            </p>
            
            <div className={styles.highlights}>
              <div className={styles.highlightItem}>
                <FiTrendingUp size={24} />
                <div>
                  <strong>Commissions Élevées</strong>
                  <p>Jusqu'à 20% de commission par client</p>
                </div>
              </div>
              <div className={styles.highlightItem}>
                <FiUsers size={24} />
                <div>
                  <strong>Pas de Limite</strong>
                  <p>Gagnez autant que vous le souhaitez</p>
                </div>
              </div>
              <div className={styles.highlightItem}>
                <FiDollarSign size={24} />
                <div>
                  <strong>Paiements Rapides</strong>
                  <p>Retraits hebdomadaires ou mensuels</p>
                </div>
              </div>
            </div>

            <div className={styles.ctaButtons}>
              <a href={EXTERNAL_LINKS.affiliateApp} target="_blank" rel="noopener noreferrer" className={styles.primaryButton} style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: '10px' }}>
                <FiExternalLink size={20} />
                Lancer l'App Affiliate
              </a>
            </div>
          </div>

          <div className={styles.heroImage}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/affiliate home page.png"
                alt="Écran d'accueil de l'app affiliate"
                width={400}
                height={800}
                priority
                className={styles.phoneImage}
              />
            </div>
          </div>
        </div>
      </section>

      {/* ============================================================================
          COMMISSION STRUCTURE SECTION - Structure des commissions
          ============================================================================ */}
      <section className={styles.commissions}>
        <div className={styles.sectionHeader}>
          <h2>Structure de Commissions</h2>
          <p>Plus vous gagnez, plus votre commission augmente</p>
        </div>

        <div className={styles.commissionLevels}>
          <div className={styles.levelCard}>
            <div className={styles.levelBadge} style={{ background: '#CD7F32' }}>
              BRONZE
            </div>
            <h3>Niveau Bronze</h3>
            <p>Parfait pour commencer votre parcours d'affiliation</p>
          </div>

          <div className={styles.levelCard}>
            <div className={styles.levelBadge} style={{ background: '#C0C0C0' }}>
              SILVER
            </div>
            <h3>Niveau Argent</h3>
            <p>Débloquez des avantages exclusifs et un support prioritaire</p>
          </div>

          <div className={styles.levelCard + ' ' + styles.featured}>
            <div className={styles.levelBadge} style={{ background: '#FFD700' }}>
              GOLD
            </div>
            <h3>Niveau Or</h3>
            <p>Accès VIP, bonus mensuels et support dédié</p>
          </div>

          <div className={styles.levelCard}>
            <div className={styles.levelBadge} style={{ background: '#E5E4E2' }}>
              PLATINUM
            </div>
            <h3>Niveau Platine</h3>
            <p>Statut d'élite avec avantages exceptionnels</p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          FEATURES SECTION - Fonctionnalités de l'app
          ============================================================================ */}
      <section className={styles.features}>
        <div className={styles.sectionHeader}>
          <h2>Fonctionnalités Principales</h2>
          <p>Tout ce dont vous avez besoin pour gérer votre affiliation</p>
        </div>

        <div className={styles.featuresGrid}>
          {/* Feature 1: Dashboard */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>📊</div>
            <h3>Dashboard Complet</h3>
            <p>
              Visualisez vos statistiques en temps réel. Commissions, clients, 
              revenus - tout en un coup d'œil.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Statistiques en temps réel</li>
              <li><FiCheck size={18} /> Graphiques de performance</li>
              <li><FiCheck size={18} /> Historique complet</li>
            </ul>
          </div>

          {/* Feature 2: Code de Référence */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>🔗</div>
            <h3>Code de Référence Unique</h3>
            <p>
              Obtenez un code unique à partager avec vos contacts. 
              Chaque client qui l'utilise vous rapporte une commission.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Code personnalisé</li>
              <li><FiCheck size={18} /> Lien de partage direct</li>
              <li><FiCheck size={18} /> QR code généré</li>
            </ul>
          </div>

          {/* Feature 3: Suivi des Clients */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>👥</div>
            <h3>Suivi des Clients</h3>
            <p>
              Suivez tous vos clients référés. Voyez leurs commandes, 
              leurs dépenses et vos commissions associées.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Liste des clients</li>
              <li><FiCheck size={18} /> Historique des commandes</li>
              <li><FiCheck size={18} /> Commissions par client</li>
            </ul>
          </div>

          {/* Feature 4: Gestion des Retraits */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>💰</div>
            <h3>Gestion des Retraits</h3>
            <p>
              Demandez un retrait quand vous le souhaitez. Paiements rapides 
              et sécurisés directement sur votre compte.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Retraits illimités</li>
              <li><FiCheck size={18} /> Paiements sécurisés</li>
              <li><FiCheck size={18} /> Historique des paiements</li>
            </ul>
          </div>

          {/* Feature 5: Notifications */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>🔔</div>
            <h3>Notifications Instantanées</h3>
            <p>
              Recevez des notifications pour chaque nouvelle commande de vos clients, 
              chaque commission gagnée et chaque retrait approuvé.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Notifications push</li>
              <li><FiCheck size={18} /> Alertes de commission</li>
              <li><FiCheck size={18} /> Mises à jour de statut</li>
            </ul>
          </div>

          {/* Feature 6: Support Dédié */}
          <div className={styles.featureCard}>
            <div className={styles.featureIcon}>🎧</div>
            <h3>Support Dédié</h3>
            <p>
              Une équipe dédiée pour vous aider. Questions, problèmes, 
              conseils - nous sommes toujours là pour vous.
            </p>
            <ul className={styles.featureList}>
              <li><FiCheck size={18} /> Chat en direct</li>
              <li><FiCheck size={18} /> Email support</li>
              <li><FiCheck size={18} /> Ressources d'aide</li>
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
          <p>Une expérience utilisateur intuitive et professionnelle</p>
        </div>

        <div className={styles.screenshotsGrid}>
          <div className={styles.screenshotItem}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/affiliate home page simple.png"
                alt="Écran d'accueil"
                width={280}
                height={560}
                className={styles.screenshot}
              />
            </div>
            <h4>Accueil</h4>
            <p>Vue d'ensemble de vos statistiques</p>
          </div>

          <div className={styles.screenshotItem}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/Affiliate customer screen.png"
                alt="Gestion des clients"
                width={280}
                height={560}
                className={styles.screenshot}
              />
            </div>
            <h4>Clients</h4>
            <p>Suivi de vos clients référés</p>
          </div>

          <div className={styles.screenshotItem}>
            <div className={styles.phoneFrame}>
              <Image
                src="/images/app_mockups/affiliate login page.png"
                alt="Connexion"
                width={280}
                height={560}
                className={styles.screenshot}
              />
            </div>
            <h4>Connexion</h4>
            <p>Accès sécurisé à votre compte</p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          HOW TO EARN SECTION - Comment gagner
          ============================================================================ */}
      <section className={styles.howToEarn}>
        <div className={styles.sectionHeader}>
          <h2>Comment Gagner</h2>
          <p>3 étapes simples pour commencer à gagner</p>
        </div>

        <div className={styles.stepsContainer}>
          <div className={styles.step}>
            <div className={styles.stepNumber}>1</div>
            <h3>Rejoindre le Programme</h3>
            <p>
              Inscrivez-vous gratuitement et obtenez votre code de référence unique. 
              Aucune condition, aucun frais.
            </p>
          </div>

          <div className={styles.stepArrow}>→</div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>2</div>
            <h3>Partager Votre Code</h3>
            <p>
              Partagez votre code avec vos amis, famille et contacts. 
              Via SMS, email, réseaux sociaux - comme vous le souhaitez.
            </p>
          </div>

          <div className={styles.stepArrow}>→</div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>3</div>
            <h3>Gagner des Commissions</h3>
            <p>
              Chaque client qui utilise votre code vous rapporte une commission. 
              Plus ils commandent, plus vous gagnez.
            </p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          BENEFITS SECTION - Avantages
          ============================================================================ */}
      <section className={styles.benefits}>
        <div className={styles.sectionHeader}>
          <h2>Avantages du Programme</h2>
          <p>Pourquoi rejoindre Alpha Affiliate</p>
        </div>

        <div className={styles.benefitsGrid}>
          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>💎</div>
            <h3>Commissions Élevées</h3>
            <p>Jusqu'à 20% de commission par client référé</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>📈</div>
            <h3>Croissance Illimitée</h3>
            <p>Pas de plafond de commission, gagnez autant que vous le souhaitez</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>🎁</div>
            <h3>Bonus Mensuels</h3>
            <p>Bonus supplémentaires pour les meilleurs affiliés</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>⚡</div>
            <h3>Paiements Rapides</h3>
            <p>Retraits hebdomadaires ou mensuels sans délai</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>🤝</div>
            <h3>Support Dédié</h3>
            <p>Équipe dédiée pour vous aider à réussir</p>
          </div>

          <div className={styles.benefitItem}>
            <div className={styles.benefitIcon}>🌟</div>
            <h3>Outils Marketing</h3>
            <p>Ressources et outils pour promouvoir votre code</p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          FAQ SECTION - Questions fréquentes
          ============================================================================ */}
      <section className={styles.faq}>
        <div className={styles.sectionHeader}>
          <h2>Questions Fréquentes</h2>
          <p>Tout ce que vous devez savoir sur le programme</p>
        </div>

        <div className={styles.faqGrid}>
          <div className={styles.faqItem}>
            <h4>Combien coûte l'inscription?</h4>
            <p>L'inscription est complètement gratuite. Aucun frais, aucune condition.</p>
          </div>

          <div className={styles.faqItem}>
            <h4>Quand reçois-je mes commissions?</h4>
            <p>Les commissions sont calculées en temps réel et vous pouvez les retirer quand vous le souhaitez.</p>
          </div>

          <div className={styles.faqItem}>
            <h4>Y a-t-il un minimum de retrait?</h4>
            <p>Oui, le minimum de retrait est de 5000 FCFA pour assurer des frais de transaction raisonnables.</p>
          </div>

          <div className={styles.faqItem}>
            <h4>Comment puis-je augmenter ma commission?</h4>
            <p>Votre commission augmente automatiquement selon votre niveau d'affiliation basé sur vos gains.</p>
          </div>

          <div className={styles.faqItem}>
            <h4>Puis-je créer des sous-affiliés?</h4>
            <p>Oui! Vous pouvez créer des sous-affiliés et gagner une commission sur leurs commissions.</p>
          </div>

          <div className={styles.faqItem}>
            <h4>Comment puis-je promouvoir mon code?</h4>
            <p>Vous pouvez partager votre code via SMS, email, réseaux sociaux ou en personne.</p>
          </div>
        </div>
      </section>

      {/* ============================================================================
          FINAL CTA SECTION - Appel à l'action final
          ============================================================================ */}
      <section className={styles.finalCta}>
        <h2>Prêt à Commencer?</h2>
        <p>Rejoignez des centaines d'affiliés qui gagnent déjà avec Alpha Pressing</p>
        
        <a href={EXTERNAL_LINKS.affiliateApp} target="_blank" rel="noopener noreferrer" className={styles.primaryButton} style={{ textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: '10px', marginTop: '24px' }}>
          <FiExternalLink size={20} />
          Accéder à l'App
        </a>

        <p className={styles.ctaNote}>
          ✓ Gratuit • Pas de frais cachés • Support 24/7
        </p>
      </section>
      </main>
      <Footer />
    </>
  );
}
