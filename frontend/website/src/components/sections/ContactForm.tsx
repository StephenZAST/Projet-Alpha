/**
 * 📧 Contact Form Section
 */

'use client';

import React, { useState } from 'react';
import styles from './ContactForm.module.css';
import { EXTERNAL_LINKS } from '@/lib/constants';

export const ContactForm: React.FC = () => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    subject: 'general',
    message: '',
  });

  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation simple
    if (!formData.firstName || !formData.lastName || !formData.email || !formData.message) {
      setStatus('error');
      setMessage('Veuillez remplir tous les champs obligatoires');
      return;
    }

    if (formData.message.length < 20) {
      setStatus('error');
      setMessage('Votre message doit contenir au moins 20 caractères');
      return;
    }

    setStatus('loading');

    try {
      // Simuler un envoi (à remplacer par un appel API réel)
      await new Promise((resolve) => setTimeout(resolve, 1000));

      setStatus('success');
      setMessage('Merci! Votre message a été envoyé. Nous vous répondrons sous 24h.');
      setFormData({
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        subject: 'general',
        message: '',
      });

      // Réinitialiser le message après 5 secondes
      setTimeout(() => setStatus('idle'), 5000);
    } catch (error) {
      setStatus('error');
      setMessage('Une erreur est survenue. Veuillez réessayer.');
    }
  };

  return (
    <section className={styles.contactSection}>
      <div className={styles.container}>
        {/* En-tête */}
        <div className={styles.header}>
          <h1 className={styles.title}>Nous Sommes Là Pour Vous</h1>
          <p className={styles.subtitle}>
            Questions? Suggestions? Nous aimons vous entendre!
          </p>
        </div>

        {/* Contenu */}
        <div className={styles.contentGrid}>
          {/* Section Info */}
          <div className={styles.infoSection}>
            <h2 className={styles.infoTitle}>Coordonnées</h2>

            {/* Adresse */}
            <div className={styles.infoItem}>
              <div>
                <span className={styles.infoIcon}>📍</span>
              </div>
              <div className={styles.infoLabel}>Adresse</div>
              <p className={styles.infoText}>
                Zone 1 Boulevard Tensoba
                <br />
                Rue 28.384
                <br />
                Ouagadougou, Burkina Faso
              </p>
            </div>

            {/* Téléphone */}
            <div className={styles.infoItem}>
              <div>
                <span className={styles.infoIcon}>📞</span>
              </div>
              <div className={styles.infoLabel}>Téléphone</div>
              <p className={styles.infoText}>
                <a href={`tel:${EXTERNAL_LINKS.phone}`} className={styles.infoLink}>
                  {EXTERNAL_LINKS.phone}
                </a>
              </p>
            </div>

            {/* Email */}
            <div className={styles.infoItem}>
              <div>
                <span className={styles.infoIcon}>✉️</span>
              </div>
              <div className={styles.infoLabel}>Email</div>
              <p className={styles.infoText}>
                <a href={`mailto:${EXTERNAL_LINKS.email}`} className={styles.infoLink}>
                  {EXTERNAL_LINKS.email}
                </a>
              </p>
            </div>

            {/* Horaires */}
            <div className={styles.infoItem}>
              <div>
                <span className={styles.infoIcon}>🕐</span>
              </div>
              <div className={styles.infoLabel}>Horaires</div>
              <p className={styles.infoText}>
                Lun-Sam: 9h - 19h
                <br />
                Dim: 10h - 18h
                <br />
                <em>(Fermé les jours fériés)</em>
              </p>
            </div>
          </div>

          {/* Formulaire */}
          <div className={styles.formSection}>
            <h2 className={styles.formTitle}>Nous Contacter</h2>

            {status !== 'idle' && (
              <div className={`${styles.formMessage} ${styles[`form${status.charAt(0).toUpperCase() + status.slice(1)}`]}`}>
                {message}
              </div>
            )}

            <form onSubmit={handleSubmit}>
              <div className={styles.formRow}>
                <div className={styles.formGroup}>
                  <label htmlFor="firstName" className={styles.formLabel}>
                    Prénom *
                  </label>
                  <input
                    type="text"
                    id="firstName"
                    name="firstName"
                    value={formData.firstName}
                    onChange={handleChange}
                    className={styles.formInput}
                    required
                  />
                </div>

                <div className={styles.formGroup}>
                  <label htmlFor="lastName" className={styles.formLabel}>
                    Nom *
                  </label>
                  <input
                    type="text"
                    id="lastName"
                    name="lastName"
                    value={formData.lastName}
                    onChange={handleChange}
                    className={styles.formInput}
                    required
                  />
                </div>
              </div>

              <div className={styles.formRow}>
                <div className={styles.formGroup}>
                  <label htmlFor="email" className={styles.formLabel}>
                    Email *
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className={styles.formInput}
                    required
                  />
                </div>

                <div className={styles.formGroup}>
                  <label htmlFor="phone" className={styles.formLabel}>
                    Téléphone
                  </label>
                  <input
                    type="tel"
                    id="phone"
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    className={styles.formInput}
                  />
                </div>
              </div>

              <div className={styles.formGroup}>
                <label htmlFor="subject" className={styles.formLabel}>
                  Sujet
                </label>
                <select
                  id="subject"
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  className={styles.formSelect}
                >
                  <option value="general">Question générale</option>
                  <option value="support">Support & Réclamation</option>
                  <option value="pricing">Information Tarifs</option>
                  <option value="partnership">Partenariat</option>
                  <option value="feedback">Retours d'Expérience</option>
                </select>
              </div>

              <div className={styles.formGroup}>
                <label htmlFor="message" className={styles.formLabel}>
                  Message *
                </label>
                <textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  className={styles.formTextarea}
                  placeholder="Écrivez votre message..."
                  required
                />
              </div>

              <button
                type="submit"
                className={styles.formButton}
                disabled={status === 'loading'}
              >
                {status === 'loading' ? 'Envoi en cours...' : 'Envoyer le Message'}
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
};
