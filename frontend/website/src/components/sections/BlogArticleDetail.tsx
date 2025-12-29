/**
 * 📝 Blog Article Detail - Affichage détaillé d'un article
 */

'use client';

import React, { useEffect } from 'react';
import styles from './BlogArticleDetail.module.css';
import { BlogArticle, formatDate, getAuthorName } from '@/types/blog';

interface BlogArticleDetailProps {
  article: BlogArticle;
}

export const BlogArticleDetail: React.FC<BlogArticleDetailProps> = ({ article }) => {
  const formattedDate = formatDate(article.published_at);
  const updatedDate = formatDate(article.updated_at);
  const authorName = getAuthorName(article.author);

  // Ajouter les schemas.org structured data (BlogPosting + BreadcrumbList)
  useEffect(() => {
    // Schema 1: BlogPosting
    const blogPostingSchema = {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',
      headline: article.title,
      description: article.seo_description || article.excerpt,
      image: article.featured_image || 'https://alphalaundry.com/images/blog-default.jpg',
      datePublished: article.published_at,
      dateModified: article.updated_at || article.published_at,
      author: {
        '@type': 'Person',
        name: article.author?.first_name && article.author?.last_name 
          ? `${article.author.first_name} ${article.author.last_name}`
          : 'Alpha Laundry',
        email: article.author?.email
      },
      publisher: {
        '@type': 'Organization',
        name: 'Alpha Laundry',
        logo: {
          '@type': 'ImageObject',
          url: 'https://alphalaundry.com/logo.png',
          width: 200,
          height: 60
        }
      },
      mainEntityOfPage: {
        '@type': 'WebPage',
        '@id': `https://alphalaundry.com/blog/${article.slug}`
      },
      keywords: article.seo_keywords?.join(', '),
      articleBody: article.content,
      wordCount: article.content?.split(/\s+/).length || 0,
      timeRequired: `PT${article.reading_time || 5}M`
    };

    // Schema 2: BreadcrumbList
    const breadcrumbSchema = {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        {
          '@type': 'ListItem',
          position: 1,
          name: 'Accueil',
          item: 'https://alphalaundry.com'
        },
        {
          '@type': 'ListItem',
          position: 2,
          name: 'Blog',
          item: 'https://alphalaundry.com/blog'
        },
        {
          '@type': 'ListItem',
          position: 3,
          name: article.category?.name || 'Articles',
          item: `https://alphalaundry.com/blog?category=${article.category?.id}`
        },
        {
          '@type': 'ListItem',
          position: 4,
          name: article.title,
          item: `https://alphalaundry.com/blog/${article.slug}`
        }
      ]
    };

    // Ajouter BlogPosting schema
    const blogPostingScript = document.createElement('script');
    blogPostingScript.type = 'application/ld+json';
    blogPostingScript.innerHTML = JSON.stringify(blogPostingSchema);
    document.head.appendChild(blogPostingScript);

    // Ajouter BreadcrumbList schema
    const breadcrumbScript = document.createElement('script');
    breadcrumbScript.type = 'application/ld+json';
    breadcrumbScript.innerHTML = JSON.stringify(breadcrumbSchema);
    document.head.appendChild(breadcrumbScript);

    return () => {
      document.head.removeChild(blogPostingScript);
      document.head.removeChild(breadcrumbScript);
    };
  }, [article]);

  return (
    <article className={styles.articleDetail}>
      <div className={styles.container}>
        {/* Header */}
        <header className={styles.header}>
          <div className={styles.breadcrumb}>
            <a href="/blog">Blog</a>
            <span>/</span>
            <a href={`/blog?category=${article.category?.id}`}>{article.category?.name}</a>
            <span>/</span>
            <span>{article.title}</span>
          </div>

          <h1 className={styles.title}>{article.title}</h1>

          <div className={styles.meta}>
            <div className={styles.metaItem}>
              <span className={styles.label}>Publié le</span>
              <time dateTime={article.published_at}>{formattedDate}</time>
            </div>

            {article.updated_at !== article.published_at && (
              <div className={styles.metaItem}>
                <span className={styles.label}>Mis à jour le</span>
                <time dateTime={article.updated_at}>{updatedDate}</time>
              </div>
            )}

            <div className={styles.metaItem}>
              <span className={styles.label}>Auteur</span>
              <span>{authorName}</span>
            </div>

            <div className={styles.metaItem}>
              <span className={styles.label}>Temps de lecture</span>
              <span>⏱️ {article.reading_time} min</span>
            </div>

            {article.views_count !== undefined && (
              <div className={styles.metaItem}>
                <span className={styles.label}>Vues</span>
                <span>👁️ {article.views_count.toLocaleString('fr-FR')}</span>
              </div>
            )}
          </div>

          {article.category && (
            <div className={styles.category}>
              {article.category.name}
            </div>
          )}
        </header>

        {/* Featured Image */}
        {article.featured_image && (
          <div className={styles.featuredImage}>
            <img
              src={article.featured_image}
              alt={`${article.title} - ${article.category?.name || 'Blog Alpha Laundry'}`}
              title={article.title}
              loading="lazy"
              width={1200}
              height={630}
            />
          </div>
        )}

        {/* Content */}
        <div className={styles.content}>
          <div
            className={styles.body}
            dangerouslySetInnerHTML={{ __html: article.content }}
          />
        </div>

        {/* Keywords */}
        {article.seo_keywords && article.seo_keywords.length > 0 && (
          <div className={styles.keywords}>
            <h3>Mots-clés</h3>
            <div className={styles.keywordsList}>
              {article.seo_keywords.map((keyword, index) => (
                <a
                  key={index}
                  href={`/blog?search=${encodeURIComponent(keyword)}`}
                  className={styles.keyword}
                >
                  #{keyword}
                </a>
              ))}
            </div>
          </div>
        )}

        {/* Share Section */}
        <div className={styles.share}>
          <h3>Partager cet article</h3>
          <div className={styles.shareButtons}>
            <ShareButton
              platform="facebook"
              url={`https://alphalaundry.com/blog/${article.slug}`}
              title={article.title}
            />
            <ShareButton
              platform="twitter"
              url={`https://alphalaundry.com/blog/${article.slug}`}
              title={article.title}
            />
            <ShareButton
              platform="linkedin"
              url={`https://alphalaundry.com/blog/${article.slug}`}
              title={article.title}
            />
            <ShareButton
              platform="whatsapp"
              url={`https://alphalaundry.com/blog/${article.slug}`}
              title={article.title}
            />
          </div>
        </div>

        {/* Author Info */}
        {article.author && (
          <div className={styles.authorInfo}>
            <div className={styles.authorDetails}>
              <h4>À propos de l'auteur</h4>
              <p className={styles.authorName}>{authorName}</p>
              {article.author.email && (
                <a href={`mailto:${article.author.email}`} className={styles.authorEmail}>
                  Contacter l'auteur
                </a>
              )}
            </div>
          </div>
        )}
      </div>
    </article>
  );
};

// Share Button Component
interface ShareButtonProps {
  platform: 'facebook' | 'twitter' | 'linkedin' | 'whatsapp';
  url: string;
  title: string;
}

const ShareButton: React.FC<ShareButtonProps> = ({ platform, url, title }) => {
  const shareUrls = {
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
    twitter: `https://twitter.com/intent/tweet?url=${encodeURIComponent(url)}&text=${encodeURIComponent(title)}`,
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`,
    whatsapp: `https://wa.me/?text=${encodeURIComponent(title + ' ' + url)}`
  };

  const icons = {
    facebook: '👍',
    twitter: '𝕏',
    linkedin: '💼',
    whatsapp: '💬'
  };

  return (
    <a
      href={shareUrls[platform]}
      target="_blank"
      rel="noopener noreferrer"
      className={`shareButton ${platform}`}
      title={`Partager sur ${platform}`}
    >
      {icons[platform]}
    </a>
  );
};
