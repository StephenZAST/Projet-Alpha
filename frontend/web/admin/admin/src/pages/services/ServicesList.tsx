import { useState } from 'react';
import { useAsync } from '../../hooks/useAsync';
import { api } from '../../utils/api';
import { SearchBar } from '../../components/common/SearchBar';
import { LoadingSpinner } from '../../components/common/Loading';
import { ExportButton } from '../../components/common/ExportButton';
import { DataTable } from '../../components/common/DataTable';
import { Button } from '../../components/common/Button';
import { Modal } from '../../components/common/Modal';
import { Edit2, Trash2 } from 'react-feather';
import { colors } from '../../theme/colors';
import { usePermissions } from '../../hooks/usePermissions';

interface Service {
  id: string;
  name: string;
  description: string;
  price: number;
  status: 'active' | 'inactive';
  createdAt: string;
  updatedAt: string;
}

interface ServiceFormData {
  name: string;
  description: string;
  price: number;
  status: Service['status'];
}

export const ServicesList = () => {
  const { data: services, loading, error, refetch } = useAsync<Service[]>(() => 
    api.get('/admin/services')
  );
  const { hasPermission } = usePermissions();
  const [searchTerm, setSearchTerm] = useState('');
  const [editingService, setEditingService] = useState<Service | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState<ServiceFormData>({
    name: '',
    description: '',
    price: 0,
    status: 'active'
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingService) {
        await api.put(`/admin/services/${editingService.id}`, formData);
      } else {
        await api.post('/admin/services', formData);
      }
      setIsModalOpen(false);
      setEditingService(null);
      setFormData({ name: '', description: '', price: 0, status: 'active' });
      refetch();
    } catch (err: Error) {
      console.error('Failed to save service:', err);
      // Add error notification here
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this service?')) {
      return;
    }
    try {
      await api.delete(`/admin/services/${id}`);
      refetch();
    } catch (err: unknown) {
      console.error('Failed to delete service:', err);
      // Add error notification here
    }
  };

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'description', label: 'Description' },
    { 
      key: 'price', 
      label: 'Price',
      render: (value: number) => `$${value.toFixed(2)}`,
      sortable: true
    },
    { 
      key: 'status', 
      label: 'Status',
      render: (value: Service['status']) => (
        <span style={{
          padding: '4px 8px',
          borderRadius: '4px',
          backgroundColor: value === 'active' ? colors.successLight : colors.errorLight,
          color: value === 'active' ? colors.success : colors.error
        }}>
          {value.toUpperCase()}
        </span>
      )
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: unknown, service: Service) => (
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
          {hasPermission('services', 'update') && (
            <Button
              variant="secondary"
              onClick={() => {
                setEditingService(service);
                setFormData({
                  name: service.name,
                  description: service.description,
                  price: service.price,
                  status: service.status
                });
                setIsModalOpen(true);
              }}
            >
              <Edit2 size={16} />
            </Button>
          )}
          {hasPermission('services', 'delete') && (
            <Button
              variant="secondary"
              onClick={() => handleDelete(service.id)}
            >
              <Trash2 size={16} />
            </Button>
          )}
        </div>
      )
    }
  ];

  if (loading) return <LoadingSpinner />;
  if (error) return (
    <div style={{ 
      padding: '24px', 
      color: colors.error,
      backgroundColor: colors.errorLight,
      borderRadius: '8px',
      textAlign: 'center'
    }}>
      {error}
    </div>
  );

  const filteredServices = services?.filter(service => 
    service.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    service.description.toLowerCase().includes(searchTerm.toLowerCase())
  ) || [];

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center',
        marginBottom: '24px' 
      }}>
        <h1>Services Management</h1>
        {hasPermission('services', 'create') && (
          <Button 
            variant="primary"
            onClick={() => {
              setEditingService(null);
              setFormData({ name: '', description: '', price: 0, status: 'active' });
              setIsModalOpen(true);
            }}
          >
            Add New Service
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
          placeholder="Search services..." 
        />
        <ExportButton 
          data={filteredServices} 
          filename="services-list" 
          type="csv"
          columns={['name', 'description', 'price', 'status']}
        />
      </div>

      <DataTable
        data={filteredServices}
        columns={columns}
        loading={loading}
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setEditingService(null);
          setFormData({ name: '', description: '', price: 0, status: 'active' });
        }}
        title={editingService ? 'Edit Service' : 'Add New Service'}
      >
        <form onSubmit={handleSubmit}>
          {/* Add form inputs here */}
        </form>
      </Modal>
    </div>
  );
};
