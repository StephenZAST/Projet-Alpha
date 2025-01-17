import { useState } from 'react';
import { useAsync } from '../../hooks/useAsync';
import { api } from '../../utils/api';
import { SearchBar } from '../../components/common/SearchBar';
import { LoadingSpinner } from '../../components/common/Loading';
import { ExportButton } from '../../components/common/ExportButton';
import { DataTable } from '../../components/common/DataTable';
import { Button } from '../../components/common/Button';
import { colors } from '../../theme/colors';
import { Edit2, Trash2 } from 'react-feather';

interface Service {
  id: string;
  name: string;
  description: string;
  price: number;
  status: 'active' | 'inactive';
}

export const ServicesList = () => {
  const { data: services, loading, error, refetch } = useAsync<Service[]>(() => api.get('/admin/services'));
  const [searchTerm, setSearchTerm] = useState('');

  const handleDelete = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this service?')) {
      try {
        await api.delete(`/admin/services/${id}`);
        refetch();
      } catch (error) {
        console.error('Failed to delete service:', error);
      }
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
      render: (value: string) => (
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
      render: (_: any, item: Service) => (
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
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
        <Button variant="primary">Add New Service</Button>
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
    </div>
  );
};
