/**
 * ❓ FAQ Section - Questions fréquemment posées
 */

'use client';

import React, { useState } from 'react';
import { GlassCard } from '../common/GlassCard';
import styles from './FAQ.module.css';
import { FAQ as FAQ_DATA } from '@/lib/constants';

interface FAQItemProps {
  question: string;
  answer: string;
  isOpen: boolean;
  onToggle: () => void;
}

const FAQItem: React.FC<FAQItemProps> = ({ question, answer, isOpen, onToggle }) => {
  return (
    <GlassCard
      className={styles.faqCard}
      onClick={onToggle}
      hover={true}
    >
      <div className={styles.faqHeader}>
        <h3 className={styles.question}>{question}</h3>
        <span className={`${styles.icon} ${isOpen ? styles.open : ''}`}>
          ▼
        </span>
      </div>
      {isOpen && (
        <div className={styles.answer}>
          <p>{answer}</p>
        </div>
      )}
    </GlassCard>
  );
};

export const FAQ: React.FC = () => {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <section className={styles.faq}>
      <div className={styles.container}>
        <div className={styles.header}>
          <h2 className={styles.title}>Questions Fréquemment Posées</h2>
          <p className={styles.subtitle}>
            Trouvez les réponses à vos questions les plus courantes
          </p>
        </div>

        <div className={styles.faqList}>
          {FAQ_DATA.map((item, index) => (
            <FAQItem
              key={index}
              question={item.question}
              answer={item.answer}
              isOpen={openIndex === index}
              onToggle={() => setOpenIndex(openIndex === index ? null : index)}
            />
          ))}
        </div>
      </div>
    </section>
  );
};
