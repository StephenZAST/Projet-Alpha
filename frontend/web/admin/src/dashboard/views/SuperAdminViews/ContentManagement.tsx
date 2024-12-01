import React, { useState } from 'react';
import styles from './ContentManagement.module.css';

interface Content {
  id: string;
  title: string;
  type: 'article' | 'post' | 'product' | 'announcement';
  author: string;
  status: 'published' | 'draft' | 'pending' | 'rejected';
  category: string;
  createdAt: string;
  lastModified: string;
  featured: boolean;
}

interface Category {
  id: string;
  name: string;
  count: number;
}

export const ContentManagement: React.FC = () => {
  const [activeTab, setActiveTab] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState('all');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [showContentModal, setShowContentModal] = useState(false);
  const [selectedContent, setSelectedContent] = useState<Content | null>(null);

  // Mock data
  const contents: Content[] = [
    {
      id: '1',
      title: 'New Product Launch: Premium Features',
      type: 'announcement',
      author: 'John Smith',
      status: 'published',
      category: 'Products',
      createdAt: '2024-01-15T10:30:00',
      lastModified: '2024-01-15T14:30:00',
      featured: true
    },
    {
      id: '2',
      title: 'How to Optimize Your Workflow',
      type: 'article',
      author: 'Emma Wilson',
      status: 'pending',
      category: 'Tutorials',
      createdAt: '2024-01-15T09:15:00',
      lastModified: '2024-01-15T13:45:00',
      featured: false
    },
    {
      id: '3',
      title: 'Summer Collection 2024',
      type: 'product',
      author: 'Sarah Davis',
      status: 'draft',
      category: 'Products',
      createdAt: '2024-01-14T16:20:00',
      lastModified: '2024-01-15T11:20:00',
      featured: true
    },
    {
      id: '4',
      title: 'Community Update: New Features',
      type: 'post',
      author: 'Michael Brown',
      status: 'rejected',
      category: 'Updates',
      createdAt: '2024-01-14T14:45:00',
      lastModified: '2024-01-15T10:15:00',
      featured: false
    }
  ];

  const categories: Category[] = [
    { id: '1', name: 'Products', count: 25 },
    { id: '2', name: 'Tutorials', count: 15 },
    { id: '3', name: 'Updates', count: 10 },
    { id: '4', name: 'News', count: 8 },
    { id: '5', name: 'Events', count: 5 }
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'published':
        return styles.statusPublished;
      case 'draft':
        return styles.statusDraft;
      case 'pending':
        return styles.statusPending;
      case 'rejected':
        return styles.statusRejected;
      default:
        return '';
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'article':
        return 'article';
      case 'post':
        return 'post_add';
      case 'product':
        return 'inventory';
      case 'announcement':
        return 'campaign';
      default:
        return 'description';
    }
  };

  const handleContentAction = (action: string, content: Content) => {
    setSelectedContent(content);
    switch (action) {
      case 'edit':
        setShowContentModal(true);
        break;
      case 'delete':
        // Implement delete confirmation
        break;
      default:
        break;
    }
  };

  const filteredContent = contents.filter(content => {
    const matchesSearch = 
      content.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      content.author.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = selectedType === 'all' || content.type === selectedType;
    const matchesStatus = selectedStatus === 'all' || content.status === selectedStatus;
    const matchesCategory = selectedCategory === 'all' || content.category === selectedCategory;
    const matchesTab = activeTab === 'all' || 
      (activeTab === 'featured' && content.featured) ||
      (activeTab === 'recent' && new Date(content.lastModified) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000));
    
    return matchesSearch && matchesType && matchesStatus && matchesCategory && matchesTab;
  });

  return (
    <div className={styles.contentManagement}>
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h1 className={styles.title}>Content Management</h1>
          <p className={styles.subtitle}>Manage and moderate all content across the platform</p>
        </div>
        <button 
          className={styles.addContentButton}
          onClick={() => {
            setSelectedContent(null);
            setShowContentModal(true);
          }}
        >
          <span className="material-icons">add</span>
          Create Content
        </button>
      </div>

      <div className={styles.contentTabs}>
        <button 
          className={`${styles.tabButton} ${activeTab === 'all' ? styles.active : ''}`}
          onClick={() => setActiveTab('all')}
        >
          All Content
        </button>
        <button 
          className={`${styles.tabButton} ${activeTab === 'featured' ? styles.active : ''}`}
          onClick={() => setActiveTab('featured')}
        >
          Featured
        </button>
        <button 
          className={`${styles.tabButton} ${activeTab === 'recent' ? styles.active : ''}`}
          onClick={() => setActiveTab('recent')}
        >
          Recent
        </button>
      </div>

      <div className={styles.mainContent}>
        <div className={styles.contentFilters}>
          <div className={styles.searchBar}>
            <span className="material-icons">search</span>
            <input
              type="text"
              placeholder="Search content..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
          <div className={styles.filterControls}>
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              className={styles.filterSelect}
            >
              <option value="all">All Types</option>
              <option value="article">Articles</option>
              <option value="post">Posts</option>
              <option value="product">Products</option>
              <option value="announcement">Announcements</option>
            </select>
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className={styles.filterSelect}
            >
              <option value="all">All Status</option>
              <option value="published">Published</option>
              <option value="draft">Draft</option>
              <option value="pending">Pending</option>
              <option value="rejected">Rejected</option>
            </select>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className={styles.filterSelect}
            >
              <option value="all">All Categories</option>
              {categories.map(category => (
                <option key={category.id} value={category.name}>
                  {category.name} ({category.count})
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className={styles.contentGrid}>
          {filteredContent.map(content => (
            <div key={content.id} className={styles.contentCard}>
              <div className={styles.cardHeader}>
                <span className={`material-icons ${styles.typeIcon}`}>
                  {getTypeIcon(content.type)}
                </span>
                <div className={styles.cardActions}>
                  {content.featured && (
                    <span className={`material-icons ${styles.featuredIcon}`}>star</span>
                  )}
                  <button
                    className={styles.actionButton}
                    onClick={() => handleContentAction('edit', content)}
                  >
                    <span className="material-icons">edit</span>
                  </button>
                  <button
                    className={styles.actionButton}
                    onClick={() => handleContentAction('delete', content)}
                  >
                    <span className="material-icons">delete</span>
                  </button>
                </div>
              </div>
              <h3 className={styles.contentTitle}>{content.title}</h3>
              <div className={styles.contentMeta}>
                <span className={styles.author}>By {content.author}</span>
                <span className={`${styles.status} ${getStatusColor(content.status)}`}>
                  {content.status}
                </span>
              </div>
              <div className={styles.contentDetails}>
                <span className={styles.category}>{content.category}</span>
                <span className={styles.date}>
                  {new Date(content.lastModified).toLocaleDateString()}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {showContentModal && (
        <div className={styles.modal}>
          <div className={styles.modalContent}>
            <div className={styles.modalHeader}>
              <h2>{selectedContent ? 'Edit Content' : 'Create New Content'}</h2>
              <button 
                className={styles.closeButton}
                onClick={() => setShowContentModal(false)}
              >
                <span className="material-icons">close</span>
              </button>
            </div>
            <div className={styles.modalBody}>
              <div className={styles.formGroup}>
                <label>Title</label>
                <input 
                  type="text" 
                  placeholder="Enter content title"
                  defaultValue={selectedContent?.title}
                />
              </div>
              <div className={styles.formGroup}>
                <label>Type</label>
                <select defaultValue={selectedContent?.type}>
                  <option value="article">Article</option>
                  <option value="post">Post</option>
                  <option value="product">Product</option>
                  <option value="announcement">Announcement</option>
                </select>
              </div>
              <div className={styles.formGroup}>
                <label>Category</label>
                <select defaultValue={selectedContent?.category}>
                  {categories.map(category => (
                    <option key={category.id} value={category.name}>
                      {category.name}
                    </option>
                  ))}
                </select>
              </div>
              <div className={styles.formGroup}>
                <label>Status</label>
                <select defaultValue={selectedContent?.status}>
                  <option value="published">Published</option>
                  <option value="draft">Draft</option>
                  <option value="pending">Pending Review</option>
                </select>
              </div>
              <div className={styles.formGroup}>
                <label className={styles.checkboxLabel}>
                  <input 
                    type="checkbox"
                    defaultChecked={selectedContent?.featured}
                  />
                  Featured Content
                </label>
              </div>
            </div>
            <div className={styles.modalFooter}>
              <button 
                className={styles.cancelButton}
                onClick={() => setShowContentModal(false)}
              >
                Cancel
              </button>
              <button className={styles.saveButton}>
                {selectedContent ? 'Save Changes' : 'Create Content'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
