import { useState } from 'react';
import { useAsync } from '../../hooks/useAsync';
import { api } from '../../utils/api';
import { SearchBar } from '../../components/common/SearchBar';
import { LoadingSpinner } from '../../components/common/Loading';
import { ExportButton } from '../../components/common/ExportButton';
import { DataTable } from '../../components/common/DataTable';
import { Button } from '../../components/common/Button';
import { colors } from '../../theme/colors';
import { Edit2, Trash2, Eye } from 'react-feather';

interface Article {
  id: string;
  title: string;
  content: string;
  categoryId: string;
  category: {
    name: string;
  };
  createdAt: string;
  status: 'draft' | 'published';
}

export const ArticlesList = () => {
  const { data: articles, loading, error, refetch } = useAsync<Article[]>(() => 
    api.get('/admin/articles?include=category')
  );
  const [searchTerm, setSearchTerm] = useState('');

  const handleDelete = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this article?')) {
      try {
        await api.delete(`/admin/articles/${id}`);
        refetch();
      } catch (error) {
        console.error('Failed to delete article:', error);
      }
    }
  };

  const columns = [
    { key: 'title', label: 'Title', sortable: true },
    { 
      key: 'category', 
      label: 'Category',
      render: (_: any, item: Article) => item.category?.name
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
      render: (_: any, item: Article) => (
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
          <Button
            variant="secondary"
            onClick={() => {}} // TODO: Implement view functionality
          >
            <Eye size={16} />
          </Button>
          <Button
            variant="secondary"
            onClick={() => {}} // TODO: Implement edit functionality
          >
            <Edit2 size={16} />
          </Button>
          <Button
            variant="secondary"
            onClick={() => handleDelete(item.id)}
          >
            <Trash2 size={16} />
          </Button>
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
        <Button variant="primary">Add New Article</Button>
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
          columns={['title', 'category', 'createdAt', 'status']}
        />
      </div>

      <DataTable
        data={filteredArticles}
        columns={columns}
        loading={loading}
      />
    </div>
  );
};
