import { useState } from 'react';
import { usePermissions } from '../../hooks/usePermissions';
import { Input } from '../common/Input';
import { Button } from '../common/Button';
import { colors } from '../../theme/colors';

interface ServiceFormProps {
  service?: {
    id: string;
    name: string;
    description: string;
    price: number;
    status: 'active' | 'inactive';
  };
  onSubmit: (data: any) => Promise<void>;
  onCancel: () => void;
}

export const ServiceForm: React.FC<ServiceFormProps> = ({
  service,
  onSubmit,
  onCancel
}) => {
  const { hasPermission } = usePermissions();
  const [formData, setFormData] = useState(service || {
    name: '',
    description: '',
    price: 0,
    status: 'active' as const
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canEdit = hasPermission('services', service ? 'update' : 'create');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!canEdit) return;

    try {
      setLoading(true);
      setError(null);
      await onSubmit(formData);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ maxWidth: '600px' }}>
      <Input
        label="Name"
        value={formData.name}
        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
        disabled={!canEdit || loading}
        required
      />

      <Input
        label="Price"
        type="number"
        value={formData.price}
        onChange={(e) => setFormData(prev => ({ ...prev, price: parseFloat(e.target.value) }))}
        disabled={!canEdit || loading}
        required
      />

      <div style={{ marginBottom: '24px' }}>
        <label style={{ display: 'block', marginBottom: '8px' }}>Description</label>
        <textarea
          value={formData.description}
          onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
          disabled={!canEdit || loading}
          style={{
            width: '100%',
            minHeight: '100px',
            padding: '8px',
            borderRadius: '4px',
            border: `1px solid ${colors.gray300}`
          }}
        />
      </div>

      <div style={{ marginBottom: '24px' }}>
        <label style={{ display: 'block', marginBottom: '8px' }}>Status</label>
        <select
          value={formData.status}
          onChange={(e) => setFormData(prev => ({ 
            ...prev, 
            status: e.target.value as 'active' | 'inactive' 
          }))}
          disabled={!canEdit || loading}
          style={{
            width: '100%',
            padding: '8px',
            borderRadius: '4px',
            border: `1px solid ${colors.gray300}`
          }}
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      {error && (
        <div style={{ 
          color: colors.error, 
          marginBottom: '16px',
          padding: '8px',
          backgroundColor: colors.errorLight,
          borderRadius: '4px'
        }}>
          {error}
        </div>
      )}

      <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end' }}>
        <Button
          type="button"
          variant="secondary"
          onClick={onCancel}
          disabled={loading}
        >
          Cancel
        </Button>
        {canEdit && (
          <Button
            type="submit"
            disabled={loading}
          >
            {loading ? 'Saving...' : service ? 'Update Service' : 'Create Service'}
          </Button>
        )}
      </div>
    </form>
  );
};
