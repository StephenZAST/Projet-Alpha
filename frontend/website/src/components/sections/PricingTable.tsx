/**
 * 💰 Pricing Table Section - Tableau des tarifs dynamique
 */

'use client';

import React, { useEffect, useState } from 'react';
import styles from './PricingTable.module.css';

interface ArticleServicePrice {
  id: string;
  article_id: string;
  service_type_id: string;
  service_id?: string;
  article_name?: string;
  service_type_name?: string;
  service_name?: string;
  base_price?: number;
  premium_price?: number;
  price_per_kg?: number;
  is_available?: boolean;
}

interface PricingDialogState {
  isOpen: boolean;
  article: ArticleServicePrice | null;
}

export const PricingTable: React.FC = () => {
  const [prices, setPrices] = useState<ArticleServicePrice[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [dataSource, setDataSource] = useState<'api' | 'fallback'>('api');
  const [dialogState, setDialogState] = useState<PricingDialogState>({ isOpen: false, article: null });

  // URL Render du backend
  const RENDER_BACKEND_URL = 'https://alpha-laundry-backend.onrender.com';

  // Données de fallback
  const fallbackPrices: ArticleServicePrice[] = [
    { id: '1', article_id: 'a1', service_type_id: 's1', service_id: 's1', article_name: 'Chemise', service_type_name: 'Laverie', service_name: 'Lavage Simple', base_price: 2500, premium_price: 3000 },
    { id: '2', article_id: 'a2', service_type_id: 's2', service_id: 's2', article_name: 'Pantalon', service_type_name: 'Nettoyage à Sec', service_name: 'Nettoyage à Sec', base_price: 3500, premium_price: 4200 },
    { id: '3', article_id: 'a3', service_type_id: 's1', service_id: 's1', article_name: 'T-shirt', service_type_name: 'Laverie', service_name: 'Lavage Simple', base_price: 1500, premium_price: 1800 },
    { id: '4', article_id: 'a4', service_type_id: 's2', service_id: 's2', article_name: 'Robe', service_type_name: 'Nettoyage à Sec', service_name: 'Nettoyage à Sec', base_price: 5000, premium_price: 6000 },
    { id: '5', article_id: 'a5', service_type_id: 's3', service_id: 's3', article_name: 'Veste', service_type_name: 'Retouche', service_name: 'Retouche et Ajustement', base_price: 4000 },
  ];

  // Fonction de retry avec délai exponentiel
  const fetchWithRetry = async (url: string, maxRetries = 3): Promise<Response> => {
    let lastError: Error | null = null;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 10000);

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

  // Récupérer les tarifs du backend avec retry
  useEffect(() => {
    const fetchPrices = async () => {
      try {
        setIsLoading(true);
        const url = `${RENDER_BACKEND_URL}/api/article-services/prices`;
        
        console.log('🔄 Récupération des tarifs depuis:', url);
        const response = await fetchWithRetry(url, 3);

        if (!response.ok) {
          throw new Error(`Erreur HTTP ${response.status}`);
        }

        const data = await response.json();
        const pricingData = Array.isArray(data) ? data : data.data || [];
        
        const limitedPrices = pricingData.slice(0, 50);
        
        if (limitedPrices.length > 0) {
          setPrices(limitedPrices);
          setDataSource('api');
          console.log('✅ Tarifs récupérés depuis API:', limitedPrices.length, 'éléments');
        } else {
          throw new Error('Aucune donnée retournée');
        }
      } catch (error) {
        console.error('❌ Erreur API:', error);
        setPrices(fallbackPrices);
        setDataSource('fallback');
      } finally {
        setIsLoading(false);
      }
    };

    fetchPrices();
  }, []);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('fr-BF', {
      style: 'currency',
      currency: 'XOF',
    }).format(price);
  };

  // Grouper par service_name (Service comme "Lavage Simple", "Nettoyage à Sec")
  const groupedByService = prices.reduce((acc, price) => {
    const serviceName = price.service_name || 'Autres Services';
    if (!acc[serviceName]) {
      acc[serviceName] = [];
    }
    acc[serviceName].push(price);
    return acc;
  }, {} as Record<string, ArticleServicePrice[]>);

  // Récupérer les articles uniques pour un service
  const getArticlesForService = (serviceItems: ArticleServicePrice[]) => {
    const seen = new Set<string>();
    return serviceItems.filter(item => {
      if (seen.has(item.article_id)) return false;
      seen.add(item.article_id);
      return true;
    });
  };

  return (
    <section className={styles.pricingSection}>
      <div className={styles.container}>
        {dataSource === 'fallback' && (
          <div style={{
            backgroundColor: '#FEF3C7',
            border: '1px solid #FCD34D',
            color: '#92400E',
            padding: '12px 16px',
            borderRadius: '8px',
            marginBottom: '24px',
            fontSize: '14px',
            textAlign: 'center'
          }}>
            ⚠️ Les tarifs affichés sont à titre indicatif. Veuillez vérifier les prix actuels auprès de notre support.
          </div>
        )}

        <div className={styles.header}>
          <div className={styles.superTitle}>Transparence & Équité</div>
          <h1 className={styles.title}>Tarification Transparente</h1>
          <p className={styles.subtitle}>
            Qualité Premium à Prix Compétitifs. Pas de frais cachés, juste une qualité réelle.
          </p>
        </div>

        <div className={styles.introduction}>
          <h2 className={styles.introductionTitle}>Nos Prix, Notre Promesse</h2>
          <p className={styles.introductionText}>
            Nous croyons à la transparence totale. Pas de frais cachés, pas de surcharge, pas de 
            surprise. Nos prix reflètent la qualité réelle du service que vous recevrez. Et souvent, 
            nous sommes plus avantageux que la concurrence. Comment? Par l'efficacité opérationnelle, 
            les volumes de commandes, et notre passion pour la satisfaction client.
          </p>
        </div>

        <div className={styles.tableWrapper}>
          {isLoading ? (
            <div className={styles.loadingMessage}>Chargement des tarifs en cours...</div>
          ) : prices.length === 0 ? (
            <div className={styles.loadingMessage}>
              Pour consulter nos tarifs détaillés, veuillez contacter notre équipe ou utiliser notre application.
            </div>
          ) : (
            <div style={{ display: 'grid', gap: '32px' }}>
              {Object.entries(groupedByService).map(([serviceName, serviceItems]) => {
                const articles = getArticlesForService(serviceItems);
                return (
                  <div key={serviceName}>
                    <h3 style={{
                      fontSize: '20px',
                      fontWeight: '700',
                      marginBottom: '20px',
                      color: '#2563EB',
                      paddingBottom: '12px',
                      borderBottom: '3px solid #2563EB',
                      textTransform: 'uppercase',
                      letterSpacing: '0.5px'
                    }}>
                      {serviceName}
                    </h3>

                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))',
                      gap: '12px'
                    }}>
                      {articles.map((article) => (
                        <ArticleCard
                          key={article.article_id}
                          article={article}
                          onClickArticle={() => setDialogState({ isOpen: true, article })}
                        />
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Dialog des prix */}
        {dialogState.isOpen && dialogState.article && (
          <PricingDialog
            article={dialogState.article}
            allPrices={prices}
            onClose={() => setDialogState({ isOpen: false, article: null })}
            formatPrice={formatPrice}
          />
        )}

        <div className={styles.introduction}>
          <h2 className={styles.introductionTitle}>Clients Réguliers = Réductions Garanties</h2>
          <div className={styles.introductionText}>
            <div style={{ marginBottom: '1rem' }}>
              🎁 <strong>Programme Loyauté</strong> - Accumulez des points à chaque commande
            </div>
            <div style={{ marginBottom: '1rem' }}>
              📍 <strong>Meilleurs Tarifs</strong> - Réductions progressives à partir du 3e mois
            </div>
            <div style={{ marginBottom: '1rem' }}>
              🎯 <strong>Services Prioritaires</strong> - Délais express pour nos clients réguliers
            </div>
            <div>
              💳 <strong>Paiement Flexible</strong> - Options adaptées à vos besoins
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

// Article Card Component avec CSS Module
interface ArticleCardProps {
  article: ArticleServicePrice;
  onClickArticle: () => void;
}

const ArticleCard: React.FC<ArticleCardProps> = ({ article, onClickArticle }) => {
  const [isHovered, setIsHovered] = React.useState(false);

  return (
    <div
      className={styles.articleCard}
      onClick={onClickArticle}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      style={{
        transform: isHovered ? 'translateY(-4px)' : 'translateY(0)',
        boxShadow: isHovered ? '0 8px 24px rgba(37, 99, 235, 0.25)' : 'none'
      }}
    >
      <h4 className={styles.articleCardTitle}>
        {article.article_name}
      </h4>
      <span className={styles.articleCardCta}>
        Voir tarifs →
      </span>
    </div>
  );
};

// Dialog Tarification
interface PricingDialogProps {
  article: ArticleServicePrice;
  allPrices: ArticleServicePrice[];
  onClose: () => void;
  formatPrice: (price: number) => string;
}

const PricingDialog: React.FC<PricingDialogProps> = ({ article, allPrices, onClose, formatPrice }) => {
  // Récupérer tous les prix pour cet article
  const articlePrices = allPrices.filter(p => p.article_id === article.article_id);

  return (
    <div className={styles.dialogOverlay} onClick={onClose}>
      <div className={styles.dialogContent} onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div className={styles.dialogHeader}>
          <div>
            <h2 className={styles.dialogTitle}>
              {article.article_name}
            </h2>
            <p className={styles.dialogSubtitle}>
              Tarification disponible pour cet article
            </p>
          </div>
          <button
            onClick={onClose}
            className={styles.dialogCloseButton}
          >
            ✕
          </button>
        </div>

        {/* Info box */}
        <div className={styles.dialogInfoBox}>
          Les prix varient selon le service choisi. Des réductions peuvent s'appliquer.
        </div>

        {/* Prix par service */}
        <div className={styles.dialogPricesList}>
          {articlePrices.map((price) => (
            <div key={price.id} className={styles.dialogPriceItem}>
              <div className={styles.dialogPriceItemHeader}>
                <h4 className={styles.dialogPriceItemTitle}>
                  {price.service_name}
                </h4>
                <p className={styles.dialogPriceItemSubtitle}>
                  {price.service_type_name}
                </p>
              </div>

              {/* Prices Grid */}
              <div className={styles.dialogPriceGrid}>
                <div className={styles.dialogPriceBox}>
                  <div className={styles.dialogPriceLabel}>
                    ✓ BASIC
                  </div>
                  <div className={styles.dialogPriceValue}>
                    {formatPrice(price.base_price || 0)}
                  </div>
                </div>

                <div className={`${styles.dialogPriceBox} ${price.premium_price ? styles.premium : styles.disabled}`}>
                  <div className={styles.dialogPriceLabel}>
                    ⭐ PREMIUM
                  </div>
                  <div className={styles.dialogPriceValue}>
                    {price.premium_price ? formatPrice(price.premium_price) : 'N/A'}
                  </div>
                </div>
              </div>

              {/* Prix/kg */}
              {price.price_per_kg && (
                <div className={styles.dialogPricePerKg}>
                  ⚖️ Au kg: {formatPrice(price.price_per_kg)}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
