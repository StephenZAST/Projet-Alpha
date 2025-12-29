/**
 * 📝 Related Articles - Articles connexes
 */

'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import styles from './RelatedArticles.module.css';
import { BlogArticle, BlogCategory, formatDateShort } from '@/types/blog';

interface RelatedArticlesProps {
  currentArticleId: string;
  category: BlogCategory;
}

export const RelatedArticles: React.FC<RelatedArticlesProps> = ({ currentArticleId, category }) => {
  const [articles, setArticles] = useState<BlogArticle[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const BACKEND_URL = 'https://alpha-laundry-backend.onrender.com';

  useEffect(() => {
    const fetchRelatedArticles = async () => {
      try {
        setIsLoading(true);
        const response = await fetch(
          `${BACKEND_URL}/api/blog-articles?category=${category.id}&limit=3&exclude=${currentArticleId}`
        );

        if (response.ok) {
          const data = await response.json();
          setArticles((data.data || []).slice(0, 3));
        }
      } catch (error) {
        console.error('Error fetching related articles:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchRelatedArticles();
  }, [currentArticleId, category.id]);

  if (isLoading || articles.length === 0) {
    return null;
  }

  return (
    <section className={styles.relatedArticlesSection}>
      <div className={styles.container}>
        <h2 className={styles.title}>Articles connexes</h2>

        <div className={styles.articlesGrid}>
          {articles.map((article) => (
            <Link key={article.id} href={`/blog/${article.slug}`}>
              <article className={styles.articleCard}>
                {article.featured_image && (
                  <div className={styles.articleImage}>
                    <img
                      src={article.featured_image}
                      alt={`${article.title} - Article blog ${article.category?.name || 'Alpha Laundry'}`}
                      title={article.title}
                      loading="lazy"
                      width={300}
                      height={200}
                    />
                  </div>
                )}

                <div className={styles.articleContent}>
                  {article.category && (
                    <span className={styles.category}>{article.category.name}</span>
                  )}
                  <h3 className={styles.title}>{article.title}</h3>
                  <p className={styles.excerpt}>{article.excerpt}</p>

                  <div className={styles.articleFooter}>
                    {article.published_at && (
                      <span className={styles.date}>
                        {formatDateShort(article.published_at)}
                      </span>
                    )}
                    {article.reading_time && (
                      <span className={styles.readingTime}>⏱️ {article.reading_time} min</span>
                    )}
                  </div>
                </div>
              </article>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
};
