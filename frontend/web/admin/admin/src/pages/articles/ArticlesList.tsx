import { useState } from 'react';
import { useAsync } from '../../hooks/useAsync';
import api from '../../utils/api';
import { SearchBar } from '../../components/common/SearchBar';
import { LoadingSpinner } from '../../components/common/Loading';
import { ExportButton } from '../../components/common/ExportButton';
import { DataTable } from '../../components/common/DataTable';
import { Button } from '../../components/common/Button';
import { Modal } from '../../components/common/Modal';
import { colors } from '../../theme/colors';
import { Edit2, Trash2, Eye } from 'react-feather';
import { usePermissions } from '../../hooks/usePermissions';

interface Article {
  id: string;
  title: string;
  content: string;
  categoryId: string;
  category: {
    id: string;
    name: string;
  };
  createdAt: string;
  status: 'draft' | 'published';
}

interface ArticleFormData {
  title: string;
  content: string;
  categoryId: string;
  status: Article['status'];
}

export const ArticlesList = () => {
  const { data: articles, loading, error, refetch } = useAsync<Article[]>(() => 
    api.get('/admin/articles?include=category')
  );
  const { hasPermission } = usePermissions();
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null);
  const [formData, setFormData] = useState<ArticleFormData>({
    title: '',
    content: '',
    categoryId: '',
    status: 'draft'
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (selectedArticle) {
        await api.put(`/admin/articles/${selectedArticle.id}`, formData);
      } else {
        await api.post('/admin/articles', formData);
      }
      setIsModalOpen(false);
      setSelectedArticle(null);
      setFormData({ title: '', content: '', categoryId: '', status: 'draft' });
      refetch();
    } catch (err) {
      console.error('Failed to save article:', err);
      // Add error notification here
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this article?')) {
      return;
    }
    try {
      await api.delete(`/admin/articles/${id}`);
      refetch();
    } catch (err) {
      console.error('Failed to delete article:', err);
      // Add error notification here
    }
  };

  const columns = [
    { key: 'title', label: 'Title', sortable: true },
    { 
      key: 'category', 
      label: 'Category',
      render: (_: unknown, item: Article) => item.category?.name
    },
    { 
      key: 'createdAt', 
      label: 'Created At',
      render: (value: string) => new Date(value).toLocaleDateString(),
      sortable: true
    },
    { 
      key: 'status', 
      label: 'Status',
      render: (value: string) => (
        <span style={{
          padding: '4px 8px',
          borderRadius: '4px',
          backgroundColor: value === 'published' ? colors.successLight : colors.warningLight,
          color: value === 'published' ? colors.success : colors.warning
        }}>
          {value.toUpperCase()}
        </span>
      )
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: unknown, article: Article) => (
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
          {hasPermission('articles', 'read') && (
            <Button
              variant="secondary"
              onClick={() => {
                setSelectedArticle(article);
                setIsModalOpen(true);
              }}
            >
              <Eye size={16} />
            </Button>
          )}
          {hasPermission('articles', 'update') && (
            <Button
              variant="secondary"
              onClick={() => {
                setSelectedArticle(article);
                setFormData({
                  title: article.title,
                  content: article.content,
                  categoryId: article.categoryId,
                  status: article.status
                });
                setIsModalOpen(true);
              }}
            >
              <Edit2 size={16} />
            </Button>
          )}
          {hasPermission('articles', 'delete') && (
            <Button
              variant="secondary"
              onClick={() => handleDelete(article.id)}
            >
              <Trash2 size={16} />
            </Button>
          )}
        </div>
      )
    }
  ];

  if (loading) return <LoadingSpinner />;
  if (error) return <div style={{ color: colors.error }}>{error}</div>;

  const filteredArticles = articles?.filter(article => 
    article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    article.category?.name.toLowerCase().includes(searchTerm.toLowerCase())
  ) || [];

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '24px' 
      }}>
        <h1>Articles Management</h1>
        {hasPermission('articles', 'create') && (
          <Button 
            variant="primary"
            onClick={() => {
              setSelectedArticle(null);
              setFormData({ title: '', content: '', categoryId: '', status: 'draft' });
              setIsModalOpen(true);
            }}
          >
            Add New Article
          </Button>
        )}
      </div>

      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        marginBottom: '24px',
        gap: '16px'
      }}>
        <SearchBar 
          onSearch={setSearchTerm} 
          placeholder="Search articles..." 
        />
        <ExportButton 
          data={filteredArticles} 
          filename="articles-list" 
          type="csv"
          columns={['title', 'category.name', 'createdAt', 'status']}
        />
      </div>

      <DataTable
        data={filteredArticles}
        columns={columns}
        loading={loading}
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setSelectedArticle(null);
          setFormData({ title: '', content: '', categoryId: '', status: 'draft' });
        }}
        title={selectedArticle ? 'Edit Article' : 'Add New Article'}
        size="large"
      >
        <ArticleForm
          article={selectedArticle}
          onSubmit={handleSubmit}
          onCancel={() => setIsModalOpen(false)}
        />
      </Modal>
    </div>
  );
};
