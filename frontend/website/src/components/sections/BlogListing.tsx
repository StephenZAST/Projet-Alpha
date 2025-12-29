/**
 * 📝 Blog Listing Section - Affichage des articles de blog
 * Design cohérent avec Alpha Laundry + thème clair/sombre
 */

'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import styles from './BlogListing.module.css';
import { BlogArticle, BlogCategory, getAuthorName } from '@/types/blog';

interface BlogListingProps {
  initialCategory?: string;
}

export const BlogListing: React.FC<BlogListingProps> = ({ initialCategory }) => {
  const [articles, setArticles] = useState<BlogArticle[]>([]);
  const [categories, setCategories] = useState<BlogCategory[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(initialCategory || null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalArticles, setTotalArticles] = useState(0);

  const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || 'https://alpha-laundry-backend.onrender.com';
  const ITEMS_PER_PAGE = 12;

  // Récupérer les catégories
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await fetch(`${BACKEND_URL}/api/blog-categories`);
        if (!response.ok) {
          throw new Error('Failed to fetch categories');
        }
        const data = await response.json();
        setCategories(data.data || []);
      } catch (error) {
        console.error('Error fetching categories:', error);
      }
    };

    fetchCategories();
  }, [BACKEND_URL]);

  // Récupérer les articles
  useEffect(() => {
    const fetchArticles = async () => {
      try {
        setIsLoading(true);
        setError(null);
        
        // Construire l'URL avec les paramètres
        const params = new URLSearchParams();
        params.append('page', currentPage.toString());
        params.append('limit', ITEMS_PER_PAGE.toString());
        
        if (selectedCategory) {
          params.append('category_id', selectedCategory);
        }

        const url = `${BACKEND_URL}/api/blog-articles?${params.toString()}`;
        
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error('Failed to fetch articles');
        }
        
        const data = await response.json();
        setArticles(data.data || []);
        setTotalArticles(data.total || 0);
        setTotalPages(Math.ceil((data.total || 0) / ITEMS_PER_PAGE));
      } catch (error) {
        console.error('Error fetching articles:', error);
        setError('Erreur lors du chargement des articles');
        setArticles([]);
      } finally {
        setIsLoading(false);
      }
    };

    fetchArticles();
  }, [selectedCategory, currentPage, BACKEND_URL]);

  const handleCategoryChange = (categoryId: string | null) => {
    setSelectedCategory(categoryId);
    setCurrentPage(1);
  };

  return (
    <section className={styles.blogListingSection}>
      <div className={styles.container}>
        {/* Header */}
        <div className={styles.header}>
          <div className={styles.superTitle}>Expertise & Conseils</div>
          <h1 className={styles.title}>Blog Alpha Laundry</h1>
          <p className={styles.subtitle}>
            Découvrez nos articles experts sur la blanchisserie, le nettoyage à sec et l'entretien des vêtements.
            Conseils pratiques et astuces professionnelles pour prendre soin de vos textiles.
          </p>
        </div>

        {/* Categories Filter */}
        <div className={styles.categoriesFilter}>
          <button
            className={`${styles.categoryButton} ${selectedCategory === null ? styles.active : ''}`}
            onClick={() => handleCategoryChange(null)}
          >
            Tous les articles ({totalArticles})
          </button>
          {categories.map((category) => (
            <button
              key={category.id}
              className={`${styles.categoryButton} ${selectedCategory === category.id ? styles.active : ''}`}
              onClick={() => handleCategoryChange(category.id)}
            >
              {category.name}
            </button>
          ))}
        </div>

        {/* Error Message */}
        {error && (
          <div className={styles.errorMessage}>
            {error}
          </div>
        )}

        {/* Articles Grid */}
        {isLoading ? (
          <div className={styles.loadingMessage}>Chargement des articles...</div>
        ) : articles.length === 0 ? (
          <div className={styles.emptyMessage}>
            Aucun article trouvé. Revenez bientôt pour de nouveaux contenus !
          </div>
        ) : (
          <>
            <div className={styles.articlesGrid}>
              {articles.map((article) => (
                <ArticleCard key={article.id} article={article} />
              ))}
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <div className={styles.pagination}>
                <button
                  disabled={currentPage === 1}
                  onClick={() => setCurrentPage(currentPage - 1)}
                  className={styles.paginationButton}
                >
                  ← Précédent
                </button>

                <div className={styles.pageNumbers}>
                  {Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
                    const startPage = Math.max(1, currentPage - 2);
                    return startPage + i;
                  }).map((page) => (
                    <button
                      key={page}
                      onClick={() => setCurrentPage(page)}
                      className={`${styles.pageNumber} ${currentPage === page ? styles.active : ''}`}
                    >
                      {page}
                    </button>
                  ))}
                </div>

                <button
                  disabled={currentPage === totalPages}
                  onClick={() => setCurrentPage(currentPage + 1)}
                  className={styles.paginationButton}
                >
                  Suivant →
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </section>
  );
};

// Article Card Component
interface ArticleCardProps {
  article: BlogArticle;
}

const ArticleCard: React.FC<ArticleCardProps> = ({ article }) => {
  const formattedDate = article.published_at 
    ? new Date(article.published_at).toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    : 'Date non disponible';

  const authorName = getAuthorName(article.author);

  return (
    <Link href={`/blog/${article.slug}`}>
      <article className={styles.articleCard}>
        {article.featured_image && (
          <div className={styles.articleImage}>
            <img
              src={article.featured_image}
              alt={article.title}
              loading="lazy"
            />
          </div>
        )}

        <div className={styles.articleContent}>
          <div className={styles.articleMeta}>
            {article.category && (
              <span className={styles.category}>{article.category.name}</span>
            )}
            {article.reading_time && (
              <span className={styles.readingTime}>⏱️ {article.reading_time} min</span>
            )}
          </div>

          <h3 className={styles.articleTitle}>{article.title}</h3>

          <p className={styles.articleExcerpt}>{article.excerpt}</p>

          <div className={styles.articleFooter}>
            <span className={styles.date}>{formattedDate}</span>
            <span className={styles.author}>Par {authorName}</span>
          </div>
        </div>

        <div className={styles.articleCta}>
          Lire l'article →
        </div>
      </article>
    </Link>
  );
};
