import { useState } from 'react';
import { useAsync } from '../../hooks/useAsync';
import { api } from '../../utils/api';
import { SearchBar } from '../../components/common/SearchBar';
import { Button } from '../../components/common/Button';
import { DataTable } from '../../components/common/DataTable';
import { Modal } from '../../components/common/Modal';
import { Input } from '../../components/common/Input';
import { usePermissions } from '../../hooks/usePermissions';
import { colors } from '../../theme/colors';

interface Category {
  id: string;
  name: string;
  description?: string;
  createdAt: string;
}

export const CategoriesList = () => {
  const { hasPermission } = usePermissions();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({ name: '', description: '' });

  const { data: categories, loading, error, refetch } = useAsync<Category[]>(() => 
    api.get('/admin/categories')
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (selectedCategory) {
        await api.put(`/admin/categories/${selectedCategory.id}`, formData);
      } else {
        await api.post('/admin/categories', formData);
      }
      setIsModalOpen(false);
      setSelectedCategory(null);
      setFormData({ name: '', description: '' });
      refetch();
    } catch (error) {
      console.error('Failed to save category:', error);
    }
  };

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'description', label: 'Description' },
    { 
      key: 'createdAt', 
      label: 'Created At',
      render: (value: string) => new Date(value).toLocaleDateString()
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, category: Category) => (
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
          {hasPermission('categories', 'update') && (
            <Button
              variant="secondary"
              onClick={() => {
                setSelectedCategory(category);
                setFormData({
                  name: category.name,
                  description: category.description || ''
                });
                setIsModalOpen(true);
              }}
            >
              Edit
            </Button>
          )}
        </div>
      )
    }
  ];

  const filteredCategories = categories?.filter(category =>
    category.name.toLowerCase().includes(searchTerm.toLowerCase())
  ) || [];

  return (
    <div style={{ padding: '24px' }}>
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: '24px'
      }}>
        <h1>Categories</h1>
        {hasPermission('categories', 'create') && (
          <Button
            onClick={() => {
              setSelectedCategory(null);
              setFormData({ name: '', description: '' });
              setIsModalOpen(true);
            }}
          >
            Add Category
          </Button>
        )}
      </div>

      <SearchBar
        onSearch={setSearchTerm}
        placeholder="Search categories..."
      />

      <DataTable
        data={filteredCategories}
        columns={columns}
        loading={loading}
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setSelectedCategory(null);
          setFormData({ name: '', description: '' });
        }}
        title={selectedCategory ? 'Edit Category' : 'Add Category'}
      >
        <form onSubmit={handleSubmit}>
          <Input
            label="Name"
            value={formData.name}
            onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
            required
          />

          <Input
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
          />

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '24px' }}>
            <Button
              type="button"
              variant="secondary"
              onClick={() => setIsModalOpen(false)}
            >
              Cancel
            </Button>
            <Button type="submit">
              {selectedCategory ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
